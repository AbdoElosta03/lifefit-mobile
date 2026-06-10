import 'package:dio/dio.dart';
import 'base_service.dart';
import '../models/profile_web/client_profile_bundle.dart';

/// Client profile: GET/PUT `/api/client/profile`.
class ProfileService extends BaseService {
  /// GET `/api/client/profile` — fitness profile, stats, and preferences bundle.
  Future<ClientProfileBundle> fetchProfile() async {
    final response = await dio.get('client/profile');
    if (response.statusCode == 200 && response.data is Map<String, dynamic>) {
      return ClientProfileBundle.fromJson(response.data as Map<String, dynamic>);
    }
    throw Exception('تعذر تحميل الملف الشخصي');
  }

  /// PUT `/api/client/profile` — returns the same bundle shape as [fetchProfile].
  Future<ClientProfileBundle> updateProfile(Map<String, dynamic> body) async {
    try {
      final response = await dio.put('client/profile', data: body);
      if (response.statusCode == 200 && response.data is Map<String, dynamic>) {
        return ClientProfileBundle.fromJson(response.data as Map<String, dynamic>);
      }
      throw Exception('رد غير متوقع: ${response.statusCode}');
    } on DioException catch (e) {
      final data = e.response?.data;
      String msg = 'فشل حفظ الملف الشخصي';
      if (data is Map && data['message'] != null) {
        msg = data['message'].toString();
      }
      throw Exception(msg);
    }
  }
}
