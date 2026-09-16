// Provider registry — maps ProviderId → HostingProvider singleton.

import '../models/connection.dart';
import '../models/registrar_id.dart';
import 'hosting/hosting_provider.dart';
import 'hosting/vercel_provider.dart';
import 'hosting/netlify_provider.dart';
import 'hosting/cloudflare_pages_provider.dart';
import 'registrar/registrar_provider.dart';
import 'registrar/godaddy_provider.dart';
import 'registrar/porkbun_provider.dart';
import 'registrar/cloudflare_registrar_provider.dart';

final _hostingRegistry = <ProviderId, HostingProvider>{
  ProviderId.vercel: VercelProvider(),
  ProviderId.netlify: NetlifyProvider(),
  ProviderId.cloudflarepages: CloudflarePagesProvider(),
};

final _registrarRegistry = <RegistrarId, RegistrarProvider>{
  RegistrarId.godaddy: GoDaddyProvider(),
  RegistrarId.porkbun: PorkbunProvider(),
  RegistrarId.cloudflareregistrar: CloudflareRegistrarProvider(),
};

HostingProvider providerFor(ProviderId id) {
  final p = _hostingRegistry[id];
  assert(p != null, 'No provider registered for $id — add it to provider_registry.dart');
  return p!;
}

List<HostingProvider> get allHostingProviders => _hostingRegistry.values.toList();

RegistrarProvider registrarProviderFor(RegistrarId id) {
  final p = _registrarRegistry[id];
  assert(p != null, 'No registrar registered for $id — add it to provider_registry.dart');
  return p!;
}

List<RegistrarProvider> get allRegistrarProviders => _registrarRegistry.values.toList();

