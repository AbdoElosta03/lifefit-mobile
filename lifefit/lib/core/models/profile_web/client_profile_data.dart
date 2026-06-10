/// Editable fitness profile fields from `/api/client/profile` → `profile`.
class ClientProfileData {
  final double? heightCm;
  final double? targetWeightKg;
  final String? goalNotes;
  final String? birthDate;
  final String? gender;

  const ClientProfileData({
    this.heightCm,
    this.targetWeightKg,
    this.goalNotes,
    this.birthDate,
    this.gender,
  });

  factory ClientProfileData.fromJson(Map<String, dynamic> json) {
    return ClientProfileData(
      heightCm: _toDouble(json['height_cm']),
      targetWeightKg: _toDouble(json['target_weight_kg']),
      goalNotes: json['goal_notes']?.toString(),
      birthDate: json['birth_date']?.toString(),
      gender: json['gender']?.toString(),
    );
  }

  static double? _toDouble(dynamic v) {
    if (v == null) return null;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString());
  }
}
