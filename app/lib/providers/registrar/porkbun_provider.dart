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

class PorkbunProvider implements RegistrarProvider {
  PorkbunProvider({String? baseUrl})
    : _baseUrl = baseUrl ?? 'https://api.porkbun.com/api/json/v3';

  final String _baseUrl;

  @override
  RegistrarId get id => RegistrarId.porkbun;

  @override
  String get displayName => 'Porkbun';

  Dio _client(Credential credential) => buildClient(
    baseUrl: _baseUrl,
    credential: credential,
    rateLimit: ProviderRateLimit.porkbun,
  );

  @override
  Future<Result<ValidatedAccount>> validate(Credential credential) async {
    final dio = _client(credential);
    try {
      final res = await dio.get<Map<String, dynamic>>('/ping');
      final data = res.data;
      if (data == null) {
        return const Err(UnknownException('Empty response from Porkbun'));
      }

      final status = data['status'] as String?;
      if (status != 'SUCCESS') {
        final msg = data['message'] as String? ?? 'Invalid Porkbun credentials';
        return Err(UnauthorizedException(msg));
      }

      final yourIp = data['yourIp'] as String?;
      final displayName = yourIp != null
          ? 'Porkbun ($yourIp)'
          : 'Porkbun Account';

      return Ok(
        ValidatedAccount(accountId: 'porkbun', displayName: displayName),
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
    try {
      final allDomains = <RegisteredDomain>[];
      int start = 0;
      const batchSize = 1000;

      while (true) {
        final path = start == 0 ? '/domain/listAll' : '/domain/listAll?start=$start';
        final res = await dio.get<Map<String, dynamic>>(path);
        final data = res.data;
        if (data == null) {
          if (allDomains.isNotEmpty) break;
          return const Err(UnknownException('Empty response from Porkbun'));
        }

        final status = data['status'] as String?;
        if (status != 'SUCCESS') {
          if (allDomains.isNotEmpty) break;
          final msg =
              data['message'] as String? ?? 'Failed to list Porkbun domains';
          return Err(UnknownException(msg));
        }

        final domainsList = (data['domains'] as List?) ?? [];
        if (domainsList.isEmpty) break;

        for (final raw in domainsList) {
          final m = raw as Map<String, dynamic>;
          final rawDomain = (m['domain'] as String? ?? '').trim();
          final rawStatus = m['status'] as String?;

          allDomains.add(
            RegisteredDomain(
              domain: rawDomain,
              connectionId: c.id,
              registrar: RegistrarId.porkbun,
              status: normalizePorkbunStatus(rawStatus),
              rawStatus: rawStatus,
              expiresAt: parsePorkbunDate(m['expireDate']),
              autoRenew: parsePorkbunBool(m['autoRenew']),
              locked: parsePorkbunBool(m['securityLock']),
              privacy: parsePorkbunBool(m['whoisPrivacy']),
              fetchedAt: DateTime.now().toUtc(),
            ),
          );
        }

        if (domainsList.length < batchSize) break;
        start += batchSize;
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
      final res = await dio.get<Map<String, dynamic>>('/dns/retrieve/$domain');
      final data = res.data;
      if (data == null) {
        return const Err(UnknownException('Empty response from Porkbun DNS'));
      }

      final status = data['status'] as String?;
      if (status != 'SUCCESS') {
        final msg =
            data['message'] as String? ?? 'Failed to retrieve DNS records';
        return Err(UnknownException(msg));
      }

      final recordsList = (data['records'] as List?) ?? [];
      final result = recordsList.map((raw) {
        final m = raw as Map<String, dynamic>;
        return DnsRecord(
          id: (m['id'] ?? '').toString(),
          domain: domain,
          type: m['type'] as String? ?? '',
          name: m['name'] as String? ?? '',
          content: m['content'] as String? ?? '',
          ttl: parseDnsTtl(m['ttl']),
          priority: parseDnsPriority(m['prio']),
          proxied: false,
        );
      }).toList();

      return Ok(result);
    } on DioException catch (e) {
      return Err(dioExceptionToApiException(e));
    } catch (e) {
      return Err(UnknownException.fromError(e));
    }
  }
}
