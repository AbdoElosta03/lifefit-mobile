import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lifefit/core/models/exercise.dart';
import 'package:lifefit/core/models/workout.dart';
import 'package:lifefit/core/services/api_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // مكتبة الريفربود
import 'workout_provider.dart'; // ملف البروفايدر الخاص بك

// 1. تغيير الكلاس إلى ConsumerStatefulWidget ليعمل الـ ref
class WorkoutLogScreen extends ConsumerStatefulWidget {
  final Exercise exercise;
  final Workout workout;

  const WorkoutLogScreen({
    super.key,
    required this.exercise,
    required this.workout,
  });

  @override
  ConsumerState<WorkoutLogScreen> createState() => _WorkoutLogScreenState();
}

// 2. تغيير الحالة إلى ConsumerState
class _WorkoutLogScreenState extends ConsumerState<WorkoutLogScreen> {
  late List<_SetLogFields> _sets;
  bool _isSubmitting = false;
  Timer? _restTimer;
  int _restRemaining = 60;
  bool _restRunning = false;

  @override
  void initState() {
    super.initState();
    final setsCount = widget.exercise.sets > 0 ? widget.exercise.sets : 1;
    _sets = List.generate(
      setsCount,
      (index) => _SetLogFields(
        targetReps: _parseTargetReps(widget.exercise.reps),
        targetWeight: widget.exercise.targetWeight,
      ),
    );
  }

  @override
  void dispose() {
    for (final set in _sets) {
      set.dispose();
    }
    _restTimer?.cancel();
    super.dispose();
  }

  int _parseTargetReps(String repsText) {
    final match = RegExp(r'(\d+)').firstMatch(repsText);
    return match != null ? int.tryParse(match.group(1)!) ?? 0 : 0;
  }

  double _parseDouble(String value, double fallback) {
    return double.tryParse(value.trim()) ?? fallback;
  }

  int _parseInt(String value, int fallback) {
    return int.tryParse(value.trim()) ?? fallback;
  }

  void _startRestTimer() {
    _restTimer?.cancel();
    setState(() {
      _restRemaining = 60;
      _restRunning = true;
    });
    _restTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_restRemaining <= 1) {
        timer.cancel();
        setState(() => _restRunning = false);
      } else {
        setState(() => _restRemaining -= 1);
      }
    });
  }

  Future<void> _submitLog() async {
    if (_isSubmitting) return;

    FocusScope.of(context).unfocus();
    final scheduleId = widget.workout.scheduleId ?? widget.workout.id;

    setState(() => _isSubmitting = true);

    try {
      final entries = <Map<String, dynamic>>[];
      for (var i = 0; i < _sets.length; i++) {
        final set = _sets[i];
        final actualReps = _parseInt(
          set.actualRepsController.text.isEmpty
              ? (set.targetReps?.toString() ?? '0')
              : set.actualRepsController.text,
          set.targetReps ?? 0,
        );
        final actualWeight = _parseDouble(
          set.actualWeightController.text.isEmpty
              ? (set.targetWeight?.toString() ?? '0.0')
              : set.actualWeightController.text,
          set.targetWeight ?? 0,
        );

        entries.add({
          'exercise_id': widget.exercise.id,
          'set_number': i + 1,
          'target_reps': set.targetReps ?? actualReps,
          'actual_reps': actualReps,
          'target_weight': set.targetWeight ?? actualWeight,
          'actual_weight': actualWeight,
          'rpe': 7,
          'notes': set.notesController.text.trim().isEmpty
              ? null
              : set.notesController.text.trim(),
        });
      }

      final requestBody = {
        'schedule_id': scheduleId,
        'total_duration_seconds': 0,
        'notes': null,
        'status': 'completed',
        'exercises': entries,
      };

      final api = ApiService();
      final response = await api.saveWorkoutLog(requestBody);

      final success =
          response != null &&
          (response.statusCode == 200 || response.statusCode == 201);

      if (success) {
        // 3. تحديث البيانات في البروفايدر فور النجاح وقبل الخروج
        await ref.read(workoutProvider.notifier).fetchTodayWorkout();

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم حفظ سجل التمرين بنجاح')),
        );

        // 4. الرجوع لشاشة التمارين الرئيسية (إغلاق شاشتين)
        int count = 0;
        Navigator.of(context).popUntil((_) => count++ >= 2);
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تعذر حفظ السجل، حاول مجدداً')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('حدث خطأ: $e')));
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final primary = const Color(0xFF00D9D9);
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'تسجيل التمرين',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.black,
            size: 18,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _buildHeaderCard(primary),
            const SizedBox(height: 12),
            _buildRestTimerCard(primary),
            const SizedBox(height: 16),
            const Text(
              'المجموعات',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 10),
            ...List.generate(
              _sets.length,
              (index) => _buildSetCard(index, primary),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primary,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _isSubmitting ? null : _submitLog,
                child: _isSubmitting
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : const Text(
                        'إنهاء التمرين',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard(Color primary) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.black.withOpacity(0.04)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            widget.workout.title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            textAlign: TextAlign.right,
          ),
          const SizedBox(height: 4),
          Text(
            widget.exercise.name,
            style: const TextStyle(fontSize: 15, color: Colors.grey),
            textAlign: TextAlign.right,
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            alignment: WrapAlignment.end,
            children: [
              _smallTag(
                '${widget.exercise.sets} مجموعات',
                Colors.blue[50]!,
                Colors.blue,
              ),
              _smallTag(
                '${widget.exercise.reps} عدات',
                Colors.orange[50]!,
                Colors.orange,
              ),
              _smallTag(
                _weightText(widget.exercise.targetWeight),
                Colors.green[50]!,
                Colors.green,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRestTimerCard(Color primary) {
    final minutes = (_restRemaining ~/ 60).toString().padLeft(2, '0');
    final seconds = (_restRemaining % 60).toString().padLeft(2, '0');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black.withOpacity(0.04)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'مؤقت الراحة',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              SizedBox(height: 2),
              Text(
                '60 ثانية للراحة',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$minutes:$seconds',
                  style: TextStyle(color: primary, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 10),
              TextButton(
                onPressed: _restRunning ? null : _startRestTimer,
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: primary,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(_restRunning ? 'يعمل' : 'ابدأ'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSetCard(int index, Color primary) {
    final set = _sets[index];
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black.withOpacity(0.04)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'المجموعة ${index + 1}',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              Text(
                'الهدف: ${set.targetReps ?? '--'} | ${_weightText(set.targetWeight)}',
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: set.actualRepsController,
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  decoration: _inputDecoration('العدات'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: set.actualWeightController,
                  textAlign: TextAlign.center,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: _inputDecoration('الوزن كجم'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: set.notesController,
            textAlign: TextAlign.right,
            maxLines: 1,
            decoration: _inputDecoration('ملاحظات المجمـوعة'),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(fontSize: 12, color: Colors.grey),
      filled: true,
      fillColor: const Color(0xFFF7F9FC),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
    );
  }

  Widget _smallTag(String text, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.bold,
          fontSize: 11,
        ),
      ),
    );
  }

  String _weightText(double? w) {
    if (w == null || w == 0) return 'بوزن الجسم';
    return '${w.toStringAsFixed(w % 1 == 0 ? 0 : 1)} كجم';
  }
}

// 5. كلاس تنظيم الحقول لكل مجموعة
class _SetLogFields {
  final TextEditingController actualRepsController;
  final TextEditingController actualWeightController;
  final TextEditingController notesController;
  final int? targetReps;
  final double? targetWeight;

  _SetLogFields({required this.targetReps, required this.targetWeight})
    // هنا نقوم بوضع القيم المستهدفة كقيم أولية للنصوص
    : actualRepsController = TextEditingController(
        text: targetReps?.toString() ?? '',
      ),
      actualWeightController = TextEditingController(
        text: targetWeight?.toString() ?? '',
      ),
      notesController = TextEditingController();

  void dispose() {
    actualRepsController.dispose();
    actualWeightController.dispose();
    notesController.dispose();
  }
}
