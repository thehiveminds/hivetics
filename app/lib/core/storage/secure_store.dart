

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../models/credential.dart';
import 'credential_codec.dart';

class SecureStore {
  SecureStore._();
  static final SecureStore instance = SecureStore._();

  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  static String _tokenKey(String connectionId) => 'token_$connectionId';

  Future<void> saveToken(String connectionId, String token) =>
      saveCredential(connectionId, BearerCredential(token: token));

  Future<void> saveCredential(String connectionId, Credential credential) async {
    await _storage.write(
      key: _tokenKey(connectionId),
      value: encodeCredential(credential),
    );
  }

  Future<Credential?> loadCredential(String connectionId) async {
    final raw = await _storage.read(key: _tokenKey(connectionId));
    if (raw == null) return null;
    final decoded = decodeCredential(raw);
    if (decoded.migrated) {
      await saveCredential(connectionId, decoded.credential);
    }
    return decoded.credential;
  }

  Future<void> deleteCredential(String connectionId) async {
    await _storage.delete(key: _tokenKey(connectionId));
  }

  Future<bool> hasCredential(String connectionId) async {
    return await _storage.containsKey(key: _tokenKey(connectionId));
  }
}
