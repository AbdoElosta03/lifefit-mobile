import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' hide TextDirection;

import '../../../core/models/programs/client_program_detail.dart';
import '../../../core/services/client_program_service.dart';
import 'client_programs_provider.dart';

class ClientProgramDetailScreen extends ConsumerWidget {
  final int assignmentId;

  const ClientProgramDetailScreen({super.key, required this.assignmentId});

  static const _primary = Color(0xFF00D9D9);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(clientProgramDetailProvider(assignmentId));
    final service = ClientProgramService();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: async.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: _primary, strokeWidth: 2.5),
        ),
        error: (e, _) => _ErrorView(
          message: e.toString().replaceFirst('Exception: ', ''),
          onRetry: () =>
              ref.invalidate(clientProgramDetailProvider(assignmentId)),
        ),
        data: (detail) {
          return RefreshIndicator(
            color: _primary,
            onRefresh: () async {
              ref.invalidate(clientProgramDetailProvider(assignmentId));
              await ref
                  .read(clientProgramDetailProvider(assignmentId).future);
            },
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              slivers: [
                // ── Gradient Hero Header ────────────────────────
                SliverToBoxAdapter(
                  child: _ProgramHeader(
                    detail: detail,
                    trainerImageUrl: service
                        .resolveMediaUrl(detail.trainer.profileImage),
                    onBack: () => Navigator.pop(context),
                  ),
                ),

                // ── Schedules section title ─────────────────────
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(20, 24, 20, 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          'الجداول والتمارين',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        SizedBox(width: 6),
                        Icon(Icons.calendar_month_outlined,
                            size: 20, color: _primary),
                      ],
                    ),
                  ),
                ),

                // ── Schedules ───────────────────────────────────
                if (detail.schedules.isEmpty)
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 48),
                      child: Center(
                        child: Text(
                          'لا توجد جداول لهذا البرنامج.',
                          style:
                              TextStyle(color: Colors.grey, fontSize: 14),
                        ),
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (_, i) => _ScheduleSection(
                          entry: detail.schedules[i],
                          service: service,
                        ),
                        childCount: detail.schedules.length,
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────
// Gradient Hero Header
// ─────────────────────────────────────────

class _ProgramHeader extends StatelessWidget {
  final ClientProgramDetail detail;
  final String trainerImageUrl;
  final VoidCallback onBack;

  const _ProgramHeader({
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
        gradient: LinearGradient(
          colors: [Color(0xFF00D9D9), Color(0xFF0099AA)],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
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
              // ── Top bar: back + status ──────────────────────
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
                  // Status pill
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          statusLabel,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          width: 7,
                          height: 7,
                          decoration: BoxDecoration(
                            color: statusColor == const Color(0xFF00D9D9)
                                ? Colors.white
                                : statusColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              // ── Trainer + Program name ──────────────────────
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

              // ── Stats row ──────────────────────────────────
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _statItem(Icons.calendar_today_outlined, 'البدء', start),
                    _vDivider(),
                    _statItem(
                      Icons.date_range_outlined,
                      'المدة',
                      detail.program.durationWeeks != null
                          ? '${detail.program.durationWeeks} أسابيع'
                          : '—',
                    ),
                    _vDivider(),
                    _statItem(
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

              // ── Notes ──────────────────────────────────────
              if (detail.notes != null && detail.notes!.isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 10),
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

  static Widget _statItem(IconData icon, String label, String value) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.white, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
          textAlign: TextAlign.center,
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.72),
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  static Widget _vDivider() {
    return Container(
      height: 36,
      width: 1,
      color: Colors.white.withOpacity(0.25),
    );
  }

  static Color _statusColor(String? s) {
    switch (s?.toLowerCase()) {
      case 'active':
        return const Color(0xFF00D9D9);
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

  static String _statusAr(String? s) {
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

// ─────────────────────────────────────────
// Trainer Avatar (white style for gradient bg)
// ─────────────────────────────────────────

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
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withOpacity(0.35),
      ),
      child: child,
    );
  }
}

// ─────────────────────────────────────────
// Schedule Section
// ─────────────────────────────────────────

class _ScheduleSection extends StatelessWidget {
  final ProgramScheduleEntry entry;
  final ClientProgramService service;

  const _ScheduleSection({
    required this.entry,
    required this.service,
  });

  static const _primary = Color(0xFF00D9D9);
  static const _dark = Color(0xFF1E293B);

  @override
  Widget build(BuildContext context) {
    final w = entry.workout;
    final dayPart =
        entry.dayOfWeek != null ? 'يوم ${entry.dayOfWeek}' : '';
    final weekPart =
        entry.weekNumber != null ? 'أسبوع ${entry.weekNumber}' : null;
    final subtitle = [if (weekPart != null) weekPart, if (dayPart.isNotEmpty) dayPart]
        .join(' · ');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            tilePadding:
                const EdgeInsets.fromLTRB(14, 8, 14, 8),
            childrenPadding:
                const EdgeInsets.fromLTRB(14, 0, 14, 14),
            iconColor: _primary,
            collapsedIconColor: Colors.grey[400],
            title: Row(
              children: [
                // Exercise count badge
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 9, vertical: 4),
                  decoration: BoxDecoration(
                    color: _primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${w.exercises.length} تمرين',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: _primary,
                    ),
                  ),
                ),
                const Spacer(),
                // Workout name + day
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      w.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                        color: _dark,
                      ),
                    ),
                    if (subtitle.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text(
                        subtitle,
                        style: TextStyle(
                            fontSize: 11, color: Colors.grey[600]),
                      ),
                    ],
                  ],
                ),
              ],
            ),
            children: [
              if (w.description != null && w.description!.isNotEmpty)
                Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    w.description!,
                    textAlign: TextAlign.right,
                    style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[700],
                        height: 1.4),
                  ),
                ),
              if (w.exercises.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    'لا تمارين في هذا التمرين.',
                    style: TextStyle(
                        color: Colors.grey[600], fontSize: 13),
                    textAlign: TextAlign.center,
                  ),
                )
              else
                ...w.exercises.map(
                  (e) => _ExerciseTile(exercise: e, service: service),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────
// Exercise Tile
// ─────────────────────────────────────────

class _ExerciseTile extends StatelessWidget {
  final ProgramExerciseRow exercise;
  final ClientProgramService service;

  const _ExerciseTile({
    required this.exercise,
    required this.service,
  });

  @override
  Widget build(BuildContext context) {
    final img = service.resolveMediaUrl(exercise.imageUrl);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ExerciseImage(url: img),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  exercise.name,
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: Color(0xFF1E293B),
                  ),
                ),
                if (exercise.muscleGroup != null &&
                    exercise.muscleGroup!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color:
                            const Color(0xFF8B5CF6).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        exercise.muscleGroup!,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF8B5CF6),
                        ),
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 6),
                Wrap(
                  spacing: 5,
                  runSpacing: 4,
                  textDirection: TextDirection.rtl,
                  children: [
                    if (exercise.sets != null)
                      _metaChip(
                          '${exercise.sets} مج', const Color(0xFF00D9D9)),
                    if (exercise.reps != null)
                      _metaChip('${exercise.reps} تكرار',
                          const Color(0xFF3ABEF9)),
                    if (exercise.durationMinutes != null)
                      _metaChip('${exercise.durationMinutes} د',
                          const Color(0xFFF59E0B)),
                    if (exercise.restSeconds != null)
                      _metaChip('راحة ${exercise.restSeconds}ث',
                          const Color(0xFFEF4444)),
                  ],
                ),
                if (exercise.notes != null &&
                    exercise.notes!.isNotEmpty) ...[
                  const SizedBox(height: 5),
                  Text(
                    exercise.notes!,
                    textAlign: TextAlign.right,
                    style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[600],
                        height: 1.3),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget _metaChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(7),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────
// Exercise Image
// ─────────────────────────────────────────

class _ExerciseImage extends StatelessWidget {
  final String url;
  const _ExerciseImage({required this.url});

  @override
  Widget build(BuildContext context) {
    if (url.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          url,
          width: 66,
          height: 66,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _placeholder(),
        ),
      );
    }
    return _placeholder();
  }

  Widget _placeholder() {
    return Container(
      width: 66,
      height: 66,
      decoration: BoxDecoration(
        color: const Color(0xFF00D9D9).withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Icon(Icons.sports_gymnastics,
          color: Color(0xFF00D9D9), size: 28),
    );
  }
}

// ─────────────────────────────────────────
// Error State
// ─────────────────────────────────────────

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.wifi_off_rounded, size: 56, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'تعذّر التحميل',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: const TextStyle(fontSize: 13, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00D9D9),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
              icon: const Icon(Icons.refresh),
              label: const Text('إعادة المحاولة',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
