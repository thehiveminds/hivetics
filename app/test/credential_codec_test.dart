// Credential storage codec — Phase 2 §3.5/§8. A legacy Phase 1 row is a bare
// bearer-token string with no JSON envelope; it must read back correctly and
// be flagged for a silent one-time rewrite.

import 'package:flutter_test/flutter_test.dart';
import 'package:hivehub/core/storage/credential_codec.dart';
import 'package:hivehub/models/credential.dart';

void main() {
  group('decodeCredential', () {
    test('legacy bare token migrates to BearerCredential', () {
      final decoded = decodeCredential('sk_live_abc123');
      expect(decoded.migrated, isTrue);
      expect(decoded.credential, isA<BearerCredential>());
      expect((decoded.credential as BearerCredential).token, 'sk_live_abc123');
    });

    test('bearer JSON round-trips without re-migration', () {
      final encoded = encodeCredential(const BearerCredential(token: 'tok_1'));
      final decoded = decodeCredential(encoded);
      expect(decoded.migrated, isFalse);
      expect((decoded.credential as BearerCredential).token, 'tok_1');
    });

    test('keypair JSON round-trips without re-migration', () {
      final encoded = encodeCredential(
        const KeyPairCredential(apiKey: 'key_1', secretKey: 'secret_1'),
      );
      final decoded = decodeCredential(encoded);
      expect(decoded.migrated, isFalse);
      final cred = decoded.credential as KeyPairCredential;
      expect(cred.apiKey, 'key_1');
      expect(cred.secretKey, 'secret_1');
    });

    test('malformed JSON is treated as a legacy bare token', () {
      final decoded = decodeCredential('{not valid json');
      expect(decoded.migrated, isTrue);
      expect((decoded.credential as BearerCredential).token, '{not valid json');
    });
  });
}
