import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/profile_web/client_profile_bundle.dart';
import '../../../core/services/profile_web_service.dart';

class ClientProfileWebNotifier
    extends StateNotifier<AsyncValue<ClientProfileBundle>> {
  final ProfileWebService _service;

  ClientProfileWebNotifier(this._service) : super(const AsyncValue.loading()) {
    fetch();
  }

  Future<void> fetch() async {
    state = const AsyncValue.loading();
    try {
      final bundle = await _service.fetchProfile();
      state = AsyncValue.data(bundle);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> refresh() => fetch();

  Future<void> update(Map<String, dynamic> body) async {
    final bundle = await _service.updateProfile(body);
    state = AsyncValue.data(bundle);
  }
}

final clientProfileWebProvider = StateNotifierProvider<ClientProfileWebNotifier,
    AsyncValue<ClientProfileBundle>>((ref) {
  return ClientProfileWebNotifier(ProfileWebService());
});
