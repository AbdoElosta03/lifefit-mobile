// Translate gender to Arabic label.
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

// Display value or a dash.
String displayOrDash(Object? v) {
  if (v == null) return '—';
  final s = v.toString().trim();
  return s.isEmpty ? '—' : s;
}
