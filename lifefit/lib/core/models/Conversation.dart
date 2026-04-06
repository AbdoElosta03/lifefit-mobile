class Conversation {
  final int id;
  final String expertName;
  final String? lastMessage;
  final DateTime updatedAt;
  final int unreadCount;
  final bool isOnline;

  Conversation({
    required this.id,
    required this.expertName,
    this.lastMessage,
    required this.updatedAt,
    this.unreadCount = 0,
    this.isOnline = false,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) {
    // 1. استخراج اسم الطرف الآخر
    final otherUser = json['other_user'] as Map<String, dynamic>?;
    final name = otherUser != null ? otherUser['name'] : 'خبير';

    // 2. استخراج نص الرسالة الأخيرة وتاريخها
    final lastMsgMap = json['last_message'] as Map<String, dynamic>?;
    final body = lastMsgMap != null ? lastMsgMap['body'] : null;

    final dateStr = lastMsgMap != null 
        ? lastMsgMap['created_at'] 
        : (json['updated_at'] ?? DateTime.now().toString());

    return Conversation(
      id: json['id'],
      expertName: name,
      lastMessage: body,
      updatedAt: DateTime.parse(dateStr),
      unreadCount: json['unread_count'] ?? 0,
      isOnline: json['is_online'] ?? false,
    );
  }
}