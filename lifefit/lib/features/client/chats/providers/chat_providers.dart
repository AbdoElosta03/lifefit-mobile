import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/auth/auth_provider.dart';
import '../../../../core/models/chat/chat_message_model.dart';
import '../../../../core/models/chat/chat_model.dart';
import '../../../../core/services/firestore_chat_service.dart';

final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

final firestoreChatServiceProvider = Provider<FirestoreChatService>((ref) {
  return FirestoreChatService(ref.watch(firestoreProvider));
});

final currentUserIdProvider = Provider<String?>((ref) {
  final user = ref.watch(authProvider).user;
  return user?.id.toString();
});

/// Used to pick list titles: client sees coach, coach sees client (Firestore names).
final currentUserRoleProvider = Provider<String?>((ref) {
  return ref.watch(authProvider).user?.role;
});

final chatsStreamProvider = StreamProvider.autoDispose<List<ChatModel>>((ref) {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) return const Stream.empty();
  return ref.watch(firestoreChatServiceProvider).watchChats(userId);
});

final messagesStreamProvider =
    StreamProvider.autoDispose.family<List<ChatMessageModel>, String>(
  (ref, chatId) {
    return ref.watch(firestoreChatServiceProvider).watchMessages(chatId, 50);
  },
);

final typingStreamProvider =
    StreamProvider.autoDispose.family<Map<String, bool>, String>(
  (ref, chatId) {
    return ref.watch(firestoreChatServiceProvider).watchTyping(chatId);
  },
);

/// Streams isOnline boolean for any userId from users/{userId}.
/// Used by ChatDetailsScreen to show an online dot in the AppBar.
final presenceStreamProvider =
    StreamProvider.autoDispose.family<bool, String>((ref, userId) {
  if (userId.isEmpty) return Stream.value(false);
  return ref
      .watch(firestoreChatServiceProvider)
      .watchPresence(userId)
      .map((data) => data['isOnline'] == true);
});

class ChatComposerState {
  final bool isSending;
  final String? errorMessage;
  final bool isTyping;

  const ChatComposerState({
    this.isSending = false,
    this.errorMessage,
    this.isTyping = false,
  });

  ChatComposerState copyWith({
    bool? isSending,
    String? errorMessage,
    bool? isTyping,
  }) {
    return ChatComposerState(
      isSending: isSending ?? this.isSending,
      errorMessage: errorMessage,
      isTyping: isTyping ?? this.isTyping,
    );
  }
}

final chatComposerProvider =
    StateNotifierProvider.autoDispose.family<ChatComposerController,
        ChatComposerState, String>((ref, chatId) {
  return ChatComposerController(
    service: ref.watch(firestoreChatServiceProvider),
    chatId: chatId,
    userId: ref.watch(currentUserIdProvider),
  );
});

class ChatComposerController extends StateNotifier<ChatComposerState> {
  ChatComposerController({
    required FirestoreChatService service,
    required String chatId,
    required String? userId,
  })  : _service = service,
        _chatId = chatId,
        _userId = userId,
        super(const ChatComposerState());

  final FirestoreChatService _service;
  final String _chatId;
  final String? _userId;
  Timer? _typingTimer;

  Future<void> sendMessage(String text) async {
    final userId = _userId;
    if (userId == null || text.trim().isEmpty) return;

    state = state.copyWith(isSending: true, errorMessage: null);
    try {
      await _service.sendMessage(
        chatId: _chatId,
        senderId: userId,
        text: text.trim(),
      );
      state = state.copyWith(isSending: false);
    } catch (e) {
      state = state.copyWith(
        isSending: false,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> markAsRead() async {
    final userId = _userId;
    if (userId == null) return;

    try {
      await _service.markMessagesAsRead(chatId: _chatId, userId: userId);
    } catch (_) {}
  }

  Future<void> setTyping(bool isTyping) async {
    final userId = _userId;
    if (userId == null) return;

    _typingTimer?.cancel();
    state = state.copyWith(isTyping: isTyping);

    try {
      await _service.setTyping(
        chatId: _chatId,
        userId: userId,
        isTyping: isTyping,
      );
    } catch (_) {}

    if (isTyping) {
      _typingTimer = Timer(const Duration(seconds: 2), () {
        _service.setTyping(
          chatId: _chatId,
          userId: userId,
          isTyping: false,
        );
      });
    }
  }

  @override
  void dispose() {
    _typingTimer?.cancel();
    super.dispose();
  }
}

class ChatPagingState {
  final List<ChatMessageModel> olderMessages;
  final bool isFetchingMore;
  final bool hasMore;
  final String? errorMessage;

  const ChatPagingState({
    this.olderMessages = const [],
    this.isFetchingMore = false,
    this.hasMore = true,
    this.errorMessage,
  });

  ChatPagingState copyWith({
    List<ChatMessageModel>? olderMessages,
    bool? isFetchingMore,
    bool? hasMore,
    String? errorMessage,
  }) {
    return ChatPagingState(
      olderMessages: olderMessages ?? this.olderMessages,
      isFetchingMore: isFetchingMore ?? this.isFetchingMore,
      hasMore: hasMore ?? this.hasMore,
      errorMessage: errorMessage,
    );
  }
}

final chatPagingProvider = StateNotifierProvider.autoDispose
    .family<ChatPagingController, ChatPagingState, String>((ref, chatId) {
  return ChatPagingController(
    service: ref.watch(firestoreChatServiceProvider),
    chatId: chatId,
  );
});

class ChatPagingController extends StateNotifier<ChatPagingState> {
  ChatPagingController({
    required FirestoreChatService service,
    required String chatId,
  })  : _service = service,
        _chatId = chatId,
        super(const ChatPagingState());

  final FirestoreChatService _service;
  final String _chatId;

  Future<void> loadOlderMessages(DateTime? before) async {
    if (before == null || state.isFetchingMore || !state.hasMore) return;

    state = state.copyWith(isFetchingMore: true, errorMessage: null);
    try {
      final result = await _service.fetchOlderMessages(
        chatId: _chatId,
        before: before,
      );

      if (result.isEmpty) {
        state = state.copyWith(isFetchingMore: false, hasMore: false);
        return;
      }

      final merged = _mergeById(state.olderMessages, result);
      state = state.copyWith(
        olderMessages: merged,
        isFetchingMore: false,
        hasMore: true,
      );
    } catch (e) {
      state = state.copyWith(
        isFetchingMore: false,
        errorMessage: e.toString(),
      );
    }
  }

  List<ChatMessageModel> _mergeById(
    List<ChatMessageModel> existing,
    List<ChatMessageModel> incoming,
  ) {
    final map = <String, ChatMessageModel>{
      for (final message in existing) message.id: message,
    };
    for (final message in incoming) {
      map[message.id] = message;
    }
    final merged = map.values.toList();
    merged.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return merged;
  }
}
