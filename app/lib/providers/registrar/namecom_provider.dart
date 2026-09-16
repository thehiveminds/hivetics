import 'dart:convert';
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

class NameComProvider implements RegistrarProvider {
  NameComProvider({String? baseUrl})
      : _baseUrl = baseUrl ?? 'https://api.name.com';

  final String _baseUrl;

  @override
  RegistrarId get id => RegistrarId.namecom;

  @override
  String get displayName => 'Name.com';

  Dio _client(Credential credential) {
    final Map<String, String> headers = {};
    if (credential is KeyPairCredential) {
      final user = credential.apiKey.trim();
      final token = credential.secretKey.trim();
      final basicAuth = base64Encode(utf8.encode('$user:$token'));
      headers['Authorization'] = 'Basic $basicAuth';
    }
    return buildClient(
      baseUrl: _baseUrl,
      credential: credential,
      rateLimit: ProviderRateLimit.namecom,
      extraHeaders: headers,
    );
  }

  @override
  Future<Result<ValidatedAccount>> validate(Credential credential) async {
    final dio = _client(credential);
    try {
      final res = await dio.get<Map<String, dynamic>>(
        '/core/v1/domains',
        queryParameters: {'perPage': 1, 'page': 1},
      );
      final data = res.data;
      if (data == null) {
        return const Err(UnknownException('Empty response from Name.com'));
      }

      final username = credential is KeyPairCredential
          ? credential.apiKey.trim()
          : 'Name.com Account';

      return Ok(
        ValidatedAccount(accountId: username, displayName: 'Name.com ($username)'),
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
    const int perPage = 250;

    try {
      while (page <= 200) {
        final res = await dio.get<Map<String, dynamic>>(
          '/core/v1/domains',
          queryParameters: {'perPage': perPage, 'page': page},
        );
        final data = res.data;
        if (data == null) break;

        final domainsList = (data['domains'] as List?) ?? [];
        for (final raw in domainsList) {
          final m = raw as Map<String, dynamic>;
          final rawDomain = (m['domainName'] as String? ?? m['domain'] as String? ?? '').trim();
          if (rawDomain.isEmpty) continue;

          final rawStatus = (m['status'] as String? ?? '').trim();
          final autoRenew = m['autorenewEnabled'] is bool
              ? m['autorenewEnabled'] as bool
              : (m['autoRenew'] is bool ? m['autoRenew'] as bool : null);

          allDomains.add(
            RegisteredDomain(
              domain: rawDomain,
              connectionId: c.id,
              registrar: RegistrarId.namecom,
              status: normalizeNamecomStatus(rawStatus),
              rawStatus: rawStatus,
              expiresAt: parseFlexibleDate(m['expireDate']),
              autoRenew: autoRenew,
              locked: m['locked'] is bool ? m['locked'] as bool : null,
              privacy: m['privacyEnabled'] is bool ? m['privacyEnabled'] as bool : null,
              fetchedAt: DateTime.now().toUtc(),
            ),
          );
        }

        final nextPage = (data['nextPage'] as num?)?.toInt();
        if (nextPage != null && nextPage > page) {
          page = nextPage;
        } else if (domainsList.length >= perPage) {
          page++;
        } else {
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
      final res = await dio.get<Map<String, dynamic>>('/core/v1/domains/$domain/records');
      final data = res.data;
      if (data == null) {
        return const Err(UnknownException('Empty response from Name.com DNS'));
      }

      final recordsList = (data['records'] as List?) ?? [];
      final result = recordsList.map((raw) {
        final m = raw as Map<String, dynamic>;
        return DnsRecord(
          id: (m['id'] ?? '').toString(),
          domain: domain,
          type: (m['type'] ?? '').toString(),
          name: (m['host'] ?? m['name'] ?? '').toString(),
          content: (m['answer'] ?? m['data'] ?? m['content'] ?? '').toString(),
          ttl: parseDnsTtl(m['ttl']),
          priority: parseDnsPriority(m['priority']),
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
