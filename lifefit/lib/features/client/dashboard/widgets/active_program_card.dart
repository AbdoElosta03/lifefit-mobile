import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../programs/client_programs_provider.dart';

/// Displays the first active/recent program assigned to the client.
class ActiveProgramCard extends ConsumerWidget {
  const ActiveProgramCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final programsAsync = ref.watch(clientProgramsProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _SectionTitle(title: 'البرنامج الحالي', icon: Icons.star_outline_rounded),
          const SizedBox(height: 10),
          programsAsync.when(
            loading: () => _CardSkeleton(),
            error: (_, __) => const _EmptyCard(message: 'تعذر تحميل البرنامج'),
            data: (programs) {
              if (programs.isEmpty) {
                return const _EmptyCard(message: 'لم يُعيَّن برنامج بعد');
              }

              // Show the first active program, or the most recent one
              final program = programs.firstWhere(
                (p) => p.status == 'active',
                orElse: () => programs.first,
              );

              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1E293B), Color(0xFF334155)],
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF1E293B).withOpacity(0.2),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Status badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: program.status == 'active'
                                ? const Color(0xFF00D9D9).withOpacity(0.2)
                                : Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            program.status == 'active' ? 'نشط' : (program.status ?? ''),
                            style: TextStyle(
                              fontSize: 11,
                              color: program.status == 'active'
                                  ? const Color(0xFF00D9D9)
                                  : Colors.white70,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        // Program name
                        Flexible(
                          child: Text(
                            program.programName,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.right,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Trainer row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          program.trainerName,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.white70,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFF00D9D9).withOpacity(0.2),
                          ),
                          child: const Icon(
                            Icons.person_outline,
                            size: 16,
                            color: Color(0xFF00D9D9),
                          ),
                        ),
                      ],
                    ),

                    if (program.programDurationWeeks != null ||
                        program.startDate != null) ...[
                      const SizedBox(height: 12),
                      const Divider(color: Colors.white12, height: 1),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          if (program.programDurationWeeks != null) ...[
                            _InfoChip(
                              icon: Icons.calendar_today_outlined,
                              text: '${program.programDurationWeeks} أسابيع',
                            ),
                            const SizedBox(width: 10),
                          ],
                          if (program.startDate != null)
                            _InfoChip(
                              icon: Icons.play_arrow_rounded,
                              text: _formatDate(program.startDate!),
                            ),
                        ],
                      ),
                    ],
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime d) => '${d.day}/${d.month}/${d.year}';
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String text;
  const _InfoChip({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(text, style: const TextStyle(fontSize: 12, color: Colors.white60)),
        const SizedBox(width: 4),
        Icon(icon, size: 13, color: Colors.white60),
      ],
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

class _CardSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
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
