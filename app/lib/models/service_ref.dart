import 'connection.dart';
import 'registrar_id.dart';

/// What a [Connection] talks to — a hosting provider or a registrar.
/// `ProviderId` stays a closed enum of hosting providers only; this union is
/// the seam that lets a registrar reach the connections list without also
/// reaching `providerFor()` / `listProjects()`.
sealed class ServiceRef {
  const ServiceRef();
  String get id;
  String get displayName;
}

final class HostRef extends ServiceRef {
  const HostRef(this.provider);
  final ProviderId provider;

  @override
  String get id => provider.id;
  @override
  String get displayName => provider.displayName;
}

final class RegistrarRef extends ServiceRef {
  const RegistrarRef(this.registrar);
  final RegistrarId registrar;

  @override
  String get id => registrar.id;
  @override
  String get displayName => registrar.displayName;
}

enum AnalyticsProviderId {
  gsc('gsc', 'Google Search Console'),
  ga4('ga4', 'Google Analytics 4'),
  clarity('clarity', 'Microsoft Clarity'),
  plausible('plausible', 'Plausible Analytics'),
  umami('umami', 'Umami Analytics');

  const AnalyticsProviderId(this.id, this.displayName);
  final String id;
  final String displayName;

  static AnalyticsProviderId fromId(String id) =>
      AnalyticsProviderId.values.firstWhere(
        (a) => a.id == id,
        orElse: () => AnalyticsProviderId.gsc,
      );
}

final class AnalyticsRef extends ServiceRef {
  const AnalyticsRef(this.analytics);
  final AnalyticsProviderId analytics;

  @override
  String get id => analytics.id;
  @override
  String get displayName => analytics.displayName;
}

