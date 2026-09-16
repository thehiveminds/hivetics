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
