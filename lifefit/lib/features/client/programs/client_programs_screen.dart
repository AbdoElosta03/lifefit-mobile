import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/models/programs/program_assignment_summary.dart';
import '../../../core/services/client_program_service.dart';
import 'client_program_detail_screen.dart';
import 'client_programs_provider.dart';

class ClientProgramsScreen extends ConsumerWidget {
  const ClientProgramsScreen({super.key});

  static const _primary = Color(0xFF00D9D9);
  static const _dark = Color(0xFF1E293B);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(clientProgramsProvider);
    final service = ClientProgramService();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: async.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: _primary, strokeWidth: 2.5),
        ),
        error: (e, _) => _ErrorView(
          message: e.toString().replaceFirst('Exception: ', ''),
          onRetry: () => ref.read(clientProgramsProvider.notifier).refresh(),
        ),
        data: (list) {
          if (list.isEmpty) {
            return const _EmptyView();
          }
          return RefreshIndicator(
            color: _primary,
            onRefresh: () => ref.read(clientProgramsProvider.notifier).refresh(),
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              slivers: [
                // ── Header ─────────────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 56, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.arrow_back_ios,
                                  size: 20, color: _dark),
                              onPressed: () => Navigator.pop(context),
                            ),
                            const Spacer(),
                          ],
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'برامجي التدريبية',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: _dark,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${list.length} برنامج مخصّص لك',
                          style: const TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ),

                // ── Stats Banner ────────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 4),
                    child: _StatsBanner(programs: list),
                  ),
                ),

                // ── Section title ───────────────────────────────
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(20, 24, 20, 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          'جميع البرامج',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: _dark,
                          ),
                        ),
                        SizedBox(width: 6),
                        Icon(Icons.fitness_center, size: 18, color: _primary),
                      ],
                    ),
                  ),
                ),

                // ── Programs list ───────────────────────────────
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, i) => _ProgramCard(
                        item: list[i],
                        imageUrl: service.resolveMediaUrl(list[i].trainerImage),
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => ClientProgramDetailScreen(
                              assignmentId: list[i].id,
                            ),
                          ),
                        ),
                      ),
                      childCount: list.length,
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
// Stats Banner  (like CaloriesCard in nutrition)
// ─────────────────────────────────────────

class _StatsBanner extends StatelessWidget {
  final List<ProgramAssignmentSummary> programs;
  const _StatsBanner({required this.programs});

  @override
  Widget build(BuildContext context) {
    final total = programs.length;
    final active =
        programs.where((p) => p.status?.toLowerCase() == 'active').length;
    final completed =
        programs.where((p) => p.status?.toLowerCase() == 'completed').length;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF00D9D9), Color(0xFF0099AA)],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00D9D9).withOpacity(0.28),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Icon(Icons.sports_gymnastics,
                  color: Colors.white, size: 36),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'البرامج النشطة',
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.85), fontSize: 13),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$active برنامج',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: LinearProgressIndicator(
              value: total > 0 ? active / total : 0,
              minHeight: 8,
              valueColor:
                  const AlwaysStoppedAnimation<Color>(Colors.white),
              backgroundColor: Colors.white.withOpacity(0.25),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'مكتمل: $completed',
                style: TextStyle(
                    color: Colors.white.withOpacity(0.8), fontSize: 12),
              ),
              Text(
                'الإجمالي: $total',
                style: TextStyle(
                    color: Colors.white.withOpacity(0.8), fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────
// Program Card
// ─────────────────────────────────────────

class _ProgramCard extends StatelessWidget {
  final ProgramAssignmentSummary item;
  final String imageUrl;
  final VoidCallback onTap;

  const _ProgramCard({
    required this.item,
    required this.imageUrl,
    required this.onTap,
  });

  static const _primary = Color(0xFF00D9D9);
  static const _dark = Color(0xFF1E293B);

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
              // Colored gradient top bar
              Container(
                height: 4,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      statusColor,
                      statusColor.withOpacity(0.3),
                    ],
                    begin: Alignment.centerRight,
                    end: Alignment.centerLeft,
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // ── Top row: avatar + info ──────────────────
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
                                  color: _dark,
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
                              // Status badge
                              Align(
                                alignment: Alignment.centerRight,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: statusColor.withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        statusLabel,
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          color: statusColor,
                                        ),
                                      ),
                                      const SizedBox(width: 5),
                                      Container(
                                        width: 6,
                                        height: 6,
                                        decoration: BoxDecoration(
                                          color: statusColor,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),
                    Divider(height: 1, color: Colors.grey.withOpacity(0.1)),
                    const SizedBox(height: 12),

                    // ── Bottom row: chips + arrow ───────────────
                    Row(
                      children: [
                        // Arrow button
                        Container(
                          padding: const EdgeInsets.all(7),
                          decoration: BoxDecoration(
                            color: _primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(9),
                          ),
                          child: const Icon(Icons.arrow_forward_ios,
                              size: 12, color: _primary),
                        ),
                        const Spacer(),
                        _chip(Icons.calendar_today_outlined, dateStr),
                        if (item.programDurationWeeks != null) ...[
                          const SizedBox(width: 6),
                          _chip(Icons.date_range_outlined,
                              '${item.programDurationWeeks} أسابيع'),
                        ],
                      ],
                    ),

                    const SizedBox(height: 10),

                    // Trainer name
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
      case 'scheduled':
        return const Color(0xFF8B5CF6);
      default:
        return Colors.grey;
    }
  }

  static String _statusLabel(String? s) {
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

  static Widget _chip(IconData icon, String label) {
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

// ─────────────────────────────────────────
// Trainer Avatar with gradient ring
// ─────────────────────────────────────────

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
        backgroundColor: const Color(0xFF00D9D9).withOpacity(0.2),
        child: const Icon(Icons.person, color: Color(0xFF00D9D9), size: 22),
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
            backgroundColor: const Color(0xFF00D9D9).withOpacity(0.2),
            child: const Icon(Icons.person, color: Color(0xFF00D9D9)),
          ),
        ),
      );
    }
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [Color(0xFF00D9D9), Color(0xFF0099AA)],
        ),
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

// ─────────────────────────────────────────
// Empty State
// ─────────────────────────────────────────

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: const Color(0xFF00D9D9).withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.fitness_center_outlined,
                size: 64,
                color: Color(0xFF00D9D9),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'لا توجد برامج بعد',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'لم يتم تخصيص برامج تدريبية لك بعد.\nتواصل مع المدرّب الخاص بك.',
              style: TextStyle(fontSize: 14, color: Colors.grey, height: 1.6),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
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
