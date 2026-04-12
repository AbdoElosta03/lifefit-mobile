import 'exercise_log.dart';

class WorkoutLog {
  final int id;
  final int scheduleId;
  final String status;
  final bool trainerReviewed;
  final int? totalDurationSeconds;
  final String? notes;
  final List<ExerciseLog> exerciseLogs;

  const WorkoutLog({
    required this.id,
    required this.scheduleId,
    required this.status,
    this.trainerReviewed = false,
    this.totalDurationSeconds,
    this.notes,
    this.exerciseLogs = const [],
  });

  factory WorkoutLog.fromJson(Map<String, dynamic> json) {
    final logsJson = json['exercise_logs'];
    final logs = logsJson is List
        ? logsJson
            .whereType<Map>()
            .map((e) => ExerciseLog.fromJson(Map<String, dynamic>.from(e)))
            .toList()
        : <ExerciseLog>[];

    return WorkoutLog(
      id: (json['id'] as num?)?.toInt() ?? 0,
      scheduleId: (json['schedule_id'] as num?)?.toInt() ?? 0,
      status: (json['status'] ?? 'pending').toString(),
      trainerReviewed: json['trainer_reviewed'] == true,
      totalDurationSeconds: (json['total_duration_seconds'] as num?)?.toInt(),
      notes: json['notes']?.toString(),
      exerciseLogs: logs,
    );
  }

  bool hasLogForExercise(int exerciseId) {
    return exerciseLogs.any((log) => log.exerciseId == exerciseId);
  }
}
