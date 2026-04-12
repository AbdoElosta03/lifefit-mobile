String translateActivityLevel(String? level) {
  if (level == null || level.isEmpty) return 'غير محدد';
  switch (level.toLowerCase()) {
    case 'sedentary':
      return 'خامل';
    case 'low':
      return 'منخفض';
    case 'moderate':
      return 'متوسط';
    case 'active':
      return 'نشط';
    case 'athlete':
      return 'رياضي';
    default:
      return level;
  }
}

String translateGender(String? g) {
  if (g == null || g.isEmpty) return 'غير محدد';
  switch (g.toLowerCase()) {
    case 'male':
      return 'ذكر';
    case 'female':
      return 'أنثى';
    default:
      return g;
  }
}

String displayOrDash(Object? v) {
  if (v == null) return '—';
  final s = v.toString().trim();
  return s.isEmpty ? '—' : s;
}
