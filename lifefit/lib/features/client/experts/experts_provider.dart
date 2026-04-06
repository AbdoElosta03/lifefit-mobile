import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/experts.dart';
import '../../../core/services/api_service.dart';

class ExpertsProvider extends StateNotifier<AsyncValue<List<Experts>>> {
  final ApiService _apiService = ApiService();

  ExpertsProvider() : super(const AsyncLoading()) {
    fetchExperts();
  }

  Future<void> fetchExperts() async {
    state = const AsyncLoading();
    try {
      final response = await _apiService.getExperts();
      if (response == null || response.statusCode != 200) {
        throw Exception("خطا في السيرفر: ${response?.statusCode}");
      }

      final List expertsData = response.data['experts'] ?? [];
      final experts = expertsData
          .map((data) => Experts.fromJson(data as Map<String, dynamic>))
          .toList();

      state = AsyncValue.data(experts);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  // Final provider to be used in the app
  static final provider =
      StateNotifierProvider<ExpertsProvider, AsyncValue<List<Experts>>>(
        (ref) => ExpertsProvider(),
      );
}
