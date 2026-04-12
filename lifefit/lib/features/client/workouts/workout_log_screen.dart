import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/workout/today_schedule.dart';
import '../../../core/models/workout/exercise.dart';
import '../../../core/models/workout/exercise_log.dart';
import 'workout_provider.dart';

class WorkoutLogScreen extends ConsumerStatefulWidget {
  final TodaySchedule schedule;
  final Exercise exercise;

  const WorkoutLogScreen({
    super.key,
    required this.schedule,
    required this.exercise,
  });

  @override
  ConsumerState<WorkoutLogScreen> createState() =>
      _WorkoutLogScreenState();
}

class _WorkoutLogScreenState extends ConsumerState<WorkoutLogScreen> {
  late List<_SetFields> _sets;
  bool _isSubmitting = false;
  Timer? _restTimer;
  int _restRemaining = 60;
  bool _restRunning = false;

  static const _primary = Color(0xFF00D9D9);

  Exercise get _exercise => widget.exercise;
  TodaySchedule get _schedule => widget.schedule;

  @override
  void initState() {
    super.initState();
    final pivot = _exercise.pivot;
    final count = (pivot?.sets ?? 1).clamp(1, 20);
    final targetReps = _parseFirstInt(pivot?.reps);
    final targetWeight = pivot?.targetWeight;

    _sets = List.generate(
      count,
      (_) => _SetFields(
        targetReps: targetReps,
        targetWeight: targetWeight,
      ),
    );
  }

  @override
  void dispose() {
    for (final s in _sets) {
      s.dispose();
    }
    _restTimer?.cancel();
    super.dispose();
  }

  int? _parseFirstInt(String? text) {
    if (text == null) return null;
    final match = RegExp(r'(\d+)').firstMatch(text);
    return match != null ? int.tryParse(match.group(1)!) : null;
  }

  void _startRestTimer() {
    _restTimer?.cancel();
    final restSec = _exercise.pivot?.restSeconds ?? 60;
    setState(() {
      _restRemaining = restSec;
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
    setState(() => _isSubmitting = true);

    try {
      final exerciseLogs = <ExerciseLog>[];
      for (var i = 0; i < _sets.length; i++) {
        final s = _sets[i];
        final actualReps = _intFrom(s.repsCtrl.text, s.targetReps);
        final actualWeight = _doubleFrom(s.weightCtrl.text, s.targetWeight);

        exerciseLogs.add(ExerciseLog(
          exerciseId: _exercise.id,
          setNumber: i + 1,
          targetReps: s.targetReps,
          actualReps: actualReps,
          targetWeight: s.targetWeight,
          actualWeight: actualWeight,
          intensityType: _exercise.pivot?.intensityType ?? 'weight',
          rpeTarget: _exercise.pivot?.rpeTarget,
          notes: s.notesCtrl.text.trim().isEmpty ? null : s.notesCtrl.text.trim(),
        ));
      }

      final success = await ref.read(todaySchedulesProvider.notifier).saveWorkoutLog(
            scheduleId: _schedule.scheduleId,
            exerciseLogs: exerciseLogs,
          );

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم حفظ سجل التمرين بنجاح')),
        );
        int count = 0;
        Navigator.of(context).popUntil((_) => count++ >= 2);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تعذر حفظ السجل، حاول مجدداً')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('حدث خطأ: $e')));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  int? _intFrom(String text, int? fallback) {
    if (text.trim().isEmpty) return fallback;
    return int.tryParse(text.trim()) ?? fallback;
  }

  double? _doubleFrom(String text, double? fallback) {
    if (text.trim().isEmpty) return fallback;
    return double.tryParse(text.trim()) ?? fallback;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text('تسجيل التمرين',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              color: Colors.black, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _buildHeader(),
            const SizedBox(height: 12),
            _buildRestTimer(),
            const SizedBox(height: 16),
            const Text('المجموعات',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 10),
            ...List.generate(_sets.length, (i) => _buildSetCard(i)),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primary,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _isSubmitting ? null : _submitLog,
                child: _isSubmitting
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text('إنهاء التمرين',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final pivot = _exercise.pivot;
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
          Text(_schedule.workout.name,
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              textAlign: TextAlign.right),
          const SizedBox(height: 4),
          Text(_exercise.name,
              style: const TextStyle(fontSize: 15, color: Colors.grey),
              textAlign: TextAlign.right),
          if (pivot != null) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              alignment: WrapAlignment.end,
              children: [
                _tag('${pivot.sets} مجموعات', Colors.blue[50]!, Colors.blue),
                _tag('${pivot.reps} عدات', Colors.orange[50]!, Colors.orange),
                _tag(_weightLabel(pivot.targetWeight), Colors.green[50]!,
                    Colors.green),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRestTimer() {
    final mm = (_restRemaining ~/ 60).toString().padLeft(2, '0');
    final ss = (_restRemaining % 60).toString().padLeft(2, '0');

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
            children: [
              const Text('مؤقت الراحة',
                  style: TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 2),
              Text('${_exercise.pivot?.restSeconds ?? 60} ثانية للراحة',
                  style: const TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          ),
          Row(children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: _primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text('$mm:$ss',
                  style: TextStyle(
                      color: _primary, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(width: 10),
            TextButton(
              onPressed: _restRunning ? null : _startRestTimer,
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: _primary,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child: Text(_restRunning ? 'يعمل' : 'ابدأ'),
            ),
          ]),
        ],
      ),
    );
  }

  Widget _buildSetCard(int index) {
    final s = _sets[index];
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
              Text('المجموعة ${index + 1}',
                  style: const TextStyle(fontWeight: FontWeight.w700)),
              Text(
                'الهدف: ${s.targetReps ?? "--"} | ${_weightLabel(s.targetWeight)}',
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(
              child: TextFormField(
                controller: s.repsCtrl,
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                decoration: _inputDeco('العدات'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: s.weightCtrl,
                textAlign: TextAlign.center,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: _inputDeco('الوزن كجم'),
              ),
            ),
          ]),
          const SizedBox(height: 10),
          TextFormField(
            controller: s.notesCtrl,
            textAlign: TextAlign.right,
            maxLines: 1,
            decoration: _inputDeco('ملاحظات المجموعة'),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDeco(String label) => InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontSize: 12, color: Colors.grey),
        filled: true,
        fillColor: const Color(0xFFF7F9FC),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none),
      );

  Widget _tag(String text, Color bg, Color fg) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration:
            BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
        child: Text(text,
            style:
                TextStyle(color: fg, fontWeight: FontWeight.bold, fontSize: 11)),
      );

  String _weightLabel(double? w) {
    if (w == null || w == 0) return 'بوزن الجسم';
    return '${w.toStringAsFixed(w % 1 == 0 ? 0 : 1)} كجم';
  }
}

class _SetFields {
  final TextEditingController repsCtrl;
  final TextEditingController weightCtrl;
  final TextEditingController notesCtrl;
  final int? targetReps;
  final double? targetWeight;

  _SetFields({this.targetReps, this.targetWeight})
      : repsCtrl = TextEditingController(text: targetReps?.toString() ?? ''),
        weightCtrl =
            TextEditingController(text: targetWeight?.toString() ?? ''),
        notesCtrl = TextEditingController();

  void dispose() {
    repsCtrl.dispose();
    weightCtrl.dispose();
    notesCtrl.dispose();
  }
}
