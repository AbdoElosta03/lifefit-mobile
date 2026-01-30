import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/exercise.dart';
import '../../../core/models/workout.dart';
import 'workout_details_screen.dart';
import 'workout_provider.dart';

class WorkoutsScreen extends ConsumerWidget {
  const WorkoutsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const String unifiedImage =
        'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?w=400';

    final workoutAsync = ref.watch(workoutProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: workoutAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: Color(0xFF00D9D9)),
        ),
        error: (error, stack) => _buildErrorState(ref, error.toString()),
        data: (workout) {
          if (workout == null || workout.exercises.isEmpty) {
            return _buildEmptyState(context, ref);
          }
          return RefreshIndicator(
            onRefresh: () => ref.read(workoutProvider.notifier).refresh(),
            color: const Color(0xFF00D9D9),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
              child: _buildContent(context, workout, unifiedImage),
            ),
          );
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, Workout workout, String img) {
    final totalExercises = workout.exercises.length;
    final completedExercises =
        workout.exercises.where((e) => e.status == 'completed').length;
    final progressValue =
        totalExercises > 0 ? completedExercises / totalExercises : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        const Text(
          'التدريب',
          style: TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.bold),
        ),
        Text(
          workout.title,
          style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 24),
        _buildProgressCard(
          totalExercises: totalExercises,
          completedExercises: completedExercises,
          progressValue: progressValue,
          durationMinutes: workout.estimatedDurationMinutes,
        ),
        const SizedBox(height: 30),
        const Text(
          'قائمة التمارين',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        ...workout.exercises.map(
          (exercise) => _buildWorkoutItem(
            context,
            workout: workout,
            exercise: exercise,
            desc: 'اضغط لعرض التفاصيل',
            img: img,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context, WidgetRef ref) {
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
              child: const Icon(Icons.fitness_center, size: 80, color: Color(0xFF00D9D9)),
            ),
            const SizedBox(height: 24),
            const Text('يوم راحة مستحق!', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            const Text(
              'لا توجد تمارين مجدولة لليوم. عضلاتك تحتاج للراحة لتنمو بشكل أفضل.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15, color: Colors.grey, height: 1.5),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => ref.read(workoutProvider.notifier).refresh(),
              icon: const Icon(Icons.refresh),
              label: const Text('تحديث القائمة'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00D9D9),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(WidgetRef ref, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 60),
          const SizedBox(height: 16),
          Text('خطأ في جلب البيانات', style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(message, style: const TextStyle(color: Colors.grey), textAlign: TextAlign.center),
          TextButton(
            onPressed: () => ref.read(workoutProvider.notifier).refresh(),
            child: const Text('إعادة المحاولة'),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkoutItem(
    BuildContext context, {
    required Workout workout,
    required Exercise exercise,
    required String desc,
    required String img,
  }) {
    final bool isDone = exercise.status == 'completed';

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: isDone ? Border.all(color: Colors.green.withOpacity(0.5)) : null,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10)],
      ),
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => WorkoutDetailsScreen(
              exercise: exercise,
              workout: workout,
              imageUrl: img,
            ),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
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
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    Text(
                      isDone ? 'تم الإكمال بنجاح' : desc,
                      style: TextStyle(fontSize: 12, color: isDone ? Colors.green : Colors.grey),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        _buildSmallTag('${exercise.sets} جولات', Colors.blue[50]!, Colors.blue),
                        const SizedBox(width: 5),
                        _buildSmallTag('${exercise.reps} عدة', Colors.orange[50]!, Colors.orange),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 15),
              ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Stack(
                  children: [
                    Image.network(img, width: 75, height: 75, fit: BoxFit.cover),
                    if (isDone)
                      Container(
                        width: 75,
                        height: 75,
                        color: Colors.black.withOpacity(0.3),
                        child: const Icon(Icons.done_all, color: Colors.white, size: 28),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressCard({
    required int totalExercises,
    required int completedExercises,
    required double progressValue,
    int? durationMinutes,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            textDirection: TextDirection.rtl,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text('ملخص التدريب', style: TextStyle(color: Colors.grey, fontSize: 12)),
                  Text(
                    'المدة: ${durationMinutes ?? "--"} دقيقة',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Text(
                '$completedExercises/$totalExercises',
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF00D9D9),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          LinearProgressIndicator(
            value: progressValue,
            minHeight: 8,
            borderRadius: BorderRadius.circular(10),
            backgroundColor: const Color(0xFFF0F0F0),
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF00D9D9)),
          ),
        ],
      ),
    );
  }

  Widget _buildSmallTag(String text, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(8)),
      child: Text(
        text,
        style: TextStyle(color: textColor, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }
}