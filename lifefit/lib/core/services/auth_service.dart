import 'package:dio/dio.dart';
import '../auth/token_storage.dart';
import 'base_service.dart';

class AuthService extends BaseService {
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
