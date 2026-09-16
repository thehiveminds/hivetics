

/// Sealed credential. Only sub-types are written to secure storage.
sealed class Credential {
  const Credential();
}

/// Bearer token — Vercel, Netlify, Cloudflare, GoDaddy, Clarity.
final class BearerCredential extends Credential {
  const BearerCredential({required this.token});
  final String token;

  @override
  String toString() => 'BearerCredential([REDACTED])';
}

final class KeyPairCredential extends Credential {
  const KeyPairCredential({required this.apiKey, required this.secretKey});
  final String apiKey;
  final String secretKey;

  @override
  String toString() => 'KeyPairCredential([REDACTED])';
}

final class OAuthCredential extends Credential {
  OAuthCredential({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresAt,
  });
  String accessToken;
  String refreshToken;
  DateTime expiresAt;

  bool get isExpired => DateTime.now().isAfter(expiresAt);

  @override
  String toString() => 'OAuthCredential([REDACTED])';
}
