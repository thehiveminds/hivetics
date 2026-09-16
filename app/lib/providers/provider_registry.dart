// MIT Licence — TheHiveMinds / Hive Hub
// Provider registry — maps ProviderId → HostingProvider singleton.

import '../models/connection.dart';
import 'hosting/hosting_provider.dart';
import 'hosting/vercel_provider.dart';
import 'hosting/netlify_provider.dart';
import 'hosting/cloudflare_pages_provider.dart';

final _registry = <ProviderId, HostingProvider>{
  ProviderId.vercel:           VercelProvider(),
  ProviderId.netlify:          NetlifyProvider(),
  ProviderId.cloudflarepages:  CloudflarePagesProvider(),
};

HostingProvider providerFor(ProviderId id) {
  final p = _registry[id];
  assert(p != null, 'No provider registered for $id — add it to provider_registry.dart');
  return p!;
}

List<HostingProvider> get allHostingProviders => _registry.values.toList();
