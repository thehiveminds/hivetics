import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/network/api_exception.dart';
import '../core/storage/secure_store.dart';
import '../models/connection.dart';
import '../models/deploy_status.dart';
import '../models/service_ref.dart';
import '../models/site.dart';
import '../models/site_alert.dart';
import '../providers/provider_registry.dart';
import 'connections_notifier.dart';

/// Per-connection fetch result — error is not global.
class ConnectionFetchResult {
  const ConnectionFetchResult({
    required this.connection,
    this.sites = const [],
    this.error,
  });
  final Connection connection;
  final List<Site> sites;
  final ApiException? error;
  bool get hasError => error != null;
}

class SitesState {
  const SitesState({
    this.results = const [],
    this.isRefreshing = false,
  });
  final List<ConnectionFetchResult> results;
  final bool isRefreshing;

  List<Site> get allSites =>
      results.expand((r) => r.sites).toList()
        ..sort((a, b) {
          // Alerts first, then last-deployed desc.
          if (a.hasAlerts != b.hasAlerts) return a.hasAlerts ? -1 : 1;
          return b.sortKey.compareTo(a.sortKey);
        });

  bool get anyError => results.any((r) => r.hasError);
}

class SitesNotifier extends AsyncNotifier<SitesState> {
  @override
  Future<SitesState> build() async {
    // Watch connections — rebuild when connections change.
    final connections = await ref.watch(connectionsProvider.future);
    return _fetchAll(connections);
  }

  /// Pull-to-refresh — hosting providers only (DESIGN §7).
  Future<void> refresh() async {
    final connections = await ref.read(connectionsProvider.future);
    state = AsyncData(
      (state.valueOrNull ?? const SitesState()).copyWith(isRefreshing: true),
    );
    final result = await _fetchAll(connections);
    state = AsyncData(result);
  }

  Future<SitesState> _fetchAll(List<Connection> connections) async {
    final results = await Future.wait(
      connections.map((c) => _fetchConnection(c)),
    );
    return SitesState(results: results);
  }

  Future<ConnectionFetchResult> _fetchConnection(Connection c) async {
    final host = c.service;
    if (host is! HostRef) {
      // Registrar-only connections never yield Sites; the merge engine
      // (§6) joins their domains onto Sites instead.
      return ConnectionFetchResult(connection: c);
    }

    final token = await SecureStore.instance.loadCredential(c.id);
    if (token == null) {
      return ConnectionFetchResult(
        connection: c,
        error: const UnauthorizedException('No token found — reconnect'),
      );
    }

    final provider = providerFor(host.provider);
    final projectsResult = await provider.listProjects(c, token.token);

    return projectsResult.when(
      ok: (projects) {
        final sites = projects.map((project) {
          // Phase 1: no embedded latest deployment in this path.
          // The projects list response already has latestDeployments[0] for Vercel.
          // For Phase 1 we leave latestDeployment null and rely on listDeployments on detail.
          final domain = project.primaryDomain;
          final siteId = domain ?? 'host:${project.id}';

          final alerts = <SiteAlert>[];
          if (c.isUnauthorized) {
            alerts.add(SiteAlert.tokenExpired(host.provider.displayName));
          } else if (project.latestDeployment?.status == DeployStatus.failed) {
            alerts.add(SiteAlert.buildFailed);
          }

          return Site(
            id: siteId,
            displayName: domain ?? project.name,
            domain: domain,
            hostProject: project,
            latestDeployment: project.latestDeployment,
            alerts: alerts,
          );
        }).toList();

        return ConnectionFetchResult(connection: c, sites: sites);
      },
      err: (e) {
        // Record the error in drift for display in the connection list.
        ref
            .read(connectionsProvider.notifier)
            .setError(c.id, e.runtimeType.toString());
        return ConnectionFetchResult(connection: c, error: e);
      },
    );
  }
}

extension _SitesStateExt on SitesState {
  SitesState copyWith({bool? isRefreshing}) => SitesState(
        results: results,
        isRefreshing: isRefreshing ?? this.isRefreshing,
      );
}

final sitesProvider =
    AsyncNotifierProvider<SitesNotifier, SitesState>(SitesNotifier.new);
