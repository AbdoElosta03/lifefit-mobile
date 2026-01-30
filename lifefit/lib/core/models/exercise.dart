class Exercise {
  final int id;
  final String name;
  final int sets;
  final String reps;
  final double? targetWeight;
  final int? restSeconds;
  final String status;

  Exercise({
    required this.name,
    required this.sets,
    required this.reps,
    this.targetWeight,
    this.restSeconds,
    required this.id,
    required this.status,
  });

  factory Exercise.fromJson(Map<String, dynamic> json) {
    final pivotRaw = json['pivot'];
    final pivot = pivotRaw is Map ? Map<String, dynamic>.from(pivotRaw) : null;
    final bool isCompleted = json['is_completed'] ?? false;
    final setsRaw = pivot?['sets'] ?? json['sets'] ?? 0;
    final repsRaw = pivot?['reps'] ?? json['reps'] ?? '0';
    final targetWeightRaw = pivot?['target_weight'] ?? json['target_weight'];
    final restSecondsRaw = pivot?['rest_seconds'] ?? json['rest_seconds'];

    return Exercise(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: (json['name'] ?? '').toString(),
      status: isCompleted ? 'completed' : 'pending',
      sets: setsRaw is num ? setsRaw.toInt() : int.tryParse(setsRaw.toString()) ?? 0,
      reps: repsRaw.toString(),
      targetWeight: targetWeightRaw == null
          ? null
          : (targetWeightRaw is num
              ? targetWeightRaw.toDouble()
              : double.tryParse(targetWeightRaw.toString())),
      restSeconds: restSecondsRaw == null
          ? null
          : (restSecondsRaw is num
              ? restSecondsRaw.toInt()
              : int.tryParse(restSecondsRaw.toString())),
    );
  }
}
