import 'package:flutter/material.dart';
import '../../../core/ui/app_colors.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/profile_web/client_profile_bundle.dart';
import 'profile_provider.dart';

class ProfileEditSheet extends ConsumerStatefulWidget {
  final ClientProfileBundle initial;

  const ProfileEditSheet({super.key, required this.initial});

  @override
  ConsumerState<ProfileEditSheet> createState() => _ProfileEditSheetState();
}

class _ProfileEditSheetState extends ConsumerState<ProfileEditSheet> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _birthCtrl;
  late final TextEditingController _heightCtrl;
  late final TextEditingController _targetWeightCtrl;
  late final TextEditingController _weightCtrl;
  late final TextEditingController _muscleCtrl;
  late final TextEditingController _fatCtrl;
  late final TextEditingController _notesCtrl;
  bool _saving = false;

  static const _accent = AppColors.primary;

  @override
  void initState() {
    super.initState();
    final u = widget.initial.user;
    final p = widget.initial.profile;
    final s = widget.initial.currentStats;
    _nameCtrl = TextEditingController(text: u.name);
    _birthCtrl = TextEditingController(text: p.birthDate ?? '');
    _heightCtrl = TextEditingController(text: p.heightCm?.toString() ?? '');
    _targetWeightCtrl =
        TextEditingController(text: p.targetWeightKg?.toString() ?? '');
    _weightCtrl = TextEditingController(text: s.weightKg?.toString() ?? '');
    _muscleCtrl =
        TextEditingController(text: s.muscleMassKg?.toString() ?? '');
    _fatCtrl = TextEditingController(text: s.bodyFatPct?.toString() ?? '');
    _notesCtrl = TextEditingController(text: p.goalNotes ?? '');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _birthCtrl.dispose();
    _heightCtrl.dispose();
    _targetWeightCtrl.dispose();
    _weightCtrl.dispose();
    _muscleCtrl.dispose();
    _fatCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final body = <String, dynamic>{};
    if (_nameCtrl.text.trim().isNotEmpty) body['name'] = _nameCtrl.text.trim();
    if (_birthCtrl.text.trim().isNotEmpty) {
      body['birth_date'] = _birthCtrl.text.trim();
    }
    _putNum(body, 'height_cm', _heightCtrl.text);
    _putNum(body, 'target_weight_kg', _targetWeightCtrl.text);
    _putNum(body, 'weight_kg', _weightCtrl.text);
    _putNum(body, 'muscle_mass_kg', _muscleCtrl.text);
    _putNum(body, 'body_fat_pct', _fatCtrl.text);
    if (_notesCtrl.text.trim().isNotEmpty) {
      body['goal_notes'] = _notesCtrl.text.trim();
    }

    try {
      await ref.read(clientProfileProvider.notifier).update(body);
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم حفظ التغييرات'),
            backgroundColor: _accent,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _putNum(Map<String, dynamic> map, String key, String text) {
    final t = text.trim();
    if (t.isEmpty) return;
    final n = double.tryParse(t);
    if (n != null) map[key] = n;
  }

  @override
  Widget build(BuildContext context) {
    // Bottom sheet container.
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 12,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Drag handle.
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Sheet title.
            const Text(
              'تعديل الملف الشخصي',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 16),
            // Name field.
            _field('الاسم', _nameCtrl, Icons.person_outline),
            const SizedBox(height: 12),
            // Birth date field.
            _field(
              'تاريخ الميلاد (YYYY-MM-DD)',
              _birthCtrl,
              Icons.calendar_today_outlined,
              keyboard: TextInputType.datetime,
            ),
            const SizedBox(height: 12),
            // Height and target weight row.
            Row(
              children: [
                Expanded(child: _field('الطول (سم)', _heightCtrl, Icons.height)),
                const SizedBox(width: 12),
                Expanded(
                    child: _field(
                        'الوزن المستهدف (كجم)', _targetWeightCtrl, Icons.flag)),
              ],
            ),
            const SizedBox(height: 12),
            // Current stats title.
            const Text(
              'القياسات الحالية',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
            ),
            const SizedBox(height: 8),
            // Current stats row.
            Row(
              children: [
                Expanded(
                    child: _field('الوزن (كجم)', _weightCtrl, Icons.monitor_weight)),
                const SizedBox(width: 12),
                Expanded(
                    child: _field('كتلة عضلية', _muscleCtrl, Icons.accessibility)),
              ],
            ),
            const SizedBox(height: 12),
            // Body fat field.
            _field('نسبة الدهون %', _fatCtrl, Icons.pie_chart_outline),
            const SizedBox(height: 12),
            // Notes field.
            _field('ملاحظات الأهداف', _notesCtrl, Icons.notes, maxLines: 3),
            const SizedBox(height: 24),
            // Save button.
            SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: _saving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _accent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: _saving
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('حفظ', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(
    String label,
    TextEditingController c,
    IconData icon, {
    TextInputType keyboard = TextInputType.text,
    int maxLines = 1,
  }) {
    // Input field.
    return TextField(
      controller: c,
      maxLines: maxLines,
      keyboardType: keyboard,
      textAlign: TextAlign.right,
      decoration: InputDecoration(
        labelText: label,
        // Leading icon.
        prefixIcon: Icon(icon, color: _accent, size: 20),
        filled: true,
        fillColor: AppColors.background,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  
}
