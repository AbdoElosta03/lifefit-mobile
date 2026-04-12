import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/workout/today_schedule.dart';
import '../../../core/models/workout/exercise_log.dart';
import '../../../core/services/workout_service.dart';

class TodaySchedulesNotifier
    extends StateNotifier<AsyncValue<List<TodaySchedule>>> {
  final WorkoutService _service;

  TodaySchedulesNotifier(this._service) : super(const AsyncValue.loading()) {
    fetch();
  }

  Future<void> fetch() async {
    state = const AsyncValue.loading();
    try {
      final schedules = await _service.fetchTodaySchedules();
      state = AsyncValue.data(schedules);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> refresh() => fetch();

  Future<bool> saveWorkoutLog({
    required int scheduleId,
    required List<ExerciseLog> exerciseLogs,
    int? totalDurationSeconds,
    String? notes,
  }) async {
    try {
      final updated = await _service.saveWorkoutLog(
        scheduleId: scheduleId,
        exerciseLogs: exerciseLogs,
        totalDurationSeconds: totalDurationSeconds,
        notes: notes,
      );

      state.whenData((schedules) {
        final newList = schedules.map((s) {
          return s.scheduleId == updated.scheduleId ? updated : s;
        }).toList();
        state = AsyncValue.data(newList);
      });

      return true;
    } catch (e) {
      return false;
    }
  }
}

final todaySchedulesProvider = StateNotifierProvider<TodaySchedulesNotifier,
    AsyncValue<List<TodaySchedule>>>((ref) {
  return TodaySchedulesNotifier(WorkoutService());
});
