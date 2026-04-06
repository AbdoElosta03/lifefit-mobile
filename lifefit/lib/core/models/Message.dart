enum MessageStatus { sending, sent, delivered, seen }

class Message {
  final int id;
  final int conversationId;
  final int senderId;
  final String body;
  final String? mediaUrl; // أضفنا هذا للحالات المستقبلية
  final DateTime createdAt;
  final bool isSeen;
  final String senderName; // مفيد لعرض اسم المرسل فوق الرسالة

  Message({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.body,
    this.mediaUrl,
    required this.createdAt,
    this.isSeen = false,
    this.senderName = '',
  });
  Message copyWith({
    int? id,
    int? conversationId,
    int? senderId,
    String? body,
    DateTime? createdAt,
    bool? isSeen,
  }) {
    return Message(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      senderId: senderId ?? this.senderId,
      body: body ?? this.body,
      createdAt: createdAt ?? this.createdAt,
      isSeen: isSeen ?? this.isSeen,
    );
  }

  factory Message.fromJson(Map<String, dynamic> json) {
    // استخراج بيانات المرسل
    final sender = json['sender'] as Map<String, dynamic>?;
    
    return Message(
      id: json['id'] ?? 0,
      conversationId: json['conversation_id'] ?? 0,
      senderId: json['sender_id'] ?? 0,
      body: json['body'] ?? '',
      mediaUrl: json['media_url'],
      // التأكد من تحويل التاريخ بشكل صحيح
      createdAt: DateTime.parse(json['created_at']),
      // في الـ JSON يسمى الحقل read_at، إذا كان ليس null فهي seen
      isSeen: json['read_at'] != null,
      senderName: sender != null ? sender['name'] : '',
    );
  }
}