import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/workout/today_schedule.dart';
import '../../../core/models/workout/exercise.dart';
import 'exercise_video_card.dart';
import 'workout_log_screen.dart';
import 'workout_provider.dart';

class WorkoutDetailScreen extends ConsumerWidget {
  final TodaySchedule schedule;
  final Exercise exercise;

  const WorkoutDetailScreen({
    super.key,
    required this.schedule,
    required this.exercise,
  });

  static const _primary = Color(0xFF00D9D9);

  /// Always read the live schedule from the provider so state stays fresh.
  TodaySchedule _liveSchedule(WidgetRef ref) {
    final list = ref.watch(todaySchedulesProvider).valueOrNull;
    if (list != null) {
      for (final s in list) {
        if (s.scheduleId == schedule.scheduleId) return s;
      }
    }
    return schedule;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final live = _liveSchedule(ref);
    final isDone = live.isExerciseLogged(exercise.id);
    final pivot = exercise.pivot;
    final videoUrl = exercise.videoUrl;
    final hasVideo = videoUrl != null && videoUrl.trim().isNotEmpty;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        centerTitle: true,
        title: const Text(
          'تفاصيل التمرين',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _buildImage(),
            if (hasVideo) ...[
              const SizedBox(height: 16),
              ExerciseVideoCard(videoUrl: videoUrl.trim(), primary: _primary),
            ],
            const SizedBox(height: 24),
            Text(
              exercise.name,
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            if (exercise.description != null &&
                exercise.description!.trim().isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                exercise.description!,
                textAlign: TextAlign.right,
                style: const TextStyle(
                    fontSize: 14, color: Colors.grey, height: 1.5),
              ),
            ],
            if (exercise.muscles != null &&
                exercise.muscles!.trim().isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'العضلات: ${exercise.muscles}',
                style: const TextStyle(fontSize: 13, color: Colors.grey),
              ),
            ],
            const SizedBox(height: 30),
            const Text(
              'معلومات التدريب',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            if (pivot != null) ...[
              Row(children: [
                Expanded(
                    child: _detailCard('العدات', pivot.reps, Icons.repeat)),
                const SizedBox(width: 12),
                Expanded(
                    child:
                        _detailCard('المجموعات', '${pivot.sets}', Icons.layers)),
              ]),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(
                    child: _detailCard('الوزن',
                        _weightText(pivot.targetWeight), Icons.fitness_center)),
                const SizedBox(width: 12),
                Expanded(
                    child: _detailCard(
                        'الراحة', '${pivot.restSeconds ?? 60} ثانية', Icons.timer)),
              ]),
            ],
            const SizedBox(height: 40),
            // Status badge
            if (isDone)
              Center(
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00D9D9).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    'تم إكمال هذا التمرين — يمكنك إعادة التسجيل لتحديثه',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF00D9D9),
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primary,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  elevation: 2,
                ),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => WorkoutLogScreen(
                      schedule: live,
                      exercise: exercise,
                    ),
                  ),
                ),
                child: Text(
                  isDone ? 'تعديل التسجيل' : 'ابدأ تسجيل المجموعات',
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage() {
    final url = exercise.imageUrl;
    return Container(
      height: 250,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.05), blurRadius: 15),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: url != null && url.isNotEmpty
            ? Image.network(
                url,
                fit: BoxFit.cover,
                width: double.infinity,
                height: 250,
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return const Center(
                    child: CircularProgressIndicator(color: _primary),
                  );
                },
                errorBuilder: (_, __, ___) => const Center(
                  child:
                      Icon(Icons.fitness_center, size: 50, color: Colors.grey),
                ),
              )
            : const Center(
                child:
                    Icon(Icons.fitness_center, size: 50, color: Colors.grey),
              ),
      ),
    );
  }

  Widget _detailCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: _primary, size: 20),
          const SizedBox(height: 8),
          Text(label,
              style: const TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 2),
          Text(value,
              style: const TextStyle(
                  fontSize: 15, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  String _weightText(double? w) {
    if (w == null || w == 0) return 'حسب قدرتك';
    return '${w.toStringAsFixed(w % 1 == 0 ? 0 : 1)} كجم';
  }
}
