

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../models/credential.dart';

class SecureStore {
  SecureStore._();
  static final SecureStore instance = SecureStore._();

  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  static String _tokenKey(String connectionId) => 'token_$connectionId';

  Future<void> saveToken(String connectionId, String token) async {
    await _storage.write(key: _tokenKey(connectionId), value: token);
  }

  Future<BearerCredential?> loadCredential(String connectionId) async {
    final token = await _storage.read(key: _tokenKey(connectionId));
    if (token == null) return null;
    return BearerCredential(token: token);
  }

  Future<void> deleteCredential(String connectionId) async {
    await _storage.delete(key: _tokenKey(connectionId));
  }

  Future<bool> hasCredential(String connectionId) async {
    return await _storage.containsKey(key: _tokenKey(connectionId));
  }
}
