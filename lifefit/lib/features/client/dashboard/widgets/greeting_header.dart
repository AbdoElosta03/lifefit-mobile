import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/models/user.dart';

class GreetingHeader extends StatelessWidget {
  final User? user;
  const GreetingHeader({super.key, this.user});

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'صباح الخير';
    if (hour < 17) return 'مرحباً';
    return 'مساء الخير';
  }

  String get _formattedDate =>
      DateFormat('EEEE، d MMMM yyyy', 'ar').format(DateTime.now());

  String get _motivationalLine {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'ابدأ يومك بقوة وتركيز 💪';
    if (hour < 17) return 'واصل تقدمك نحو هدفك 🎯';
    return 'أنهِ يومك بنشاط وتحدٍّ 🔥';
  }

  @override
  Widget build(BuildContext context) {
    final firstName = user?.name.split(' ').first ?? '...';

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            _formattedDate,
            style: const TextStyle(fontSize: 13, color: Colors.grey),
          ),
          const SizedBox(height: 6),
          Text(
            '$_greeting، $firstName!',
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _motivationalLine,
            style: const TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
