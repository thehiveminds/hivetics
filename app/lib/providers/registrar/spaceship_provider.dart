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

class SpaceshipProvider implements RegistrarProvider {
  SpaceshipProvider({String? baseUrl})
      : _baseUrl = baseUrl ?? 'https://spaceship.dev/api';

  final String _baseUrl;

  @override
  RegistrarId get id => RegistrarId.spaceship;

  @override
  String get displayName => 'Spaceship';

  Dio _client(Credential credential) {
    final Map<String, String> headers = {};
    if (credential is KeyPairCredential) {
      headers['X-API-Key'] = credential.apiKey;
      headers['X-API-Secret'] = credential.secretKey;
    }
    return buildClient(
      baseUrl: _baseUrl,
      credential: credential,
      rateLimit: ProviderRateLimit.spaceship,
      extraHeaders: headers,
    );
  }

  @override
  Future<Result<ValidatedAccount>> validate(Credential credential) async {
    final dio = _client(credential);
    try {
      final res = await dio.get<Map<String, dynamic>>(
        '/v1/domains',
        queryParameters: {'take': 1, 'skip': 0},
      );
      final data = res.data;
      if (data == null) {
        return const Err(UnknownException('Empty response from Spaceship'));
      }

      return const Ok(
        ValidatedAccount(accountId: 'spaceship', displayName: 'Spaceship Account'),
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
    int skip = 0;
    const int take = 100;

    try {
      while (true) {
        final res = await dio.get<Map<String, dynamic>>(
          '/v1/domains',
          queryParameters: {'take': take, 'skip': skip},
        );
        final data = res.data;
        if (data == null) break;

        final items = (data['items'] as List?) ?? (data['domains'] as List?) ?? [];
        final total = (data['total'] as num?)?.toInt() ?? 0;

        for (final raw in items) {
          final m = raw as Map<String, dynamic>;
          final rawDomain = (m['unicodeName'] as String? ??
                  m['name'] as String? ??
                  m['domain'] as String? ??
                  '')
              .trim();
          if (rawDomain.isEmpty) continue;

          final rawStatus = m['lifecycleStatus'] as String? ?? m['status'] as String?;
          final epp = (m['eppStatuses'] as List?)?.map((e) => e.toString().toLowerCase()).toList() ?? [];
          final isLocked = epp.any((s) => s.contains('transferprohibited'));

          final privacyObj = m['privacyProtection'] as Map<String, dynamic>?;
          final isPrivate = privacyObj != null &&
              (privacyObj['contactForm'] == true ||
                  (privacyObj['level'] != null && privacyObj['level'] != 'none'));

          allDomains.add(
            RegisteredDomain(
              domain: rawDomain,
              connectionId: c.id,
              registrar: RegistrarId.spaceship,
              status: normalizeSpaceshipStatus(rawStatus),
              rawStatus: rawStatus,
              expiresAt: parseFlexibleDate(m['expirationDate'] ?? m['expireDate']),
              autoRenew: m['autoRenew'] is bool ? m['autoRenew'] as bool : null,
              locked: isLocked,
              privacy: isPrivate,
              fetchedAt: DateTime.now().toUtc(),
            ),
          );
        }

        skip += items.length;
        if (items.length < take || (total > 0 && skip >= total)) {
          break;
        }
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
      final res = await dio.get<dynamic>('/v1/dns/records/$domain');
      final data = res.data;
      if (data == null) {
        return const Err(UnknownException('Empty response from Spaceship DNS'));
      }

      final List rawRecords;
      if (data is Map<String, dynamic>) {
        rawRecords = (data['items'] as List?) ?? (data['records'] as List?) ?? [];
      } else if (data is List) {
        rawRecords = data;
      } else {
        rawRecords = [];
      }

      final result = rawRecords.map((raw) {
        final m = raw as Map<String, dynamic>;
        return DnsRecord(
          id: (m['id'] ?? '').toString(),
          domain: domain,
          type: (m['type'] ?? '').toString(),
          name: (m['name'] ?? '').toString(),
          content: (m['data'] ?? m['value'] ?? m['content'] ?? '').toString(),
          ttl: parseDnsTtl(m['ttl']),
          priority: parseDnsPriority(m['priority'] ?? m['prio']),
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
