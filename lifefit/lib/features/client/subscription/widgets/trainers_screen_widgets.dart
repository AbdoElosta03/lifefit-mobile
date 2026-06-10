import 'package:flutter/material.dart';
import '../../../../core/ui/app_colors.dart';
import '../../../../core/models/subscription/expert_model.dart';

/// Stats Banner with aggregate numbers of experts and subscriptions.
class TrainersStatsBanner extends StatelessWidget {
  final List<ExpertModel> experts;

  const TrainersStatsBanner({super.key, required this.experts});

  @override
  Widget build(BuildContext context) {
    // Calculative logic for stats
    final subscribed = experts.where((e) => e.isSubscribed).length;
    final trainers = experts.where((e) => e.role == 'trainer').length;
    final nutritionists =
        experts.where((e) => e.role == 'nutritionist').length;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _BannerStat(
            label: 'مشترك',
            value: '$subscribed',
            icon: Icons.check_circle_outline,
          ),
          _vDivider(),
          _BannerStat(
            label: 'مدرب',
            value: '$trainers',
            icon: Icons.fitness_center,
          ),
          _vDivider(),
          _BannerStat(
            label: 'أخصائي',
            value: '$nutritionists',
            icon: Icons.restaurant_menu_outlined,
          ),
        ],
      ),
    );
  }

  static Widget _vDivider() => Container(
        height: 40,
        width: 1,
        color: Colors.white.withOpacity(0.3),
      );
}

class _BannerStat extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _BannerStat({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.white, size: 22),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}

/// Category filtering chips (All, Trainer, Nutritionist).
class TrainersFilterChips extends StatelessWidget {
  final String current;
  final void Function(String) onChanged;

  const TrainersFilterChips({
    super.key,
    required this.current,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        _chip('nutritionist', 'أخصائي تغذية', Icons.restaurant_menu_outlined),
        const SizedBox(width: 8),
        _chip('trainer', 'مدرب', Icons.fitness_center_outlined),
        const SizedBox(width: 8),
        _chip('all', 'الكل', Icons.people_outline),
      ],
    );
  }

  Widget _chip(String value, String label, IconData icon) {
    final selected = current == value;
    return GestureDetector(
      onTap: () => onChanged(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                  ),
                ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color:
                    selected ? Colors.white : const Color(0xFF64748B),
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              icon,
              size: 14,
              color: selected ? Colors.white : const Color(0xFF64748B),
            ),
          ],
        ),
      ),
    );
  }
}

/// View shown when no experts match the filter criteria.
class TrainersEmptyView extends StatelessWidget {
  const TrainersEmptyView({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(48),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.people_outline,
              size: 56,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'لا يوجد متخصصون',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'لا توجد نتائج للفئة المختارة.',
            style: TextStyle(fontSize: 13, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Error view with retry capability.
class TrainersErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const TrainersErrorView({
    super.key,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.wifi_off_rounded, size: 56, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'تعذّر التحميل',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: const TextStyle(fontSize: 13, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
              icon: const Icon(Icons.refresh),
              label: const Text(
                'إعادة المحاولة',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
