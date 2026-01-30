import 'exercise.dart';
class Workout {
  final int id;
  final int? scheduleId;
  final String title;
  final int? estimatedDurationMinutes;
  final List<Exercise> exercises;

  Workout({
    required this.id,
    this.scheduleId,
    required this.title,
    this.estimatedDurationMinutes,
    required this.exercises,
  });

  factory Workout.fromJson(Map<String, dynamic> json) {
    final exercisesJson = json['exercises'];
    final exercises = exercisesJson is List
        ? exercisesJson
            .whereType<Map>()
            .map((e) => Exercise.fromJson(Map<String, dynamic>.from(e)))
            .toList()
        : <Exercise>[];

    return Workout(
      id: (json['id'] as num?)?.toInt() ?? 0,
      // Backend endpoint /client/today-workouts returns WorkoutResource directly (no schedule_id).
      scheduleId: (json['schedule_id'] as num?)?.toInt(),
      // Backend uses "name" for workout title.
      title: (json['name'] ?? json['title'] ?? '').toString(),
      // Backend uses "estimated_duration" (minutes) while older code expected "estimated_duration_minutes".
      estimatedDurationMinutes:
          (json['estimated_duration_minutes'] as num?)?.toInt() ??
          (json['estimated_duration'] as num?)?.toInt(),
      exercises: exercises,
    );
  }
}