import 'package:flutter/material.dart';
import '../../../../core/ui/app_colors.dart';
import '../../../../core/models/programs/program_assignment_summary.dart';

/// Stats Banner displaying program assignment overview.
class ProgramsStatsBanner extends StatelessWidget {
  final List<ProgramAssignmentSummary> programs;
  
  const ProgramsStatsBanner({super.key, required this.programs});

  @override
  Widget build(BuildContext context) {
    final total = programs.length;
    final active =
        programs.where((p) => p.status?.toLowerCase() == 'active').length;
    final completed =
        programs.where((p) => p.status?.toLowerCase() == 'completed').length;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.28),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Icon(Icons.sports_gymnastics,
                  color: Colors.white, size: 36),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'البرامج النشطة',
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.85), fontSize: 13),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$active برنامج',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Progress indicator for active programs relative to total
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: LinearProgressIndicator(
              value: total > 0 ? active / total : 0,
              minHeight: 8,
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              backgroundColor: Colors.white.withOpacity(0.25),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'مكتمل: $completed',
                style: TextStyle(
                    color: Colors.white.withOpacity(0.8), fontSize: 12),
              ),
              Text(
                'الإجمالي: $total',
                style: TextStyle(
                    color: Colors.white.withOpacity(0.8), fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
