import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/chat/chat_message_model.dart';
import '../models/chat/chat_model.dart';

/// Real-time chat layer on Firestore (messages, typing, presence).
/// Chat metadata is created by Laravel; this service handles live messaging.
class FirestoreChatService {
  FirestoreChatService(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _chats =>
      _firestore.collection('chats');

  /// Creates (or merges into) the Firestore chat document after Laravel
  /// generates the [chatId]. Call this once right after [startChat] succeeds.
  ///
  /// Uses [SetOptions.merge] so existing [lastMessage] / subcollections are not
  /// wiped. [lastMessage] / [lastMessageAt] are only written for new docs or
  /// when those fields are missing (legacy documents).
  Future<void> ensureChatDoc({
    required String chatId,
    required String clientId,
    required String clientName,
    String? clientAvatarUrl,
    required String coachId,
    required String coachName,
    String? coachAvatarUrl,
    required String type,
    required String status,
  }) async {
    final ref = _chats.doc(chatId);
    final snap = await ref.get();
    final existing = snap.data();

    final payload = <String, dynamic>{
      'participants': [clientId, coachId],
      'clientId': clientId,
      'clientName': clientName,
      'coachId': coachId,
      'coachName': coachName,
      'type': type,
      'status': status,
    };
    if (clientAvatarUrl != null && clientAvatarUrl.isNotEmpty) {
      payload['clientAvatarUrl'] = clientAvatarUrl;
    }
    if (coachAvatarUrl != null && coachAvatarUrl.isNotEmpty) {
      payload['coachAvatarUrl'] = coachAvatarUrl;
    }

    if (!snap.exists) {
      payload['createdAt'] = FieldValue.serverTimestamp();
      payload['lastMessage'] = '';
      payload['lastMessageAt'] = FieldValue.serverTimestamp();
    } else {
      final data = existing ?? <String, dynamic>{};
      if (data['createdAt'] == null) {
        payload['createdAt'] = FieldValue.serverTimestamp();
      }
      if (!data.containsKey('lastMessage')) {
        payload['lastMessage'] = '';
      }
      if (!data.containsKey('lastMessageAt')) {
        payload['lastMessageAt'] = FieldValue.serverTimestamp();
      }
    }

    await ref.set(payload, SetOptions(merge: true));
  }

  /// Live list of chats where [userId] is a participant, newest activity first.
  Stream<List<ChatModel>> watchChats(String userId) {
    return _chats
        .where('participants', arrayContains: userId)
        .orderBy('lastMessageAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => ChatModel.fromDoc(doc))
              .toList(),
        );
  }

  /// Live stream of the latest [limit] messages in a chat (newest first).
  Stream<List<ChatMessageModel>> watchMessages(String chatId, int limit) {
    return _chats
        .doc(chatId)
        .collection('messages')
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => ChatMessageModel.fromDoc(doc, chatId))
              .toList(),
        );
  }

  /// Atomically writes a message and updates the chat's lastMessage preview.
  Future<void> sendMessage({
    required String chatId,
    required String senderId,
    required String text,
  }) async {
    final chatRef = _chats.doc(chatId);
    final messagesRef = chatRef.collection('messages');
    final messageRef = messagesRef.doc();

    final message = ChatMessageModel(
      id: messageRef.id,
      chatId: chatId,
      senderId: senderId,
      text: text,
      createdAt: DateTime.now(),
      isRead: false,
    );

    final batch = _firestore.batch();

    batch.set(messageRef, {
      ...message.toMap(),
      'createdAt': FieldValue.serverTimestamp(),
    });

    batch.set(
      chatRef,
      {
        'lastMessage': text,
        'lastMessageAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );

    await batch.commit();
  }

  /// Marks up to 50 unread messages from the other participant as read.
  Future<void> markMessagesAsRead({
    required String chatId,
    required String userId,
  }) async {
    final query = await _chats
        .doc(chatId)
        .collection('messages')
        .where('isRead', isEqualTo: false)
        .limit(50)
        .get();

    if (query.docs.isEmpty) return;

    final batch = _firestore.batch();
    for (final doc in query.docs) {
      final senderId = (doc.data()['senderId'] ?? '').toString();
      if (senderId == userId) continue;
      batch.update(doc.reference, {'isRead': true});
    }
    await batch.commit();
  }

  /// Updates the `typing` map on the chat doc for the given [userId].
  Future<void> setTyping({
    required String chatId,
    required String userId,
    required bool isTyping,
  }) async {
    await _chats.doc(chatId).set(
      {
        'typing': {userId: isTyping},
      },
      SetOptions(merge: true),
    );
  }

  /// Live map of userId → isTyping for a chat room.
  Stream<Map<String, bool>> watchTyping(String chatId) {
    return _chats.doc(chatId).snapshots().map((doc) {
      final data = doc.data();
      final typing = data?['typing'] as Map<String, dynamic>?;
      if (typing == null) return <String, bool>{};
      return typing.map((key, value) => MapEntry(key, value == true));
    });
  }

  // ── Presence ─────────────────────────────────────────────────────────────

  /// Writes own online/offline state to users/{userId}.
  /// Same Firestore path used by Vue web (usePresence composable).
  Future<void> setPresence(String userId, {required bool isOnline}) async {
    await _firestore.collection('users').doc(userId).set(
      {
        'isOnline': isOnline,
        'lastSeen': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  /// Realtime stream for a peer's presence document.
  Stream<Map<String, dynamic>> watchPresence(String userId) {
    if (userId.isEmpty) return Stream.value({});
    return _firestore
        .collection('users')
        .doc(userId)
        .snapshots()
        .map((snap) => snap.data() ?? {});
  }

  /// One-shot pagination: loads messages older than [before] for scroll-up.
  Future<List<ChatMessageModel>> fetchOlderMessages({
    required String chatId,
    required DateTime before,
    int limit = 30,
  }) async {
    final snapshot = await _chats
        .doc(chatId)
        .collection('messages')
        .orderBy('createdAt', descending: true)
        .startAfter([Timestamp.fromDate(before)])
        .limit(limit)
        .get();

    return snapshot.docs
        .map((doc) => ChatMessageModel.fromDoc(doc, chatId))
        .toList();
  }
}
