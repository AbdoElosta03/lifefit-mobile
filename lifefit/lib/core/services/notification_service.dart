import 'package:dio/dio.dart';

import '../models/notifications/paginated_notifications.dart';
import 'base_service.dart';

/// In-app notifications: paginated list and read-state management.
class NotificationService extends BaseService {
  /// GET `/api/notifications?page=` — Laravel paginator.
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

  /// PUT `/api/notifications/{id}/read` — marks a single notification as read.
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

  /// PUT `/api/notifications/read-all` — marks every notification as read.
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

  /// Pulls Laravel `message` field from the error body when available.
  Exception _dioError(DioException e) {
    final msg = e.response?.data is Map
        ? (e.response?.data as Map)['message']?.toString()
        : null;
    return Exception(msg ?? e.message ?? 'Request failed');
  }
}
