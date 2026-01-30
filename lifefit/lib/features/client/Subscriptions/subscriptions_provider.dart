import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/api_service.dart';
import '../../../core/models/subscription.dart';

class SubscriptionsProvider extends StateNotifier<List<Subscription>> {
  final ApiService _apiService = ApiService();

  SubscriptionsProvider() : super([]) {
    fetchSubscriptions();
  }
  

  Future<void> fetchSubscriptions() async {
    try {
    final response = await _apiService.getSubscriptions();
    if (response != null && response.statusCode == 200) {
      final List subscriptionsData = response.data?? [];
      state = subscriptionsData
          .map((data) => Subscription.fromJson(data))
          .toList();
    }
    else {
      print(" خطا في السيرفر : ${response?.statusCode}");
    }
    } catch (e) {
      print("Error fetching: $e");
    }
  }
  // إلغاء الاشتراك
  Future<void> cancelSubscription(int subscriptionId) async {
    try {
    final response = await _apiService.cancelSubscription(subscriptionId.toString());
    if (response != null && response.statusCode == 200) {
      // بعد الإلغاء، إعادة جلب الاشتراكات لتحديث الحالة
      await fetchSubscriptions();
    }
    else {
      print(" خطا في السيرفر : ${response?.statusCode}");
    }
  } catch (e) {
      print("Error cancelling subscription: $e");
    }
  }
  
  //final provider to be used in the app
  static final provider = StateNotifierProvider<SubscriptionsProvider, List<Subscription>>(
    (ref) => SubscriptionsProvider(),
  );
}
