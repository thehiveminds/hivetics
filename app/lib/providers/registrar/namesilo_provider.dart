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

class NameSiloProvider implements RegistrarProvider {
  NameSiloProvider({String? baseUrl})
      : _baseUrl = baseUrl ?? 'https://www.namesilo.com';

  final String _baseUrl;

  @override
  RegistrarId get id => RegistrarId.namesilo;

  @override
  String get displayName => 'NameSilo';

  String _extractKey(Credential credential) {
    if (credential is BearerCredential) return credential.token.trim();
    if (credential is KeyPairCredential) return credential.apiKey.trim();
    return '';
  }

  Dio _client(Credential credential) => buildClient(
        baseUrl: _baseUrl,
        credential: credential,
        rateLimit: ProviderRateLimit.namesilo,
      );

  @override
  Future<Result<ValidatedAccount>> validate(Credential credential) async {
    final dio = _client(credential);
    final key = _extractKey(credential);
    try {
      final res = await dio.get<Map<String, dynamic>>(
        '/api/listDomains',
        queryParameters: {
          'pageSize': 1,
          'page': 1,
          'version': 1,
          'type': 'json',
          'key': key,
        },
      );
      final data = res.data;
      if (data == null) {
        return const Err(UnknownException('Empty response from NameSilo'));
      }

      final reply = data['reply'] as Map<String, dynamic>?;
      final code = reply?['code']?.toString();
      if (code != '300') {
        final detail = reply?['detail']?.toString() ?? 'Invalid NameSilo API Key';
        return Err(UnauthorizedException(detail));
      }

      return const Ok(
        ValidatedAccount(accountId: 'namesilo', displayName: 'NameSilo Account'),
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
    int page = 1;
    const int pageSize = 100;

    try {
      while (true) {
        final res = await dio.get<Map<String, dynamic>>(
          '/api/listDomains',
          queryParameters: {
            'pageSize': pageSize,
            'page': page,
            'version': 1,
            'type': 'json',
            'key': key,
          },
        );
        final data = res.data;
        if (data == null) break;

        final reply = data['reply'] as Map<String, dynamic>?;
        final code = reply?['code']?.toString();
        if (code != '300') {
          final detail = reply?['detail']?.toString() ?? 'Failed to list NameSilo domains';
          return Err(UnknownException(detail));
        }

        final domainsRaw = reply?['domains']?['domain'];
        final List domainsList;
        if (domainsRaw is List) {
          domainsList = domainsRaw;
        } else if (domainsRaw is Map) {
          domainsList = [domainsRaw];
        } else {
          domainsList = [];
        }

        for (final raw in domainsList) {
          final m = raw as Map<String, dynamic>;
          final rawDomain = (m['domain'] as String? ?? m['name'] as String? ?? '').trim();
          if (rawDomain.isEmpty) continue;

          final rawStatus = (m['status'] as String? ?? '').trim();
          final autoRenew = m['auto_renew'] == 'Yes' || m['auto_renew'] == true || m['autoRenew'] == true;
          final isLocked = m['locked'] == 'Yes' || m['locked'] == true;
          final isPrivate = m['private'] == 'Yes' || m['private'] == true || m['privacy'] == true;

          allDomains.add(
            RegisteredDomain(
              domain: rawDomain,
              connectionId: c.id,
              registrar: RegistrarId.namesilo,
              status: normalizeNameSiloStatus(rawStatus),
              rawStatus: rawStatus,
              expiresAt: parseFlexibleDate(m['expires'] ?? m['expiration']),
              autoRenew: autoRenew,
              locked: isLocked,
              privacy: isPrivate,
              fetchedAt: DateTime.now().toUtc(),
            ),
          );
        }

        final pager = reply?['pager'] as Map<String, dynamic>?;
        final total = int.tryParse(pager?['total']?.toString() ?? '0') ?? 0;

        if (domainsList.length < pageSize || (total > 0 && allDomains.length >= total)) {
          break;
        }
        page++;
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
        '/api/dnsListRecords',
        queryParameters: {
          'domain': domain,
          'version': 1,
          'type': 'json',
          'key': key,
        },
      );
      final data = res.data;
      if (data == null) {
        return const Err(UnknownException('Empty response from NameSilo DNS'));
      }

      final reply = data['reply'] as Map<String, dynamic>?;
      final code = reply?['code']?.toString();
      if (code != '300') {
        final detail = reply?['detail']?.toString() ?? 'Failed to retrieve DNS records';
        return Err(UnknownException(detail));
      }

      final rawRecords = reply?['resource_record'];
      final List recordsList;
      if (rawRecords is List) {
        recordsList = rawRecords;
      } else if (rawRecords is Map) {
        recordsList = [rawRecords];
      } else {
        recordsList = [];
      }

      final result = recordsList.map((raw) {
        final m = raw as Map<String, dynamic>;
        return DnsRecord(
          id: (m['record_id'] ?? '').toString(),
          domain: domain,
          type: (m['type'] ?? '').toString(),
          name: (m['host'] ?? '').toString(),
          content: (m['value'] ?? '').toString(),
          ttl: parseDnsTtl(m['ttl']),
          priority: parseDnsPriority(m['distance']),
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
