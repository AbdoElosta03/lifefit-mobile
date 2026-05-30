import 'package:flutter/material.dart';
import '../../../core/ui/app_colors.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'goals_section.dart';
import 'measurements_section.dart';
import 'personal_records_preview_section.dart';

class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Screen scaffold for overall progress.
    return Scaffold(
      backgroundColor: AppColors.background,
      // Scrollable content.
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Section label.
            const Text(
              'التقدم',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
            // Main title.
            const Text(
              'تتبع إنجازاتك',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 22),
            // Goals widget section.
            const GoalsSection(),
            const SizedBox(height: 22),
            // Measurements widget section.
            const MeasurementsSection(),
            const SizedBox(height: 22),
            // Personal records preview widget.
            const PersonalRecordsPreviewSection(),
          ],
        ),
      ),
    );
  }
}
