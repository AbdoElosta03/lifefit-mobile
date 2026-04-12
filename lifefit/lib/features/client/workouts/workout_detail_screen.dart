import 'package:flutter/material.dart';
import '../../../core/models/workout/today_schedule.dart';
import '../../../core/models/workout/exercise.dart';
import 'exercise_video_card.dart';
import 'workout_log_screen.dart';

class WorkoutDetailScreen extends StatelessWidget {
  final TodaySchedule schedule;
  final Exercise exercise;

  const WorkoutDetailScreen({
    super.key,
    required this.schedule,
    required this.exercise,
  });

  static const _primary = Color(0xFF00D9D9);

  bool get _isDone => schedule.isExerciseLogged(exercise.id);

  @override
  Widget build(BuildContext context) {
    final pivot = exercise.pivot;
    final videoUrl = exercise.videoUrl;
    final hasVideo = videoUrl != null && videoUrl.trim().isNotEmpty;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
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
          icon:
              const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
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
                    child: _detailCard(
                        'المجموعات', '${pivot.sets}', Icons.layers)),
              ]),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(
                    child: _detailCard('الوزن',
                        _weightText(pivot.targetWeight), Icons.fitness_center)),
                const SizedBox(width: 12),
                Expanded(
                    child: _detailCard(
                        'الراحة',
                        '${pivot.restSeconds ?? 60} ثانية',
                        Icons.timer)),
              ]),
            ],
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isDone ? Colors.grey : _primary,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  elevation: _isDone ? 0 : 2,
                ),
                onPressed: _isDone
                    ? null
                    : () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => WorkoutLogScreen(
                              schedule: schedule,
                              exercise: exercise,
                            ),
                          ),
                        ),
                child: Text(
                  _isDone ? 'تم إكمال التمرين بنجاح' : 'ابدأ تسجيل المجموعات',
                  style: TextStyle(
                    fontSize: 18,
                    color: _isDone ? Colors.white70 : Colors.white,
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
                  child: Icon(Icons.fitness_center, size: 50, color: Colors.grey),
                ),
              )
            : const Center(
                child: Icon(Icons.fitness_center, size: 50, color: Colors.grey),
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
              style:
                  const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  String _weightText(double? w) {
    if (w == null || w == 0) return 'حسب قدرتك';
    return '${w.toStringAsFixed(w % 1 == 0 ? 0 : 1)} كجم';
  }
}
