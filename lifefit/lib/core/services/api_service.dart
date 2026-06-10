import '../models/user.dart';
import 'auth_service.dart';
import 'user_service.dart';
import 'workout_service.dart';
import 'nutrition_service.dart';
import 'profile_web_service.dart';

import 'notification_service.dart';
import '../models/notifications/paginated_notifications.dart';

/// Facade that exposes all domain services and legacy method aliases.
/// Prefer injecting individual services in new code.
class ApiService {
  final auth = AuthService();
  final user = UserService();
  final workout = WorkoutService();
  final nutrition = NutritionService();
  final profile = ProfileService();
  final notification = NotificationService();

  // Legacy shortcuts — delegate to the modular services below.
  Future login(String email, String password) => auth.login(email, password);
  Future register({required String name, required String email, required String password, required String role}) =>
      auth.register(name: name, email: email, password: password, role: role);

  Future<User> fetchCurrentUser() => auth.fetchCurrentUser();
  Future<void> logout() => auth.logout();
  Future<String> forgotPassword(String email) => auth.forgotPassword(email);
  Future<String> resetPassword({
    required String email,
    required String otp,
    required String password,
    required String passwordConfirmation,
  }) =>
      auth.resetPassword(
        email: email,
        otp: otp,
        password: password,
        passwordConfirmation: passwordConfirmation,
      );

  /// Web API: today's schedules (list).
  Future fetchTodaySchedules() => workout.fetchTodaySchedules();

  Future getProfileWeb() => profile.fetchProfile();
  Future updateProfileWeb(Map<String, dynamic> body) =>
      profile.updateProfile(body);

  Future<PaginatedNotifications> fetchNotificationsPage({int page = 1}) =>
      notification.fetchPage(page: page);
  Future<void> markNotificationAsReadById(int id) => notification.markAsRead(id);
  Future<void> markAllNotificationsRead() => notification.markAllRead();
  

}

