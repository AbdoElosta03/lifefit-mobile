import 'package:flutter/material.dart';
import '../../../features/client/notifications/notifications_screen.dart';
import '../../../features/client/Settings/settings_screen.dart';
import '../../../features/client/experts/experts_screen.dart';
import '../../../features/client/chats/chats_screen.dart';
import '../../../features/client/health_profile/health_profile_screen.dart';
import '../../../features/client/Subscriptions/subscriptions_screen.dart';
class ClientDrawer extends StatelessWidget {
  const ClientDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      // حواف دائرية ناعمة لتناسب التصميم الاحترافي
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(35),
          bottomLeft: Radius.circular(35),
        ),
      ),
      child: Column(
        children: [
          // 1. الهيدر الملون (نفس السيستم المتبع)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 60, bottom: 30),
            decoration: const BoxDecoration(
              color: Color(0xFF00D9D9),
              borderRadius: BorderRadius.only(topLeft: Radius.circular(35)),
            ),
            child: Column(
              children: [
                // صورة البروفايل
                Container(
                  padding: const EdgeInsets.all(3),
                  decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                  child: CircleAvatar(
                    radius: 42,
                    backgroundColor: Colors.grey[200],
                    child: const Icon(Icons.person, size: 50, color: Color(0xFF00D9D9)),
                  ),
                ),
                const SizedBox(height: 15),
                const Text(
                  'أحمد محمد',
                  style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const Text(
                  'عميل مميز',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),

          // 2. التبويبات الستة
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
              children: [
                _buildDrawerItem(context, Icons.add_moderator_rounded, 'الملف الصحي', () {
                  Navigator.pop(context); // إغلاق الدرواير
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const HealthProfileScreen()),
                  );
                }),
                _buildDrawerItem(context, Icons.group_rounded, 'الخبراء', () {
                  Navigator.pop(context); 
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ExpertsScreen()),
                  );
                }),
                _buildDrawerItem(context, Icons.chat_bubble_outline_rounded, 'المحادثات', () {
                  Navigator.pop(context); 
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ChatListScreen(), 
                    ),
                  );

                }),
                _buildDrawerItem(context, Icons.notifications_none_rounded, 'الإشعارات', () {
                  Navigator.pop(context); // إغلاق الدرواير
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const NotificationsScreen()),
                  );
                }),
                _buildDrawerItem(context, Icons.card_membership_rounded, 'الاشتراكات', () {
                  Navigator.pop(context); // إغلاق الدرواير
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SubscriptionsScreen()),
                  );
                  // أضف وجهة الاشتراكات هنا
                }),
                _buildDrawerItem(context, Icons.settings_outlined, 'الإعدادات', () {
                  // أضف وجهة الإعدادات هنا
                  Navigator.pop(context); // إغلاق الدرواير
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SettingsScreen()),
                  );
                }),
              ],
            ),
          ),

          // 3. زر تسجيل الخروج
          const Divider(),
          _buildDrawerItem(context, Icons.logout_rounded, 'تسجيل الخروج', () {
            // كود تسجيل الخروج والربط مع Laravel مستقبلاً
          }, isLogout: true),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // ميثود بناء العناصر بشكل نظيف وقابل للربط
  Widget _buildDrawerItem(BuildContext context, IconData icon, String title, VoidCallback onTap, {bool isLogout = false}) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20),
      // الأيقونة في جهة اليمين لتناسب الواجهة العربية (trailing)
      trailing: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isLogout ? Colors.red[50] : const Color(0xFF00D9D9).withOpacity(0.08),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: isLogout ? Colors.redAccent : const Color(0xFF00D9D9), size: 22),
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