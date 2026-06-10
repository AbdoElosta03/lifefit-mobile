// Display helpers for ProfileScreen — no provider dependency.

/// Maps API gender code to Arabic UI label.
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

/// Returns em-dash when [v] is null or empty.
String displayOrDash(Object? v) {
  if (v == null) return '—';
  final s = v.toString().trim();
  return s.isEmpty ? '—' : s;
}
