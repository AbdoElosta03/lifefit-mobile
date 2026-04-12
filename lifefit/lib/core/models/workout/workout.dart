import 'exercise.dart';

class Workout {
  final int id;
  final String name;
  final String? description;
  final int? estimatedDuration;
  final String? difficulty;
  final String? type;
  final List<Exercise> exercises;

  const Workout({
    required this.id,
    required this.name,
    this.description,
    this.estimatedDuration,
    this.difficulty,
    this.type,
    this.exercises = const [],
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
      name: (json['name'] ?? '').toString(),
      description: json['description']?.toString(),
      estimatedDuration: (json['estimated_duration'] as num?)?.toInt(),
      difficulty: json['difficulty']?.toString(),
      type: json['type']?.toString(),
      exercises: exercises,
    );
  }
}
