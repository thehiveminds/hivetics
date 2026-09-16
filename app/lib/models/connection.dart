enum ProviderId {
  vercel('vercel', 'Vercel'),
  netlify('netlify', 'Netlify'),
  cloudflarepages('cloudflarepages', 'Cloudflare Pages');

  const ProviderId(this.id, this.displayName);
  final String id;
  final String displayName;

  static ProviderId fromId(String id) =>
      ProviderId.values.firstWhere((p) => p.id == id);
}

class Connection {
  const Connection({
    required this.id,
    required this.providerId,
    required this.displayName,
    this.accountId,
    this.accountName,
    this.lastSyncedAt,
    this.lastError,
  });

  final String id;
  final ProviderId providerId;

  final String displayName;

  final String? accountId;

  final String? accountName;

  final DateTime? lastSyncedAt;

  final String? lastError;

  bool get hasError => lastError != null;
  bool get isUnauthorized => lastError == 'UnauthorizedException';

  Connection copyWith({
    String? displayName,
    String? accountId,
    String? accountName,
    DateTime? lastSyncedAt,
    String? lastError,
    bool clearError = false,
  }) => Connection(
    id: id,
    providerId: providerId,
    displayName: displayName ?? this.displayName,
    accountId: accountId ?? this.accountId,
    accountName: accountName ?? this.accountName,
    lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
    lastError: clearError ? null : (lastError ?? this.lastError),
  );
}
