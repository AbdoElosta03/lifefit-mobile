import 'package:flutter/material.dart';
import '../../../../core/ui/app_colors.dart';
import '../../../../core/models/programs/client_program_detail.dart';
import 'package:intl/intl.dart';

/// Top header for the program detail screen, using a thematic gradient background.
class ProgramDetailHeader extends StatelessWidget {
  final ClientProgramDetail detail;
  final String trainerImageUrl;
  final VoidCallback onBack;

  const ProgramDetailHeader({
    super.key,
    required this.detail,
    required this.trainerImageUrl,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final start = detail.startDate != null
        ? DateFormat.yMMMd('ar').format(detail.startDate!)
        : '—';
    final statusColor = _statusColor(detail.status);
    final statusLabel = _statusAr(detail.status);

    return Container(
      decoration: const BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 26),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Top navigation and status pill
              Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_ios,
                          color: Colors.white, size: 18),
                      onPressed: onBack,
                    ),
                  ),
                  const Spacer(),
                  _StatusPill(label: statusLabel, color: statusColor),
                ],
              ),

              const SizedBox(height: 18),

              // Trainer and Program info
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _TrainerAvatarWhite(url: trainerImageUrl),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          detail.program.name,
                          textAlign: TextAlign.right,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              detail.trainer.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(Icons.person_outline,
                                color: Colors.white.withOpacity(0.75),
                                size: 15),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              if (detail.program.description != null &&
                  detail.program.description!.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  detail.program.description!,
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.85),
                    fontSize: 13,
                    height: 1.45,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],

              const SizedBox(height: 20),

              // Stats overview row
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _StatItem(Icons.calendar_today_outlined, 'البدء', start),
                    _VDivider(),
                    _StatItem(
                      Icons.date_range_outlined,
                      'المدة',
                      detail.program.durationWeeks != null
                          ? '${detail.program.durationWeeks} أسابيع'
                          : '—',
                    ),
                    _VDivider(),
                    _StatItem(
                      Icons.speed_outlined,
                      'الصعوبة',
                      (detail.program.difficultyLevel != null &&
                              detail.program.difficultyLevel!.isNotEmpty)
                          ? detail.program.difficultyLevel!
                          : '—',
                    ),
                  ],
                ),
              ),

              // Client-specific notes
              if (detail.notes != null && detail.notes!.isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          detail.notes!,
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 12,
                            height: 1.4,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(Icons.notes_outlined,
                          color: Colors.white.withOpacity(0.7), size: 16),
                    ],
                  ),
                ),
              ],
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
      default:
        return Colors.white;
    }
  }

  String _statusAr(String? s) {
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
      default:
        return s;
    }
  }
}

class _StatusPill extends StatelessWidget {
  final String label;
  final Color color;
  const _StatusPill({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 12)),
          const SizedBox(width: 6),
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              color: color == AppColors.primary ? Colors.white : color,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _StatItem(this.icon, this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.white, size: 20),
        const SizedBox(height: 4),
        Text(value,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
            textAlign: TextAlign.center),
        Text(label,
            style: TextStyle(
                color: Colors.white.withOpacity(0.72), fontSize: 10)),
      ],
    );
  }
}

class _VDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
        height: 36, width: 1, color: Colors.white.withOpacity(0.25));
  }
}

class _TrainerAvatarWhite extends StatelessWidget {
  final String url;
  const _TrainerAvatarWhite({required this.url});

  @override
  Widget build(BuildContext context) {
    const size = 54.0;
    Widget child;
    if (url.isEmpty) {
      child = CircleAvatar(
        radius: size / 2,
        backgroundColor: Colors.white.withOpacity(0.3),
        child: const Icon(Icons.person, color: Colors.white, size: 24),
      );
    } else {
      child = ClipOval(
        child: Image.network(
          url,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => CircleAvatar(
            radius: size / 2,
            backgroundColor: Colors.white.withOpacity(0.3),
            child: const Icon(Icons.person, color: Colors.white),
          ),
        ),
      );
    }
    return Container(
      padding: const EdgeInsets.all(2.5),
      decoration:
          BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(0.35)),
      child: child,
    );
  }
}
