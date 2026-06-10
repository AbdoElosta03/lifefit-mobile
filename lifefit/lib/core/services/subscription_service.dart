import 'package:dio/dio.dart';

import '../models/subscription/expert_model.dart';
import '../models/subscription/my_subscription_model.dart';
import 'base_service.dart';

/// Client subscription flow: browse experts, pay, and view active subscriptions.
class SubscriptionService extends BaseService {
  /// GET `/api/client/available-experts` — coaches/services the client can subscribe to.
  Future<List<ExpertModel>> fetchExperts() async {
    try {
      final response = await dio.get('client/available-experts');
      final list = response.data['data'];
      if (list is List) {
        return list
            .whereType<Map>()
            .map((e) => ExpertModel.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] ?? e.message;
      throw Exception('فشل تحميل قائمة المتخصصين: $msg');
    }
  }

  /// POST `/api/client/services/{id}/initiate-payment` — starts payment gateway session.
  Future<Map<String, dynamic>> initiatePayment(int serviceId) async {
    try {
      final response =
          await dio.post('client/services/$serviceId/initiate-payment');
      return Map<String, dynamic>.from(response.data as Map);
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] ?? e.message;
      throw Exception(msg);
    }
  }

  /// POST `/api/client/payments/confirm` — called after successful gateway callback.
  Future<void> confirmPayment({
    required String merchantReference,
    String? networkReference,
  }) async {
    try {
      await dio.post('client/payments/confirm', data: {
        'merchant_reference': merchantReference,
        if (networkReference != null) 'network_reference': networkReference,
      });
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] ?? e.message;
      throw Exception(msg);
    }
  }

  /// POST `/api/client/payments/fail` — best-effort; swallows errors silently.
  Future<void> failPayment({
    required String merchantReference,
    String? errorCode,
  }) async {
    try {
      await dio.post('client/payments/fail', data: {
        'merchant_reference': merchantReference,
        if (errorCode != null) 'error_code': errorCode,
      });
    } catch (_) {}
  }

  /// GET `/api/client/my-subscriptions` — active and past subscriptions.
  Future<List<MySubscription>> fetchMySubscriptions() async {
    try {
      final response = await dio.get('client/my-subscriptions');
      final list = response.data['data'];
      if (list is List) {
        return list
            .whereType<Map>()
            .map((e) => MySubscription.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] ?? e.message;
      throw Exception('فشل تحميل اشتراكاتي: $msg');
    }
  }
}
