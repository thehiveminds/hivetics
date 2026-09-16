import 'package:dio/dio.dart';
import '../../core/network/api_client.dart';
import '../../core/network/rate_limiter.dart';
import '../../core/network/api_exception.dart';
import '../../core/network/retry_interceptor.dart';
import '../../core/result.dart';
import '../../models/connection.dart';
import '../../models/credential.dart';
import '../../models/deploy_status.dart';
import '../../models/deployment.dart';
import '../../models/project.dart';
import 'hosting_provider.dart';
import 'status_normalizer.dart';

class CloudflarePagesProvider implements HostingProvider {
  static const _base = 'https://api.cloudflare.com/client/v4';

  @override
  ProviderId get id => ProviderId.cloudflarepages;

  @override
  String get displayName => 'Cloudflare Pages';

  Dio _client(String token) => buildClient(
        baseUrl: _base,
        credential: BearerCredential(token: token),
        rateLimit: ProviderRateLimit.cloudflare,
      );

  @override
  Future<Result<ValidatedAccount>> validate(
    String token, {
    String? selectedAccountId,
  }) async {
    final dio = _client(token);
    try {
      // Establish that the token itself is good BEFORE reading /accounts.
      // /accounts answers 200 with an EMPTY result for a token that lacks the
      // "Account Settings: Read" permission, so an empty list on its own cannot
      // distinguish "bad token" from "valid token, missing one permission".
      final verifyRes =
          await dio.get<Map<String, dynamic>>('/user/tokens/verify');
      _checkCfSuccess(verifyRes.data);

      final res = await dio.get<Map<String, dynamic>>('/accounts');
      _checkCfSuccess(res.data);
      final accounts = (res.data!['result'] as List?) ?? [];

      if (accounts.isEmpty) {
        // Token verified, but it cannot enumerate accounts.
        return const Err(ForbiddenException(
          'Token is valid but cannot list accounts. Add the '
          '"Account Settings: Read" permission to it (alongside '
          '"Cloudflare Pages: Read"), then reconnect.',
        ));
      }

      // Single account — auto-select.
      if (accounts.length == 1 || selectedAccountId != null) {
        final account = selectedAccountId != null
            ? accounts.firstWhere(
                (a) => (a as Map)['id'] == selectedAccountId,
                orElse: () => accounts.first,
              )
            : accounts.first;
        final m = account as Map<String, dynamic>;
        return Ok(ValidatedAccount(
          accountId: m['id'] as String,
          displayName: m['name'] as String? ?? 'Cloudflare Account',
        ));
      }

      // Multiple accounts — surface the picker.
      final options = accounts.map((a) {
        final m = a as Map<String, dynamic>;
        return AccountOption(id: m['id'] as String, name: m['name'] as String? ?? m['id'] as String);
      }).toList();

      return Ok(ValidatedAccount(
        accountId: options.first.id,
        displayName: 'Cloudflare',
        teamOptions: options,
      ));
    } on DioException catch (e) {
      return Err(dioExceptionToApiException(e));
    } on ApiException catch (e) {
      return Err(e);
    } catch (e) {
      return Err(UnknownException.fromError(e));
    }
  }

  @override
  Future<Result<List<Project>>> listProjects(Connection c, String token) async {
    if (c.accountId == null) {
      return const Err(ForbiddenException('Cloudflare account ID not set — reconnect'));
    }
    final dio = _client(token);
    try {
      final res = await dio.get<Map<String, dynamic>>(
        '/accounts/${c.accountId}/pages/projects',
      );
      _checkCfSuccess(res.data);
      final rawList = (res.data!['result'] as List?) ?? [];

      final projects = rawList.map((raw) {
        final m = raw as Map<String, dynamic>;
        final domains = (m['domains'] as List?)?.cast<String>() ?? [];
        // subdomain is the *.pages.dev address
        final subdomain = m['subdomain'] as String?;
        if (subdomain != null && !domains.contains(subdomain)) {
          domains.insert(0, subdomain);
        }

        final name = m['name'] as String? ?? '';
        // The Pages API addresses projects by NAME, not by the UUID in `id`
        // (/accounts/{account_id}/pages/projects/{project_name}/deployments).
        // Names are unique per account, so the name is the usable identifier.
        final projectId = name.isNotEmpty ? name : (m['id'] as String? ?? '');

        Deployment? latestDeploy;
        final ld = m['latest_deployment'];
        if (ld != null && ld is Map<String, dynamic>) {
          latestDeploy = _mapDeployment(ld, projectId, c.id);
        }

        return Project(
          id: projectId,
          connectionId: c.id,
          providerId: ProviderId.cloudflarepages,
          name: name,
          framework: null, // CF Pages does not expose a framework field
          productionBranch: m['production_branch'] as String?,
          domains: domains,
          latestDeployment: latestDeploy,
          updatedAt: parseIso8601Timestamp(m['created_on']),
          fetchedAt: DateTime.now().toUtc(),
        );
      }).toList();

      return Ok(projects);
    } on DioException catch (e) {
      return Err(dioExceptionToApiException(e));
    } on ApiException catch (e) {
      return Err(e);
    } catch (e) {
      return Err(UnknownException.fromError(e));
    }
  }

  @override
  Future<Result<List<Deployment>>> listDeployments(
    Connection c,
    String token,
    String projectId, {
    int limit = 20,
    String? cursor,
  }) async {
    if (c.accountId == null) {
      return const Err(ForbiddenException('Cloudflare account ID not set'));
    }
    final dio = _client(token);
    final pageParam = cursor != null ? '&page=$cursor' : '';
    try {
      final res = await dio.get<Map<String, dynamic>>(
        '/accounts/${c.accountId}/pages/projects/$projectId/deployments?per_page=$limit$pageParam',
      );
      _checkCfSuccess(res.data);
      final rawList = (res.data!['result'] as List?) ?? [];
      final deployments = rawList
          .map((raw) => _mapDeployment(raw as Map<String, dynamic>, projectId, c.id))
          .toList();
      return Ok(deployments);
    } on DioException catch (e) {
      return Err(dioExceptionToApiException(e));
    } on ApiException catch (e) {
      return Err(e);
    } catch (e) {
      return Err(UnknownException.fromError(e));
    }
  }

  @override
  Future<Result<List<String>>> listProjectDomains(
    Connection c,
    String token,
    String projectId,
  ) async {
    // Domains are embedded in the projects list response. Return empty here;
    // listProjects already captures them.
    return const Ok([]);
  }

  Deployment _mapDeployment(Map<String, dynamic> m, String projectId, String connectionId) {
    // ⚠️ NO top-level status field — derive from latest_stage.
    final latestStage = m['latest_stage'] as Map<String, dynamic>?;
    final status = normalizeCloudflarePagesStageMap(latestStage);

    // Duration: ended_on(deploy stage) - started_on(queued stage)
    Duration? duration;
    final stages = (m['stages'] as List?) ?? [];
    DateTime? queuedStart;
    DateTime? deployEnd;
    for (final stage in stages) {
      final s = stage as Map<String, dynamic>;
      if (s['name'] == 'queued')  queuedStart = parseIso8601Timestamp(s['started_on']);
      if (s['name'] == 'deploy')  deployEnd   = parseIso8601Timestamp(s['ended_on']);
    }
    if (queuedStart != null && deployEnd != null) {
      duration = deployEnd.difference(queuedStart);
      if (duration.isNegative) duration = null;
    }

    final trigger = m['deployment_trigger'] as Map<String, dynamic>?;
    final triggerMeta = trigger?['metadata'] as Map<String, dynamic>?;

    // On failure: no error message field — synthesise from stage name.
    String? errorMessage;
    if (status == DeployStatus.failed && latestStage != null) {
      errorMessage = 'Build failed at stage: ${latestStage['name']}';
    }

    return Deployment(
      id: m['id'] as String? ?? '',
      projectId: projectId,
      connectionId: connectionId,
      status: status,
      url: m['url'] as String?,
      branch: triggerMeta?['branch'] as String?,
      environment: m['environment'] as String?,
      duration: duration,
      errorMessage: errorMessage,
      commitMessage: triggerMeta?['commit_message'] as String?,
      commitSha: triggerMeta?['commit_hash'] as String?,
      commitAuthor: null,
      createdAt: parseIso8601Timestamp(m['created_on']) ?? DateTime.now().toUtc(),
    );
  }

  /// Check the Cloudflare envelope success flag.
  /// Throws [UnknownException] if success:false, even on HTTP 200.
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
