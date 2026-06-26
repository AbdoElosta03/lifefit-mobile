import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Persists the Sanctum bearer token. Read by [BaseService] on each request.
class TokenStorage {
  static const _storage = FlutterSecureStorage();
  static const _keyToken = 'auth_token';

  static Future<void> saveToken(String token) async {
    try {
      await _storage.write(key: _keyToken, value: token);
    } catch (e) {
      print('TokenStorage.saveToken error: $e');
    }
  }

  static Future<String?> getToken() async {
    try {
      return await _storage.read(key: _keyToken);
    } catch (e) {
      print('TokenStorage.getToken error: $e');
      return null;
    }
  }

  /// Called on logout and when [AuthNotifier.restoreSession] fails.
  static Future<void> deleteToken() async {
    try {
      await _storage.delete(key: _keyToken);
    } catch (e) {
      print('TokenStorage.deleteToken error: $e');
    }
  }

  /// Fast check used before hitting `/api/user` on cold start.
  static Future<bool> hasToken() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }
}
