import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/models/chat/chat_message_model.dart';
import '../providers/chat_providers.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/chat_input.dart';
import '../widgets/empty_state.dart';
import '../widgets/typing_indicator.dart';

class ChatDetailsScreen extends ConsumerStatefulWidget {
  const ChatDetailsScreen({
    super.key,
    required this.chatId,
    required this.title,
    required this.peerId,
  });

  final String chatId;
  final String title;
  final String peerId;

  @override
  ConsumerState<ChatDetailsScreen> createState() => _ChatDetailsScreenState();
}

class _ChatDetailsScreenState extends ConsumerState<ChatDetailsScreen> {
  late final AppLifecycleListener _lifecycle;

  @override
  void initState() {
    super.initState();
    _lifecycle = AppLifecycleListener(
      onResume: () => _setOwnPresence(true),
      onHide: () => _setOwnPresence(false),
      onPause: () => _setOwnPresence(false),
      onDetach: () => _setOwnPresence(false),
    );
    Future.microtask(() {
      ref.read(chatComposerProvider(widget.chatId).notifier).markAsRead();
      _setOwnPresence(true);
    });
  }

  void _setOwnPresence(bool online) {
    final uid = ref.read(currentUserIdProvider);
    if (uid == null || uid.isEmpty) return;
    ref
        .read(firestoreChatServiceProvider)
        .setPresence(uid, isOnline: online);
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    _setOwnPresence(false);
    ref.read(chatComposerProvider(widget.chatId).notifier).setTyping(false);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final messagesAsync = ref.watch(messagesStreamProvider(widget.chatId));
    final pagingState = ref.watch(chatPagingProvider(widget.chatId));
    final typingAsync = ref.watch(typingStreamProvider(widget.chatId));
    final currentUserId = ref.watch(currentUserIdProvider);
    final composerState = ref.watch(chatComposerProvider(widget.chatId));
    final isOnline = ref.watch(presenceStreamProvider(widget.peerId)).valueOrNull ?? false;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.title, style: const TextStyle(fontSize: 16)),
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.only(left: 4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isOnline ? Colors.green : Colors.grey.shade400,
                  ),
                ),
                Text(
                  isOnline ? 'متصل الآن' : 'غير متصل',
                  style: TextStyle(
                    fontSize: 12,
                    color: isOnline ? Colors.green : Colors.grey.shade500,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: messagesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => EmptyState(
                title: 'Unable to load messages',
                message: e.toString(),
                icon: Icons.error_outline,
              ),
              data: (streamMessages) {
                final combined = _mergeMessages(
                  streamMessages,
                  pagingState.olderMessages,
                );

                if (combined.isEmpty) {
                  return const EmptyState(
                    title: 'Say hello',
                    message: 'Send the first message to start the chat.',
                    icon: Icons.chat_bubble_outline,
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  reverse: true,
                  itemCount: combined.length + (pagingState.hasMore ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == combined.length && pagingState.hasMore) {
                      return _LoadOlderButton(
                        isLoading: pagingState.isFetchingMore,
                        onPressed: () {
                          final oldest = combined.last.createdAt;
                          ref
                              .read(chatPagingProvider(widget.chatId).notifier)
                              .loadOlderMessages(oldest);
                        },
                      );
                    }

                    final message = combined[index];
                    final isMe = currentUserId != null &&
                        message.senderId == currentUserId;

                    return ChatBubble(
                      message: message,
                      isMe: isMe,
                      timeLabel: DateFormat.Hm().format(message.createdAt),
                    );
                  },
                );
              },
            ),
          ),
          if (typingAsync.valueOrNull != null &&
              _isSomeoneTyping(typingAsync.value!, currentUserId))
            const Padding(
              padding: EdgeInsets.only(bottom: 4),
              child: TypingIndicator(),
            ),
          ChatInput(
            isSending: composerState.isSending,
            onSend: (text) => ref
                .read(chatComposerProvider(widget.chatId).notifier)
                .sendMessage(text),
            onTypingChanged: (isTyping) => ref
                .read(chatComposerProvider(widget.chatId).notifier)
                .setTyping(isTyping),
          ),
        ],
      ),
    );
  }

  List<ChatMessageModel> _mergeMessages(
    List<ChatMessageModel> streamMessages,
    List<ChatMessageModel> olderMessages,
  ) {
    final map = <String, ChatMessageModel>{
      for (final message in streamMessages) message.id: message,
      for (final message in olderMessages) message.id: message,
    };
    final merged = map.values.toList();
    merged.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return merged;
  }

  bool _isSomeoneTyping(Map<String, bool> typing, String? currentUserId) {
    for (final entry in typing.entries) {
      if (entry.key != currentUserId && entry.value == true) return true;
    }
    return false;
  }
}

class _LoadOlderButton extends StatelessWidget {
  const _LoadOlderButton({
    required this.isLoading,
    required this.onPressed,
  });

  final bool isLoading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 12),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Center(
        child: TextButton.icon(
          onPressed: onPressed,
          icon: const Icon(Icons.history),
          label: const Text('Load earlier messages'),
        ),
      ),
    );
  }
}
