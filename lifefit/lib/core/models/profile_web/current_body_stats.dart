class CurrentBodyStats {
  final double? weightKg;
  final double? bodyFatPct;
  final double? muscleMassKg;
  final String? recordedAt;

  const CurrentBodyStats({
    this.weightKg,
    this.bodyFatPct,
    this.muscleMassKg,
    this.recordedAt,
  });

  factory CurrentBodyStats.fromJson(Map<String, dynamic> json) {
    return CurrentBodyStats(
      weightKg: _toDouble(json['weight_kg']),
      bodyFatPct: _toDouble(json['body_fat_pct']),
      muscleMassKg: _toDouble(json['muscle_mass_kg']),
      recordedAt: json['recorded_at']?.toString(),
    );
  }

  static double? _toDouble(dynamic v) {
    if (v == null) return null;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString());
  }
}
