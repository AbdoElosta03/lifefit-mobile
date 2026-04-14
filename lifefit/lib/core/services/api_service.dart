import '../models/user.dart';
import 'auth_service.dart';
import 'workout_service.dart';
import 'nutrition_service.dart';
import 'profile_service.dart';
import 'profile_web_service.dart';
import 'social_service.dart';

/// One-stop shop for all services to maintain backward compatibility
class ApiService {
  final auth = AuthService();
  final workout = WorkoutService();
  final nutrition = NutritionService();
  final profile = ProfileService();
  final profileWeb = ProfileWebService();
  final social = SocialService();

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

  Future getTodayNutrition() => nutrition.getTodayNutrition();
  Future saveDailyIntakeMealLog({String? logDate, required int mealId, required List<Map<String, dynamic>> items}) => 
      nutrition.saveDailyIntakeMealLog(logDate: logDate, mealId: mealId, items: items);

  Future getProfile() => profile.getProfile();
  Future saveProfile(Map<String, dynamic> body) => profile.saveProfile(body);
  Future getExperts() => profile.getExperts();
  Future getSubscriptions() => profile.getSubscriptions();
  Future cancelSubscription(String id) => profile.cancelSubscription(id);

  Future getNotifications() => social.getNotifications();
  Future markNotificationAsRead(String id) => social.markNotificationAsRead(id);
  Future getConversations() => social.getConversations();
  Future getMessages(int conversationId) => social.getMessages(conversationId);
  Future sendMessage(int conversationId, String body) => social.sendMessage(conversationId, body);
  Future markConversationRead(int conversationId) => social.markConversationRead(conversationId);
}

