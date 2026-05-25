import 'package:flutter/material.dart';
import '../../../core/ui/app_colors.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'subscription_provider.dart';
import 'widgets/trainers_expert_card.dart';
import 'widgets/trainers_screen_widgets.dart';

class TrainersScreen extends ConsumerStatefulWidget {
  const TrainersScreen({super.key});

  @override
  ConsumerState<TrainersScreen> createState() => _TrainersScreenState();
}

class _TrainersScreenState extends ConsumerState<TrainersScreen> {
  /// 'all' | 'trainer' | 'nutritionist'
  String _filter = 'all';

  static const _primary = Color(0xFF00D9D9);
  static const _dark = Color(0xFF1E293B);

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(expertsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: async.when(
        loading: () =>
            const Center(child: CircularProgressIndicator(color: _primary)),
        error: (e, _) => TrainersErrorView(
          message: e.toString().replaceFirst('Exception: ', ''),
          onRetry: () => ref.read(expertsProvider.notifier).refresh(),
        ),
        data: (experts) {
          final filtered = _filter == 'all'
              ? experts
              : experts.where((e) => e.role == _filter).toList();

          return RefreshIndicator(
            color: _primary,
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
                                  size: 20, color: _dark),
                              onPressed: () => Navigator.pop(context),
                            ),
                            const Spacer(),
                          ],
                        ),
                        const Text(
                          'المدربون والمتخصصون',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: _dark,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${experts.length} متخصص متاح',
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
