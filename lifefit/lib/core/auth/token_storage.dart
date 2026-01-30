import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorage {
  // إنشاء نسخة واحدة من المكتبة (Singleton)
  static const _storage = FlutterSecureStorage();

  // مفتاح تخزين التوكن
  static const _keyToken = 'auth_token';

  // 1. دالة حفظ التوكن
  static Future<void> saveToken(String token) async {
    await _storage.write(key: _keyToken, value: token);
  }

  // 2. دالة جلب التوكن
  static Future<String?> getToken() async {
    return await _storage.read(key: _keyToken);
  }

  // 3. دالة مسح التوكن (عند تسجيل الخروج)
  static Future<void> deleteToken() async {
    await _storage.delete(key: _keyToken);
  }

  // 4. دالة للتأكد هل المستخدم مسجل دخول أم لا (وجود توكن)
  static Future<bool> hasToken() async {
    String? token = await getToken();
    return token != null;
  }
}