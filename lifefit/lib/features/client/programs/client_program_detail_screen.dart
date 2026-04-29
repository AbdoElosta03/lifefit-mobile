import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/models/programs/client_program_detail.dart';
import '../../../core/services/client_program_service.dart';
import 'client_programs_provider.dart';

class ClientProgramDetailScreen extends ConsumerWidget {
  final int assignmentId;

  const ClientProgramDetailScreen({super.key, required this.assignmentId});

  static const _primary = Color(0xFF00D9D9);
  static const _dark = Color(0xFF1E293B);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(clientProgramDetailProvider(assignmentId));
    final service = ClientProgramService();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        centerTitle: true,
        title: async.maybeWhen(
          data: (d) => Text(
            d.program.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 17,
            ),
          ),
          orElse: () => const Text(
            'تفاصيل البرنامج',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: async.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: _primary, strokeWidth: 2.5),
        ),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.error_outline, size: 48, color: Colors.red.shade400),
                const SizedBox(height: 12),
                Text(
                  e.toString(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    ref.invalidate(clientProgramDetailProvider(assignmentId));
                  },
                  child: const Text('إعادة المحاولة'),
                ),
              ],
            ),
          ),
        ),
        data: (detail) {
          return RefreshIndicator(
            color: _primary,
            onRefresh: () async {
              ref.invalidate(clientProgramDetailProvider(assignmentId));
              await ref.read(clientProgramDetailProvider(assignmentId).future);
            },
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
              children: [
                _MetaCard(
                  detail: detail,
                  trainerImageUrl: service.resolveMediaUrl(detail.trainer.profileImage),
                ),
                const SizedBox(height: 16),
                const Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    'الجداول والتمارين',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: _dark,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                if (detail.schedules.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Text(
                      'لا توجد جداول لهذا البرنامج.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                  )
                else
                  ...detail.schedules.map(
                    (s) => _ScheduleSection(
                      entry: s,
                      service: service,
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

class _MetaCard extends StatelessWidget {
  final ClientProgramDetail detail;
  final String trainerImageUrl;

  const _MetaCard({
    required this.detail,
    required this.trainerImageUrl,
  });

  @override
  Widget build(BuildContext context) {
    final start = detail.startDate != null
        ? DateFormat.yMMMd('ar').format(detail.startDate!)
        : '—';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (detail.program.description != null &&
              detail.program.description!.isNotEmpty) ...[
            Text(
              detail.program.description!,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
                height: 1.4,
              ),
            ),
            const SizedBox(height: 14),
          ],
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      detail.trainer.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'المدرّب',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              _RoundImage(url: trainerImageUrl),
            ],
          ),
          const Divider(height: 24),
          _rowMeta('تاريخ البدء', start),
          if (detail.program.durationWeeks != null)
            _rowMeta('المدة', '${detail.program.durationWeeks} أسابيع'),
          if (detail.program.difficultyLevel != null &&
              detail.program.difficultyLevel!.isNotEmpty)
            _rowMeta('الصعوبة', detail.program.difficultyLevel!),
          _rowMeta('الحالة', _statusAr(detail.status)),
          if (detail.notes != null && detail.notes!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'ملاحظات',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              detail.notes!,
              textAlign: TextAlign.right,
              style: TextStyle(fontSize: 13, color: Colors.grey[800], height: 1.35),
            ),
          ],
        ],
      ),
    );
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

  static Widget _rowMeta(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: Color(0xFF1E293B),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}

class _RoundImage extends StatelessWidget {
  final String url;

  const _RoundImage({required this.url});

  @override
  Widget build(BuildContext context) {
    const r = 28.0;
    if (url.isEmpty) {
      return CircleAvatar(
        radius: r,
        backgroundColor: const Color(0xFF00D9D9).withValues(alpha: 0.2),
        child: const Icon(Icons.person, color: Color(0xFF00D9D9)),
      );
    }
    return CircleAvatar(
      radius: r,
      backgroundImage: NetworkImage(url),
      onBackgroundImageError: (_, __) {},
      child: null,
    );
  }
}

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
    final dayPart = entry.dayOfWeek != null ? 'يوم ${entry.dayOfWeek}' : 'يوم —';
    final weekPart =
        entry.weekNumber != null ? 'الأسبوع ${entry.weekNumber}' : null;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        iconColor: _primary,
        collapsedIconColor: _primary,
        title: Align(
          alignment: Alignment.centerRight,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                w.name,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                  color: _dark,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                [weekPart, dayPart].whereType<String>().join(' · '),
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
        children: [
          if (w.description != null && w.description!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Text(
                w.description!,
                textAlign: TextAlign.right,
                style: TextStyle(fontSize: 13, color: Colors.grey[700], height: 1.35),
              ),
            ),
          if (w.exercises.isEmpty)
            Text(
              'لا تمارين في هذا التمرين.',
              style: TextStyle(color: Colors.grey[600], fontSize: 13),
            )
          else
            ...w.exercises.map((e) => _ExerciseTile(exercise: e, service: service)),
        ],
      ),
    );
  }
}

class _ExerciseTile extends StatelessWidget {
  final ProgramExerciseRow exercise;
  final ClientProgramService service;

  const _ExerciseTile({
    required this.exercise,
    required this.service,
  });

  static const _dark = Color(0xFF1E293B);

  @override
  Widget build(BuildContext context) {
    final img = service.resolveMediaUrl(exercise.imageUrl);
    final meta = <String>[
      if (exercise.sets != null) '${exercise.sets} مجموعات',
      if (exercise.reps != null) '${exercise.reps} تكرارات',
      if (exercise.durationMinutes != null) '${exercise.durationMinutes} د',
      if (exercise.restSeconds != null) 'راحة ${exercise.restSeconds}ث',
    ].join(' · ');

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (img.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                img,
                width: 56,
                height: 56,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 56,
                  height: 56,
                  color: Colors.grey[200],
                  child: const Icon(Icons.fitness_center, color: Colors.grey),
                ),
              ),
            )
          else
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.sports_gymnastics, color: Colors.grey),
            ),
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
                    color: _dark,
                  ),
                ),
                if (exercise.muscleGroup != null &&
                    exercise.muscleGroup!.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    exercise.muscleGroup!,
                    textAlign: TextAlign.right,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
                if (meta.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    meta,
                    textAlign: TextAlign.right,
                    style: TextStyle(fontSize: 11, color: Colors.grey[700]),
                  ),
                ],
                if (exercise.notes != null && exercise.notes!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    exercise.notes!,
                    textAlign: TextAlign.right,
                    style: TextStyle(fontSize: 11, color: Colors.grey[600], height: 1.3),
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
