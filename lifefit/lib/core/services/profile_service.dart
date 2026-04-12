import 'package:dio/dio.dart';
import 'base_service.dart';

class ProfileService extends BaseService {
  Future<Response?> getProfile() async {
    try {
      return await dio.get("client/app-profile");
    } catch (e) {
      return null;
    }
  }

  Future<Response?> saveProfile(Map<String, dynamic> body) async {
    try {
      return await dio.post(
        "client/app-profile",
        data: body,
      );
    } catch (e) {
      if (e is DioException) {
        return e.response;
      }
      return null;
    }
  }

  Future<Response?> getExperts() async {
    try {
      return await dio.get("client/app-experts");
    } catch (e) {
      return null;
    }
  }

  Future<Response?> getSubscriptions() async {
    try {
      return await dio.get("client/app-subscriptions");
    } catch (e) {
      return null;
    }
  }

  Future<Response?> cancelSubscription(String id) async {
    try {
      return await dio.post("client/app-subscriptions/$id/cancel");
    } catch (e) {
      return null;
    }
  }
}
