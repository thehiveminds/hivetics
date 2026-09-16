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
import '../hosting/status_normalizer.dart' show parseIso8601Timestamp;
import 'registrar_provider.dart';
import 'registrar_status_normalizer.dart';

class GoDaddyProvider implements RegistrarProvider {
  GoDaddyProvider({String? baseUrl})
    : _baseUrl = baseUrl ?? 'https://api.godaddy.com';

  final String _baseUrl;

  @override
  RegistrarId get id => RegistrarId.godaddy;

  @override
  String get displayName => 'GoDaddy';

  Dio _client(Credential credential) {
    final Map<String, String> headers = {};
    if (credential is KeyPairCredential) {
      headers['Authorization'] =
          'sso-key ${credential.apiKey.trim()}:${credential.secretKey.trim()}';
    } else if (credential is BearerCredential) {
      final t = credential.token.trim();
      if (!t.startsWith('sso-key ') && !t.startsWith('Bearer ')) {
        headers['Authorization'] = 'sso-key $t';
      }
    }
    return buildClient(
      baseUrl: _baseUrl,
      credential: credential,
      rateLimit: ProviderRateLimit.godaddy,
      extraHeaders: headers,
    );
  }

  @override
  Future<Result<ValidatedAccount>> validate(Credential credential) async {
    final dio = _client(credential);
    try {
      final res = await dio.get<dynamic>('/v1/domains?limit=1');
      if (res.statusCode == 200) {
        return const Ok(
          ValidatedAccount(
            accountId: 'godaddy',
            displayName: 'GoDaddy Account',
          ),
        );
      }
      return const Err(UnauthorizedException('Invalid GoDaddy credentials'));
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
    try {
      final allDomains = <RegisteredDomain>[];
      String? marker;
      const limit = 1000;

      while (true) {
        final query = StringBuffer('/v1/domains?includes=nameServers&limit=$limit');
        if (marker != null && marker.isNotEmpty) {
          query.write('&marker=${Uri.encodeQueryComponent(marker)}');
        }

        final res = await dio.get<dynamic>(query.toString());
        final rawList = (res.data is List ? res.data as List : []);
        if (rawList.isEmpty) break;

        String? lastDomain;
        for (final raw in rawList) {
          final m = raw as Map<String, dynamic>;
          final rawDomain = (m['domain'] as String? ?? '').trim();
          final rawStatus = m['status'] as String?;
          final nsList =
              (m['nameServers'] as List?)
                  ?.map((ns) => ns.toString().trim())
                  .where((ns) => ns.isNotEmpty)
                  .toList() ??
              const <String>[];

          allDomains.add(
            RegisteredDomain(
              domain: rawDomain,
              connectionId: c.id,
              registrar: RegistrarId.godaddy,
              status: normalizeGoDaddyStatus(rawStatus),
              rawStatus: rawStatus,
              expiresAt: parseIso8601Timestamp(m['expires']),
              autoRenew: m['renewAuto'] as bool?,
              locked: m['locked'] as bool?,
              privacy: (m['privacy'] ?? m['v1-privacy']) as bool?,
              nameServers: nsList,
              fetchedAt: DateTime.now().toUtc(),
            ),
          );
          if (rawDomain.isNotEmpty) {
            lastDomain = rawDomain;
          }
        }

        if (rawList.length < limit || lastDomain == null || lastDomain == marker) {
          break;
        }
        marker = lastDomain;
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

    // 1. Try v1 endpoint first
    try {
      final res = await dio.get<dynamic>('/v1/domains/$domain/records');
      final rawList = (res.data is List ? res.data as List : []);
      if (rawList.isNotEmpty) {
        return Ok(_parseRecords(rawList, domain));
      }
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      if (status != 404 && status != 422 && status != 400) {
        return Err(dioExceptionToApiException(e));
      }
      // If 404/422/400, proceed to try v3 fallback
    } catch (_) {}

    // 2. Try v3 endpoint fallback
    try {
      final res = await dio.get<dynamic>('/v3/domains/zones/$domain/dns-records');
      final dynamic data = res.data;
      final rawList = (data is List
          ? data
          : (data is Map && data['records'] is List
              ? data['records'] as List
              : []));
      return Ok(_parseRecords(rawList, domain));
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      // 404 or 422 means domain uses external nameservers or has no DNS records on GoDaddy
      if (status == 404 || status == 422) {
        return const Ok(<DnsRecord>[]);
      }
      return Err(dioExceptionToApiException(e));
    } catch (e) {
      return Err(UnknownException.fromError(e));
    }
  }

  List<DnsRecord> _parseRecords(List<dynamic> rawList, String domain) {
    return rawList.map((raw) {
      final m = raw as Map<String, dynamic>;
      final type = m['type'] as String? ?? '';
      final name = m['name'] as String? ?? '';
      final content = (m['data'] ?? m['content'] ?? '') as String;
      final id = '${type}_${name}_$content';

      return DnsRecord(
        id: id,
        domain: domain,
        type: type,
        name: name,
        content: content,
        ttl: parseDnsTtl(m['ttl']),
        priority: parseDnsPriority(m['priority'] ?? m['prio']),
        proxied: false,
      );
    }).toList();
  }
}
