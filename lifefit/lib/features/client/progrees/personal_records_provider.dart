import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/progress/personal_record.dart';
import '../../../core/services/progress_service.dart';

class PersonalRecordsNotifier
    extends StateNotifier<AsyncValue<List<PersonalRecord>>> {
  final ProgressService _service;

  PersonalRecordsNotifier(this._service) : super(const AsyncValue.loading()) {
    fetch();
  }

  Future<void> fetch() async {
    state = const AsyncValue.loading();
    try {
      final list = await _service.fetchPersonalRecords();
      state = AsyncValue.data(list);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> refresh() => fetch();
}

final personalRecordsProvider = StateNotifierProvider<PersonalRecordsNotifier,
    AsyncValue<List<PersonalRecord>>>((ref) {
  return PersonalRecordsNotifier(ProgressService());
});
