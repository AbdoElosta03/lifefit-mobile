class HealthProfile {
  final int? age;
  final double? heightCm;
  final double? targetWeightKg;
  final String? goalNotes;
  final String? activityLevel;
  final String? birthDate;

  HealthProfile({
    this.age,
    this.heightCm,
    this.targetWeightKg,
    this.goalNotes,
    this.activityLevel,
    this.birthDate,
  });

  factory HealthProfile.fromJson(Map<String, dynamic> json) {
    return HealthProfile(
      age: json['age'] as int?,
      birthDate: json['birth_date'] as String?,
      heightCm: _toDouble(json['height_cm']),
      targetWeightKg: _toDouble(json['target_weight_kg']),
      goalNotes: json['goal_notes'] as String?,
      activityLevel: json['current_activity_level'] as String?,
    );
  }
}

double? _toDouble(dynamic v) {
  if (v == null) return null;
  if (v is num) return v.toDouble();
  return double.tryParse(v.toString());
}
