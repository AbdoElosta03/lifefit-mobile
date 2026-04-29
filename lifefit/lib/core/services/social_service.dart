import 'package:dio/dio.dart';
import 'base_service.dart';

class SocialService extends BaseService {
  Future<Response?> getConversations() async {
    try {
      return await dio.get("conversations");
    } catch (e) {
      return null;
    }
  }

  Future<Response?> getMessages(int conversationId) async {
    try {
      return await dio.get("conversations/$conversationId/messages");
    } catch (e) {
      return null;
    }
  }

  Future<Response?> sendMessage(int conversationId, String body) async {
    try {
      return await dio.post(
        "messages",
        data: {
          "conversation_id": conversationId,
          "body": body,
        },
      );
    } catch (e) {
      return null;
    }
  }

  Future<Response?> markConversationRead(int conversationId) async {
    try {
      return await dio.post("conversations/$conversationId/read");
    } catch (e) {
      return null;
    }
  }
}
