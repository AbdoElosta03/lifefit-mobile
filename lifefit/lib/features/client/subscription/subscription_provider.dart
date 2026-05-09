import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/subscription/expert_model.dart';
import '../../../core/models/subscription/my_subscription_model.dart';
import '../../../core/services/subscription_service.dart';

// ─── Experts Provider ─────────────────────────────────────────────────────────

class ExpertsNotifier
    extends StateNotifier<AsyncValue<List<ExpertModel>>> {
  final SubscriptionService _service;

  ExpertsNotifier(this._service) : super(const AsyncValue.loading()) {
    fetch();
  }

  Future<void> fetch() async {
    state = const AsyncValue.loading();
    try {
      state = AsyncValue.data(await _service.fetchExperts());
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> refresh() => fetch();
}

final expertsProvider = StateNotifierProvider<
    ExpertsNotifier, AsyncValue<List<ExpertModel>>>(
  (ref) => ExpertsNotifier(SubscriptionService()),
);

// ─── My Subscriptions Provider ────────────────────────────────────────────────

final mySubscriptionsProvider =
    FutureProvider.autoDispose<List<MySubscription>>((ref) {
  return SubscriptionService().fetchMySubscriptions();
});
