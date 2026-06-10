import 'package:flutter/material.dart';
import '../../../../core/ui/app_colors.dart';
import '../../../../core/models/programs/program_assignment_summary.dart';
import 'package:intl/intl.dart';

/// Card showing summary info for a single program assignment.
class ProgramSummaryCard extends StatelessWidget {
  final ProgramAssignmentSummary item;
  final String imageUrl;
  final VoidCallback onTap;

  const ProgramSummaryCard({
    super.key,
    required this.item,
    required this.imageUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final dateStr = item.startDate != null
        ? DateFormat.yMMMd('ar').format(item.startDate!)
        : '—';
    final statusColor = _statusColor(item.status);
    final statusLabel = _statusLabel(item.status);

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
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Column(
            children: [
              // Indicator bar based on status
              Container(
                height: 4,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [statusColor, statusColor.withOpacity(0.3)],
                    begin: Alignment.centerRight,
                    end: Alignment.centerLeft,
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _TrainerAvatar(url: imageUrl),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                item.programName,
                                textAlign: TextAlign.right,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              if (item.programDescription != null &&
                                  item.programDescription!.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text(
                                  item.programDescription!,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.right,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                    height: 1.4,
                                  ),
                                ),
                              ],
                              const SizedBox(height: 8),
                              _StatusBadge(label: statusLabel, color: statusColor),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),
                    Divider(height: 1, color: Colors.grey.withOpacity(0.1)),
                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(7),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(9),
                          ),
                          child: const Icon(Icons.arrow_forward_ios,
                              size: 12, color: AppColors.primary),
                        ),
                        const Spacer(),
                        _InfoChip(Icons.calendar_today_outlined, dateStr),
                        if (item.programDurationWeeks != null) ...[
                          const SizedBox(width: 6),
                          _InfoChip(Icons.date_range_outlined,
                              '${item.programDurationWeeks} أسابيع'),
                        ],
                      ],
                    ),

                    const SizedBox(height: 10),

                    // Trainer Name reference
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          item.trainerName,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(Icons.person_outline,
                            size: 15, color: Colors.grey[500]),
                      ],
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

  Color _statusColor(String? s) {
    switch (s?.toLowerCase()) {
      case 'active':
        return AppColors.primary;
      case 'completed':
        return const Color(0xFF3ABEF9);
      case 'paused':
        return const Color(0xFFF59E0B);
      case 'cancelled':
      case 'canceled':
        return const Color(0xFFEF4444);
      case 'scheduled':
        return const Color(0xFF8B5CF6);
      default:
        return Colors.grey;
    }
  }

  String _statusLabel(String? s) {
    if (s == null || s.isEmpty) return '—';
    switch (s.toLowerCase()) {
      case 'active':
        return 'نشط';
      case 'completed':
        return 'مكتمل';
      case 'paused':
        return 'متوقف';
      case 'cancelled':
      case 'canceled':
        return 'ملغى';
      case 'scheduled':
        return 'مجدول';
      default:
        return s;
    }
  }
}

class _StatusBadge extends StatelessWidget {
  final String label;
  final Color color;
  const _StatusBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label,
                style: TextStyle(
                    fontSize: 11, fontWeight: FontWeight.w700, color: color)),
            const SizedBox(width: 5),
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _InfoChip(this.icon, this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(9),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Color(0xFF64748B),
            ),
          ),
          const SizedBox(width: 4),
          Icon(icon, size: 12, color: const Color(0xFF64748B)),
        ],
      ),
    );
  }
}

class _TrainerAvatar extends StatelessWidget {
  final String url;
  const _TrainerAvatar({required this.url});

  @override
  Widget build(BuildContext context) {
    const size = 52.0;
    Widget inner;
    if (url.isEmpty) {
      inner = CircleAvatar(
        radius: size / 2,
        backgroundColor: AppColors.primary.withOpacity(0.2),
        child: const Icon(Icons.person, color: AppColors.primary, size: 22),
      );
    } else {
      inner = ClipOval(
        child: Image.network(
          url,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => CircleAvatar(
            radius: size / 2,
            backgroundColor: AppColors.primary.withOpacity(0.2),
            child: const Icon(Icons.person, color: AppColors.primary),
          ),
        ),
      );
    }
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: AppColors.primaryGradient,
      ),
      child: Container(
        padding: const EdgeInsets.all(2),
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
        child: inner,
      ),
    );
  }
}
