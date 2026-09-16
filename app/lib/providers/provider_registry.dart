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
import 'registrar/spaceship_provider.dart';
import 'registrar/namecom_provider.dart';
import 'registrar/gandi_provider.dart';
import 'registrar/namesilo_provider.dart';
import 'registrar/dynadot_provider.dart';
import '../models/service_ref.dart';
import 'analytics/analytics_provider.dart';
import 'analytics/gsc_provider.dart';
import 'analytics/generic_analytics_provider.dart';

final _hostingRegistry = <ProviderId, HostingProvider>{
  ProviderId.vercel: VercelProvider(),
  ProviderId.netlify: NetlifyProvider(),
  ProviderId.cloudflarepages: CloudflarePagesProvider(),
};

final _registrarRegistry = <RegistrarId, RegistrarProvider>{
  RegistrarId.godaddy: GoDaddyProvider(),
  RegistrarId.porkbun: PorkbunProvider(),
  RegistrarId.cloudflareregistrar: CloudflareRegistrarProvider(),
  RegistrarId.spaceship: SpaceshipProvider(),
  RegistrarId.namecom: NameComProvider(),
  RegistrarId.gandi: GandiProvider(),
  RegistrarId.namesilo: NameSiloProvider(),
  RegistrarId.dynadot: DynadotProvider(),
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

final _analyticsRegistry = <AnalyticsProviderId, AnalyticsProvider>{
  AnalyticsProviderId.gsc: GscProvider(),
  AnalyticsProviderId.ga4: const GenericAnalyticsProvider(AnalyticsProviderId.ga4),
  AnalyticsProviderId.clarity: const GenericAnalyticsProvider(AnalyticsProviderId.clarity),
  AnalyticsProviderId.plausible: const GenericAnalyticsProvider(AnalyticsProviderId.plausible),
  AnalyticsProviderId.umami: const GenericAnalyticsProvider(AnalyticsProviderId.umami),
};

AnalyticsProvider analyticsProviderFor(AnalyticsProviderId id) {
  final p = _analyticsRegistry[id];
  assert(p != null, 'No analytics provider registered for $id — add it to provider_registry.dart');
  return p!;
}

List<AnalyticsProvider> get allAnalyticsProviders => _analyticsRegistry.values.toList();


