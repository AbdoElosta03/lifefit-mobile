import 'package:dio/dio.dart';
import 'base_service.dart';
import '../models/nutrition/today_meals_response.dart';

class NutritionService extends BaseService {
  /// GET /api/client/today-meals
  Future<TodayMealsResponse> fetchTodayMeals() async {
    try {
      final response = await dio.get('client/today-meals');
      final data = response.data;
      if (data is Map<String, dynamic>) {
        return TodayMealsResponse.fromJson(data);
      }
      return const TodayMealsResponse(meals: []);
    } on DioException catch (e) {
      // 200 with empty data is still valid
      if (e.response?.statusCode == 200) {
        final data = e.response?.data;
        if (data is Map<String, dynamic>) {
          return TodayMealsResponse.fromJson(data);
        }
      }
      final msg = e.response?.data?['message'] ?? e.message;
      throw Exception('فشل تحميل وجبات اليوم: $msg');
    }
  }

  /// POST /api/client/intake-logs/single — log or skip a single meal
  Future<Map<String, dynamic>> logSingleMeal({
    required String logDate,
    required int scheduleId,
    required int mealId,
    required String mealType,
    required double actualWeightGrams,
    required double referenceWeightG,
    bool skipped = false,
  }) async {
    try {
      final response = await dio.post('client/intake-logs/single', data: {
        'log_date': logDate,
        'meal_plan_schedule_id': scheduleId,
        'meal_id': mealId,
        'meal_type': mealType,
        'actual_weight_grams': actualWeightGrams,
        'reference_weight_g': referenceWeightG,
        'skipped': skipped,
      });
      return response.data is Map<String, dynamic>
          ? response.data as Map<String, dynamic>
          : {};
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] ?? e.message;
      throw Exception('فشل تسجيل الوجبة: $msg');
    }
  }
}
