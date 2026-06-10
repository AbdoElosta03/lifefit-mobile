import 'package:flutter/material.dart';
import '../../../../core/ui/app_colors.dart';

/// Standard empty state view for programs.
class ProgramEmptyView extends StatelessWidget {
  const ProgramEmptyView({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.fitness_center_outlined,
                size: 64,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'لا توجد برامج بعد',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'لم يتم تخصيص برامج تدريبية لك بعد.\nتواصل مع المدرّب الخاص بك.',
              style: TextStyle(fontSize: 14, color: Colors.grey, height: 1.6),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
