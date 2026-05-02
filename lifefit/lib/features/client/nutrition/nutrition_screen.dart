import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/models/nutrition/meal_schedule.dart';
import '../../../core/models/nutrition/today_meals_response.dart';
import 'nutrition_provider.dart';
import 'widgets/macros_summary_card.dart';
import 'widgets/meal_card.dart';
import 'log_meal_sheet.dart';

class NutritionScreen extends ConsumerWidget {
  const NutritionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(nutritionProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: state.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: Color(0xFF00D9D9)),
        ),
        error: (err, _) => _ErrorView(
          message: err.toString().replaceFirst('Exception: ', ''),
          onRetry: () => ref.read(nutritionProvider.notifier).refresh(),
        ),
        data: (data) => data.meals.isEmpty
            ? _EmptyView(onRefresh: () => ref.read(nutritionProvider.notifier).refresh())
            : _MealsList(data: data),
      ),
    );
  }
}

// ─────────────────────────────────────────
// Main meals list
// ─────────────────────────────────────────

class _MealsList extends ConsumerWidget {
  final TodayMealsResponse data;
  const _MealsList({required this.data});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final today = DateFormat('EEEE، d MMMM', 'ar').format(DateTime.now());
    // Group meals by type, preserving meal_order within each group
    final grouped = <String, List<MealSchedule>>{};
    final sortedMeals = [...data.meals]..sort((a, b) {
        final typeOrder = _typeOrder(a.mealType) - _typeOrder(b.mealType);
        if (typeOrder != 0) return typeOrder;
        return a.mealOrder - b.mealOrder;
      });

    for (final m in sortedMeals) {
      grouped.putIfAbsent(m.mealType, () => []).add(m);
    }

    return RefreshIndicator(
      color: const Color(0xFF00D9D9),
      onRefresh: () => ref.read(nutritionProvider.notifier).refresh(),
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          // Header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    'خطتي الغذائية',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        today,
                        style: const TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                      if (data.planName != null) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFF00D9D9).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            data.planName!,
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFF00D9D9),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Macros summary
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
              child: MacrosSummaryCard(data: data),
            ),
          ),

          // Meals grouped by type
          for (final entry in grouped.entries) ...[
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
                child: _SectionHeader(mealType: entry.key, meals: entry.value),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (_, i) {
                    final schedule = entry.value[i];
                    return MealCard(
                      schedule: schedule,
                      onTap: () => LogMealSheet.show(context, schedule),
                      onLog: () => LogMealSheet.show(context, schedule),
                      onSkip: () => _confirmSkip(context, ref, schedule),
                    );
                  },
                  childCount: entry.value.length,
                ),
              ),
            ),
          ],

          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }

  int _typeOrder(String type) {
    const order = {'breakfast': 0, 'lunch': 1, 'dinner': 2, 'snack': 3};
    return order[type] ?? 4;
  }

  Future<void> _confirmSkip(
    BuildContext context,
    WidgetRef ref,
    MealSchedule schedule,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text('تخطى الوجبة', textAlign: TextAlign.right),
        content: Text(
          'هل تريد تخطي وجبة "${schedule.meal?.name}"؟',
          textAlign: TextAlign.right,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('تخطى', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true && schedule.meal != null) {
      ref.read(nutritionProvider.notifier).skipMeal(
            scheduleId: schedule.scheduleId,
            mealId: schedule.meal!.id,
            mealType: schedule.mealType,
            referenceWeightG: schedule.referenceWeightG,
          );
    }
  }
}

// ─────────────────────────────────────────
// Section header (e.g. "فطور • 2 وجبة")
// ─────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String mealType;
  final List<MealSchedule> meals;

  const _SectionHeader({required this.mealType, required this.meals});

  String get _label {
    switch (mealType) {
      case 'breakfast':
        return 'الفطور';
      case 'lunch':
        return 'الغداء';
      case 'dinner':
        return 'العشاء';
      case 'snack':
        return 'وجبات خفيفة';
      default:
        return mealType;
    }
  }

  IconData get _icon {
    switch (mealType) {
      case 'breakfast':
        return Icons.wb_sunny_outlined;
      case 'lunch':
        return Icons.lunch_dining_outlined;
      case 'dinner':
        return Icons.nights_stay_outlined;
      default:
        return Icons.cookie_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final eaten = meals.where((m) => m.isEaten).length;
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          '$eaten/${meals.length}',
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
        const SizedBox(width: 6),
        Text(
          _label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1E293B),
          ),
        ),
        const SizedBox(width: 6),
        Icon(_icon, size: 18, color: const Color(0xFF00D9D9)),
      ],
    );
  }
}

// ─────────────────────────────────────────
// Empty state (no plan assigned)
// ─────────────────────────────────────────

class _EmptyView extends StatelessWidget {
  final VoidCallback onRefresh;
  const _EmptyView({required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF00D9D9).withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.restaurant_menu_outlined,
                size: 60,
                color: Color(0xFF00D9D9),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'لا توجد وجبات اليوم',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'لم يتم تخصيص خطة غذائية لك بعد.\nتواصل مع أخصائي التغذية الخاص بك.',
              style: TextStyle(fontSize: 14, color: Colors.grey, height: 1.6),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRefresh,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00D9D9),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
              icon: const Icon(Icons.refresh),
              label: const Text('تحديث', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────
// Error state
// ─────────────────────────────────────────

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});

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
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
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
                backgroundColor: const Color(0xFF00D9D9),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
              icon: const Icon(Icons.refresh),
              label: const Text('إعادة المحاولة', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
