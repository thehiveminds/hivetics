import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/storage/secure_store.dart';
import '../models/connection.dart';
import '../models/credential.dart';
import '../models/project_analytics.dart';
import '../models/service_ref.dart';
import '../providers/hosting/vercel_provider.dart';
import '../providers/provider_registry.dart';
import 'connections_notifier.dart';

typedef ProjectAnalyticsArgs = ({
  String connectionId,
  String projectId,
  AnalyticsTimeframe timeframe,
});

final projectAnalyticsProvider =
    FutureProvider.family<ProjectAnalytics?, ProjectAnalyticsArgs>(
  (ref, args) async {
    final connections = await ref.watch(connectionsProvider.future);
    final connection =
        connections.where((c) => c.id == args.connectionId).firstOrNull;
    if (connection == null) return null;

    final host = connection.service;
    if (host is! HostRef) return null;

    final credential = await SecureStore.instance.loadCredential(connection.id);
    if (credential is! BearerCredential) return null;

    if (host.provider == ProviderId.vercel) {
      final provider = providerFor(ProviderId.vercel) as VercelProvider;
      final res = await provider.getProjectAnalytics(
        connection,
        credential.token,
        args.projectId,
        timeframe: args.timeframe,
      );
      return res.when(
        ok: (data) => data,
        err: (_) => null,
      );
    }

    return null;
  },
);
