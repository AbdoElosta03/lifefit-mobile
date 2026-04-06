import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorage {
  // إنشاء نسخة واحدة من المكتبة (Singleton)
  static const _storage = FlutterSecureStorage();

  // مفتاح تخزين التوكن
  static const _keyToken = 'auth_token';

  // 1. دالة حفظ التوكن
  static Future<void> saveToken(String token) async {
    try {
      await _storage.write(key: _keyToken, value: token);
    } catch (e) {
      print('TokenStorage.saveToken error: $e');
    }
  }

  // 2. دالة جلب التوكن
  static Future<String?> getToken() async {
    try {
      return await _storage.read(key: _keyToken);
    } catch (e) {
      print('TokenStorage.getToken error: $e');
      return null;
    }
  }

  // 3. دالة مسح التوكن (عند تسجيل الخروج)
  static Future<void> deleteToken() async {
    try {
      await _storage.delete(key: _keyToken);
    } catch (e) {
      print('TokenStorage.deleteToken error: $e');
    }
  }

  // 4. دالة للتأكد هل المستخدم مسجل دخول أم لا (وجود توكن)
  static Future<bool> hasToken() async {
    String? token = await getToken();
    return token != null;
  }
}
