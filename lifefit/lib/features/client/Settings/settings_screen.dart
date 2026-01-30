import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('إعدادات الحساب', 
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 1. قسم البروفايل العلوي
            _buildProfileHeader(),
            
            const SizedBox(height: 25),

            // 2. قسم المعلومات الشخصية
            _buildSectionTitle('المعلومات الشخصية'),
            _buildSettingsCard([
              _buildSettingsItem(Icons.person_outline_rounded, 'الاسم الكامل', 'أحمد محمد'),
              _buildSettingsItem(Icons.email_outlined, 'البريد الإلكتروني', 'ahmed@example.com'),
              _buildSettingsItem(Icons.phone_android_rounded, 'رقم الهاتف', '+218 91 0000000'),
              _buildSettingsItem(Icons.location_on_outlined, 'العنوان', 'طرابلس، ليبيا'),
            ]),

            const SizedBox(height: 20),

            // 3. قسم الأمان
            _buildSectionTitle('الأمان والحساب'),
            _buildSettingsCard([
              _buildSettingsItem(Icons.lock_outline_rounded, 'تغيير كلمة المرور', 'تعديل الآن', isAction: true),
              _buildSettingsItem(Icons.verified_user_outlined, 'توثيق الحساب', 'نشط'),
            ]),

            const SizedBox(height: 20),
            
            // زر حذف الحساب
            TextButton(
              onPressed: () {},
              child: const Text('حذف الحساب نهائياً', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  // رأس الصفحة (الصورة والاسم)
  Widget _buildProfileHeader() {
    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
              child: const CircleAvatar(
                radius: 50,
                backgroundColor: Color(0xFF00D9D9),
                child: Icon(Icons.person, size: 60, color: Colors.white),
              ),
            ),
            CircleAvatar(
              radius: 18,
              backgroundColor: Colors.white,
              child: IconButton(
                icon: const Icon(Icons.camera_alt_rounded, size: 18, color: Color(0xFF00D9D9)),
                onPressed: () {},
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        const Text('أحمد محمد', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const Text('تعديل صورة البروفايل', style: TextStyle(color: Colors.grey, fontSize: 13)),
      ],
    );
  }

  // ميثود بناء عنوان القسم
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(right: 8, bottom: 8),
      child: Align(
        alignment: Alignment.centerRight,
        child: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey)),
      ),
    );
  }

  // ميثود بناء كارد يحتوي على مجموعة خيارات
  Widget _buildSettingsCard(List<Widget> items) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(children: items),
    );
  }

  // ميثود بناء عنصر واحد داخل الإعدادات
  Widget _buildSettingsItem(IconData icon, String title, String value, {bool isAction = false}) {
    return ListTile(
      leading: isAction ? const Icon(Icons.arrow_back_ios_new_rounded, size: 14, color: Colors.grey) : Text(value, style: const TextStyle(color: Colors.grey, fontSize: 14)),
      title: Text(title, textAlign: TextAlign.right, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
      trailing: Icon(icon, color: const Color(0xFF00D9D9), size: 22),
      onTap: () {},
    );
  }
}