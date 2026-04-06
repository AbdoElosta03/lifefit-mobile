import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/profile.dart';
import '../../../core/services/api_service.dart';

class ProfileProvider extends StateNotifier<AsyncValue<Profile>> {
  final ApiService _apiService = ApiService();

  ProfileProvider() : super(const AsyncLoading()) {
    fetchProfile();
  }

  Future<void> fetchProfile() async {
    state = const AsyncLoading();
    try {
      final response = await _apiService.getProfile();
      if (response == null || response.statusCode != 200) {
        throw Exception("خطا في السيرفر: ${response?.statusCode}");
      }

      final profileData = response.data['data'] as Map<String, dynamic>?;
      if (profileData == null) {
        throw Exception("بيانات الملف الشخصي غير موجودة");
      }

      final profile = Profile.fromJson(profileData);
      state = AsyncValue.data(profile);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> saveProfile(Profile profile) async {
    try {
      final body = {
        "age": profile.age,
        "height_cm": profile.heightCm,
        "target_weight_kg": profile.targetWeightKg,
        "goal_notes": profile.goalNotes,
        "current_activity_level": profile.activityLevel,
        // "birth_date": profile.birthDate,
      };

      final response = await _apiService.saveProfile(body);
      if (response == null) {
        throw Exception("لم يتم استلام رد من الخادم");
      }

      if (response.statusCode != 200 && response.statusCode != 201) {
        final data = response.data;
        String serverMessage = '';
        if (data is Map<String, dynamic>) {
          if (data['message'] != null) {
            serverMessage = data['message'].toString();
          } else if (data['errors'] != null) {
            serverMessage = data['errors'].toString();
          }
        } else if (data != null) {
          serverMessage = data.toString();
        }

        throw Exception(
          "خطا في السيرفر: ${response.statusCode} ${serverMessage.isNotEmpty ? '- $serverMessage' : ''}",
        );
      }

      // تحديث الملف الشخصي بعد الحفظ
      await fetchProfile();
    } catch (e) {
      print("Error saving profile: $e");
      rethrow;
    }
  }

  // Final provider to be used in the app
  static final provider =
      StateNotifierProvider<ProfileProvider, AsyncValue<Profile>>(
        (ref) => ProfileProvider(),
      );
}