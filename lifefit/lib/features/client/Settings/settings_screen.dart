import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/models/user.dart';
import '../../../core/ui/app_colors.dart';
import 'account_edit_sheet.dart';
import 'change_password_sheet.dart';
import 'settings_provider.dart';

// ─── Account Settings Screen ──────────────────────────────────────────────────
// Data source: accountSettingsProvider → GET /api/user
// Edit: account_edit_sheet (PUT /api/user) | Avatar: POST /api/avatar
// Password: change_password_sheet (POST /api/change-password)

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(accountSettingsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'إعدادات الحساب',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      // Standard AsyncValue pattern: loading / error / data
      body: async.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (e, _) => _ErrorPane(
          message: e.toString().replaceFirst('Exception: ', ''),
          onRetry: () => ref.read(accountSettingsProvider.notifier).refresh(),
        ),
        data: (user) => _SettingsBody(user: user),
      ),
    );
  }
}

class _ErrorPane extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorPane({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: onRetry,
              style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
              child: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsBody extends ConsumerWidget {
  final User user;

  const _SettingsBody({required this.user});

  String _orPlaceholder(String? value) {
    final v = value?.trim();
    if (v == null || v.isEmpty) return 'غير محدد';
    return v;
  }

  /// Uploads image as multipart to POST /api/avatar and updates local state.
  Future<void> _pickAvatar(BuildContext context, WidgetRef ref) async {
    final picker = ImagePicker();
    final x = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (x == null || !context.mounted) return;

    try {
      final bytes = await x.readAsBytes();
      await ref.read(accountSettingsProvider.notifier).uploadAvatar(
            bytes: bytes,
            fileName: x.name,
          );
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم تحديث الصورة الشخصية')),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // email_verified_at from API — read-only, no edit action here
    final verifiedLabel = user.isEmailVerified ? 'نشط' : 'غير موثّق';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildProfileHeader(context, ref),
          const SizedBox(height: 25),
          // Account fields — all items open the same edit sheet
          _buildSectionTitle('المعلومات الشخصية'),
          _buildSettingsCard([
            _buildSettingsItem(
              Icons.person_outline_rounded,
              'الاسم الكامل',
              user.name,
              onTap: () => showAccountEditSheet(context, user),
            ),
            _buildSettingsItem(
              Icons.email_outlined,
              'البريد الإلكتروني',
              user.email,
              onTap: () => showAccountEditSheet(context, user),
            ),
            _buildSettingsItem(
              Icons.phone_android_rounded,
              'رقم الهاتف',
              _orPlaceholder(user.phone),
              onTap: () => showAccountEditSheet(context, user),
            ),
            _buildSettingsItem(
              Icons.edit_outlined,
              'تعديل بيانات الحساب',
              'تعديل الآن',
              isAction: true,
              onTap: () => showAccountEditSheet(context, user),
            ),
          ]),
          const SizedBox(height: 20),
          _buildSectionTitle('الأمان والحساب'),
          _buildSettingsCard([
            _buildSettingsItem(
              Icons.lock_outline_rounded,
              'تغيير كلمة المرور',
              'تعديل الآن',
              isAction: true,
              onTap: () => showChangePasswordSheet(context),
            ),
            _buildSettingsItem(
              Icons.verified_user_outlined,
              'توثيق الحساب',
              verifiedLabel,
            ),
          ]),
          const SizedBox(height: 20),
          // TODO: no delete-account endpoint in the backend yet
          TextButton(
            onPressed: () {},
            child: const Text(
              'حذف الحساب نهائياً',
              style: TextStyle(
                color: Colors.redAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, WidgetRef ref) {
    final avatarUrl = user.displayAvatarUrl;

    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: CircleAvatar(
                radius: 50,
                backgroundColor: AppColors.primary,
                backgroundImage:
                    avatarUrl != null ? NetworkImage(avatarUrl) : null,
                child: avatarUrl == null
                    ? const Icon(Icons.person, size: 60, color: Colors.white)
                    : null,
              ),
            ),
            CircleAvatar(
              radius: 18,
              backgroundColor: Colors.white,
              child: IconButton(
                icon: const Icon(
                  Icons.camera_alt_rounded,
                  size: 18,
                  color: AppColors.primary,
                ),
                onPressed: () => _pickAvatar(context, ref),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          user.name,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const Text(
          'تعديل صورة البروفايل',
          style: TextStyle(color: Colors.grey, fontSize: 13),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(right: 8, bottom: 8),
      child: Align(
        alignment: Alignment.centerRight,
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsCard(List<Widget> items) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(children: items),
    );
  }

  Widget _buildSettingsItem(
    IconData icon,
    String title,
    String value, {
    bool isAction = false,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: isAction
          ? const Icon(Icons.arrow_back_ios_new_rounded,
              size: 14, color: Colors.grey)
          : Text(
              value,
              style: const TextStyle(color: Colors.grey, fontSize: 14),
            ),
      title: Text(
        title,
        textAlign: TextAlign.right,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
      ),
      trailing: Icon(icon, color: AppColors.primary, size: 22),
      onTap: onTap,
    );
  }
}
