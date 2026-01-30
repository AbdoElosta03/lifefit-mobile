import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/nutrition_day.dart';
import '../../../core/services/api_service.dart';

// 1. التعريف الآن أصبح AsyncNotifier
class NutritionNotifier extends AsyncNotifier<NutritionDay?> {
  final ApiService _apiService = ApiService();

  // 2. دالة build هي المسؤولة عن الحالة الابتدائية (Initial State)
  @override
  FutureOr<NutritionDay?> build() async {
    // سيقوم بجلب البيانات تلقائياً عند أول استخدام
    return _fetchData();
  }

  // دالة خاصة لجلب البيانات من السيرفر
  
  Future<NutritionDay?> _fetchData() async {
    final response = await _apiService.getTodayNutrition();

    if (response == null) {
      throw Exception('تعذر الاتصال بالسيرفر');
    }

    final statusCode = response.statusCode ?? 0;

    if (statusCode != 200) {
      final msg = (response.data is Map)
          ? (response.data['message'] ?? response.data['error'])
          : null;

      if (msg != null) {
        throw Exception('خطأ من السيرفر ($statusCode): $msg');
      }
      throw Exception('خطأ من السيرفر ($statusCode)');
    }
    // -------------------------------------------

    final status = (response.data is Map) ? response.data['status'] : null;

    if (status == 'success') {
      return NutritionDay.fromJson(response.data['data']);
    }

    if (status == 'empty') {
      return null;
    }

    throw Exception('خطأ غير معروف');
  }

  // 3. دالة لتحديث البيانات (مثل عمل Refresh)
  Future<void> refresh() async {
    state = const AsyncLoading(); // وضع الحالة في وضع التحميل
    state = await AsyncValue.guard(
      () => _fetchData(),
    ); // محاولة الجلب وتخزين النتيجة أو الخطأ
  }
}

// 4. تعريف الـ Provider الجديد
final nutritionProvider =
    AsyncNotifierProvider<NutritionNotifier, NutritionDay?>(() {
      return NutritionNotifier();
    });
