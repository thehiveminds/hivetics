import '../shared/domain_utils.dart';
import 'registrar_id.dart';

enum DomainStatus {
  active,
  expiring,
  expired,
  cancelled,
  suspended,
  pending,
  unknown,
}

class RegisteredDomain {
  RegisteredDomain({
    required String domain,
    required this.connectionId,
    required this.registrar,
    required this.status,
    this.rawStatus,
    this.expiresAt,
    this.autoRenew,
    this.locked,
    this.privacy,
    this.nameServers = const [],
    required this.fetchedAt,
  }) : domain = normalizeDomain(domain);

  /// Normalized apex domain — the join key (§3.2).
  final String domain;

  final String connectionId;
  final RegistrarId registrar;
  final DomainStatus status;

  /// Raw status string from provider API for detail display.
  final String? rawStatus;

  /// Expiration timestamp, always in UTC.
  final DateTime? expiresAt;

  final bool? autoRenew;
  final bool? locked;
  final bool? privacy;

  final List<String> nameServers;
  final DateTime fetchedAt;

  /// Days until expiration relative to today (calendar day difference in UTC).
  /// Returns null if [expiresAt] is null.
  int? get daysUntilExpiry {
    if (expiresAt == null) return null;
    final now = DateTime.now().toUtc();
    final expiryDate = DateTime.utc(
      expiresAt!.year,
      expiresAt!.month,
      expiresAt!.day,
    );
    final nowDate = DateTime.utc(now.year, now.month, now.day);
    return expiryDate.difference(nowDate).inDays;
  }

  /// Whether domain has already expired (days <= 0).
  bool get isExpired => (daysUntilExpiry ?? 999) <= 0;

  /// Whether domain expires within 30 days and has not yet expired (1..30 days).
  /// Mutually exclusive with [isExpired].
  bool get isExpiringSoon => (daysUntilExpiry ?? 999) <= 30 && !isExpired;

  RegisteredDomain copyWith({
    String? domain,
    String? connectionId,
    RegistrarId? registrar,
    DomainStatus? status,
    String? rawStatus,
    DateTime? expiresAt,
    bool? autoRenew,
    bool? locked,
    bool? privacy,
    List<String>? nameServers,
    DateTime? fetchedAt,
  }) => RegisteredDomain(
    domain: domain ?? this.domain,
    connectionId: connectionId ?? this.connectionId,
    registrar: registrar ?? this.registrar,
    status: status ?? this.status,
    rawStatus: rawStatus ?? this.rawStatus,
    expiresAt: expiresAt ?? this.expiresAt,
    autoRenew: autoRenew ?? this.autoRenew,
    locked: locked ?? this.locked,
    privacy: privacy ?? this.privacy,
    nameServers: nameServers ?? this.nameServers,
    fetchedAt: fetchedAt ?? this.fetchedAt,
  );
}
