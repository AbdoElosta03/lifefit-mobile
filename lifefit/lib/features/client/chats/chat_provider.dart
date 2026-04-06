import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/Message.dart'; 
import '../../../core/services/api_service.dart';

// تعريف حالة الشاشة بالكامل (لا تغيير هنا، فهي ممتازة للتنظيم)
class ChatState {
  final List<Message> messages;
  final bool isTyping;
  final bool isLoading;

  ChatState({
    this.messages = const [],
    this.isTyping = false,
    this.isLoading = false,
  });

  ChatState copyWith({
    List<Message>? messages,
    bool? isTyping,
    bool? isLoading,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      isTyping: isTyping ?? this.isTyping,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

final chatProvider = StateNotifierProvider<ChatNotifier, ChatState>((ref) {
  return ChatNotifier();
});

class ChatNotifier extends StateNotifier<ChatState> {
  ChatNotifier() : super(ChatState());

  final ApiService _api = ApiService();

  // جلب الرسائل من الـ API عند فتح المحادثة
  Future<void> loadMessages(int conversationId) async {
    state = state.copyWith(isLoading: true);
    try {
      final res = await _api.getMessages(conversationId);
      if (res == null) {
        state = state.copyWith(isLoading: false);
        return;
      }

      final data = res.data;
      // معالجة البيانات القادمة من الباجينيشن (Laravel Pagination)
      final List rawData = data is Map<String, dynamic>
          ? (data['data'] as List? ?? [])
          : [];
          
      final messages = rawData
          .map((m) => Message.fromJson(m as Map<String, dynamic>))
          .toList();
          
      state = state.copyWith(
        // نعكس الرسائل لتظهر الأحدث في الأسفل في الـ ListView
        messages: messages.reversed.toList(), 
        isLoading: false,
      );
    } catch (_) {
      state = state.copyWith(isLoading: false);
    }
  }

  // إرسال رسالة جديدة
  Future<void> send(int conversationId, String text) async {
    try {
      final res = await _api.sendMessage(conversationId, text);

      if (res != null) {
        // بما أننا ألغينا السوكت، نأخذ الرسالة التي عادت من السيرفر (Response)
        // ونضيفها فوراً للقائمة لكي يراها المستخدم
        final newMessage = Message.fromJson(res.data as Map<String, dynamic>);
        
        state = state.copyWith(
          messages: [...state.messages, newMessage],
        );
      }
    } catch (e) {
      // هنا يمكنك إضافة تنبيه في حال فشل الإرسال
    }
  }

  // تحديث حالة الـ Seen للرسائل محلياً
  // ملاحظة: بما أننا ألغينا السوكت، هذه ستحدث فقط في جهاز المستخدم الحالي
  // المستخدم الآخر سيعرف أنها قُرئت عند تحديث صفحته أو عبر إشعار Firebase
  void markAsSeenLocal() {
    final updatedMessages = state.messages.map((m) {
      return m.copyWith(isSeen: true); // تأكد من وجود دالة copyWith داخل موديل Message
    }).toList();
    
    state = state.copyWith(messages: updatedMessages);
  }

  // تنظيف الرسائل عند الخروج من الصفحة (مهم لكي لا تظهر رسائل قديمة عند فتح محادثة أخرى)
  void clearMessages() {
    state = ChatState();
  }
}