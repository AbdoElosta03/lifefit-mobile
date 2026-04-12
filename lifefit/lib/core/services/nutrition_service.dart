import 'package:dio/dio.dart';
import 'base_service.dart';

class NutritionService extends BaseService {
  Future<Response> getTodayNutrition() async {
    try {
      return await dio.get("client/app-today-nutrition");
    } on DioException catch (e) {
      // لو السيرفر رجّع error (مثلاً 500 أو 404)
      if (e.response != null) {
        return e.response!;
      }

      // لو المشكلة شبكة (مافيش اتصال)
      throw Exception("Network error: ${e.message}");
    }
  }

  Future<Response> saveDailyIntakeMealLog({
    String? logDate,
    required int mealId,
    required List<Map<String, dynamic>> items,
  }) async {
    try {
      return await dio.post(
        "client/app-daily-intake-logs",
        data: {
          if (logDate != null) 'log_date': logDate,
          'meal_id': mealId,
          'items': items,
        },
      );
    } on DioException catch (e) {
      if (e.response != null) {
        return e.response!;
      }

      throw Exception("Network error: ${e.message}");
    }
  }
}