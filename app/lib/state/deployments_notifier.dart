import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/storage/secure_store.dart';
import '../models/deployment.dart';
import '../models/connection.dart';
import '../models/service_ref.dart';
import '../providers/provider_registry.dart';
import 'connections_notifier.dart';

class DeploymentsNotifier extends AsyncNotifier<List<Deployment>> {
  @override
  Future<List<Deployment>> build() async {
    final connections = await ref.watch(connectionsProvider.future);
    return _fetchAll(connections);
  }

  Future<void> refresh() async {
    final connections = await ref.read(connectionsProvider.future);
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _fetchAll(connections));
  }

  Future<List<Deployment>> _fetchAll(List<Connection> connections) async {
    final all = <Deployment>[];

    await Future.wait(connections.map((c) async {
      final host = c.service;
      if (host is! HostRef) return;

      final token = await SecureStore.instance.loadCredential(c.id);
      if (token == null) return;

      final provider = providerFor(host.provider);

      // List all projects first to get project IDs.
      final projectsResult = await provider.listProjects(c, token.token);
      final projects = projectsResult.valueOrThrow; // silently skipped on error

      await Future.wait(projects.take(10).map((project) async {
        final deployResult = await provider.listDeployments(
          c,
          token.token,
          project.id,
          limit: 10,
        );
        deployResult.when(
          ok: (deploys) => all.addAll(deploys),
          err: (_) {},
        );
      }));
    }).toList());

    // Sort newest first across all providers.
    all.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return all;
  }
}

final deploymentsProvider =
    AsyncNotifierProvider<DeploymentsNotifier, List<Deployment>>(
  DeploymentsNotifier.new,
);

// ── Per-project deployments (for detail screen) ────────────────────────────

final projectDeploymentsProvider = FutureProvider.family<List<Deployment>, ({String connectionId, String projectId})>(
  (ref, args) async {
    final connections = await ref.watch(connectionsProvider.future);
    final connection = connections.firstWhere((c) => c.id == args.connectionId);
    final host = connection.service;
    if (host is! HostRef) return [];
    final token = await SecureStore.instance.loadCredential(connection.id);
    if (token == null) return [];
    final provider = providerFor(host.provider);
    final result = await provider.listDeployments(
      connection,
      token.token,
      args.projectId,
      limit: 20,
    );
    return result.valueOrThrow;
  },
);
