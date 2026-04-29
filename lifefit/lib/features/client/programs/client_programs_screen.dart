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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(clientProgramsProvider);
    final service = ClientProgramService();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        centerTitle: true,
        title: const Text(
          'برامجي',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
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
                  onPressed: () => ref.read(clientProgramsProvider.notifier).refresh(),
                  child: const Text('إعادة المحاولة'),
                ),
              ],
            ),
          ),
        ),
        data: (list) {
          if (list.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Text(
                  'لا توجد برامج مخصّصة لك بعد.',
                  style: TextStyle(color: Colors.grey[600], fontSize: 15),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          return RefreshIndicator(
            color: _primary,
            onRefresh: () => ref.read(clientProgramsProvider.notifier).refresh(),
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
              itemCount: list.length,
              itemBuilder: (context, i) {
                return _ProgramCard(
                  item: list[i],
                  imageUrl: service.resolveMediaUrl(list[i].trainerImage),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => ClientProgramDetailScreen(assignmentId: list[i].id),
                      ),
                    );
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}

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

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            item.programName,
                            textAlign: TextAlign.right,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              color: _dark,
                            ),
                          ),
                          if (item.programDescription != null &&
                              item.programDescription!.isNotEmpty) ...[
                            const SizedBox(height: 6),
                            Text(
                              item.programDescription!,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[600],
                                height: 1.35,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    _TrainerAvatar(url: imageUrl),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.chevron_left, color: Colors.grey[400], size: 22),
                    const Spacer(),
                    Text(
                      item.trainerName,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[800],
                      ),
                    ),
                    const SizedBox(width: 6),
                    Icon(Icons.person_outline, size: 18, color: Colors.grey[600]),
                  ],
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.end,
                  children: [
                    _chip(Icons.flag_outlined, _statusLabel(item.status)),
                    _chip(Icons.calendar_today_outlined, dateStr),
                    if (item.programDurationWeeks != null)
                      _chip(
                        Icons.date_range_outlined,
                        '${item.programDurationWeeks} أسابيع',
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: _primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: _dark,
            ),
          ),
          const SizedBox(width: 4),
          Icon(icon, size: 14, color: _primary),
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
    if (url.isEmpty) {
      return CircleAvatar(
        radius: size / 2,
        backgroundColor: const Color(0xFF00D9D9).withValues(alpha: 0.2),
        child: const Icon(Icons.fitness_center, color: Color(0xFF00D9D9)),
      );
    }
    return ClipOval(
      child: Image.network(
        url,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => CircleAvatar(
          radius: size / 2,
          backgroundColor: const Color(0xFF00D9D9).withValues(alpha: 0.2),
          child: const Icon(Icons.person, color: Color(0xFF00D9D9)),
        ),
      ),
    );
  }
}
