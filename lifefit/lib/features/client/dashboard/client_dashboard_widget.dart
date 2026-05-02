import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/auth/auth_provider.dart';
import '../../client/workouts/workout_provider.dart';
import '../../client/nutrition/nutrition_provider.dart';
import '../../client/progrees/measurements_provider.dart';
import '../../client/progrees/goals_provider.dart';
import '../../client/programs/client_programs_provider.dart';
import '../../client/profile_web/profile_provider_web.dart';
import 'widgets/greeting_header.dart';
import 'widgets/today_activity_row.dart';
import 'widgets/body_stats_row.dart';
import 'widgets/goal_progress_card.dart';
import 'widgets/active_program_card.dart';

class ClientDashboardWidget extends ConsumerWidget {
  const ClientDashboardWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;

    Future<void> doRefresh() async {
      await Future.wait([
        ref.read(todaySchedulesProvider.notifier).refresh(),
        ref.read(nutritionProvider.notifier).refresh(),
        ref.read(clientProfileWebProvider.notifier).refresh(),
        ref.read(goalsProvider.notifier).refresh(),
        ref.read(measurementsProvider.notifier).refresh(),
        ref.read(clientProgramsProvider.notifier).refresh(),
      ]);
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: RefreshIndicator(
        color: const Color(0xFF00D9D9),
        onRefresh: doRefresh,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // Greeting
            SliverToBoxAdapter(child: GreetingHeader(user: user)),

            const SliverToBoxAdapter(child: SizedBox(height: 20)),

            // Today's workout + nutrition side-by-side
            const SliverToBoxAdapter(child: _SectionLabel(
              title: 'نشاط اليوم',
              icon: Icons.today_rounded,
            )),
            const SliverToBoxAdapter(child: SizedBox(height: 10)),
            const SliverToBoxAdapter(child: TodayActivityRow()),

            const SliverToBoxAdapter(child: SizedBox(height: 24)),

            // Current body stats
            const SliverToBoxAdapter(child: BodyStatsRow()),

            const SliverToBoxAdapter(child: SizedBox(height: 24)),

            // Goal progress
            const SliverToBoxAdapter(child: GoalProgressCard()),

            const SliverToBoxAdapter(child: SizedBox(height: 24)),

            // Active program
            const SliverToBoxAdapter(child: ActiveProgramCard()),

            const SliverToBoxAdapter(child: SizedBox(height: 32)),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String title;
  final IconData icon;

  const _SectionLabel({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
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
      ),
    );
  }
}
