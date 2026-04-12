import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/workout/today_schedule.dart';
import '../../../core/models/workout/exercise.dart';
import 'workout_provider.dart';
import 'workout_detail_screen.dart';
import 'exercise_thumbnail.dart';

class WorkoutsScreen extends ConsumerWidget {
  const WorkoutsScreen({super.key});

  static const _primary = Color(0xFF00D9D9);
  static const _bg = Color(0xFFF8F9FA);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final schedulesAsync = ref.watch(todaySchedulesProvider);

    return Scaffold(
      backgroundColor: _bg,
      body: schedulesAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: _primary),
        ),
        error: (error, _) => _ErrorView(
          message: error.toString(),
          onRetry: () => ref.read(todaySchedulesProvider.notifier).refresh(),
        ),
        data: (schedules) {
          if (schedules.isEmpty) {
            return _RestDayView(
              onRefresh: () =>
                  ref.read(todaySchedulesProvider.notifier).refresh(),
            );
          }
          return RefreshIndicator(
            onRefresh: () =>
                ref.read(todaySchedulesProvider.notifier).refresh(),
            color: _primary,
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
              itemCount: schedules.length,
              itemBuilder: (context, index) =>
                  _ScheduleCard(schedule: schedules[index]),
            ),
          );
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Schedule Card — one per workout in the day
// ---------------------------------------------------------------------------
class _ScheduleCard extends StatelessWidget {
  final TodaySchedule schedule;
  const _ScheduleCard({required this.schedule});

  @override
  Widget build(BuildContext context) {
    final workout = schedule.workout;
    final exercises = workout.exercises;
    final completed = schedule.isCompleted;

    final loggedIds = <int>{};
    if (schedule.workoutLog != null) {
      for (final log in schedule.workoutLog!.exerciseLogs) {
        loggedIds.add(log.exerciseId);
      }
    }

    final completedCount =
        exercises.where((e) => loggedIds.contains(e.id)).length;
    final total = exercises.length;
    final progress = total > 0 ? completedCount / total : 0.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              textDirection: TextDirection.rtl,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          if (completed)
                            Container(
                              margin: const EdgeInsets.only(left: 8),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: Colors.green.shade50,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text('مكتمل',
                                  style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.green.shade700,
                                      fontWeight: FontWeight.bold)),
                            ),
                          Flexible(
                            child: Text(
                              workout.name,
                              style: const TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      if (workout.description != null &&
                          workout.description!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            workout.description!,
                            style: const TextStyle(
                                fontSize: 13, color: Colors.grey),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.right,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Progress bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: _ProgressRow(
              completed: completedCount,
              total: total,
              progress: progress,
              durationMinutes: workout.estimatedDuration,
            ),
          ),

          const Divider(height: 1),

          // Exercise list
          ...exercises.map((exercise) {
            final isDone = loggedIds.contains(exercise.id);
            return _ExerciseTile(
              schedule: schedule,
              exercise: exercise,
              isDone: isDone,
            );
          }),

          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Progress row
// ---------------------------------------------------------------------------
class _ProgressRow extends StatelessWidget {
  final int completed;
  final int total;
  final double progress;
  final int? durationMinutes;
  const _ProgressRow({
    required this.completed,
    required this.total,
    required this.progress,
    this.durationMinutes,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          textDirection: TextDirection.rtl,
          children: [
            Text(
              'المدة: ${durationMinutes ?? "--"} دقيقة',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            Text(
              '$completed/$total',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF00D9D9),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: progress,
          minHeight: 7,
          borderRadius: BorderRadius.circular(10),
          backgroundColor: const Color(0xFFF0F0F0),
          valueColor:
              const AlwaysStoppedAnimation<Color>(Color(0xFF00D9D9)),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Exercise tile
// ---------------------------------------------------------------------------
class _ExerciseTile extends StatelessWidget {
  final TodaySchedule schedule;
  final Exercise exercise;
  final bool isDone;
  const _ExerciseTile({
    required this.schedule,
    required this.exercise,
    required this.isDone,
  });

  @override
  Widget build(BuildContext context) {
    final pivot = exercise.pivot;
    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => WorkoutDetailScreen(
            schedule: schedule,
            exercise: exercise,
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            Icon(
              isDone ? Icons.check_circle : Icons.arrow_back_ios_new,
              size: isDone ? 22 : 14,
              color: isDone ? Colors.green : const Color(0xFF00D9D9),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    exercise.name,
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    isDone ? 'تم الإكمال بنجاح' : 'اضغط لعرض التفاصيل',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDone ? Colors.green : Colors.grey,
                    ),
                  ),
                  if (pivot != null) ...[
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        _tag('${pivot.sets} جولات', Colors.blue[50]!,
                            Colors.blue),
                        const SizedBox(width: 5),
                        _tag('${pivot.reps} عدة', Colors.orange[50]!,
                            Colors.orange),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 12),
            ExerciseThumbnail(
              imageUrl: exercise.imageUrl,
              dimmed: isDone,
              size: 72,
            ),
          ],
        ),
      ),
    );
  }

  Widget _tag(String text, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration:
          BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
      child: Text(text,
          style:
              TextStyle(color: fg, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }
}

// ---------------------------------------------------------------------------
// Rest Day View
// ---------------------------------------------------------------------------
class _RestDayView extends StatelessWidget {
  final VoidCallback onRefresh;
  const _RestDayView({required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF00D9D9).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.fitness_center,
                  size: 80, color: Color(0xFF00D9D9)),
            ),
            const SizedBox(height: 24),
            const Text('يوم راحة مستحق!',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            const Text(
              'لا توجد تمارين مجدولة لليوم.\nعضلاتك تحتاج للراحة لتنمو بشكل أفضل.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15, color: Colors.grey, height: 1.5),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: onRefresh,
              icon: const Icon(Icons.refresh),
              label: const Text('تحديث القائمة'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00D9D9),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Error View
// ---------------------------------------------------------------------------
class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 60),
          const SizedBox(height: 16),
          const Text('خطأ في جلب البيانات',
              style: TextStyle(fontWeight: FontWeight.bold)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
            child: Text(message,
                style: const TextStyle(color: Colors.grey),
                textAlign: TextAlign.center),
          ),
          TextButton(
            onPressed: onRetry,
            child: const Text('إعادة المحاولة'),
          ),
        ],
      ),
    );
  }
}
