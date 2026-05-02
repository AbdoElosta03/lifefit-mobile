import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/models/workout/today_schedule.dart';
import '../../../../core/models/nutrition/today_meals_response.dart';
import '../../workouts/workout_provider.dart';
import '../../nutrition/nutrition_provider.dart';
import '../../home/client_home_provider.dart';

/// Two side-by-side compact cards: today's workout status + today's nutrition.
class TodayActivityRow extends ConsumerWidget {
  const TodayActivityRow({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workoutsAsync = ref.watch(todaySchedulesProvider);
    final nutritionAsync = ref.watch(nutritionProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: workoutsAsync.when(
              loading: () => _ActivityCard.loading(
                icon: Icons.fitness_center_rounded,
                color: const Color(0xFF00D9D9),
                label: 'تمرين اليوم',
              ),
              error: (_, __) => _ActivityCard.empty(
                icon: Icons.fitness_center_rounded,
                color: const Color(0xFF00D9D9),
                label: 'تمرين اليوم',
                sub: 'لا يوجد',
              ),
              data: (schedules) => _WorkoutCard(schedules: schedules),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: nutritionAsync.when(
              loading: () => _ActivityCard.loading(
                icon: Icons.restaurant_rounded,
                color: const Color(0xFF3ABEF9),
                label: 'التغذية',
              ),
              error: (_, __) => _ActivityCard.empty(
                icon: Icons.restaurant_rounded,
                color: const Color(0xFF3ABEF9),
                label: 'التغذية',
                sub: 'لا توجد بيانات',
              ),
              data: (data) => _NutritionCard(data: data),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────
// Workout mini-card
// ─────────────────────────────────────────

class _WorkoutCard extends ConsumerWidget {
  final List<TodaySchedule> schedules;
  const _WorkoutCard({required this.schedules});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (schedules.isEmpty) {
      return _ActivityCard.empty(
        icon: Icons.self_improvement_rounded,
        color: const Color(0xFF00D9D9),
        label: 'تمرين اليوم',
        sub: 'يوم راحة',
      );
    }

    final first = schedules.first;
    final total = first.workout.exercises.length;
    final done = first.workoutLog?.exerciseLogs.length ?? 0;
    final progress = total > 0 ? done / total : 0.0;
    final isCompleted = first.isCompleted;

    return _ActivityCard(
      icon: isCompleted ? Icons.check_circle_rounded : Icons.fitness_center_rounded,
      color: const Color(0xFF00D9D9),
      label: 'تمرين اليوم',
      value: isCompleted ? 'مكتمل ✓' : '$done/$total',
      sub: first.workout.name,
      progress: progress,
      onTap: () => ref.read(clientHomeProvider.notifier).changeTab(1),
    );
  }
}

// ─────────────────────────────────────────
// Nutrition mini-card
// ─────────────────────────────────────────

class _NutritionCard extends ConsumerWidget {
  final TodayMealsResponse data;
  const _NutritionCard({required this.data});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (data.meals.isEmpty) {
      return _ActivityCard.empty(
        icon: Icons.restaurant_outlined,
        color: const Color(0xFF3ABEF9),
        label: 'التغذية',
        sub: 'لا توجد وجبات',
      );
    }

    final consumed = data.totalConsumedCalories;
    final target = data.totalTargetCalories;
    final progress = target > 0 ? (consumed / target).clamp(0.0, 1.0) : 0.0;
    final eatenCount = data.meals.where((m) => m.isEaten).length;
    final totalCount = data.meals.length;

    return _ActivityCard(
      icon: Icons.restaurant_rounded,
      color: const Color(0xFF3ABEF9),
      label: 'التغذية',
      value: '${consumed.toStringAsFixed(0)} سعرة',
      sub: 'من ${target.toStringAsFixed(0)} | $eatenCount/$totalCount وجبة',
      progress: progress,
      onTap: () => ref.read(clientHomeProvider.notifier).changeTab(2),
    );
  }
}

// ─────────────────────────────────────────
// Generic activity card
// ─────────────────────────────────────────

class _ActivityCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final String? value;
  final String? sub;
  final double? progress;
  final VoidCallback? onTap;
  final bool isLoading;

  const _ActivityCard({
    required this.icon,
    required this.color,
    required this.label,
    this.value,
    this.sub,
    this.progress,
    this.onTap,
    this.isLoading = false,
  });

  factory _ActivityCard.loading({
    required IconData icon,
    required Color color,
    required String label,
  }) =>
      _ActivityCard(icon: icon, color: color, label: label, isLoading: true);

  factory _ActivityCard.empty({
    required IconData icon,
    required Color color,
    required String label,
    required String sub,
  }) =>
      _ActivityCard(icon: icon, color: color, label: label, sub: sub, value: '—');

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: color, size: 18),
                ),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (isLoading)
              const SizedBox(
                height: 20,
                child: Center(
                  child: SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              )
            else ...[
              Text(
                value ?? '—',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: value == 'مكتمل ✓' ? Colors.green : const Color(0xFF1E293B),
                ),
                textAlign: TextAlign.right,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (sub != null) ...[
                const SizedBox(height: 2),
                Text(
                  sub!,
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                  textAlign: TextAlign.right,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
            if (progress != null) ...[
              const SizedBox(height: 10),
              LinearProgressIndicator(
                value: progress,
                minHeight: 5,
                borderRadius: BorderRadius.circular(8),
                backgroundColor: color.withOpacity(0.1),
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
