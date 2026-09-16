import 'package:dio/dio.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_exception.dart';
import '../../core/network/retry_interceptor.dart';
import '../../core/result.dart';
import '../../models/connection.dart';
import '../../models/credential.dart';
import '../../models/deployment.dart';
import '../../models/project.dart';
import 'hosting_provider.dart';
import 'status_normalizer.dart';

class VercelProvider implements HostingProvider {
  static const _base = 'https://api.vercel.com';

  @override
  ProviderId get id => ProviderId.vercel;

  @override
  String get displayName => 'Vercel';

  Dio _client(String token) => buildClient(
        baseUrl: _base,
        credential: BearerCredential(token: token),
      );

  @override
  Future<Result<ValidatedAccount>> validate(
    String token, {
    String? selectedAccountId,
  }) async {
    final dio = _client(token);
    try {
      final userRes = await dio.get<Map<String, dynamic>>('/v2/user');
      final userData = userRes.data!;
      final user = userData['user'] as Map<String, dynamic>? ?? userData;
      final userName =
          (user['name'] ?? user['username'] ?? 'Vercel Account') as String;
      final defaultTeamId = user['defaultTeamId'] as String?;

      // Fetch teams associated with this token
      List<AccountOption> options = [];
      try {
        final teamsRes = await dio.get<Map<String, dynamic>>('/v2/teams');
        final teamsRaw = (teamsRes.data?['teams'] as List?) ?? [];
        if (teamsRaw.isNotEmpty) {
          options.add(AccountOption(
            id: 'personal',
            name: '$userName (Personal)',
          ));
          for (final t in teamsRaw) {
            final m = t as Map<String, dynamic>;
            final teamId = m['id'] as String;
            final teamName =
                (m['name'] ?? m['slug'] ?? teamId) as String;
            options.add(AccountOption(id: teamId, name: teamName));
          }
        }
      } catch (_) {
        // Teams endpoint might fail with restricted tokens; ignore and fall back to personal.
      }

      if (options.length > 1) {
        if (selectedAccountId != null) {
          if (selectedAccountId == 'personal') {
            return Ok(ValidatedAccount(
              accountId: 'personal',
              displayName: '$userName (Personal)',
              teamOptions: options,
            ));
          }
          final picked = options.firstWhere(
            (o) => o.id == selectedAccountId,
            orElse: () => options.first,
          );
          return Ok(ValidatedAccount(
            accountId: picked.id,
            displayName: picked.name,
            teamOptions: options,
          ));
        }

        // If user has a defaultTeamId, choose that by default, but provide options
        final defaultOption = defaultTeamId != null
            ? options.firstWhere(
                (o) => o.id == defaultTeamId,
                orElse: () => options.first,
              )
            : options.first;

        return Ok(ValidatedAccount(
          accountId: defaultOption.id,
          displayName: defaultOption.name,
          teamOptions: options,
        ));
      }

      // Single personal account
      return Ok(ValidatedAccount(
        accountId: 'personal',
        displayName: userName,
      ));
    } on DioException catch (e) {
      return Err(dioExceptionToApiException(e));
    } catch (e) {
      return Err(UnknownException.fromError(e));
    }
  }

  String _teamQueryParam(Connection c, {bool isFirst = true}) {
    final aid = c.accountId;
    if (aid != null && aid.startsWith('team_')) {
      return '${isFirst ? '?' : '&'}teamId=$aid';
    }
    return '';
  }

  @override
  Future<Result<List<Project>>> listProjects(Connection c, String token) async {
    final dio = _client(token);
    final teamParam = _teamQueryParam(c, isFirst: false);
    try {
      final res = await dio.get<dynamic>('/v10/projects?limit=100$teamParam');
      final rawList = _extractProjectsList(res.data);

      final projects = rawList.map((raw) {
        final m = raw as Map<String, dynamic>;
        final domains = _extractProjectDomains(m);

        Deployment? latestDeploy;
        final latestDeploys = (m['latestDeployments'] as List?) ?? [];
        if (latestDeploys.isNotEmpty) {
          latestDeploy = _mapDeployment(
            latestDeploys.first as Map<String, dynamic>,
            m['id'] as String,
            c.id,
          );
        }

        return Project(
          id: m['id'] as String,
          connectionId: c.id,
          providerId: ProviderId.vercel,
          name: m['name'] as String? ?? '',
          framework: m['framework'] as String?,
          productionBranch: (m['link'] as Map?)?.tryGet('productionBranch'),
          domains: domains,
          latestDeployment: latestDeploy,
          updatedAt: parseVercelTimestamp(m['updatedAt']),
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
    final teamParam = _teamQueryParam(c, isFirst: false);
    final cursorParam = cursor != null ? '&until=$cursor' : '';
    try {
      final res = await dio.get<Map<String, dynamic>>(
        '/v7/deployments?projectId=$projectId&limit=$limit$teamParam$cursorParam',
      );
      final data = res.data!;
      final rawList = (data['deployments'] as List?) ?? [];

      final deployments = rawList.map((raw) {
        final m = raw as Map<String, dynamic>;
        return _mapDeployment(m, projectId, c.id);
      }).toList();

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
    final dio = _client(token);
    final teamParam = _teamQueryParam(c, isFirst: true);
    try {
      final res =
          await dio.get<dynamic>('/v9/projects/$projectId/domains$teamParam');
      final rawData = res.data;

      List<dynamic> rawList;
      if (rawData is List) {
        rawList = rawData;
      } else if (rawData is Map) {
        rawList = (rawData['domains'] as List?) ?? [];
      } else {
        rawList = [];
      }

      final domains = rawList
          .map((d) => (d as Map<String, dynamic>)['name'] as String?)
          .whereType<String>()
          .toList();

      return Ok(domains);
    } on DioException catch (e) {
      return Err(dioExceptionToApiException(e));
    } catch (e) {
      return Err(UnknownException.fromError(e));
    }
  }

  List<dynamic> _extractProjectsList(dynamic data) {
    if (data is List) return data;
    if (data is Map) return (data['projects'] as List?) ?? [];
    return [];
  }

  List<String> _extractProjectDomains(Map<String, dynamic> project) {
    final domains = <String>[];

    // 1. Targets production alias
    final targets = project['targets'] as Map<String, dynamic>?;
    final prod = targets?['production'] as Map<String, dynamic>?;
    final prodAliases = prod?['alias'] as List?;
    if (prodAliases != null) {
      for (final a in prodAliases) {
        if (a is String && a.isNotEmpty && !domains.contains(a)) {
          domains.add(a);
        }
      }
    }

    // 2. Latest deployments aliases
    final latestDeploys = (project['latestDeployments'] as List?) ?? [];
    if (latestDeploys.isNotEmpty) {
      final firstDeploy = latestDeploys.first as Map<String, dynamic>;
      final aliases = firstDeploy['alias'] as List?;
      if (aliases != null) {
        for (final a in aliases) {
          if (a is String && a.isNotEmpty && !domains.contains(a)) {
            domains.add(a);
          }
        }
      }
      if (domains.isEmpty) {
        final url = normalizeUrl(firstDeploy['url'] as String?);
        if (url != null) {
          final uri = Uri.tryParse(url);
          if (uri != null && uri.host.isNotEmpty) {
            domains.add(uri.host);
          }
        }
      }
    }

    // 3. Fallback to project name
    if (domains.isEmpty && project['name'] != null) {
      final name = project['name'] as String;
      if (name.isNotEmpty) {
        domains.add('$name.vercel.app');
      }
    }

    return domains;
  }

  Deployment _mapDeployment(
    Map<String, dynamic> m,
    String projectId,
    String connectionId,
  ) {
    final id = (m['uid'] ?? m['id'] ?? '') as String;
    final status = normalizeVercelStatus(m['readyState'] as String?);

    Duration? duration;
    final buildingAt = parseVercelTimestamp(m['buildingAt']);
    final readyAt = parseVercelTimestamp(m['ready'] ?? m['readyAt']);
    if (buildingAt != null && readyAt != null) {
      duration = readyAt.difference(buildingAt);
    }

    final meta = m['meta'] as Map<String, dynamic>? ?? {};
    final commitMsg = meta['githubCommitMessage'] ??
        meta['gitlabCommitMessage'] ??
        meta['bitbucketCommitMessage'];
    final commitSha = meta['githubCommitSha'] ??
        meta['gitlabCommitSha'] ??
        meta['bitbucketCommitSha'];
    final commitAuthor = meta['githubCommitAuthorName'] ??
        meta['gitlabCommitAuthorName'] ??
        meta['bitbucketCommitAuthorName'];

    return Deployment(
      id: id,
      projectId: projectId,
      connectionId: connectionId,
      status: status,
      url: normalizeUrl(m['url'] as String?),
      branch: meta['githubCommitRef'] ??
          meta['gitlabCommitRef'] ??
          meta['bitbucketCommitRef'],
      environment: m['target'] as String?,
      duration: duration,
      errorMessage: m['errorMessage'] as String?,
      commitMessage: commitMsg as String?,
      commitSha: commitSha as String?,
      commitAuthor: commitAuthor as String?,
      createdAt: parseVercelTimestamp(m['createdAt'] ?? m['created']) ??
          DateTime.now().toUtc(),
    );
  }
}

extension _MapExt on Map {
  String? tryGet(String key) => this[key] as String?;
}
