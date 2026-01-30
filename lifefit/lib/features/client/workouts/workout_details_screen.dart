import 'package:flutter/material.dart';
import '../../../core/models/exercise.dart';
import '../../../core/models/workout.dart';
import 'workout_log_screen.dart';

class WorkoutDetailsScreen extends StatelessWidget {
  final Workout workout;
  final Exercise exercise;
  final String imageUrl;

  const WorkoutDetailsScreen({
    super.key,
    required this.workout,
    required this.exercise,
    this.imageUrl =
        'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?w=800',
  });

  @override
  Widget build(BuildContext context) {
    final bool isDone = exercise.status == 'completed';
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), // الخلفية الموحدة
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
            // 1. صورة التمرين الكبيرة
            _buildExerciseImage(),

            const SizedBox(height: 24),

            // 2. اسم التمرين والوصف
            Text(
              exercise.name,
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              workout.title,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
                height: 1.5,
              ),
            ),

            const SizedBox(height: 30),

            // 3. كروت التفاصيل البيضاء
            const Text(
              'معلومات التدريب',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // استخدام الـ Row لعرض المعلومات بشكل منظم
            Row(
              children: [
                Expanded(
                  child: _buildDetailCard(
                    'العدات',
                    exercise.reps,
                    Icons.repeat,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildDetailCard(
                    'المجموعات',
                    '${exercise.sets}',
                    Icons.layers,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildDetailCard(
                    'الوزن',
                    _weightText(exercise.targetWeight),
                    Icons.fitness_center,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildDetailCard(
                    'الراحة',
                    '${exercise.restSeconds ?? 60} ثانية',
                    Icons.timer,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 40),

            
            // التحقق من حالة التمرين


SizedBox(
  width: double.infinity,
  height: 55,
  child: ElevatedButton(
    style: ElevatedButton.styleFrom(
      
      backgroundColor: isDone ? Colors.grey : const Color(0xFF00D9D9),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      elevation: isDone ? 0 : 2,
    ),
    // إذا كان isDone = true، فإن onPressed تكون null (تعطيل النقر)
    onPressed: isDone ? null : () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => WorkoutLogScreen(
            workout: workout,
            exercise: exercise,
          ),
        ),
      );
    },
    child: Text(
      // تغيير النص بناءً على الحالة
      isDone ? 'تم إكمال التمرين بنجاح' : 'ابدأ تسجيل المجموعات',
      style: TextStyle(
        fontSize: 18,
        color: isDone ? Colors.white70 : Colors.white,
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

  // ويدجت الصورة مع الظل
  Widget _buildExerciseImage() {
    return Container(
      height: 250,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: Image.network(
          imageUrl,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) =>
              const Icon(Icons.fitness_center, size: 50, color: Colors.grey),
        ),
      ),
    );
  }

  // ويدجت الكارد الأبيض الصغير (للتفاصيل)
  Widget _buildDetailCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: const Color(0xFF00D9D9), size: 20),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  String _weightText(double? w) {
    if (w == null || w == 0) return 'حسب قدرتك';
    return '${w.toStringAsFixed(w % 1 == 0 ? 0 : 1)} كجم';
  }
}
