import 'package:dio/dio.dart';
import '../../core/network/api_client.dart';
import '../../core/network/rate_limiter.dart';
import '../../core/network/api_exception.dart';
import '../../core/network/retry_interceptor.dart';
import '../../core/result.dart';
import '../../models/connection.dart';
import '../../models/credential.dart';
import '../../models/deployment.dart';
import '../../models/project.dart';
import 'hosting_provider.dart';
import 'status_normalizer.dart';

class NetlifyProvider implements HostingProvider {
  static const _base = 'https://api.netlify.com/api/v1';
  static const _version = '0.1.0';

  @override
  ProviderId get id => ProviderId.netlify;

  @override
  String get displayName => 'Netlify';

  Dio _client(String token) => buildClient(
        baseUrl: _base,
        credential: BearerCredential(token: token),
        rateLimit: ProviderRateLimit.netlify,
        extraHeaders: {'User-Agent': 'Hivetics/$_version'},
      );

  @override
  Future<Result<ValidatedAccount>> validate(
    String token, {
    String? selectedAccountId,
  }) async {
    final dio = _client(token);
    try {
      final res = await dio.get<Map<String, dynamic>>('/user');
      final data = res.data!;
      return Ok(ValidatedAccount(
        accountId: data['id'] as String? ?? '',
        displayName: data['full_name'] as String? ??
            data['email'] as String? ??
            'Netlify Account',
      ));
    } on DioException catch (e) {
      return Err(dioExceptionToApiException(e));
    } catch (e) {
      return Err(UnknownException.fromError(e));
    }
  }

  @override
  Future<Result<List<Project>>> listProjects(Connection c, String token) async {
    final dio = _client(token);
    try {
      // Returns a bare JSON array. published_deploy embedded — one call only.
      final res = await dio.get<List<dynamic>>('/sites?per_page=100');
      final rawList = res.data ?? [];

      final projects = rawList.map((raw) {
        final m = raw as Map<String, dynamic>;
        final siteId = m['id'] as String? ?? '';

        // Collect domain aliases — custom_domain is the primary.
        final domains = <String>[];
        final custom = m['custom_domain'] as String?;
        if (custom != null && custom.isNotEmpty) domains.add(custom);
        final aliases = (m['domain_aliases'] as List?)?.cast<String>() ?? [];
        domains.addAll(aliases);
        Deployment? latestDeploy;
        final pub = m['published_deploy'];
        if (pub != null && pub is Map<String, dynamic>) {
          latestDeploy = _mapDeployment(pub, siteId, c.id);
        }

        return Project(
          id: siteId,
          connectionId: c.id,
          providerId: ProviderId.netlify,
          name: m['name'] as String? ?? siteId,
          // `framework` lives on the deploy object, not on build_settings.
          framework: (pub is Map ? pub['framework'] : null) as String?,
          productionBranch: (m['build_settings'] as Map?)?['repo_branch'] as String?,
          domains: domains,
          latestDeployment: latestDeploy,
          updatedAt: parseIso8601Timestamp(m['updated_at']),
          fetchedAt: DateTime.now().toUtc(),
        );
      }).toList();

      return Ok(projects);
    } on DioException catch (e) {
      return Err(dioExceptionToApiException(e));
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
    final dio = _client(token);
    final pageParam = cursor != null ? '&page=$cursor' : '';
    try {
      final res = await dio.get<List<dynamic>>(
        '/sites/$projectId/deploys?per_page=$limit$pageParam',
      );
      final rawList = res.data ?? [];
      final deployments = rawList
          .map((raw) => _mapDeployment(raw as Map<String, dynamic>, projectId, c.id))
          .toList();
      return Ok(deployments);
    } on DioException catch (e) {
      return Err(dioExceptionToApiException(e));
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
    // Domains already extracted in listProjects from the embedded site object.
    // This method is here for interface compliance; call listProjects instead.
    return const Ok([]);
  }

  Deployment _mapDeployment(Map<String, dynamic> m, String projectId, String connectionId) {
    final status = normalizeNetlifyStatus(m['state'] as String?);

    // published_at > updated_at > created_at for best timestamp
    final createdAt = parseIso8601Timestamp(m['created_at']) ?? DateTime.now().toUtc();
    final publishedAt = parseIso8601Timestamp(m['published_at']);
    final updatedAt = parseIso8601Timestamp(m['updated_at']);

    // `deploy_time` is the real build duration in seconds. Falling back to
    // (published_at − created_at) overstates it by the queue wait.
    Duration? duration;
    final deployTime = m['deploy_time'];
    if (deployTime is num && deployTime > 0) {
      duration = Duration(seconds: deployTime.round());
    } else {
      final candidate = publishedAt ?? updatedAt;
      if (candidate != null) {
        final diff = candidate.difference(createdAt);
        if (!diff.isNegative) duration = diff;
      }
    }

    // ssl_url is the canonical URL for Netlify (full, with scheme).
    final url = (m['ssl_url'] ?? m['url']) as String?;

    return Deployment(
      id: m['id'] as String? ?? '',
      projectId: projectId,
      connectionId: connectionId,
      status: status,
      url: url,
      branch: m['branch'] as String?,
      environment: m['context'] as String?, // 'production' | 'deploy-preview' | 'branch-deploy'
      duration: duration,
      errorMessage: m['error_message'] as String?,
      // `commit_message` is the real field; `title` is a display fallback that
      // is also set for manual (non-git) deploys.
      commitMessage: (m['commit_message'] ?? m['title']) as String?,
      commitSha: m['commit_ref'] as String?,
      commitAuthor: m['committer'] as String?,
      createdAt: createdAt,
    );
  }
}
