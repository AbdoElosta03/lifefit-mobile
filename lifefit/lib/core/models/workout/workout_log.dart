import 'exercise_log.dart';

/// Client session log for a scheduled workout, including per-set [exerciseLogs].
class WorkoutLog {
  final int id;
  final int scheduleId;
  final String status;
  final bool trainerReviewed;
  final int? actualDurationMinutes;
  final int? targetDurationMinutes;
  final String? notes;
  final List<ExerciseLog> exerciseLogs;

  const WorkoutLog({
    required this.id,
    required this.scheduleId,
    required this.status,
    this.trainerReviewed = false,
    this.actualDurationMinutes,
    this.targetDurationMinutes,
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
      actualDurationMinutes: _readMinutes(
        json['actual_duration_minutes'],
        json['total_duration_seconds'],
      ),
      targetDurationMinutes: (json['target_duration_minutes'] as num?)?.toInt(),
      notes: json['notes']?.toString(),
      exerciseLogs: logs,
    );
  }

  /// Prefers `actual_duration_minutes`; falls back to legacy `total_duration_seconds`.
  static int? _readMinutes(dynamic minutes, dynamic legacySeconds) {
    if (minutes != null) {
      if (minutes is int) return minutes;
      if (minutes is num) return minutes.toInt();
      return int.tryParse(minutes.toString());
    }
    if (legacySeconds == null) return null;
    final seconds = legacySeconds is num
        ? legacySeconds.toInt()
        : int.tryParse(legacySeconds.toString());
    if (seconds == null) return null;
    return (seconds / 60).ceil();
  }

  bool hasLogForExercise(int exerciseId) {
    return exerciseLogs.any((log) => log.exerciseId == exerciseId);
  }
}
