import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/workout/today_schedule.dart';
import '../../../core/models/workout/exercise_log.dart';
import '../../../core/services/workout_service.dart';

/// Manages the state and operations for today's workout schedules.
class TodaySchedulesNotifier
    extends StateNotifier<AsyncValue<List<TodaySchedule>>> {
  final WorkoutService _service;

  TodaySchedulesNotifier(this._service) : super(const AsyncValue.loading()) {
    fetch();
  }

  /// Fetches today's schedules from the backend.
  Future<void> fetch() async {
    state = const AsyncValue.loading();
    try {
      final schedules = await _service.fetchTodaySchedules();
      state = AsyncValue.data(schedules);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  /// Reloads schedules.
  Future<void> refresh() => fetch();

  /// Saves workout logs for a specific schedule and updates local state.
  Future<bool> saveWorkoutLog({
    required int scheduleId,
    required List<ExerciseLog> exerciseLogs,
    int? actualDurationMinutes,
    String? notes,
  }) async {
    try {
      final updated = await _service.saveWorkoutLog(
        scheduleId: scheduleId,
        exerciseLogs: exerciseLogs,
        actualDurationMinutes: actualDurationMinutes,
        notes: notes,
      );

      state.whenData((schedules) {
        final newList = schedules.map((s) {
          if (s.scheduleId != updated.scheduleId) return s;
          // The API response does not load workout.exercises, so we preserve
          // the original workout (with exercises) and only patch status + log.
          return TodaySchedule(
            scheduleId: s.scheduleId,
            status: updated.status,
            workout: s.workout,
            workoutLog: updated.workoutLog,
          );
        }).toList();
        state = AsyncValue.data(newList);
      });

      return true;
    } catch (e) {
      return false;
    }
  }
}

/// Provider to access the TodaySchedulesNotifier and its state.
final todaySchedulesProvider = StateNotifierProvider<TodaySchedulesNotifier,
    AsyncValue<List<TodaySchedule>>>((ref) {
  return TodaySchedulesNotifier(WorkoutService());
});
