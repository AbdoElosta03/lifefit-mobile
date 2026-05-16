import 'package:dio/dio.dart';

import 'base_service.dart';

/// Response from POST /api/client/chats/start
class StartChatResponse {
  final int clientId;
  final String clientName;
  final String? clientAvatarUrl;
  final int coachId;
  final String coachName;
  final String? coachAvatarUrl;
  final String firebaseChatId;
  final String type;
  final String status;

  const StartChatResponse({
    required this.clientId,
    required this.clientName,
    this.clientAvatarUrl,
    required this.coachId,
    required this.coachName,
    this.coachAvatarUrl,
    required this.firebaseChatId,
    required this.type,
    required this.status,
  });

  factory StartChatResponse.fromJson(Map<String, dynamic> json) {
    return StartChatResponse(
      clientId: (json['client_id'] as num).toInt(),
      clientName: json['client_name'] as String,
      clientAvatarUrl: json['client_avatar_url'] as String?,
      coachId: (json['coach_id'] as num).toInt(),
      coachName: json['coach_name'] as String,
      coachAvatarUrl: json['coach_avatar_url'] as String?,
      firebaseChatId: json['firebase_chat_id'] as String,
      type: json['type'] as String,
      status: json['status'] as String,
    );
  }
}

/// Handles chat metadata calls to the Laravel API.
/// Actual messages are stored in Firestore via [FirestoreChatService].
class ChatService extends BaseService {
  /// Starts a chat with [coachId] or returns the existing chat metadata.
  /// Throws an [Exception] with a user-readable message on failure.
  Future<StartChatResponse> startChat({required int coachId}) async {
    try {
      final response = await dio.post(
        'client/chats/start',
        data: {'coach_id': coachId},
      );
      return StartChatResponse.fromJson(
        Map<String, dynamic>.from(response.data as Map),
      );
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] ?? e.message ?? 'Unknown error';
      throw Exception(msg);
    }
  }
}
