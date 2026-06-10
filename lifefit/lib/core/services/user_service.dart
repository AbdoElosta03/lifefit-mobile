import 'package:dio/dio.dart';
import '../models/user.dart';
import 'base_service.dart';

// ─── User Service ─────────────────────────────────────────────────────────────
// API layer for UserController — separate from ProfileService (/api/client/profile).
// Token is injected automatically via BaseService interceptor.

/// Account settings: GET/PUT `/api/user`, POST `/api/avatar`, POST `/api/change-password`.
class UserService extends BaseService {
  /// GET /api/user — returns user with avatar_url.
  Future<User> fetchUser() async {
    try {
      final response = await dio.get('user');
      if (response.statusCode == 200 && response.data is Map) {
        return User.fromJson(
          Map<String, dynamic>.from(response.data as Map),
        );
      }
      throw Exception('تعذر تحميل بيانات الحساب');
    } on DioException catch (e) {
      throw Exception(_messageFromDio(e, 'تعذر تحميل بيانات الحساب'));
    }
  }

  /// PUT /api/user — response: { success, message, user: {...} }.
  Future<User> updateUser({
    String? name,
    String? email,
    String? phone,
  }) async {
    final body = <String, dynamic>{};
    if (name != null) body['name'] = name;
    if (email != null) body['email'] = email;
    if (phone != null) body['phone'] = phone;

    try {
      final response = await dio.put('user', data: body);
      final data = response.data;
      if (response.statusCode == 200 && data is Map) {
        final userJson = data['user'];
        if (userJson is Map) {
          return User.fromJson(Map<String, dynamic>.from(userJson));
        }
      }
      throw Exception('فشل تحديث البيانات');
    } on DioException catch (e) {
      throw Exception(_messageFromDio(e, 'فشل تحديث البيانات'));
    }
  }

  /// POST /api/avatar (multipart) — returns the full image URL only.
  Future<String> updateAvatar({
    required List<int> bytes,
    required String fileName,
  }) async {
    var name = fileName.trim().isEmpty ? 'avatar.jpg' : fileName.trim();
    if (!name.contains('.')) {
      name = '$name.jpg';
    }

    try {
      final form = FormData.fromMap({
        'avatar': MultipartFile.fromBytes(bytes, filename: name),
      });
      final response = await dio.post('avatar', data: form);
      final data = response.data;
      if (response.statusCode == 200 && data is Map) {
        final url = data['avatar_url']?.toString();
        if (url != null && url.isNotEmpty) return url;
      }
      throw Exception('فشل تحديث الصورة الشخصية');
    } on DioException catch (e) {
      throw Exception(_messageFromDio(e, 'فشل تحديث الصورة الشخصية'));
    }
  }

  /// POST /api/change-password — requires current_password and new_password_confirmation.
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmation,
  }) async {
    try {
      final response = await dio.post(
        'change-password',
        data: {
          'current_password': currentPassword,
          'new_password': newPassword,
          'new_password_confirmation': confirmation,
        },
      );
      if (response.statusCode == 200) return;
      throw Exception('فشل تغيير كلمة المرور');
    } on DioException catch (e) {
      throw Exception(_messageFromDio(e, 'فشل تغيير كلمة المرور'));
    }
  }

  /// Extracts the error message from a Laravel response (e.g. 422).
  String _messageFromDio(DioException e, String fallback) {
    final data = e.response?.data;
    if (data is Map && data['message'] != null) {
      return data['message'].toString();
    }
    return fallback;
  }
}
