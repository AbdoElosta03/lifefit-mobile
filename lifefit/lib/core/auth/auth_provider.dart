import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'auth_state.dart';
import 'token_storage.dart';
import '../models/user.dart';
import '../services/api_service.dart';

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>(
  (ref) => AuthNotifier(),
);

class AuthNotifier extends StateNotifier<AuthState> {
  final ApiService _api = ApiService();

  AuthNotifier() : super(const AuthState());

  /// Call once on app start: restores [User] when a token exists in [TokenStorage].
  Future<void> restoreSession() async {
    if (!state.isInitializing) return;

    try {
      final hasToken = await TokenStorage.hasToken();
      if (!hasToken) {
        state = state.copyWith(isInitializing: false);
        return;
      }

      final user = await _api.fetchCurrentUser();
      state = state.copyWith(user: user, isInitializing: false, isLoading: false);
    } catch (_) {
      await TokenStorage.deleteToken();
      state = state.copyWith(
        isInitializing: false,
        isLoading: false,
        clearUser: true,
      );
    }
  }

  Future<void> logout() async {
    await _api.logout();
    state = const AuthState(isInitializing: false, isLoading: false);
  }

  Future<void> login({required String email, required String password}) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final response = await _api.login(email, password);
      final user = User.fromJson(response.data['user']);

      state = state.copyWith(
        user: user,
        isLoading: false,
        isInitializing: false,
      );
    } on DioException catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: _toUserMessage(e));
    }
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final response = await _api.register(
        name: name,
        email: email,
        password: password,
        role: role,
      );
      final user = User.fromJson(response.data['user']);

      state = state.copyWith(
        user: user,
        isLoading: false,
        isInitializing: false,
      );
    } on DioException catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: _toUserMessage(e));
    }
  }

  String _toUserMessage(DioException e) {
    if (e.response != null) {
      final status = e.response!.statusCode;
      final data = e.response!.data;

      if (status == 401) {
        return "البريد الإلكتروني أو كلمة المرور غير صحيحة";
      }

      if (status == 422 && data is Map && data['message'] != null) {
        return data['message'];
      }

      return "خطأ من السيرفر (${status})";
    }

    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return "انتهت مهلة الاتصال";
    }

    if (e.type == DioExceptionType.connectionError) {
      return "تحقق من اتصال الإنترنت";
    }

    return "حدث خطأ غير متوقع";
  }
}
