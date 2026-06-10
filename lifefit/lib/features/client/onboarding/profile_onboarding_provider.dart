import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/profile_web/client_profile_bundle.dart';
import '../../../core/models/profile_web/profile_completeness.dart';
import '../../../core/services/profile_web_service.dart';

/// Gate state between auth and [ClientHomeScreen].
class ProfileGateState {
  final bool isChecking;
  final bool? needsOnboarding;
  final ClientProfileBundle? bundle;
  final String? errorMessage;

  const ProfileGateState({
    this.isChecking = false,
    this.needsOnboarding,
    this.bundle,
    this.errorMessage,
  });

  ProfileGateState copyWith({
    bool? isChecking,
    bool? needsOnboarding,
    ClientProfileBundle? bundle,
    String? errorMessage,
    bool clearError = false,
  }) {
    return ProfileGateState(
      isChecking: isChecking ?? this.isChecking,
      needsOnboarding: needsOnboarding ?? this.needsOnboarding,
      bundle: bundle ?? this.bundle,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class ProfileGateNotifier extends StateNotifier<ProfileGateState> {
  final ProfileService _service;

  ProfileGateNotifier(this._service) : super(const ProfileGateState());

  /// Loads profile and decides if onboarding is required.
  Future<void> check() async {
    state = state.copyWith(isChecking: true, clearError: true);
    try {
      final bundle = await _service.fetchProfile();
      state = ProfileGateState(
        isChecking: false,
        needsOnboarding: bundle.needsOnboarding,
        bundle: bundle,
      );
    } catch (e) {
      state = ProfileGateState(
        isChecking: false,
        needsOnboarding: true,
        errorMessage: e.toString(),
      );
    }
  }

  void markComplete(ClientProfileBundle bundle) {
    state = ProfileGateState(
      needsOnboarding: false,
      bundle: bundle,
    );
  }

  void reset() {
    state = const ProfileGateState();
  }
}

final profileGateProvider =
    StateNotifierProvider<ProfileGateNotifier, ProfileGateState>((ref) {
  return ProfileGateNotifier(ProfileService());
});
