import 'package:flutter/material.dart';
import '../../../core/ui/app_colors.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'subscription_provider.dart';
import 'widgets/trainers_expert_card.dart';
import 'widgets/trainers_screen_widgets.dart';

/// Browse trainers and nutritionists, filter by role, start checkout.
/// Data flow: expertsProvider → local filter → TrainersExpertCard(expert).
class TrainersScreen extends ConsumerStatefulWidget {
  const TrainersScreen({super.key});

  @override
  ConsumerState<TrainersScreen> createState() => _TrainersScreenState();
}

class _TrainersScreenState extends ConsumerState<TrainersScreen> {
  /// 'all' | 'trainer' | 'nutritionist'
  String _filter = 'all';

  @override
  Widget build(BuildContext context) {
    // Watch expert list from provider.
    final async = ref.watch(expertsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: async.when(
        loading: () =>
            const Center(child: CircularProgressIndicator(color: AppColors.primary)),
        error: (e, _) => TrainersErrorView(
          message: e.toString().replaceFirst('Exception: ', ''),
          onRetry: () => ref.read(expertsProvider.notifier).refresh(),
        ),
        data: (experts) {
          // Client-side role filter — no extra API call.
          final filtered = _filter == 'all'
              ? experts
              : experts.where((e) => e.role == _filter).toList();

          return RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () => ref.read(expertsProvider.notifier).refresh(),
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              slivers: [
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
                                  size: 20, color: AppColors.textPrimary),
                              onPressed: () => Navigator.pop(context),
                            ),
                            const Spacer(),
                          ],
                        ),
                        const Text(
                          'المدربون ,وأخصائيو التغذية',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${experts.length} متاح',
                          style: const TextStyle(
                              fontSize: 14, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 4),
                    child: TrainersStatsBanner(experts: experts),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                    child: TrainersFilterChips(
                      current: _filter,
                      onChanged: (v) => setState(() => _filter = v),
                    ),
                  ),
                ),
                if (filtered.isEmpty)
                  const SliverToBoxAdapter(child: TrainersEmptyView())
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (_, i) =>
                            TrainersExpertCard(expert: filtered[i]),
                        childCount: filtered.length,
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
