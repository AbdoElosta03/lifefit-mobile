import 'package:dio/dio.dart';
import 'base_service.dart';
import '../models/profile_web/client_profile_bundle.dart';

/// Web client profile: GET/PUT `/api/client/profile`.
class ProfileWebService extends BaseService {
  Future<ClientProfileBundle> fetchProfile() async {
    final response = await dio.get('client/profile');
    if (response.statusCode == 200 && response.data is Map<String, dynamic>) {
      return ClientProfileBundle.fromJson(response.data as Map<String, dynamic>);
    }
    throw Exception('تعذر تحميل الملف الشخصي');
  }

  /// Same shape as [fetchProfile] after update.
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
