import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/network/api_exception.dart';
import '../core/storage/db.dart';
import '../core/storage/secure_store.dart';
import '../models/connection.dart';
import '../models/credential.dart';
import '../models/deploy_status.dart';
import '../models/registered_domain.dart';
import '../models/registrar_id.dart';
import '../models/service_ref.dart';
import '../models/site.dart';
import '../models/site_alert.dart';
import '../providers/provider_registry.dart';
import '../providers/registrar/registrar_status_normalizer.dart';
import '../shared/domain_utils.dart';
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
    final db = ref.read(dbProvider);

    // Read cached registrar domains from Drift DB (Sites refresh stays hosting-only per §6.3)
    final cachedRegistrarRows = await db.allRegisteredDomains();
    final registrarDomains = cachedRegistrarRows.map(_rowToDomain).toList();

    final results = await Future.wait(
      connections.map((c) => _fetchConnection(c, registrarDomains)),
    );
    return SitesState(results: results);
  }

  Future<ConnectionFetchResult> _fetchConnection(
    Connection c,
    List<RegisteredDomain> registrarDomains,
  ) async {
    final host = c.service;
    if (host is! HostRef) {
      // Registrar-only connections never yield Sites (§6.1);
      // their domains are joined onto Sites or live in the Domains tab.
      return ConnectionFetchResult(connection: c);
    }

    final credential = await SecureStore.instance.loadCredential(c.id);
    if (credential is! BearerCredential) {
      return ConnectionFetchResult(
        connection: c,
        error: const UnauthorizedException('No token found — reconnect'),
      );
    }

    final provider = providerFor(host.provider);
    final projectsResult = await provider.listProjects(c, credential.token);

    return projectsResult.when(
      ok: (projects) {
        final sites = projects.map((project) {
          final domain = project.primaryDomain;
          final siteId = domain ?? 'host:${project.id}';

          // Join with registrar domain on normalizeDomain (§6.1)
          RegisteredDomain? matchedDomain;
          if (domain != null && domain.isNotEmpty) {
            final normalized = normalizeDomain(domain);
            final matches = registrarDomains
                .where((rd) => rd.domain == normalized)
                .toList();

            if (matches.isNotEmpty) {
              // Same domain at two registrars: pick the one with later expiresAt (§6.1)
              matches.sort((a, b) {
                final aExp = a.expiresAt ?? DateTime.fromMillisecondsSinceEpoch(0);
                final bExp = b.expiresAt ?? DateTime.fromMillisecondsSinceEpoch(0);
                return bExp.compareTo(aExp);
              });
              matchedDomain = matches.first;
            }
          }

          final alerts = <SiteAlert>[];
          if (c.isUnauthorized) {
            alerts.add(SiteAlert.tokenExpired(host.provider.displayName));
          } else if (project.latestDeployment?.status == DeployStatus.failed) {
            alerts.add(SiteAlert.buildFailed);
          }

          // Domain alerts (§6.2)
          if (matchedDomain != null) {
            alerts.addAll(computeDomainAlerts(domain: matchedDomain));
          }

          return Site(
            id: siteId,
            displayName: domain ?? project.name,
            domain: domain,
            hostProject: project,
            latestDeployment: project.latestDeployment,
            registration: matchedDomain,
            alerts: alerts,
          );
        }).toList();

        return ConnectionFetchResult(connection: c, sites: sites);
      },
      err: (e) {
        return ConnectionFetchResult(connection: c, error: e);
      },
    );
  }

  static RegisteredDomain _rowToDomain(RegisteredDomainRow row) {
    List<String> ns = const [];
    try {
      final decoded = jsonDecode(row.nameServers);
      if (decoded is List) {
        ns = decoded.map((e) => e.toString()).toList();
      }
    } catch (_) {}

    final registrar = RegistrarId.fromId(row.registrarId);
    final status = switch (registrar) {
      RegistrarId.godaddy => normalizeGoDaddyStatus(row.rawStatus),
      RegistrarId.porkbun => normalizePorkbunStatus(row.rawStatus),
      RegistrarId.cloudflareregistrar =>
        normalizeCloudflareRegistrarStatus(row.rawStatus),
    };

    return RegisteredDomain(
      domain: row.domain,
      connectionId: row.connectionId,
      registrar: registrar,
      status: status,
      rawStatus: row.rawStatus,
      expiresAt: row.expiresAt,
      autoRenew: row.autoRenew,
      locked: row.locked,
      privacy: row.privacy,
      nameServers: ns,
      fetchedAt: row.fetchedAt,
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

