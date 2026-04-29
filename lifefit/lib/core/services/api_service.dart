import '../models/user.dart';
import 'auth_service.dart';
import 'workout_service.dart';


import 'profile_web_service.dart';
import 'social_service.dart';
import 'notification_service.dart';
import '../models/notifications/paginated_notifications.dart';

/// One-stop shop for all services to maintain backward compatibility
class ApiService {
  final auth = AuthService();
  final workout = WorkoutService();
 

  final profileWeb = ProfileWebService();
  final social = SocialService();
  final notification = NotificationService();

  // Mapping old methods to new modular services to avoid breaking changes
  Future login(String email, String password) => auth.login(email, password);
  Future register({required String name, required String email, required String password, required String role}) =>
      auth.register(name: name, email: email, password: password, role: role);

  Future<User> fetchCurrentUser() => auth.fetchCurrentUser();
  Future<void> logout() => auth.logout();

  /// Web API: today's schedules (list).
  Future fetchTodaySchedules() => workout.fetchTodaySchedules();

  Future getProfileWeb() => profileWeb.fetchProfile();
  Future updateProfileWeb(Map<String, dynamic> body) =>
      profileWeb.updateProfile(body);

  Future<PaginatedNotifications> fetchNotificationsPage({int page = 1}) =>
      notification.fetchPage(page: page);
  Future<void> markNotificationAsReadById(int id) => notification.markAsRead(id);
  Future<void> markAllNotificationsRead() => notification.markAllRead();
  Future getConversations() => social.getConversations();
  Future getMessages(int conversationId) => social.getMessages(conversationId);
  Future sendMessage(int conversationId, String body) => social.sendMessage(conversationId, body);
  Future markConversationRead(int conversationId) => social.markConversationRead(conversationId);
}

