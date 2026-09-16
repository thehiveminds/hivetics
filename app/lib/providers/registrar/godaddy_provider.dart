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

  Dio _client(Credential credential) => buildClient(
    baseUrl: _baseUrl,
    credential: credential,
    rateLimit: ProviderRateLimit.godaddy,
  );

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
      final res = await dio.get<dynamic>(
        '/v1/domains?includes=nameServers&limit=1000',
      );
      final rawList = (res.data is List ? res.data as List : []);

      final domains = rawList.map((raw) {
        final m = raw as Map<String, dynamic>;
        final rawDomain = (m['domain'] as String? ?? '').trim();
        final rawStatus = m['status'] as String?;
        final nsList =
            (m['nameServers'] as List?)
                ?.map((ns) => ns.toString().trim())
                .where((ns) => ns.isNotEmpty)
                .toList() ??
            const <String>[];

        return RegisteredDomain(
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
        );
      }).toList();

      return Ok(domains);
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
    try {
      final res = await dio.get<dynamic>('/v1/domains/$domain/records');
      final rawList = (res.data is List ? res.data as List : []);

      final records = rawList.map((raw) {
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

      return Ok(records);
    } on DioException catch (e) {
      return Err(dioExceptionToApiException(e));
    } catch (e) {
      return Err(UnknownException.fromError(e));
    }
  }
}
