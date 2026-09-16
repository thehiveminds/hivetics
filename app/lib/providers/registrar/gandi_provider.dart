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

class GandiProvider implements RegistrarProvider {
  GandiProvider({String? baseUrl})
      : _baseUrl = baseUrl ?? 'https://api.gandi.net';

  final String _baseUrl;

  @override
  RegistrarId get id => RegistrarId.gandi;

  @override
  String get displayName => 'Gandi';

  Dio _client(Credential credential) => buildClient(
        baseUrl: _baseUrl,
        credential: credential,
        rateLimit: ProviderRateLimit.gandi,
      );

  @override
  Future<Result<ValidatedAccount>> validate(Credential credential) async {
    final dio = _client(credential);
    try {
      final res = await dio.get<dynamic>(
        '/v5/domain/domains',
        queryParameters: {'per_page': 1, 'page': 1},
      );
      if (res.data == null) {
        return const Err(UnknownException('Empty response from Gandi'));
      }

      return const Ok(
        ValidatedAccount(accountId: 'gandi', displayName: 'Gandi Account'),
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
    final allDomains = <RegisteredDomain>[];
    int page = 1;
    const int perPage = 100;

    try {
      while (true) {
        final res = await dio.get<dynamic>(
          '/v5/domain/domains',
          queryParameters: {'per_page': perPage, 'page': page},
        );
        final data = res.data;
        if (data == null || data is! List) break;

        for (final raw in data) {
          final m = raw as Map<String, dynamic>;
          final rawDomain = (m['fqdn'] as String? ?? m['name'] as String? ?? '').trim();
          if (rawDomain.isEmpty) continue;

          final rawStatus = m['status'];
          final statusList = rawStatus is List ? rawStatus : [rawStatus];
          final isLocked = statusList.any((s) => s.toString().toLowerCase().contains('transferprohibited'));

          final dates = m['dates'] as Map<String, dynamic>?;
          final expiresRaw = m['dates_registry_ends_at'] ?? dates?['registry_ends_at'];

          allDomains.add(
            RegisteredDomain(
              domain: rawDomain,
              connectionId: c.id,
              registrar: RegistrarId.gandi,
              status: normalizeGandiStatus(rawStatus),
              rawStatus: rawStatus is List ? rawStatus.join(', ') : rawStatus?.toString(),
              expiresAt: parseFlexibleDate(expiresRaw),
              autoRenew: m['autorenew'] is bool ? m['autorenew'] as bool : null,
              locked: isLocked,
              privacy: m['is_private'] is bool ? m['is_private'] as bool : null,
              fetchedAt: DateTime.now().toUtc(),
            ),
          );
        }

        if (data.length < perPage) {
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
    try {
      final res = await dio.get<dynamic>('/v5/domain/domains/$domain/records');
      final data = res.data;
      if (data == null) {
        return const Err(UnknownException('Empty response from Gandi DNS'));
      }

      final List rawRecords = data is List ? data : [];
      final result = <DnsRecord>[];

      for (int i = 0; i < rawRecords.length; i++) {
        final m = rawRecords[i] as Map<String, dynamic>;
        final type = (m['rrset_type'] ?? m['type'] ?? '').toString();
        final name = (m['rrset_name'] ?? m['name'] ?? '').toString();
        final ttl = parseDnsTtl(m['rrset_ttl'] ?? m['ttl']);
        final values = m['rrset_values'] as List? ?? [m['value'] ?? m['content'] ?? ''];

        for (final val in values) {
          result.add(
            DnsRecord(
              id: '$name-$type-${result.length}',
              domain: domain,
              type: type,
              name: name,
              content: val.toString(),
              ttl: ttl,
              proxied: false,
            ),
          );
        }
      }

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
