import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/progress/body_measurement.dart';
import '../../../core/services/progress_service.dart';

class MeasurementsNotifier extends StateNotifier<AsyncValue<List<BodyMeasurement>>> {
  final ProgressService _service;

  MeasurementsNotifier(this._service) : super(const AsyncValue.loading()) {
    fetch();
  }

  Future<void> fetch() async {
    state = const AsyncValue.loading();
    try {
      final list = await _service.fetchAllMeasurements();
      state = AsyncValue.data(list);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> refresh() => fetch();

  Future<BodyMeasurement> submit(Map<String, dynamic> body) async {
    final created = await _service.storeMeasurement(body);
    await fetch();
    return created;
  }
}

final measurementsProvider =
    StateNotifierProvider<MeasurementsNotifier, AsyncValue<List<BodyMeasurement>>>(
  (ref) => MeasurementsNotifier(ProgressService()),
);
