import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/progress/client_goal.dart';
import '../../../core/services/progress_service.dart';

class GoalsNotifier extends StateNotifier<AsyncValue<List<ClientGoal>>> {
  final ProgressService _service;

  GoalsNotifier(this._service) : super(const AsyncValue.loading()) {
    fetch();
  }

  Future<void> fetch() async {
    state = const AsyncValue.loading();
    try {
      final list = await _service.fetchGoals();
      state = AsyncValue.data(list);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> refresh() => fetch();
}

final goalsProvider =
    StateNotifierProvider<GoalsNotifier, AsyncValue<List<ClientGoal>>>((ref) {
  return GoalsNotifier(ProgressService());
});
