import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/progress/client_goal.dart';
import '../profile_web/profile_provider_web.dart';
import 'edit_goals_screen.dart';
import 'goals_provider.dart';

const Color _kPrimary = Color(0xFF00D9D9);
const Color _kDark = Color(0xFF1E293B);

/// First section on Progress: active goal (`data.first`) vs profile current stats.
class GoalsSection extends ConsumerWidget {
  const GoalsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goalsAsync = ref.watch(goalsProvider);
    final profileAsync = ref.watch(clientProfileWebProvider);

    return goalsAsync.when(
      loading: () => _loadingCard(),
      error: (e, _) => _errorCard(e.toString()),
      data: (goals) {
        final goal = goals.isNotEmpty ? goals.first : null;
        return profileAsync.when(
          loading: () =>
              _goalShell(context, goal: goal, weight: null, fat: null),
          error: (_, __) =>
              _goalShell(context, goal: goal, weight: null, fat: null),
          data: (bundle) => _goalShell(
            context,
            goal: goal,
            weight: bundle.currentStats.weightKg,
            fat: bundle.currentStats.bodyFatPct,
          ),
        );
      },
    );
  }

  Widget _loadingCard() {
    return Container(
      height: 150,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: const CircularProgressIndicator(color: _kPrimary, strokeWidth: 2.5),
    );
  }

  Widget _errorCard(String msg) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(msg, textAlign: TextAlign.right),
    );
  }

  Widget _goalShell(
    BuildContext context, {
    required ClientGoal? goal,
    required double? weight,
    required double? fat,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: LinearGradient(
          colors: [_kPrimary, _kPrimary.withValues(alpha: 0.7)],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        boxShadow: [
          BoxShadow(
            color: _kPrimary.withValues(alpha: 0.22),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(2),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Align(
              alignment: Alignment.centerRight,
              child: Text(
                'أهدافك',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: _kDark,
                ),
              ),
            ),
            if (goal == null) ...[
              const SizedBox(height: 6),
              Text(
                'حدّد هدف الوزن والدهون لمتابعة تقدّمك.',
                textAlign: TextAlign.right,
                style: TextStyle(color: Colors.grey[700], height: 1.35, fontSize: 13.5),
              ),
            ] else ...[
              const SizedBox(height: 10),
              _comparisonRow(
                labelCurrent: 'وزنك الحالي',
                labelTarget: 'هدف الوزن',
                current: weight,
                target: goal.targetWeight,
                unit: 'كجم',
              ),
              if (goal.targetBodyFat != null || fat != null) ...[
                const SizedBox(height: 14),
                _comparisonRow(
                  labelCurrent: 'دهونك الحالية',
                  labelTarget: 'هدف الدهون',
                  current: fat,
                  target: goal.targetBodyFat,
                  unit: '%',
                ),
              ],
              if (weight != null && goal.targetWeight != null) ...[
                const SizedBox(height: 10),
                _deltaHint(weight, goal.targetWeight!),
              ],
            ],
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => _openEdit(context, goal),
                style: OutlinedButton.styleFrom(
                  foregroundColor: _kPrimary,
                  side: BorderSide(color: _kPrimary.withValues(alpha: 0.45)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: Text(
                  goal == null ? 'تعيين الأهداف' : 'تعديل الأهداف',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openEdit(BuildContext context, ClientGoal? goal) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => EditGoalsScreen(existing: goal),
      ),
    );
  }

  Widget _comparisonRow({
    required String labelCurrent,
    required String labelTarget,
    required double? current,
    required double? target,
    required String unit,
  }) {
    return Row(
      children: [
        Expanded(
          child: _metricBlock(
            label: labelTarget,
            value: _fmt(target),
            unit: unit,
            highlight: true,
          ),
        ),
        Container(
          width: 1,
          height: 54,
          margin: const EdgeInsets.symmetric(horizontal: 10),
          color: Colors.grey.withValues(alpha: 0.25),
        ),
        Expanded(
          child: _metricBlock(
            label: labelCurrent,
            value: _fmt(current),
            unit: unit,
            highlight: false,
          ),
        ),
      ],
    );
  }

  Widget _metricBlock({
    required String label,
    required String value,
    required String unit,
    required bool highlight,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey[600],
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              unit,
              style: TextStyle(
                fontSize: 11,
                color: highlight ? _kPrimary : Colors.grey,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: highlight ? _kPrimary : _kDark,
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _fmt(double? v) {
    if (v == null) return '—';
    if (v == v.roundToDouble()) return v.toStringAsFixed(0);
    return v.toStringAsFixed(1);
  }

  Widget _deltaHint(double currentKg, double targetKg) {
    final d = (currentKg - targetKg).abs();
    if (d < 0.15) {
      return Text(
        'قريب جداً من هدف الوزن. استمر!',
        textAlign: TextAlign.right,
        style: TextStyle(fontSize: 12, color: Colors.green[700], height: 1.3),
      );
    }
    final losing = currentKg > targetKg;
    final text = losing
        ? 'متبقي نحو ${d.toStringAsFixed(1)} كغ للوصول لهدف الوزن'
        : 'يتبقى نحو ${d.toStringAsFixed(1)} كغ لزيادة الوزن حتى الهدف';

    return Text(
      text,
      textAlign: TextAlign.right,
      style: TextStyle(fontSize: 12, color: Colors.grey[700], height: 1.3),
    );
  }
}
