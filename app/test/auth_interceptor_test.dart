// Porkbun auth (Phase 2 §2.2/§8): keys must land as plain headers, never in
// a URL or POST body.

import 'package:flutter_test/flutter_test.dart';
import 'package:hivehub/core/network/auth_interceptor.dart';
import 'package:hivehub/models/credential.dart';

void main() {
  test('BearerCredential produces an Authorization header only', () {
    final headers = credentialHeaders(const BearerCredential(token: 'tok_1'));
    expect(headers, {'Authorization': 'Bearer tok_1'});
  });

  test('KeyPairCredential lands both secrets as headers, never a query param', () {
    final headers = credentialHeaders(
      const KeyPairCredential(apiKey: 'key_1', secretKey: 'secret_1'),
    );
    expect(headers, {
      'X-API-Key': 'key_1',
      'X-Secret-API-Key': 'secret_1',
    });
    // Nothing here is shaped like a query string or body field.
    expect(headers.values.every((v) => !v.contains('=') && !v.contains('&')), isTrue);
  });
}
