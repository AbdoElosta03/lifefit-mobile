import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/api_service.dart';
import '../../../core/models/Conversation.dart'; // استيراد الموديل

// نستخدم AsyncValue كما فعلت ولكن مع موديل محدد
final conversationProvider =
    StateNotifierProvider<ConversationNotifier, AsyncValue<List<Conversation>>>((ref) {
  return ConversationNotifier();
});

class ConversationNotifier extends StateNotifier<AsyncValue<List<Conversation>>> {
  ConversationNotifier() : super(const AsyncLoading()) {
    fetch();
  }

  final ApiService _api = ApiService();

  Future<void> fetch() async {
    try {
      final res = await _api.getConversations();
      if (res != null) {
        final List rawData = res.data['data'];
        final conversations = rawData.map((c) => Conversation.fromJson(c)).toList();
        state = AsyncValue.data(conversations);
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}