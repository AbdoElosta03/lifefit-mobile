import 'package:dio/dio.dart';
import 'base_service.dart';
import '../models/progress/personal_record.dart';
import '../models/progress/client_goal.dart';

/// Web client progress APIs (`/api/client/...`).
class ProgressService extends BaseService {
  /// GET `/api/client/goals` → `{ "data": [ ... ] }`
  Future<List<ClientGoal>> fetchGoals() async {
    try {
      final response = await dio.get('client/goals');
      if (response.statusCode == 200) {
        final list = response.data['data'];
        if (list is List) {
          return list
              .whereType<Map>()
              .map((e) => ClientGoal.fromJson(Map<String, dynamic>.from(e)))
              .toList();
        }
      }
      return [];
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?['message']?.toString() ??
            'تعذر تحميل الأهداف: ${e.message}',
      );
    }
  }

  /// POST `/api/client/goals` — `store` uses `updateOrCreate` by `client_id`.
  /// Backend requires `start_date` on create.
  Future<ClientGoal> createOrReplaceGoal(Map<String, dynamic> body) async {
    try {
      final response = await dio.post('client/goals', data: body);
      if ((response.statusCode == 200 || response.statusCode == 201) &&
          response.data['data'] != null) {
        return ClientGoal.fromJson(
          Map<String, dynamic>.from(response.data['data'] as Map),
        );
      }
      throw Exception('رد غير متوقع من الخادم');
    } on DioException catch (e) {
      _throwDio(e);
    }
  }

  /// PUT `/api/client/goals/{id}`
  Future<ClientGoal> updateGoal(int goalId, Map<String, dynamic> body) async {
    try {
      final response = await dio.put('client/goals/$goalId', data: body);
      if (response.statusCode == 200 && response.data['data'] != null) {
        return ClientGoal.fromJson(
          Map<String, dynamic>.from(response.data['data'] as Map),
        );
      }
      throw Exception('رد غير متوقع من الخادم');
    } on DioException catch (e) {
      _throwDio(e);
    }
  }

  Never _throwDio(DioException e) {
    final msg = e.response?.data is Map
        ? e.response?.data['message']?.toString()
        : null;
    throw Exception(msg ?? e.message ?? 'خطأ في الطلب');
  }

  /// GET `/api/client/personal-records` → `{ "data": [ ... ] }`
  Future<List<PersonalRecord>> fetchPersonalRecords() async {
    try {
      final response = await dio.get('client/personal-records');
      if (response.statusCode == 200) {
        final list = response.data['data'];
        if (list is List) {
          return list
              .whereType<Map>()
              .map((e) => PersonalRecord.fromJson(Map<String, dynamic>.from(e)))
              .toList();
        }
      }
      return [];
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?['message']?.toString() ??
            'تعذر تحميل الأرقام القياسية: ${e.message}',
      );
    }
  }
}
