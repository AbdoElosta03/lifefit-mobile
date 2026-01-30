import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/health_profile.dart';
import '../../../core/services/api_service.dart';

class HealthProfileState {
  final HealthProfile? profile;
  final bool isLoading;
  final String? message;

  HealthProfileState({this.profile, this.isLoading = false, this.message});

  HealthProfileState copyWith({HealthProfile? profile, bool? isLoading, String? message}) {
    return HealthProfileState(
      profile: profile ?? this.profile,
      isLoading: isLoading ?? this.isLoading,
      message: message,
    );
  }
}

class HealthProfileNotifier extends StateNotifier<HealthProfileState> {
  final ApiService _api = ApiService();

  HealthProfileNotifier() : super(HealthProfileState()) {
    fetch();
  }

  Future<void> fetch() async {
    state = state.copyWith(isLoading: true, message: null);
    final res = await _api.getHealthProfile();
    if (res != null && res.statusCode == 200) {
      final body = res.data;
      if (body['status'] == 'success') {
        state = HealthProfileState(
          profile: HealthProfile.fromJson(body['data']),
          isLoading: false,
        );
      } else {
        state = HealthProfileState(isLoading: false, message: body['message']);
      }
    } else {
      state = HealthProfileState(isLoading: false, message: 'تعذر جلب الملف الصحي');
    }
  }

  Future<String?> save({
    double? heightCm,
    double? targetWeightKg,
    String? goalNotes,
    String? birthDate,
    String? activity,
  }) async {
    final res = await _api.saveHealthProfile({
      'height_cm': heightCm,
      'target_weight_kg': targetWeightKg,
      'goal_notes': goalNotes,
      'birth_date': birthDate,
      'current_activity_level': activity,
    });

    if (res != null && res.statusCode == 200) {
      final body = res.data;
      if (body['status'] == 'success') {
        await fetch();
        return null;
      }
      return body['message'] ?? 'تعذر الحفظ';
    }
    return 'تعذر الحفظ';
  }
}

final healthProfileProvider =
    StateNotifierProvider<HealthProfileNotifier, HealthProfileState>((ref) {
  return HealthProfileNotifier();
});
