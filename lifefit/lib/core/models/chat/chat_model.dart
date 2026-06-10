import 'package:cloud_firestore/cloud_firestore.dart';

/// Firestore chat thread metadata; denormalized names avoid extra user lookups.
class ChatModel {
  final String id;
  final List<String> participants;
  final String? lastMessage;
  final DateTime? lastMessageAt;

  final String? clientId;
  final String? clientName;
  final String? coachId;
  final String? coachName;

  const ChatModel({
    required this.id,
    required this.participants,
    this.lastMessage,
    this.lastMessageAt,
    this.clientId,
    this.clientName,
    this.coachId,
    this.coachName,
  });

  ChatModel copyWith({
    String? id,
    List<String>? participants,
    String? lastMessage,
    DateTime? lastMessageAt,
    String? clientId,
    String? clientName,
    String? coachId,
    String? coachName,
  }) {
    return ChatModel(
      id: id ?? this.id,
      participants: participants ?? this.participants,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageAt: lastMessageAt ?? this.lastMessageAt,
      clientId: clientId ?? this.clientId,
      clientName: clientName ?? this.clientName,
      coachId: coachId ?? this.coachId,
      coachName: coachName ?? this.coachName,
    );
  }

  /// Returns the first participant that is not [currentUserId] (1:1 chats).
  String otherParticipantId(String currentUserId) {
    for (final id in participants) {
      if (id != currentUserId) return id;
    }
    return participants.isNotEmpty ? participants.first : '';
  }

  static String? _stringField(dynamic value) {
    if (value == null) return null;
    final s = value.toString().trim();
    return s.isEmpty ? null : s;
  }

  factory ChatModel.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    final participants = (data?['participants'] as List?)
            ?.map((e) => e.toString())
            .toList() ??
        <String>[];

    final lastMessageAt = data?['lastMessageAt'] as Timestamp?;

    return ChatModel(
      id: doc.id,
      participants: participants,
      lastMessage: data?['lastMessage'] as String?,
      lastMessageAt: lastMessageAt?.toDate(),
      clientId: _stringField(data?['clientId']),
      clientName: _stringField(data?['clientName']),
      coachId: _stringField(data?['coachId']),
      coachName: _stringField(data?['coachName']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'participants': participants,
      'lastMessage': lastMessage,
      'lastMessageAt': lastMessageAt,
      'clientId': clientId,
      'clientName': clientName,
      'coachId': coachId,
      'coachName': coachName,
    };
  }
}
