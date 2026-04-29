import 'package:dio/dio.dart';

import '../models/notifications/paginated_notifications.dart';
import 'base_service.dart';

class NotificationService extends BaseService {
  Future<PaginatedNotifications> fetchPage({int page = 1}) async {
    try {
      final response = await dio.get(
        'notifications',
        queryParameters: {'page': page},
      );
      if (response.statusCode == 200 && response.data is Map) {
        return PaginatedNotifications.fromJson(
          Map<String, dynamic>.from(response.data as Map),
        );
      }
      throw Exception('Unexpected response');
    } on DioException catch (e) {
      throw _dioError(e);
    }
  }

  Future<void> markAsRead(int id) async {
    try {
      final response = await dio.put('notifications/$id/read');
      if (response.statusCode != 200) {
        throw Exception('Unexpected response');
      }
    } on DioException catch (e) {
      throw _dioError(e);
    }
  }

  Future<void> markAllRead() async {
    try {
      final response = await dio.put('notifications/read-all');
      if (response.statusCode != 200) {
        throw Exception('Unexpected response');
      }
    } on DioException catch (e) {
      throw _dioError(e);
    }
  }

  Exception _dioError(DioException e) {
    final msg = e.response?.data is Map
        ? (e.response?.data as Map)['message']?.toString()
        : null;
    return Exception(msg ?? e.message ?? 'Request failed');
  }
}
