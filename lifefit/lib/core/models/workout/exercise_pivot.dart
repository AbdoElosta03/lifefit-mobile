class ExercisePivot {
  final int sets;
  final String reps;
  final double? targetWeight;
  final String? intensityType;
  final int? targetPercentage;
  final int? targetDurationSeconds;
  final int? rpeTarget;
  final int? restSeconds;
  final String? tempo;
  final String? notes;
  final int? order;

  const ExercisePivot({
    required this.sets,
    required this.reps,
    this.targetWeight,
    this.intensityType,
    this.targetPercentage,
    this.targetDurationSeconds,
    this.rpeTarget,
    this.restSeconds,
    this.tempo,
    this.notes,
    this.order,
  });

  factory ExercisePivot.fromJson(Map<String, dynamic> json) {
    return ExercisePivot(
      sets: _toInt(json['sets']) ?? 0,
      reps: (json['reps'] ?? '0').toString(),
      targetWeight: _toDouble(json['target_weight']),
      intensityType: json['intensity_type']?.toString(),
      targetPercentage: _toInt(json['target_percentage']),
      targetDurationSeconds: _toInt(json['target_duration_seconds']),
      rpeTarget: _toInt(json['rpe_target']),
      restSeconds: _toInt(json['rest_seconds']),
      tempo: json['tempo']?.toString(),
      notes: json['notes']?.toString(),
      order: _toInt(json['order']),
    );
  }

  Map<String, dynamic> toJson() => {
        'sets': sets,
        'reps': reps,
        'target_weight': targetWeight,
        'intensity_type': intensityType,
        'target_percentage': targetPercentage,
        'target_duration_seconds': targetDurationSeconds,
        'rpe_target': rpeTarget,
        'rest_seconds': restSeconds,
        'tempo': tempo,
        'notes': notes,
        'order': order,
      };

  static int? _toInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse(v.toString());
  }

  static double? _toDouble(dynamic v) {
    if (v == null) return null;
    if (v is double) return v;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString());
  }
}
