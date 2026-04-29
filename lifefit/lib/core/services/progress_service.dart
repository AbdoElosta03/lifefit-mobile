import 'package:dio/dio.dart';
import 'base_service.dart';
import '../models/progress/body_measurement.dart';
import '../models/progress/paginated_measurements.dart';
import '../models/progress/personal_record.dart';
import '../models/progress/client_goal.dart';
import '../models/progress/progress_photo.dart';
import '../models/progress/progress_photos_grouped.dart';

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

  /// GET `/api/client/measurements` — Laravel paginator; loads all pages.
  Future<List<BodyMeasurement>> fetchAllMeasurements() async {
    final all = <BodyMeasurement>[];
    try {
      var page = 1;
      while (true) {
        final response = await dio.get(
          'client/measurements',
          queryParameters: {'page': page},
        );
        if (response.statusCode != 200) break;
        final raw = response.data;
        if (raw is! Map) break;
        final paginated = PaginatedMeasurements.fromJson(
          Map<String, dynamic>.from(raw),
        );
        all.addAll(paginated.data);
        if (paginated.currentPage >= paginated.lastPage) break;
        page++;
      }
      return all;
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?['message']?.toString() ??
            'تعذر تحميل القياسات: ${e.message}',
      );
    }
  }

  /// POST `/api/client/measurements` — `date` required; other fields optional (inheritance on backend).
  Future<BodyMeasurement> storeMeasurement(Map<String, dynamic> body) async {
    try {
      final response = await dio.post('client/measurements', data: body);
      if ((response.statusCode == 200 || response.statusCode == 201) &&
          response.data is Map &&
          (response.data as Map)['data'] != null) {
        return BodyMeasurement.fromJson(
          Map<String, dynamic>.from(
            (response.data as Map)['data'] as Map,
          ),
        );
      }
      throw Exception('رد غير متوقع من الخادم');
    } on DioException catch (e) {
      _throwDio(e);
    }
  }

  /// GET `/api/client/photos` → `{ "data": { "Y-m-d": [ ... ] } }` (grouped by date).
  Future<List<ProgressPhotosDay>> fetchProgressPhotos() async {
    try {
      final response = await dio.get('client/photos');
      if (response.statusCode == 200 && response.data is Map) {
        final inner = (response.data as Map)['data'];
        return ProgressPhotosDay.parseGroupedData(inner);
      }
      return [];
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?['message']?.toString() ??
            'تعذر تحميل صور التقدم: ${e.message}',
      );
    }
  }

  /// POST `/api/client/photos` — multipart: date, photo, photo_type, optional notes.
  Future<ProgressPhoto> storeProgressPhoto({
    required DateTime date,
    required List<int> bytes,
    required String fileName,
    required String photoType,
    String? notes,
  }) async {
    var name = fileName.trim().isEmpty ? 'photo.jpg' : fileName.trim();
    if (!name.contains('.')) {
      name = '$name.jpg';
    }
    try {
      final fields = <String, dynamic>{
        'date': ClientGoal.formatDateForApi(date),
        'photo': MultipartFile.fromBytes(bytes, filename: name),
        'photo_type': photoType,
      };
      if (notes != null && notes.trim().isNotEmpty) {
        fields['notes'] = notes.trim();
      }
      final form = FormData.fromMap(fields);
      final response = await dio.post('client/photos', data: form);
      if ((response.statusCode == 200 || response.statusCode == 201) &&
          response.data is Map &&
          (response.data as Map)['data'] != null) {
        return ProgressPhoto.fromJson(
          Map<String, dynamic>.from((response.data as Map)['data'] as Map),
        );
      }
      throw Exception('Unexpected server response');
    } on DioException catch (e) {
      _throwDio(e);
    }
  }

  /// DELETE `/api/client/photos/{id}`
  Future<void> deleteProgressPhoto(int id) async {
    try {
      final response = await dio.delete('client/photos/$id');
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Unexpected server response');
      }
    } on DioException catch (e) {
      _throwDio(e);
    }
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
