import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../profile_web/profile_provider_web.dart';

/// Three tiles: current weight, body fat %, muscle mass — from profile API.
class BodyStatsRow extends ConsumerWidget {
  const BodyStatsRow({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(clientProfileWebProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _SectionTitle(title: 'قياساتك الحالية', icon: Icons.monitor_weight_outlined),
          const SizedBox(height: 10),
          profileAsync.when(
            loading: () => _StatsRowSkeleton(),
            error: (_, __) => const _StatsRowEmpty(),
            data: (bundle) {
              final stats = bundle.currentStats;
              final hasAny = stats.weightKg != null ||
                  stats.bodyFatPct != null ||
                  stats.muscleMassKg != null;

              if (!hasAny) return const _StatsRowEmpty();

              return Row(
                children: [
                  if (stats.weightKg != null)
                    Expanded(
                      child: _StatTile(
                        icon: Icons.scale_outlined,
                        color: const Color(0xFF6366F1),
                        label: 'الوزن',
                        value: '${stats.weightKg!.toStringAsFixed(1)} كغ',
                      ),
                    ),
                  if (stats.weightKg != null && stats.bodyFatPct != null)
                    const SizedBox(width: 10),
                  if (stats.bodyFatPct != null)
                    Expanded(
                      child: _StatTile(
                        icon: Icons.water_drop_outlined,
                        color: const Color(0xFFEF4444),
                        label: 'الدهون',
                        value: '${stats.bodyFatPct!.toStringAsFixed(1)}%',
                      ),
                    ),
                  if (stats.muscleMassKg != null) ...[
                    if (stats.bodyFatPct != null || stats.weightKg != null)
                      const SizedBox(width: 10),
                    Expanded(
                      child: _StatTile(
                        icon: Icons.bolt_outlined,
                        color: const Color(0xFF00D9D9),
                        label: 'العضلات',
                        value: '${stats.muscleMassKg!.toStringAsFixed(1)} كغ',
                      ),
                    ),
                  ],
                ],
              );
            },
          ),
        ],
      ),
    );
  }
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

class _StatTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final String value;
  const _StatTile({
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
        ],
      ),
    );
  }
}

class _StatsRowSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(
        3,
        (_) => Expanded(
          child: Container(
            height: 90,
            margin: const EdgeInsets.only(right: 10),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(18),
            ),
          ),
        ),
      ),
    );
  }
}

class _StatsRowEmpty extends StatelessWidget {
  const _StatsRowEmpty();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Text(
        'لم تُسجَّل قياسات بعد',
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.grey, fontSize: 13),
      ),
    );
  }
}
