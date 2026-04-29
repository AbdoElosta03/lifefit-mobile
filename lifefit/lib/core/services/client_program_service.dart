import 'package:dio/dio.dart';

import '../models/programs/client_program_detail.dart';
import '../models/programs/program_assignment_summary.dart';
import 'base_service.dart';

/// `GET /api/client/programs`, `GET /api/client/programs/{id}`.
class ClientProgramService extends BaseService {
  /// يبني رابطًا لصورة مخزّنة نسبيًا (مثل مجلد avatars).
  String resolveMediaUrl(String? path) {
    if (path == null || path.isEmpty) return '';
    if (path.startsWith('http://') || path.startsWith('https://')) return path;
    final origin = Uri.parse(baseUrl).origin;
    final clean = path.startsWith('/') ? path.substring(1) : path;
    if (clean.startsWith('storage/')) return '$origin/$clean';
    return '$origin/storage/$clean';
  }

  Future<List<ProgramAssignmentSummary>> fetchPrograms() async {
    try {
      final response = await dio.get('client/programs');
      if (response.statusCode == 200) {
        final list = response.data['data'];
        if (list is List) {
          return list
              .whereType<Map>()
              .map((e) => ProgramAssignmentSummary.fromJson(Map<String, dynamic>.from(e)))
              .toList();
        }
      }
      return [];
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?['message']?.toString() ??
            'تعذر تحميل البرامج: ${e.message}',
      );
    }
  }

  Future<ClientProgramDetail> fetchProgramDetail(int assignmentId) async {
    try {
      final response = await dio.get('client/programs/$assignmentId');
      if (response.statusCode == 200) {
        final data = response.data['data'];
        if (data is Map) {
          return ClientProgramDetail.fromJson(Map<String, dynamic>.from(data));
        }
      }
      throw Exception('رد غير متوقع من الخادم');
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('البرنامج غير موجود');
      }
      throw Exception(
        e.response?.data?['message']?.toString() ??
            'تعذر تحميل تفاصيل البرنامج: ${e.message}',
      );
    }
  }
}
