import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/workout.dart';
import '../../../core/services/api_service.dart';



class WorkoutNotifier extends StateNotifier<AsyncValue<Workout?>> {
  final ApiService _apiService = ApiService();

  // البداية تكون حالة تحميل
  WorkoutNotifier() : super(const AsyncValue.loading()) {
    fetchTodayWorkout();
  }

  Future<void> fetchTodayWorkout() async {
    state = const AsyncValue.loading();

    try {
      final response = await _apiService.getTodayWorkouts();

      if (response != null && response.statusCode == 200) {
        if (response.data['status'] == 'success') {
          // جلب البيانات بنجاح
          final workout = Workout.fromJson(response.data['data']);
          state = AsyncValue.data(workout);
        } else {
          // في حال لا توجد بيانات (يوم راحة)
          state = const AsyncValue.data(null);
        }
      } else {
        state = AsyncValue.error("تعذر جلب التمارين من السيرفر", StackTrace.current);
      }
    } catch (e, stack) {
      state = AsyncValue.error(e.toString(), stack);
    }
  }

  Future<void> refresh() async {
    await fetchTodayWorkout();
  }

  Future<void> saveWorkoutLog(Map<String, dynamic> workoutLogData) async {
    try {
      final response = await _apiService.saveWorkoutLog(workoutLogData);
      if (response != null && response.statusCode == 200) {
        print("تم حفظ سجل التمرين بنجاح");
        await refresh(); // تحديث القائمة بعد الحفظ
      }
    } catch (e) {
      print("فشل في حفظ سجل التمرين: $e");
    }
  }
}

// 2. تأكد أن النوع هنا هو AsyncValue<Workout?> ليتطابق مع الـ Notifier
final workoutProvider = StateNotifierProvider<WorkoutNotifier, AsyncValue<Workout?>>((ref) {
  return WorkoutNotifier();
});