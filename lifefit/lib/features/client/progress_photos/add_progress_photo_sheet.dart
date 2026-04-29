import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/models/progress/client_goal.dart';
import 'progress_photos_provider.dart';

Future<void> showAddProgressPhotoSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => const _AddProgressPhotoBody(),
  );
}

const Color _kPrimary = Color(0xFF00D9D9);

class _AddProgressPhotoBody extends ConsumerStatefulWidget {
  const _AddProgressPhotoBody();

  @override
  ConsumerState<_AddProgressPhotoBody> createState() => _AddProgressPhotoBodyState();
}

class _AddProgressPhotoBodyState extends ConsumerState<_AddProgressPhotoBody> {
  DateTime _date = DateTime.now();
  String _photoType = 'front';
  final _notesCtrl = TextEditingController();
  XFile? _picked;
  Uint8List? _previewBytes;
  bool _saving = false;

  static const _types = <MapEntry<String, String>>[
    MapEntry('front', 'أمامي'),
    MapEntry('back', 'خلفي'),
    MapEntry('side', 'جانبي'),
    MapEntry('other', 'أخرى'),
    MapEntry('inbody', 'InBody'),
  ];

  @override
  void dispose() {
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _pick(ImageSource source) async {
    final picker = ImagePicker();
    final x = await picker.pickImage(source: source, imageQuality: 85);
    if (x != null) {
      final b = await x.readAsBytes();
      setState(() {
        _picked = x;
        _previewBytes = b;
      });
    }
  }

  Future<void> _submit() async {
    final file = _picked;
    if (file == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى اختيار صورة')),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      await ref.read(progressPhotosProvider.notifier).uploadPhoto(
            date: _date,
            file: file,
            photoType: _photoType,
            notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
          );
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم رفع الصورة'), backgroundColor: _kPrimary),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
        ),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  'إضافة صورة تقدم',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 16),
                _dateRow(context),
                const SizedBox(height: 12),
                InputDecorator(
                  decoration: _fieldDecoration('نوع الصورة'),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _photoType,
                      isExpanded: true,
                      alignment: AlignmentDirectional.centerEnd,
                      items: _types
                          .map(
                            (e) => DropdownMenuItem(
                              value: e.key,
                              child: Text(e.value, textAlign: TextAlign.right),
                            ),
                          )
                          .toList(),
                      onChanged: _saving
                          ? null
                          : (v) {
                              if (v != null) setState(() => _photoType = v);
                            },
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _notesCtrl,
                  maxLines: 2,
                  textAlign: TextAlign.right,
                  enabled: !_saving,
                  decoration: _fieldDecoration('ملاحظات (اختياري)'),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _saving ? null : () => _pick(ImageSource.gallery),
                        icon: const Icon(Icons.photo_library_outlined, color: _kPrimary),
                        label: const Text('معرض'),
                        style: OutlinedButton.styleFrom(foregroundColor: _kPrimary),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _saving ? null : () => _pick(ImageSource.camera),
                        icon: const Icon(Icons.camera_alt_outlined, color: _kPrimary),
                        label: const Text('كاميرا'),
                        style: OutlinedButton.styleFrom(foregroundColor: _kPrimary),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (_previewBytes != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.memory(
                      _previewBytes!,
                      height: 160,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                const SizedBox(height: 18),
                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _saving ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _kPrimary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: _saving
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Text('رفع', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _dateRow(BuildContext context) {
    return Material(
      color: const Color(0xFFF8F9FA),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: _saving
            ? null
            : () async {
                final d = await showDatePicker(
                  context: context,
                  initialDate: _date,
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );
                if (d != null) setState(() => _date = d);
              },
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'تاريخ الصورة',
                  style: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey[800]),
                  textAlign: TextAlign.right,
                ),
              ),
              Text(
                ClientGoal.formatDateForApi(_date),
                style: const TextStyle(color: _kPrimary, fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.calendar_today_outlined, size: 18, color: _kPrimary),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _fieldDecoration(String label) {
    return InputDecoration(
      labelText: label,
      alignLabelWithHint: true,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
    );
  }
}
