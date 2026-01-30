import 'package:dio/dio.dart';
import '../auth/token_storage.dart';

class ApiService {
  final String _baseUrl = "http://127.0.0.1:8000/api/";
  final Dio _dio = Dio();

  Future<Response> login(String email, String password) async {
    final response = await _dio.post(
      "${_baseUrl}login",
      data: {"email": email, "password": password},
      options: Options(headers: {"Accept": "application/json"}),
    );

    // يعتمد على هيكلة الـ API: نحاول أولاً access_token ثم token لو كان الاسم مختلفاً
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
    final response = await _dio.post(
      "${_baseUrl}register",
      data: {
        "name": name,
        "email": email,
        "password": password,
        "password_confirmation": password,
        "role": role,
      },
      options: Options(headers: {"Accept": "application/json"}),
    );

    final token = response.data['access_token'] ?? response.data['token'];
    if (token != null) {
      await TokenStorage.saveToken(token);
    }

    return response;
  }

  Future<Response?> getTodayWorkouts() async {
    try {
      final token = await TokenStorage.getToken();
      if (token == null) return null;

      return await _dio.get(
        "${_baseUrl}client/today-workouts",
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
            "Accept": "application/json",
          },
        ),
      );
    } catch (e) {
      print("Error fetching workouts: $e");
      return null;
    }
  }

  Future<Response?> getTodayNutrition() async {
    try {
      final token = await TokenStorage.getToken();
      if (token == null) return null;

      //get request from today-nutrition endpoint
      return await _dio.get(
        "${_baseUrl}client/today-nutrition",
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
            "Accept": "application/json",
          },
        ),
      );
    } catch (e) {
      print("Error fetching nutrition: $e");
      return null;
    }
  }

  Future<Response?> getHealthProfile() async {
    try {
      final token = await TokenStorage.getToken();
      if (token == null) return null;

      return await _dio.get(
        "${_baseUrl}client/health-profile",
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
            "Accept": "application/json",
          },
        ),
      );
    } catch (e) {
      print("Error fetching health profile: $e");
      return null;
    }
  }

  Future<Response?> saveHealthProfile(Map<String, dynamic> body) async {
    try {
      final token = await TokenStorage.getToken();
      if (token == null) return null;

      return await _dio.post(
        "${_baseUrl}client/health-profile",
        data: body,
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
            "Accept": "application/json",
          },
        ),
      );
    } catch (e) {
      print("Error saving health profile: $e");
      return null;
    }
  }

  Future<Response?> saveWorkoutLog(Map<String, dynamic> body) async {
    try {
      final token = await TokenStorage.getToken();
      if (token == null) return null;

      return await _dio.post(
        "${_baseUrl}client/workout-logs",
        data: body,
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
            "Accept": "application/json",
          },
        ),
      );
    } catch (e) {
      print("Error saving workout log: $e");
      return null;
    }
  }

  Future<Response?> saveDailyIntakeMealLog({
    String? logDate,
    required int mealId,
    required List<Map<String, dynamic>> items,
  }) async {
    try {
      final token = await TokenStorage.getToken();
      if (token == null) return null;

      return await _dio.post(
        "${_baseUrl}client/daily-intake-logs",
        data: {
          if (logDate != null) 'log_date': logDate,
          'meal_id': mealId,
          'items': items,
        },
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
            "Accept": "application/json",
          },
        ),
      );
    } on DioException catch (e) {
      if (e.response != null) return e.response;
      print("Error saving daily intake log: ${e.message}");
      return null;
    } catch (e) {
      print("Error saving daily intake log: $e");
      return null;
    }
  }

  // method to get notifications
  Future<Response?> getNotifications() async {
    try {
      final token = await TokenStorage.getToken();
      if (token == null) return null;

      return await _dio.get(
        "${_baseUrl}client/notifications",
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
            "Accept": "application/json",
          },
        ),
      );
    } on DioException catch (e) {
      if (e.response != null) return e.response;
      print("Error fetching notifications: ${e.message}");
      return null;
    } catch (e) {
      print("Error fetching notifications: $e");
      return null;
    }
  }

  Future<Response?> markNotificationAsRead(String id) async {
    try {
      final token = await TokenStorage.getToken();
      if (token == null) return null;

      return await _dio.post(
        "${_baseUrl}client/notifications/$id/read",
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
            "Accept": "application/json",
          },
        ),
      );
    } on DioException catch (e) {
      if (e.response != null) return e.response;
      print("Error marking notification as read: ${e.message}");
      return null;
    } catch (e) {
      print("Error marking notification as read: $e");
      return null;
    }
  }
  //method to get subscriptions
  Future<Response?> getSubscriptions() async {
    try {
      final token = await TokenStorage.getToken();
      if (token == null) return null;

      return await _dio.get(
        "${_baseUrl}client/subscriptions",
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
            "Accept": "application/json",
          },
        ),
      );
    } on DioException catch (e) {
      if (e.response != null) return e.response;
      print("Error fetching subscriptions: ${e.message}");
      return null;
    } catch (e) {
      print("Error fetching subscriptions: $e");
      return null;
    }
  }
  //method to cancel subscription
  Future<Response?> cancelSubscription(String id) async {
    try {
      final token = await TokenStorage.getToken();
      if (token == null) return null;

      return await _dio.post(
        "${_baseUrl}client/subscriptions/$id/cancel",
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
            "Accept": "application/json",
          },
        ),
      );
    } on DioException catch (e) {
      if (e.response != null) return e.response;
      print("Error cancelling subscription: ${e.message}");
      return null;
    } catch (e) {
      print("Error cancelling subscription: $e");
      return null;
    }
  }
}