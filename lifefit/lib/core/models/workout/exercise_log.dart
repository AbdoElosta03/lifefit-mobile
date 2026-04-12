class ExerciseLog {
  final int? id;
  final int exerciseId;
  final int setNumber;
  final int? targetReps;
  final int? actualReps;
  final double? targetWeight;
  final double? actualWeight;
  final String? intensityType;
  final int? targetPercentage;
  final int? actualPercentage;
  final int? targetDurationSeconds;
  final int? actualDurationSeconds;
  final int? rpeTarget;
  final int? rpe;
  final String? notes;

  const ExerciseLog({
    this.id,
    required this.exerciseId,
    required this.setNumber,
    this.targetReps,
    this.actualReps,
    this.targetWeight,
    this.actualWeight,
    this.intensityType,
    this.targetPercentage,
    this.actualPercentage,
    this.targetDurationSeconds,
    this.actualDurationSeconds,
    this.rpeTarget,
    this.rpe,
    this.notes,
  });

  factory ExerciseLog.fromJson(Map<String, dynamic> json) {
    return ExerciseLog(
      id: (json['id'] as num?)?.toInt(),
      exerciseId: (json['exercise_id'] as num?)?.toInt() ?? 0,
      setNumber: (json['set_number'] as num?)?.toInt() ?? 0,
      targetReps: (json['target_reps'] as num?)?.toInt(),
      actualReps: (json['actual_reps'] as num?)?.toInt(),
      targetWeight: _toDouble(json['target_weight']),
      actualWeight: _toDouble(json['actual_weight']),
      intensityType: json['intensity_type']?.toString(),
      targetPercentage: (json['target_percentage'] as num?)?.toInt(),
      actualPercentage: (json['actual_percentage'] as num?)?.toInt(),
      targetDurationSeconds: (json['target_duration_seconds'] as num?)?.toInt(),
      actualDurationSeconds: (json['actual_duration_seconds'] as num?)?.toInt(),
      rpeTarget: (json['rpe_target'] as num?)?.toInt(),
      rpe: (json['rpe'] as num?)?.toInt(),
      notes: json['notes']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'exercise_id': exerciseId,
        'set_number': setNumber,
        if (targetReps != null) 'target_reps': targetReps,
        if (actualReps != null) 'actual_reps': actualReps,
        if (targetWeight != null) 'target_weight': targetWeight,
        if (actualWeight != null) 'actual_weight': actualWeight,
        if (intensityType != null) 'intensity_type': intensityType,
        if (targetPercentage != null) 'target_percentage': targetPercentage,
        if (actualPercentage != null) 'actual_percentage': actualPercentage,
        if (targetDurationSeconds != null)
          'target_duration_seconds': targetDurationSeconds,
        if (actualDurationSeconds != null)
          'actual_duration_seconds': actualDurationSeconds,
        if (rpeTarget != null) 'rpe_target': rpeTarget,
        if (rpe != null) 'rpe': rpe,
        if (notes != null) 'notes': notes,
      };

  static double? _toDouble(dynamic v) {
    if (v == null) return null;
    if (v is double) return v;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString());
  }
}
