// MIT Licence — TheHiveMinds / Hivetics
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

class CloudflareRegistrarProvider implements RegistrarProvider {
  CloudflareRegistrarProvider({String? baseUrl})
      : _baseUrl = baseUrl ?? 'https://api.cloudflare.com/client/v4';

  final String _baseUrl;

  @override
  RegistrarId get id => RegistrarId.cloudflareregistrar;

  @override
  String get displayName => 'Cloudflare Registrar';

  Dio _client(Credential credential) => buildClient(
        baseUrl: _baseUrl,
        credential: credential,
        rateLimit: ProviderRateLimit.cloudflare,
      );

  @override
  Future<Result<ValidatedAccount>> validate(Credential credential) async {
    // Cloudflare Registrar rides the existing Cloudflare connection.
    final dio = _client(credential);
    try {
      final verifyRes = await dio.get<Map<String, dynamic>>('/user/tokens/verify');
      _checkCfSuccess(verifyRes.data);
      return const Ok(ValidatedAccount(
        accountId: 'cloudflare',
        displayName: 'Cloudflare',
      ));
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
    final accountId = c.accountId;
    if (accountId == null || accountId.isEmpty) {
      return const Err(ForbiddenException('Cloudflare account ID not set'));
    }

    final dio = _client(credential);
    try {
      final res = await dio.get<Map<String, dynamic>>(
        '/accounts/$accountId/registrar/registrations',
      );
      _checkCfSuccess(res.data);

      final rawList = (res.data?['result'] as List?) ?? [];
      final domains = rawList.map((raw) {
        final m = raw as Map<String, dynamic>;
        final rawDomain = (m['domain'] as String? ?? '').trim();
        final rawStatus = m['status'] as String?;

        return RegisteredDomain(
          domain: rawDomain,
          connectionId: c.id,
          registrar: RegistrarId.cloudflareregistrar,
          status: normalizeCloudflareRegistrarStatus(rawStatus),
          rawStatus: rawStatus,
          expiresAt: parseIso8601Timestamp(m['expires_at']),
          autoRenew: m['auto_renew'] as bool?,
          locked: m['locked'] as bool?,
          privacy: m['privacy'] as bool?,
          fetchedAt: DateTime.now().toUtc(),
        );
      }).toList();

      return Ok(domains);
    } on DioException catch (e) {
      // Scoped tokens lacking Registrar permission return 403.
      // This is expected for tokens scoped solely to Pages/DNS.
      if (e.response?.statusCode == 403) {
        return const Ok([]);
      }
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
    try {
      // Find zone ID for domain
      final zoneRes = await dio.get<Map<String, dynamic>>('/zones?name=$domain');
      _checkCfSuccess(zoneRes.data);
      final zones = (zoneRes.data?['result'] as List?) ?? [];
      if (zones.isEmpty) {
        return const Ok([]);
      }

      final zoneId = (zones.first as Map)['id'] as String;
      final dnsRes = await dio.get<Map<String, dynamic>>('/zones/$zoneId/dns_records');
      _checkCfSuccess(dnsRes.data);

      final rawRecords = (dnsRes.data?['result'] as List?) ?? [];
      final records = rawRecords.map((raw) {
        final m = raw as Map<String, dynamic>;
        return DnsRecord(
          id: m['id'] as String? ?? '',
          domain: domain,
          type: m['type'] as String? ?? '',
          name: m['name'] as String? ?? '',
          content: m['content'] as String? ?? '',
          ttl: parseDnsTtl(m['ttl']),
          priority: parseDnsPriority(m['priority']),
          proxied: m['proxied'] as bool? ?? false,
        );
      }).toList();

      return Ok(records);
    } on DioException catch (e) {
      return Err(dioExceptionToApiException(e));
    } catch (e) {
      return Err(UnknownException.fromError(e));
    }
  }

  void _checkCfSuccess(Map<String, dynamic>? data) {
    if (data == null) throw const UnknownException('Empty response from Cloudflare');
    final success = data['success'];
    if (success == true) return;
    final errors = (data['errors'] as List?)
        ?.map((e) => (e as Map)['message'] as String? ?? '')
        .where((m) => m.isNotEmpty)
        .join('; ');
    throw UnknownException(
      (errors == null || errors.isEmpty) ? 'Cloudflare API error' : errors,
    );
  }
}
