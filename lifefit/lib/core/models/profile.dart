/// Lightweight client profile fields (legacy shape; see [ClientProfileData] for the full API).
class Profile {
  final int? age;
  final double? heightCm;
  final double? targetWeightKg;
  final String? goalNotes;
  // final String? birthDate;

  Profile({
    this.age,
    this.heightCm,
    this.targetWeightKg,
    this.goalNotes,
    // this.birthDate,
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      age: json['age'] as int?,
    //  birthDate: json['birth_date'] as String?,
      heightCm: _toDouble(json['height_cm']),
      targetWeightKg: _toDouble(json['target_weight_kg']),
      goalNotes: json['goal_notes'] as String?,
    );
  }
}

/// Accepts int, double, or numeric string from JSON.
double? _toDouble(dynamic v) {
  if (v == null) return null;
  if (v is num) return v.toDouble();
  return double.tryParse(v.toString());
}
