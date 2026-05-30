import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/profile_web/client_profile_bundle.dart';
import '../../../core/services/profile_web_service.dart';

// State notifier for web profile bundle.
class ClientProfileNotifier
    extends StateNotifier<AsyncValue<ClientProfileBundle>> {
  final ProfileService _service;

  ClientProfileNotifier(this._service) : super(const AsyncValue.loading()) {
    // Load initial data on creation.
    fetch();
  }

  // Fetch profile bundle from API.
  Future<void> fetch() async {
    state = const AsyncValue.loading();
    try {
      final bundle = await _service.fetchProfile();
      state = AsyncValue.data(bundle);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  // Explicit refresh alias.
  Future<void> refresh() => fetch();

  // Update profile and refresh state.
  Future<void> update(Map<String, dynamic> body) async {
    final bundle = await _service.updateProfile(body);
    state = AsyncValue.data(bundle);
  }
}

// Provider for client profile bundle state.
final clientProfileProvider = StateNotifierProvider<ClientProfileNotifier,
    AsyncValue<ClientProfileBundle>>((ref) {
  return ClientProfileNotifier(ProfileService());
});
