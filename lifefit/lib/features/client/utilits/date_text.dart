import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateText extends StatelessWidget {
  final String? value;
  final TextStyle? style;

  const DateText({super.key, required this.value, this.style});

  @override
  Widget build(BuildContext context) {
    // Format ISO date strings safely.
    final raw = value?.trim();
    if (raw == null || raw.isEmpty) {
      return Text('—', textAlign: TextAlign.left, style: style);
    }

    final parsed = DateTime.tryParse(raw);
    if (parsed == null) {
      return Text(raw, textAlign: TextAlign.left, style: style);
    }

    final formatted = DateFormat('dd/MM/yyyy', 'ar').format(parsed.toLocal());
    return Text(formatted, textAlign: TextAlign.left, style: style);
  }
}
