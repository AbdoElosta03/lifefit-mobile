import 'package:dio/dio.dart';
import '../auth/token_storage.dart';
import '../models/user.dart';
import 'base_service.dart';

class AuthService extends BaseService {
  /// GET `/api/user` — current Sanctum user (Bearer token).
  Future<User> fetchCurrentUser() async {
    try {
      final response = await dio.get('user');
      if (response.statusCode == 200 && response.data is Map) {
        return User.fromJson(
          Map<String, dynamic>.from(response.data as Map),
        );
      }
      throw Exception('تعذر التحقق من الجلسة');
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        await TokenStorage.deleteToken();
      }
      final msg = e.response?.data is Map
          ? e.response?.data['message']?.toString()
          : null;
      throw Exception(msg ?? e.message ?? 'تعذر التحقق من الجلسة');
    }
  }

  /// Revokes token on server (best-effort) and clears local storage.
  Future<void> logout() async {
    try {
      await dio.post('logout');
    } catch (_) {}
    await TokenStorage.deleteToken();
  }

  Future<Response> login(String email, String password) async {
    final response = await dio.post(
      "login",
      data: {"email": email, "password": password},
    );

    final token = response.data['access_token'] ?? response.data['token'];
    if (token != null) {
      await TokenStorage.saveToken(token);
    }

    return response;
  }

  Future<Response> register({
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    final response = await dio.post(
      "register",
      data: {
        "name": name,
        "email": email,
        "password": password,
        "password_confirmation": password,
        "role": role,
      },
    );

    final token = response.data['access_token'] ?? response.data['token'];
    if (token != null) {
      await TokenStorage.saveToken(token);
    }

    return response;
  }
}
