import 'dart:convert';

import '../../models/credential.dart';

/// Result of decoding a secure-storage value: the credential, plus whether
/// the caller should rewrite storage (a Phase 1 bare-token row being
/// migrated into the JSON envelope used from Phase 2 on).
class DecodedCredential {
  const DecodedCredential(this.credential, {required this.migrated});
  final Credential credential;
  final bool migrated;
}

String encodeCredential(Credential credential) => jsonEncode(switch (credential) {
      BearerCredential(:final token) => {'type': 'bearer', 'token': token},
      KeyPairCredential(:final apiKey, :final secretKey) => {
          'type': 'keypair',
          'apiKey': apiKey,
          'secretKey': secretKey,
        },
      OAuthCredential(
        :final accessToken,
        :final refreshToken,
        :final expiresAt,
      ) =>
        {
          'type': 'oauth',
          'accessToken': accessToken,
          'refreshToken': refreshToken,
          'expiresAt': expiresAt.toIso8601String(),
        },
    });

/// Decodes a value read from secure storage. Phase 1 wrote the bearer token
/// as a bare string; anything that isn't a JSON object with a recognised
/// `type` is treated as one of those legacy rows and flagged `migrated` so
/// the caller rewrites it once, silently — no reconnect prompt.
DecodedCredential decodeCredential(String raw) {
  try {
    final decoded = jsonDecode(raw);
    if (decoded is Map<String, dynamic>) {
      switch (decoded['type']) {
        case 'bearer':
          return DecodedCredential(
            BearerCredential(token: decoded['token'] as String),
            migrated: false,
          );
        case 'keypair':
          return DecodedCredential(
            KeyPairCredential(
              apiKey: decoded['apiKey'] as String,
              secretKey: decoded['secretKey'] as String,
            ),
            migrated: false,
          );
        case 'oauth':
          return DecodedCredential(
            OAuthCredential(
              accessToken: decoded['accessToken'] as String,
              refreshToken: decoded['refreshToken'] as String,
              expiresAt: DateTime.parse(decoded['expiresAt'] as String),
            ),
            migrated: false,
          );
      }
    }
  } catch (_) {
    // Not JSON at all — definitely a legacy bare token.
  }
  return DecodedCredential(BearerCredential(token: raw), migrated: true);
}
