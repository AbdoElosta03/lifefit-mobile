import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'chat_details_screen.dart';
import 'conversation_provider.dart';

class ChatListScreen extends ConsumerWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final conversationsAsync = ref.watch(conversationProvider);
    const primaryColor = Color(0xFF00D9D9);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBar(
          title: const Text('المحادثات', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          centerTitle: true,
          backgroundColor: primaryColor,
          elevation: 0,
        ),
        body: conversationsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator(color: primaryColor)),
          error: (e, _) => Center(child: Text("حدث خطأ: $e")),
          data: (list) {
            if (list.isEmpty) return const Center(child: Text("لا توجد محادثات"));
            return RefreshIndicator(
              onRefresh: () async => ref.refresh(conversationProvider),
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: list.length,
                itemBuilder: (context, index) {
                  final conv = list[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    child: ListTile(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => ChatDetailsScreen(
                          conversationId: conv.id, 
                          expertName: conv.expertName
                        )),
                      ),
                      leading: CircleAvatar(
                        backgroundColor: primaryColor.withOpacity(0.1),
                        child: Text(conv.expertName[0], style: const TextStyle(color: primaryColor)),
                      ),
                      title: Text(conv.expertName, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(conv.lastMessage ?? '', maxLines: 1),
                      trailing: conv.unreadCount > 0 
                        ? CircleAvatar(radius: 10, backgroundColor: primaryColor, child: Text("${conv.unreadCount}", style: const TextStyle(fontSize: 10, color: Colors.white)))
                        : null,
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}