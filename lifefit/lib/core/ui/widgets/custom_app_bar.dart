import 'package:flutter/material.dart';
// تأكد من استيراد الملفات الخاصة بالصفحات هنا
import '../../../features/client/profile_web/profile_screen_web.dart';
import '../../../features/client/notifications/notifications_screen.dart';



class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  const CustomAppBar({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0.5,
      centerTitle: true,
      automaticallyImplyLeading: false,

      // العنوان في المنتصف
      title: Text(title,
          style: const TextStyle(
              color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18)),

      // الأيقونات جهة اليسار (الصورة الشخصية والتنبيهات)
      leadingWidth: 110,
      leading: Row(
        children: [
          const SizedBox(width: 15),
          // صورة الملف الشخصي (تذهب للملف الصحي)
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfileScreenWeb()),
              );
            },
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                image: const DecorationImage(
                  image: NetworkImage('https://cdn-icons-png.flaticon.com/512/3135/3135715.png'), // صورة افتراضية من الإنترنت
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          // أيقونة الإشعارات (تذهب لصفحة الإشعارات)
          _buildActionIcon(
            icon: Icons.notifications_none_rounded,
            color: Colors.black87,
            bgColor: const Color(0xFFF5F5F5),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const NotificationsScreen()),
              );
            },
          ),
        ],
      ),

      // أيقونة المنيو جهة اليمين
      actions: [
        IconButton(
          icon: const Icon(Icons.notes_rounded, color: Colors.black, size: 28),
          onPressed: () => Scaffold.of(context).openEndDrawer(),
        ),
        const SizedBox(width: 10),
      ],
    );
  }

  Widget _buildActionIcon({
    required IconData icon,
    required Color color,
    required Color bgColor,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: color, size: 22),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(60);
}