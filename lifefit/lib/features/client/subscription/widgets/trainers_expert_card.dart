import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/ui/app_colors.dart';

import '../../../../core/models/subscription/expert_model.dart';
import 'expert_subscription_payment.dart';

class TrainersExpertCard extends ConsumerWidget {
  final ExpertModel expert;

  const TrainersExpertCard({super.key, required this.expert});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isTrainer = expert.role == 'trainer';
    final roleLabel = isTrainer ? 'مدرب' : 'أخصائي تغذية';
    
    // Assign secondary colors based on role
    final roleColor =
        isTrainer ? AppColors.primary : const Color(0xFF3ABEF9);
    final lowest = expert.lowestPrice;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Gradient top bar status indicator
          Container(
            height: 4,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: expert.isSubscribed
                    ? [AppColors.primary, AppColors.primary.withOpacity(0.3)]
                    : [Colors.grey.shade300, Colors.grey.shade100],
                begin: Alignment.centerRight,
                end: Alignment.centerLeft,
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // ── Profile Info Row ───────────────────────────────
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _GradientAvatar(
                      url: expert.avatarUrl,
                      active: expert.isSubscribed,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            expert.name,
                            textAlign: TextAlign.right,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              if (expert.yearsExperience > 0) ...[
                                _InfoChip(
                                  '${expert.yearsExperience} سنوات خبرة',
                                  const Color(0xFFF59E0B),
                                ),
                                const SizedBox(width: 6),
                              ],
                              _InfoChip(roleLabel, roleColor),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                // ── Specialties ────────────────────────────────────
                if (expert.specialties.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    alignment: WrapAlignment.end,
                    children: expert.specialties
                        .take(3)
                        .map((s) => _InfoChip(s, const Color(0xFF8B5CF6)))
                        .toList(),
                  ),
                ],
                const SizedBox(height: 12),
                Divider(height: 1, color: Colors.grey.withOpacity(0.1)),
                const SizedBox(height: 12),

                // ── Pricing and Subscription Status ────────────────
                Row(
                  children: [
                    if (lowest != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          'من ${lowest.toStringAsFixed(0)} ر.س',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    const Spacer(),
                    if (expert.isSubscribed)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'مشترك',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              Icons.check_circle,
                              size: 14,
                              color: AppColors.primary,
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                
                // ── Action Button ──────────────────────────────────
                if (!expert.isSubscribed && expert.services.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () => ExpertSubscriptionPayment.start(
                        context,
                        ref,
                        expert: expert,
                      ),
                      child: const Text(
                        'اشترك الآن',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GradientAvatar extends StatelessWidget {
  final String? url;
  final bool active;

  const _GradientAvatar({this.url, this.active = false});

  @override
  Widget build(BuildContext context) {
    const size = 52.0;
    Widget inner;
    if (url != null && url!.isNotEmpty) {
      inner = ClipOval(
        child: Image.network(
          url!,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _fallback(size),
        ),
      );
    } else {
      inner = _fallback(size);
    }

    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: active
              ? [AppColors.primary, AppColors.primaryDark]
              : [Colors.grey.shade300, Colors.grey.shade400],
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(2),
        decoration:
            const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
        child: inner,
      ),
    );
  }

  Widget _fallback(double size) => CircleAvatar(
        radius: size / 2,
        backgroundColor: AppColors.primary.withOpacity(0.15),
        child: const Icon(Icons.person, color: AppColors.primary, size: 22),
      );
}

class _InfoChip extends StatelessWidget {
  final String label;
  final Color color;

  const _InfoChip(this.label, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
