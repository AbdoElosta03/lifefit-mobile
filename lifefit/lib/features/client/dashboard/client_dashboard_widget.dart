import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lifefit/features/client/nutrition/meal_details_screen.dart';
import '../../../core/models/workout/exercise.dart' as workout_v2;
import '../../../core/models/workout/today_schedule.dart';
import '../nutrition/nutrition_provider.dart';
import '../workouts/workout_detail_screen.dart';
import '../workouts/workout_provider.dart';

class ClientDashboardWidget extends ConsumerWidget {
  const ClientDashboardWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final schedulesAsync = ref.watch(todaySchedulesProvider);
    final nutritionAsync = ref.watch(nutritionProvider);

    // الألوان المحدثة (حيوية أكثر ومتناسقة)
    const primaryTeal = Color(0xFF00D9D9); // التركوازي الأساسي
    const softBlue = Color(0xFF3ABEF9);    // أزرق سماوي حيوي للوجبات
    const darkSlate = Color(0xFF1E293B);   // للنصوص

    final formattedDate = "2024 يونيو 15:30";

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(todaySchedulesProvider.notifier).refresh();
          await ref.read(nutritionProvider.notifier).refresh();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const SizedBox(height: 30),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      'مرحبًا يا بطل!',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: darkSlate,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      formattedDate,
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                _buildDynamicStatsRow(schedulesAsync, nutritionAsync),

                const SizedBox(height: 20),

                // كارد التمرين القادم
                schedulesAsync.when(
                  loading: () => const Center(child: LinearProgressIndicator(color: primaryTeal)),
                  error: (err, _) => _buildErrorMiniCard('خطأ في جلب التمارين'),
                  data: (schedules) {
                    if (schedules.isEmpty) {
                      return _buildMainActionCard(
                        title: 'يوم راحة',
                        subtitle: 'لا توجد تمارين مجدولة اليوم',
                        buttonText: 'عرض الجدول الأسبوعي',
                        icon: Icons.hotel,
                        colors: [Colors.blueGrey[400]!, Colors.blueGrey[600]!],
                        onPressed: () {},
                      );
                    }

                    TodaySchedule? targetSchedule;
                    workout_v2.Exercise? nextEx;
                    for (final s in schedules) {
                      for (final ex in s.workout.exercises) {
                        if (!s.isExerciseLogged(ex.id)) {
                          targetSchedule = s;
                          nextEx = ex;
                          break;
                        }
                      }
                      if (nextEx != null) break;
                    }

                    final isAllDone = nextEx == null;
                    final title = schedules.length == 1
                        ? schedules.first.workout.name
                        : (isAllDone ? 'تمارين اليوم' : targetSchedule!.workout.name);

                    return _buildMainActionCard(
                      title: title,
                      subtitle: isAllDone
                          ? 'عاش! أنهيت تمارين اليوم'
                          : 'التمرين القادم: ${nextEx.name}',
                      buttonText: isAllDone ? 'تم الإنجاز بنجاح' : 'استكمال التمرين',
                      icon: Icons.fitness_center,
                      colors: isAllDone ? [Colors.green[400]!, Colors.green[600]!] : [primaryTeal, const Color(0xFF00B4B4)],
                      onPressed: isAllDone
                          ? () {}
                          : () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => WorkoutDetailScreen(
                                    schedule: targetSchedule!,
                                    exercise: nextEx!,
                                  ),
                                ),
                              );
                            },
                    );
                  },
                ),

                const SizedBox(height: 16),

                // كارد الوجبة القادمة (تم تغيير اللون هنا إلى أزرق سماوي منعش)
                nutritionAsync.when(
                  loading: () => const Center(child: LinearProgressIndicator(color: primaryTeal)),
                  error: (err, _) => _buildErrorMiniCard('خطأ في جلب الوجبات'),
                  data: (day) {
                    if (day == null || day.meals.isEmpty) {
                      return _buildMainActionCard(
                        title: 'لا وجبات مخصصة',
                        subtitle: 'استشر مدربك لتحديد خطتك',
                        buttonText: 'تواصل مع المدرب',
                        icon: Icons.restaurant_menu,
                        colors: [Colors.grey[400]!, Colors.grey[600]!],
                        onPressed: () {},
                      );
                    }

                    final nextMeal = day.meals.firstWhere((m) => m.isCompleted == false, orElse: () => day.meals.last);

                    return _buildMainActionCard(
                      title: nextMeal.name,
                      subtitle: "سجل وجبتك الآن للحفاظ على خطتك",
                      buttonText: 'تسجيل الوجبة',
                      icon: Icons.restaurant,
                      // تغيير اللون من الغامق إلى أزرق سماوي متدرج
                      colors: [softBlue, const Color(0xFF3572EF)],
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => MealDetailsScreen(meal: nextMeal)));
                      },
                    );
                  },
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDynamicStatsRow(
      AsyncValue<List<TodaySchedule>> schedulesAsync, AsyncValue nutritionAsync) {
    final workoutStats = _workoutStats(schedulesAsync);
    final nutritionStats = _nutritionStats(nutritionAsync);

    return Column(
      children: [
        _buildCaloriesCard(nutritionStats),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                label: '82.0 كغ',
                subLabel: 'الوزن الحالي',
                value: 0.6,
                color: const Color(0xFF6366F1),
                icon: Icons.monitor_weight_outlined,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildStatCard(
                label: workoutStats.label,
                subLabel: 'تمارين اليوم',
                value: workoutStats.progress,
                color: const Color(0xFF00D9D9),
                icon: Icons.bolt,
              ),
            ),
          ],
        ),
      ],
    );
  }

  _StatInfo _workoutStats(AsyncValue<List<TodaySchedule>> schedulesAsync) {
    return schedulesAsync.maybeWhen(
      data: (schedules) {
        if (schedules.isEmpty) {
          return const _StatInfo(label: '0 / 0', progress: 0.0);
        }
        var total = 0;
        var done = 0;
        for (final s in schedules) {
          for (final e in s.workout.exercises) {
            total++;
            if (s.isExerciseLogged(e.id)) done++;
          }
        }
        if (total == 0) return const _StatInfo(label: '0 / 0', progress: 0.0);
        return _StatInfo(
          label: '$done / $total',
          progress: (done / total).clamp(0.0, 1.0),
        );
      },
      orElse: () => const _StatInfo(label: '0 / 0', progress: 0.0),
    );
  }

  _StatInfo _nutritionStats(AsyncValue nutritionAsync) {
    return nutritionAsync.maybeWhen(
      data: (day) {
        if (day == null) return const _StatInfo(label: '0 سعرة', progress: 0.0);
        final total = (day.totalCalories as num).toDouble();
        final consumed = (day.consumedTotalCalories as num).toDouble();
        final remaining = (total - consumed);
        return _StatInfo(label: '${(remaining < 0 ? 0.0 : remaining).toStringAsFixed(0)} سعرة', progress: total > 0 ? (consumed / total).clamp(0.0, 1.0) : 0.0);
      },
      orElse: () => const _StatInfo(label: '0 سعرة', progress: 0.0),
    );
  }

  Widget _buildCaloriesCard(_StatInfo stats) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF00D9D9), Color(0xFF00B4B4)], begin: Alignment.topRight, end: Alignment.bottomLeft),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [BoxShadow(color: const Color(0xFF00D9D9).withOpacity(0.25), blurRadius: 18, offset: const Offset(0, 10))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Icon(Icons.local_fire_department, color: Colors.white, size: 36),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('السعرات المتبقية', style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 13)),
                  const SizedBox(height: 4),
                  Text(stats.label, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: LinearProgressIndicator(
              value: stats.progress,
              minHeight: 10,
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              backgroundColor: Colors.white.withOpacity(0.25),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({required String label, required String subLabel, required double value, required Color color, required IconData icon}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.grey.withOpacity(0.05))),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(width: 50, height: 50, child: CircularProgressIndicator(value: value, strokeWidth: 5, valueColor: AlwaysStoppedAnimation<Color>(color), backgroundColor: color.withOpacity(0.1))),
              Icon(icon, size: 20, color: color),
            ],
          ),
          const SizedBox(height: 10),
          FittedBox(child: Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)))),
          Text(subLabel, style: const TextStyle(fontSize: 11, color: Colors.grey), textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildMainActionCard({required String title, required String subtitle, required String buttonText, required IconData icon, required List<Color> colors, required VoidCallback onPressed}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: colors, begin: Alignment.centerRight, end: Alignment.centerLeft),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: colors.first.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: Colors.white.withOpacity(0.4), size: 36),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white), overflow: TextOverflow.ellipsis),
                    Text(subtitle, style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 13), overflow: TextOverflow.ellipsis, maxLines: 1),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: colors.first,
              minimumSize: const Size(double.infinity, 48),
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(buttonText, style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorMiniCard(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.red[50], borderRadius: BorderRadius.circular(12)),
      child: Text(message, style: const TextStyle(color: Colors.redAccent), textAlign: TextAlign.center),
    );
  }
}

class _StatInfo {
  final String label;
  final double progress;
  const _StatInfo({required this.label, required this.progress});
} 