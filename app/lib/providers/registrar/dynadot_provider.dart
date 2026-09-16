import 'package:dio/dio.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_exception.dart';
import '../../core/network/rate_limiter.dart';
import '../../core/network/retry_interceptor.dart';
import '../../core/result.dart';
import '../../models/connection.dart';
import '../../models/credential.dart';
import '../../models/dns_record.dart';
import '../../models/registered_domain.dart';
import '../../models/registrar_id.dart';
import '../hosting/hosting_provider.dart' show ValidatedAccount;
import 'registrar_provider.dart';
import 'registrar_status_normalizer.dart';

class DynadotProvider implements RegistrarProvider {
  DynadotProvider({String? baseUrl})
      : _baseUrl = baseUrl ?? 'https://api.dynadot.com';

  final String _baseUrl;

  @override
  RegistrarId get id => RegistrarId.dynadot;

  @override
  String get displayName => 'Dynadot';

  String _extractKey(Credential credential) {
    if (credential is BearerCredential) return credential.token.trim();
    if (credential is KeyPairCredential) return credential.apiKey.trim();
    return '';
  }

  Dio _client(Credential credential) => buildClient(
        baseUrl: _baseUrl,
        credential: credential,
        rateLimit: ProviderRateLimit.dynadot,
      );

  @override
  Future<Result<ValidatedAccount>> validate(Credential credential) async {
    final dio = _client(credential);
    final key = _extractKey(credential);
    try {
      final res = await dio.get<Map<String, dynamic>>(
        '/api3.json',
        queryParameters: {
          'command': 'list_domain',
          'count_per_page': 1,
          'page_index': 0,
          'key': key,
        },
      );
      final data = res.data;
      if (data == null) {
        return const Err(UnknownException('Empty response from Dynadot'));
      }

      final resp = data['ListDomainInfoResponse'] as Map<String, dynamic>? ?? data;
      final status = resp['Status']?.toString().toLowerCase();
      if (status != 'success') {
        final error = resp['Error']?.toString() ?? 'Invalid Dynadot API Key';
        return Err(UnauthorizedException(error));
      }

      return const Ok(
        ValidatedAccount(accountId: 'dynadot', displayName: 'Dynadot Account'),
      );
    } on DioException catch (e) {
      return Err(dioExceptionToApiException(e));
    } catch (e) {
      return Err(UnknownException.fromError(e));
    }
  }

  @override
  Future<Result<List<RegisteredDomain>>> listDomains(
    Connection c,
    Credential credential,
  ) async {
    final dio = _client(credential);
    final key = _extractKey(credential);
    final allDomains = <RegisteredDomain>[];
    int pageIndex = 0;
    const int countPerPage = 100;

    try {
      while (true) {
        final res = await dio.get<Map<String, dynamic>>(
          '/api3.json',
          queryParameters: {
            'command': 'list_domain',
            'count_per_page': countPerPage,
            'page_index': pageIndex,
            'key': key,
          },
        );
        final data = res.data;
        if (data == null) break;

        final resp = data['ListDomainInfoResponse'] as Map<String, dynamic>? ?? data;
        final status = resp['Status']?.toString().toLowerCase();
        if (status != 'success') {
          final error = resp['Error']?.toString() ?? 'Failed to list Dynadot domains';
          return Err(UnknownException(error));
        }

        final domainListRaw = resp['DomainList'] ?? resp['Domains'];
        final List domainsList;
        if (domainListRaw is List) {
          domainsList = domainListRaw;
        } else if (domainListRaw is Map) {
          domainsList = [domainListRaw];
        } else {
          domainsList = [];
        }

        for (final raw in domainsList) {
          final m = raw as Map<String, dynamic>;
          final rawDomain = (m['Name'] as String? ?? m['name'] as String? ?? m['Domain'] as String? ?? '').trim();
          if (rawDomain.isEmpty) continue;

          final rawStatus = (m['Status'] as String? ?? m['status'] as String? ?? '').trim();
          final autoRenewRaw = m['RenewOption'] ?? m['AutoRenew'];
          final autoRenew = autoRenewRaw == 'auto' || autoRenewRaw == true || autoRenewRaw == '1';
          final lockRaw = m['Locked'] ?? m['lock'];
          final isLocked = lockRaw == 'locked' || lockRaw == true || lockRaw == '1';
          final privacyRaw = m['Privacy'] ?? m['privacy'];
          final isPrivate = privacyRaw == 'full' || privacyRaw == true || privacyRaw == '1';

          allDomains.add(
            RegisteredDomain(
              domain: rawDomain,
              connectionId: c.id,
              registrar: RegistrarId.dynadot,
              status: normalizeDynadotStatus(rawStatus),
              rawStatus: rawStatus,
              expiresAt: parseFlexibleDate(m['Expiration'] ?? m['ExpireDate']),
              autoRenew: autoRenew,
              locked: isLocked,
              privacy: isPrivate,
              fetchedAt: DateTime.now().toUtc(),
            ),
          );
        }

        if (domainsList.length < countPerPage) {
          break;
        }
        pageIndex++;
      }

      return Ok(allDomains);
    } on DioException catch (e) {
      return Err(dioExceptionToApiException(e));
    } catch (e) {
      return Err(UnknownException.fromError(e));
    }
  }

  @override
  Future<Result<List<DnsRecord>>> listDnsRecords(
    Connection c,
    Credential credential,
    String domain,
  ) async {
    final dio = _client(credential);
    final key = _extractKey(credential);
    try {
      final res = await dio.get<Map<String, dynamic>>(
        '/api3.json',
        queryParameters: {
          'command': 'get_dns',
          'domain': domain,
          'key': key,
        },
      );
      final data = res.data;
      if (data == null) {
        return const Err(UnknownException('Empty response from Dynadot DNS'));
      }

      final resp = data['GetDnsResponse'] as Map<String, dynamic>? ?? data;
      final rawSubdomains = resp['SubDomains'] ?? resp['SubDomain'];
      final List recordsList;
      if (rawSubdomains is List) {
        recordsList = rawSubdomains;
      } else if (rawSubdomains is Map) {
        recordsList = [rawSubdomains];
      } else {
        recordsList = [];
      }

      final result = recordsList.map((raw) {
        final m = raw as Map<String, dynamic>;
        return DnsRecord(
          id: (m['Subhost'] ?? m['Name'] ?? m['Record'] ?? '').toString(),
          domain: domain,
          type: (m['RecordType'] ?? m['Type'] ?? '').toString(),
          name: (m['Subhost'] ?? m['Name'] ?? '').toString(),
          content: (m['Value'] ?? m['Content'] ?? '').toString(),
          ttl: parseDnsTtl(m['TTL']),
          proxied: false,
        );
      }).toList();

      return Ok(result);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return const Ok([]);
      }
      return Err(dioExceptionToApiException(e));
    } catch (e) {
      return Err(UnknownException.fromError(e));
    }
  }
}
