import 'workout.dart';
import 'workout_log.dart';

class TodaySchedule {
  final int scheduleId;
  final String status;
  final Workout workout;
  final WorkoutLog? workoutLog;

  const TodaySchedule({
    required this.scheduleId,
    required this.status,
    required this.workout,
    this.workoutLog,
  });

  bool get isCompleted => status == 'completed' || workoutLog != null;
  bool get isMissed => status == 'missed';
  bool get isScheduled => status == 'scheduled';

  bool isExerciseLogged(int exerciseId) {
    return workoutLog?.hasLogForExercise(exerciseId) ?? false;
  }

  factory TodaySchedule.fromJson(Map<String, dynamic> json) {
    final workoutJson = json['workout'];
    final logJson = json['workout_log'];

    return TodaySchedule(
      scheduleId: (json['schedule_id'] as num?)?.toInt() ?? 0,
      status: (json['status'] ?? 'scheduled').toString(),
      workout: workoutJson is Map<String, dynamic>
          ? Workout.fromJson(workoutJson)
          : Workout(id: 0, name: ''),
      workoutLog: logJson is Map<String, dynamic>
          ? WorkoutLog.fromJson(logJson)
          : null,
    );
  }

  TodaySchedule copyWithLog(WorkoutLog log) {
    return TodaySchedule(
      scheduleId: scheduleId,
      status: 'completed',
      workout: workout,
      workoutLog: log,
    );
  }
}
