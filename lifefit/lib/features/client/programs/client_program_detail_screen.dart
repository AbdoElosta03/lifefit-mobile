import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/ui/app_colors.dart';
import '../../../core/services/client_program_service.dart';
import 'client_programs_provider.dart';
import 'widgets/program_header.dart';
import 'widgets/schedule_section.dart';
import 'widgets/program_error_view.dart';

/// Detailed view of a specific training program assigned to the client.
class ClientProgramDetailScreen extends ConsumerWidget {
  final int assignmentId;

  const ClientProgramDetailScreen({super.key, required this.assignmentId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the individual program assignment detail
    final async = ref.watch(clientProgramDetailProvider(assignmentId));
    final service = ClientProgramService();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: async.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2.5),
        ),
        error: (e, _) => ProgramErrorView(
          message: e.toString().replaceFirst('Exception: ', ''),
          onRetry: () =>
              ref.invalidate(clientProgramDetailProvider(assignmentId)),
        ),
        data: (detail) {
          return RefreshIndicator(
            color: AppColors.primary,
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
                // Header section with program and trainer information
                SliverToBoxAdapter(
                  child: ProgramDetailHeader(
                    detail: detail,
                    trainerImageUrl: service
                        .resolveMediaUrl(detail.trainer.profileImage),
                    onBack: () => Navigator.pop(context),
                  ),
                ),

                // Section header for training schedules
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        const Text(
                          'الجداول والتمارين',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.calendar_month_outlined,
                            size: 20, color: AppColors.primary),
                      ],
                    ),
                  ),
                ),

                // List of schedules (weeks/days)
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
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (_, i) => ScheduleSection(
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

