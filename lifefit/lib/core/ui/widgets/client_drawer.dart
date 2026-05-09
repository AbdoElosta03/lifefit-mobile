import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/auth_provider.dart';
import '../../../features/client/notifications/notifications_screen.dart';
import '../../../features/client/Settings/settings_screen.dart';

import '../../../features/client/chats/chats_screen.dart';
import '../../../features/client/profile_web/profile_screen_web.dart';

import '../../../features/client/programs/client_programs_screen.dart';
import '../../../features/client/progress_photos/progress_photos_screen.dart';
import '../../../features/client/subscription/my_subscriptions_screen.dart';
import '../../../features/client/subscription/trainers_screen.dart';

class ClientDrawer extends ConsumerWidget {
  const ClientDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;
    final avatarUrl = user?.avatar;
    final userName = user?.name ?? 'المستخدم';

    return Drawer(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(35),
          bottomLeft: Radius.circular(35),
        ),
      ),
      child: Column(
        children: [
          // ── Header ──────────────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 60, bottom: 30),
            decoration: const BoxDecoration(
              color: Color(0xFF00D9D9),
              borderRadius: BorderRadius.only(topLeft: Radius.circular(35)),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(3),
                  decoration: const BoxDecoration(
                      color: Colors.white, shape: BoxShape.circle),
                  child: _UserAvatar(url: avatarUrl, radius: 42),
                ),
                const SizedBox(height: 15),
                Text(
                  userName,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
                const Text(
                  'عميل',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),

          // ── Items ────────────────────────────────────────
          Expanded(
            child: ListView(
              padding:
                  const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
              children: [
                _item(context, Icons.add_moderator_rounded, 'الملف الشخصي',
                    () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const ProfileScreenWeb()),
                  );
                }),
                _item(context, Icons.playlist_add_check_rounded, 'برامجي',
                    () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const ClientProgramsScreen()),
                  );
                }),
                _item(context, Icons.photo_camera_back_outlined, 'صور التقدم',
                    () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const ProgressPhotosScreen()),
                  );
                }),
                _item(context, Icons.groups_rounded, 'المدربون والمتخصصون',
                    () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const TrainersScreen()),
                  );
                }),
                _item(context, Icons.card_membership_rounded, 'اشتراكاتي',
                    () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const MySubscriptionsScreen()),
                  );
                }),
                _item(context, Icons.chat_bubble_outline_rounded, 'المحادثات',
                    () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const ChatListScreen()),
                  );
                }),
                _item(context, Icons.notifications_none_rounded, 'الإشعارات',
                    () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const NotificationsScreen()),
                  );
                }),
                _item(context, Icons.settings_outlined, 'اعدادات الحساب',
                    () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const SettingsScreen()),
                  );
                }),
              ],
            ),
          ),

          // ── Logout ───────────────────────────────────────
          const Divider(),
          _item(context, Icons.logout_rounded, 'تسجيل الخروج', () async {
            Navigator.pop(context);
            await ref.read(authProvider.notifier).logout();
          }, isLogout: true),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _item(
    BuildContext context,
    IconData icon,
    String title,
    VoidCallback onTap, {
    bool isLogout = false,
  }) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20),
      trailing: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isLogout
              ? Colors.red[50]
              : const Color(0xFF00D9D9).withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon,
            color: isLogout ? Colors.redAccent : const Color(0xFF00D9D9),
            size: 22),
      ),
      title: Text(
        title,
        textAlign: TextAlign.right,
        style: TextStyle(
          color: isLogout ? Colors.redAccent : Colors.black87,
          fontWeight: FontWeight.w500,
          fontSize: 16,
        ),
      ),
    );
  }
}

/// Reusable avatar widget: shows network image or fallback icon.
class _UserAvatar extends StatelessWidget {
  final String? url;
  final double radius;

  const _UserAvatar({this.url, required this.radius});

  @override
  Widget build(BuildContext context) {
    if (url != null && url!.isNotEmpty) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: Colors.grey[200],
        backgroundImage: NetworkImage(url!),
        onBackgroundImageError: (_, __) {},
        child: null,
      );
    }
    return CircleAvatar(
      radius: radius,
      backgroundColor: const Color(0xFF00D9D9).withValues(alpha: 0.15),
      child: Icon(Icons.person,
          size: radius * 1.1, color: const Color(0xFF00D9D9)),
    );
  }
}
