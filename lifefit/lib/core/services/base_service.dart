import 'package:dio/dio.dart';
import '../auth/token_storage.dart';
import '../config/server_config.dart';

/// Shared HTTP client for all Laravel API services.
/// Configures Dio with the base URL and auto-injects the Bearer token.
class BaseService {
  final String baseUrl = ServerConfig.apiBaseUrl;
  late Dio dio;

  BaseService() {
    dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      headers: {
        "Accept": "application/json",
      },
    ));

    // Attach Bearer token from secure storage on every request.
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await TokenStorage.getToken();
        if (token != null) {
          options.headers["Authorization"] = "Bearer $token";
        }
        return handler.next(options);
      },
      onError: (DioException e, handler) {
        // Centralized error logging; callers handle user-facing messages.
        print("API Error [${e.response?.statusCode}]: ${e.message}");
        return handler.next(e);
      },
    ));
  }
}
