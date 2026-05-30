import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app_colors.dart';
import '../../auth/auth_provider.dart';
import '../../../features/client/profile/profile_screen.dart';
import '../../../features/client/notifications/notifications_screen.dart';
import '../../../features/client/notifications/notification_provider.dart';

/// CustomAppBar — shared scaffold app bar for client screens.
class CustomAppBar extends ConsumerWidget implements PreferredSizeWidget {
  final String title;

  const CustomAppBar({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unread = ref.watch(unreadNotificationCountProvider);
    final hasUnread = unread > 0;
    final badgeLabel = unread > 99 ? '99+' : '$unread';
    final user = ref.watch(authProvider).user;
    final avatarUrl = user?.avatar;

    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0.5,
      centerTitle: true,
      automaticallyImplyLeading: false,

      // Widget: Title
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),

      leadingWidth: 124,
      leading: Row(
        children: [
          const SizedBox(width: 15),

          // Widget: Avatar (profile)
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const ProfileScreen()),
              );
            },
            borderRadius: BorderRadius.circular(12),
            child: _AvatarWidget(url: avatarUrl),
          ),
          const SizedBox(width: 10),

          // Widget: Notifications
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const NotificationsScreen()),
              );
            },
            borderRadius: BorderRadius.circular(12),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    hasUnread
                        ? Icons.notifications_active_rounded
                        : Icons.notifications_none_rounded,
                    color: hasUnread ? AppColors.primary : Colors.black87,
                    size: 22,
                  ),
                ),

                // Widget: Unread badge
                if (hasUnread)
                  Positioned(
                    right: -2,
                    top: -2,
                    child: Container(
                      constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        color: Colors.redAccent,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.white, width: 1.5),
                      ),
                      child: Text(
                        badgeLabel,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          height: 1.2,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),

      actions: [
        // Widget: End drawer menu
        IconButton(
          icon: const Icon(Icons.notes_rounded, color: Colors.black, size: 28),
          onPressed: () => Scaffold.of(context).openEndDrawer(),
        ),
        const SizedBox(width: 10),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(60);
}

// Widget: Avatar
class _AvatarWidget extends StatelessWidget {
  final String? url;
  const _AvatarWidget({this.url});

  @override
  Widget build(BuildContext context) {
    if (url != null && url!.isNotEmpty) {
      return Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          image: DecorationImage(
            image: NetworkImage(url!),
            fit: BoxFit.cover,
            onError: (_, __) {},
          ),
          color: AppColors.primary.withValues(alpha: 0.1),
        ),
      );
    }
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Icon(Icons.person, color: AppColors.primary, size: 22),
    );
  }
}
