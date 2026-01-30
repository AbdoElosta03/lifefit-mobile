import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/api_service.dart';
import '../../../core/models/notification.dart';


class NotificationProvider extends StateNotifier<List<Notification>> {
  final ApiService _apiService = ApiService();

  NotificationProvider() : super([]) {
    fetchNotifications();
  }
  

  Future<void> fetchNotifications() async {
    try {
    final response = await _apiService.getNotifications();
    if (response != null && response.statusCode == 200) {
      final List notificationsData = response.data['data'] ?? [];
      state = notificationsData
          .map((data) => Notification.fromJson(data))
          .toList();
    }
    else {
      print(" خطا في السيرفر : ${response?.statusCode}");
    }
    } catch (e) {
      print("Error fetching: $e");
    }
  }
  
  
  Future<void> markAsRead(int notificationId) async {
    try {
    final response = await _apiService.markNotificationAsRead(notificationId.toString());
    if (response != null && response.statusCode == 200) {
      state = state.map((notification) {
        if (notification.id == notificationId.toString()) {
          return notification.copyWith(isRead: true);
        }
        return notification;
      }).toList();
    }
    else {
      print(" خطا في السيرفر : ${response?.statusCode}");
    }
  } catch (e) {
      print("Error marking as read: $e");
    }
  }
  //final provider to be used in the app
  static final provider = StateNotifierProvider<NotificationProvider, List<Notification>>(
    (ref) => NotificationProvider(),
  );
}

