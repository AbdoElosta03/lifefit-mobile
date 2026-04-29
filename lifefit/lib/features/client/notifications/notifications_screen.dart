import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'notification_provider.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final pos = _scrollController.position;
    if (pos.pixels >= pos.maxScrollExtent - 160) {
      ref.read(notificationsProvider.notifier).loadMore();
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(notificationsProvider);
    ref.listen<String?>(
      notificationsProvider.select((s) => s.error),
      (prev, next) {
        if (next != null && next.isNotEmpty && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(next)),
          );
        }
      },
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          'الإشعارات',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.black,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: state.items.any((n) => !n.isRead)
                ? () => ref.read(notificationsProvider.notifier).markAllRead()
                : null,
            child: const Text(
              'تعليم الكل كمقروء',
              style: TextStyle(
                color: Color(0xFF00D9D9),
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: RefreshIndicator(
        color: const Color(0xFF00D9D9),
        onRefresh: () => ref.read(notificationsProvider.notifier).refresh(),
        child: state.loading && state.items.isEmpty
            ? ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(height: 120),
                  Center(child: CircularProgressIndicator(color: Color(0xFF00D9D9))),
                ],
              )
            : state.items.isEmpty
                ? ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: const [
                      SizedBox(height: 200),
                      Center(child: Text('لا توجد إشعارات حالياً')),
                    ],
                  )
                : ListView.builder(
                    controller: _scrollController,
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    itemCount: state.items.length + (state.loadingMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index >= state.items.length) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 24),
                          child: Center(
                            child: SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Color(0xFF00D9D9),
                                strokeWidth: 2,
                              ),
                            ),
                          ),
                        );
                      }
                      final notification = state.items[index];
                      final timeStr = notification.createdAt != null
                          ? DateFormat('hh:mm a').format(notification.createdAt!.toLocal())
                          : '';

                      return GestureDetector(
                        onTap: () {
                          if (!notification.isRead) {
                            ref.read(notificationsProvider.notifier).markOneRead(notification.id);
                          }
                        },
                        child: _NotificationCard(
                          title: notification.title,
                          content: notification.body,
                          time: timeStr,
                          isRead: notification.isRead,
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final String title;
  final String content;
  final String time;
  final bool isRead;

  const _NotificationCard({
    required this.title,
    required this.content,
    required this.time,
    required this.isRead,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: isRead
            ? null
            : Border.all(
                color: const Color(0xFF00D9D9).withOpacity(0.3),
                width: 1,
              ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(time, style: TextStyle(color: Colors.grey[400], fontSize: 11)),
          const Spacer(),
          Expanded(
            flex: 8,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  title,
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: isRead ? Colors.black87 : const Color(0xFF00D9D9),
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  content,
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isRead
                  ? const Color(0xFFF5F5F5)
                  : const Color(0xFF00D9D9).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isRead
                  ? Icons.notifications_none_rounded
                  : Icons.notifications_active_rounded,
              color: isRead ? Colors.grey : const Color(0xFF00D9D9),
              size: 22,
            ),
          ),
        ],
      ),
    );
  }
}
