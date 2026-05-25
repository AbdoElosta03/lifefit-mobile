import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/models/chat/chat_model.dart';
import '../providers/chat_providers.dart';
import '../widgets/chat_list_tile.dart';
import '../widgets/empty_state.dart';
import 'chat_details_screen.dart';
import 'select_coach_screen.dart';

class ChatListScreen extends ConsumerWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chatsAsync = ref.watch(chatsStreamProvider);
    final userId = ref.watch(currentUserIdProvider);
    final role = ref.watch(currentUserRoleProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('المحادثات'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'محادثة جديدة',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const SelectCoachScreen(),
              ),
            ),
          ),
        ],
      ),
      body: userId == null
          ? const EmptyState(
              title: 'يجب تسجيل الدخول',
              message: 'لم نتمكن من العثور على ملفك الشخصي.',
              icon: Icons.lock_outline,
            )
          : chatsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => EmptyState(
                title: 'حدث خطأ',
                message: e.toString(),
                icon: Icons.error_outline,
              ),
              data: (chats) {
                if (chats.isEmpty) {
                  return const EmptyState(
                    title: 'لا توجد محادثات بعد',
                    message: 'اضغط + لبدء محادثة مع مدربك.',
                    icon: Icons.chat_bubble_outline,
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: chats.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final chat = chats[index];
                    final title = _chatTitle(chat, role);
                    final peerId = chat.otherParticipantId(userId);
                    return ChatListTile(
                      chat: chat,
                      title: title,
                      accentColor: colorScheme.primary,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ChatDetailsScreen(
                              chatId: chat.id,
                              title: title,
                              peerId: peerId,
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
    );
  }

  /// Client sees [ChatModel.coachName]; trainer/nutritionist sees [ChatModel.clientName].
  /// Falls back to a generic label — never raw user IDs.
  String _chatTitle(ChatModel chat, String? role) {
    final isClient = role == 'client';
    if (isClient) {
      final name = chat.coachName?.trim();
      if (name != null && name.isNotEmpty) return name;
    } else if (role == 'trainer' || role == 'nutritionist') {
      final name = chat.clientName?.trim();
      if (name != null && name.isNotEmpty) return name;
    }
    return 'محادثة';
  }
}
