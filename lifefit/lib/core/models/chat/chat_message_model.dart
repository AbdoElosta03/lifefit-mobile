import 'package:cloud_firestore/cloud_firestore.dart';

/// Firestore document under `chats/{chatId}/messages/{messageId}`.
class ChatMessageModel {
  final String id;
  final String chatId;
  final String senderId;
  final String text;
  final DateTime createdAt;
  final bool isRead;

  const ChatMessageModel({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.text,
    required this.createdAt,
    required this.isRead,
  });

  ChatMessageModel copyWith({
    String? id,
    String? chatId,
    String? senderId,
    String? text,
    DateTime? createdAt,
    bool? isRead,
  }) {
    return ChatMessageModel(
      id: id ?? this.id,
      chatId: chatId ?? this.chatId,
      senderId: senderId ?? this.senderId,
      text: text ?? this.text,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
    );
  }

  factory ChatMessageModel.fromDoc(
    DocumentSnapshot<Map<String, dynamic>> doc,
    String chatId,
  ) {
    final data = doc.data();
    final createdAt = data?['createdAt'] as Timestamp?;

    return ChatMessageModel(
      id: doc.id,
      chatId: chatId,
      senderId: (data?['senderId'] ?? '').toString(),
      text: data?['text'] as String? ?? '',
      createdAt: createdAt?.toDate() ?? DateTime.fromMillisecondsSinceEpoch(0),
      isRead: data?['isRead'] as bool? ?? false,
    );
  }

  /// Fields written when sending a new message (server sets `createdAt` via Timestamp).
  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'text': text,
      'createdAt': createdAt,
      'isRead': isRead,
    };
  }
}
