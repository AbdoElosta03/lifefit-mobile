import 'package:dio/dio.dart';
import '../auth/token_storage.dart';

class BaseService {
  final String baseUrl = "http://127.0.0.1:8000/api/";
  late Dio dio;

  BaseService() {
    dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      headers: {
        "Accept": "application/json",
      },
    ));

    // إضافة Interceptor لإدراج التوكن تلقائياً في كل طلب
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await TokenStorage.getToken();
        if (token != null) {
          options.headers["Authorization"] = "Bearer $token";
        }
        return handler.next(options);
      },
      onError: (DioException e, handler) {
        // معالجة مركزية للأخطاء
        print("API Error [${e.response?.statusCode}]: ${e.message}");
        return handler.next(e);
      },
    ));
  }
}
