import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../progrees/goals_provider.dart';
import '../../profile_web/profile_provider_web.dart';

/// Shows target weight vs current weight with a progress bar.
class GoalProgressCard extends ConsumerWidget {
  const GoalProgressCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goalsAsync = ref.watch(goalsProvider);
    final profileAsync = ref.watch(clientProfileWebProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _SectionTitle(title: 'هدف الوزن', icon: Icons.flag_outlined),
          const SizedBox(height: 10),
          goalsAsync.when(
            loading: () => _CardSkeleton(),
            error: (_, __) => const _EmptyCard(message: 'تعذر تحميل الأهداف'),
            data: (goals) {
              if (goals.isEmpty) {
                return const _EmptyCard(message: 'لم تُحدَّد أهداف بعد');
              }
              final goal = goals.first;
              final targetWeight = goal.targetWeight;
              if (targetWeight == null) {
                return const _EmptyCard(message: 'لا يوجد هدف وزن محدد');
              }

              final currentWeight = profileAsync.valueOrNull?.currentStats.weightKg;
              return _GoalCard(
                currentWeight: currentWeight,
                targetWeight: targetWeight,
                targetDate: goal.targetDate,
              );
            },
          ),
        ],
      ),
    );
  }
}

class _GoalCard extends StatelessWidget {
  final double? currentWeight;
  final double targetWeight;
  final DateTime? targetDate;

  const _GoalCard({
    this.currentWeight,
    required this.targetWeight,
    this.targetDate,
  });

  double get _progress {
    if (currentWeight == null) return 0;
    // If losing weight: progress = (start - current) / (start - target)
    // We approximate start as currentWeight + some offset; simpler: use target proximity
    final diff = (currentWeight! - targetWeight).abs();
    if (diff == 0) return 1.0;
    // Show progress as how close current is to target relative to a 30 kg range
    final pct = 1 - (diff / 30).clamp(0.0, 1.0);
    return pct;
  }

  Color get _progressColor {
    if (_progress >= 0.8) return const Color(0xFF22C55E);
    if (_progress >= 0.5) return const Color(0xFF00D9D9);
    return const Color(0xFF3ABEF9);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Target weight pill
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF00D9D9).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'الهدف: ${targetWeight.toStringAsFixed(1)} كغ',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF00D9D9),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              // Current weight
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    currentWeight != null
                        ? '${currentWeight!.toStringAsFixed(1)} كغ'
                        : '— كغ',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const Text(
                    'الوزن الحالي',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: _progress,
              minHeight: 10,
              backgroundColor: Colors.grey.withOpacity(0.1),
              valueColor: AlwaysStoppedAnimation<Color>(_progressColor),
            ),
          ),
          if (targetDate != null) ...[
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${(_progress * 100).toStringAsFixed(0)}% تقدم',
                  style: TextStyle(
                    fontSize: 12,
                    color: _progressColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'الهدف بحلول: ${_formatDate(targetDate!)}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  String _formatDate(DateTime d) =>
      '${d.day}/${d.month}/${d.year}';
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final IconData icon;
  const _SectionTitle({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1E293B),
          ),
        ),
        const SizedBox(width: 6),
        Icon(icon, size: 18, color: const Color(0xFF00D9D9)),
      ],
    );
  }
}

class _CardSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }
}

class _EmptyCard extends StatelessWidget {
  final String message;
  const _EmptyCard({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: const TextStyle(color: Colors.grey, fontSize: 13),
      ),
    );
  }
}
