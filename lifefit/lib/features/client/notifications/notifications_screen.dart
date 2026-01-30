import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'notification_provider.dart';
import 'package:intl/intl.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.read(NotificationProvider.provider.notifier).fetchNotifications();

    final notifications = ref.watch(NotificationProvider.provider);

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
      ),
      // إضافة RefreshIndicator هنا
      body: RefreshIndicator(
        color: const Color(0xFF00D9D9), // لون حلقة التحميل
        onRefresh: () async {
          // استدعاء دالة الجلب وانتظارها حتى تنتهي
          await ref
              .read(NotificationProvider.provider.notifier)
              .fetchNotifications();
        },
        child: notifications.isEmpty
            ? ListView(
                // استخدمنا ListView هنا ليعمل السحب حتى لو القائمة فارغة
                children: const [
                  SizedBox(height: 200),
                  Center(child: Text('لا توجد إشعارات حالياً')),
                ],
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: notifications.length,
                itemBuilder: (context, index) {
                  final notification = notifications[index];

                  return GestureDetector(
                    onTap: () {
                      if (!notification.isRead) {
                        ref
                            .read(NotificationProvider.provider.notifier)
                            .markAsRead(int.parse(notification.id));
                      }
                    },
                    child: _buildNotificationCard(
                      title: notification.title,
                      content: notification.message,
                      time: DateFormat(
                        'hh:mm a',
                      ).format(notification.timestamp),
                      isRead: notification.isRead,
                    ),
                  );
                },
              ),
      ),
    );
  }

  // دالة بناء الكارد تبقى كما هي دون تغيير
  Widget _buildNotificationCard({
    required String title,
    required String content,
    required String time,
    required bool isRead,
  }) {
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
