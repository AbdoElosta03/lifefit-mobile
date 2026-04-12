import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/progress/client_goal.dart';
import '../../../core/services/progress_service.dart';
import 'goals_provider.dart';

/// Create or update goals. Dates are shown here (not on the main Progress card).
class EditGoalsScreen extends ConsumerStatefulWidget {
  /// `null` → first-time create (`POST /client/goals`).
  final ClientGoal? existing;

  const EditGoalsScreen({super.key, this.existing});

  @override
  ConsumerState<EditGoalsScreen> createState() => _EditGoalsScreenState();
}

class _EditGoalsScreenState extends ConsumerState<EditGoalsScreen> {
  late final TextEditingController _weightCtrl;
  late final TextEditingController _fatCtrl;
  late DateTime _startDate;
  DateTime? _targetDate;
  bool _saving = false;

  static const _primary = Color(0xFF00D9D9);

  @override
  void initState() {
    super.initState();
    final g = widget.existing;
    _weightCtrl = TextEditingController(
      text: g?.targetWeight?.toString() ?? '',
    );
    _fatCtrl = TextEditingController(
      text: g?.targetBodyFat?.toString() ?? '',
    );
    _startDate = g?.startDate ?? DateTime.now();
    _targetDate = g?.targetDate;
  }

  @override
  void dispose() {
    _weightCtrl.dispose();
    _fatCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickStart() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (d != null) setState(() => _startDate = d);
  }

  Future<void> _pickTarget() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _targetDate ?? _startDate.add(const Duration(days: 30)),
      firstDate: _startDate,
      lastDate: DateTime(2100),
    );
    if (d != null) setState(() => _targetDate = d);
  }

  Future<void> _save() async {
    final w = double.tryParse(_weightCtrl.text.trim());
    final f = double.tryParse(_fatCtrl.text.trim());

    setState(() => _saving = true);
    final service = ProgressService();

    try {
      if (widget.existing != null) {
        final body = <String, dynamic>{
          if (w != null) 'target_weight': w,
          if (f != null) 'target_body_fat': f,
          'start_date': ClientGoal.formatDateForApi(_startDate),
          if (_targetDate != null)
            'target_date': ClientGoal.formatDateForApi(_targetDate!),
        };
        await service.updateGoal(widget.existing!.id, body);
      } else {
        await service.createOrReplaceGoal({
          'start_date': ClientGoal.formatDateForApi(_startDate),
          if (w != null) 'target_weight': w,
          if (f != null) 'target_body_fat': f,
          if (_targetDate != null)
            'target_date': ClientGoal.formatDateForApi(_targetDate!),
        });
      }

      await ref.read(goalsProvider.notifier).refresh();
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم حفظ الأهداف'),
          backgroundColor: _primary,
        ),
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
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        centerTitle: true,
        title: Text(
          widget.existing != null ? 'تعديل الأهداف' : 'أهدافك',
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _field(
              label: 'هدف الوزن (كجم)',
              ctrl: _weightCtrl,
              icon: Icons.flag_outlined,
            ),
            const SizedBox(height: 14),
            _field(
              label: 'هدف نسبة الدهون (%)',
              ctrl: _fatCtrl,
              icon: Icons.pie_chart_outline,
            ),
            const SizedBox(height: 20),
            _dateTile(
              title: 'تاريخ البدء',
              date: _startDate,
              onTap: _pickStart,
            ),
            const SizedBox(height: 10),
            _dateTile(
              title: 'التاريخ المستهدف (اختياري)',
              date: _targetDate,
              onTap: _pickTarget,
              allowClear: true,
              onClear: () => setState(() => _targetDate = null),
            ),
            const SizedBox(height: 28),
            SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: _saving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: _saving
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'حفظ',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field({
    required String label,
    required TextEditingController ctrl,
    required IconData icon,
  }) {
    return TextField(
      controller: ctrl,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      textAlign: TextAlign.right,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: _primary),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _dateTile({
    required String title,
    required DateTime? date,
    required VoidCallback onTap,
    bool allowClear = false,
    VoidCallback? onClear,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              if (allowClear && date != null && onClear != null)
                IconButton(
                  onPressed: onClear,
                  icon: const Icon(Icons.close, size: 20),
                  color: Colors.grey,
                ),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                  textAlign: TextAlign.right,
                ),
              ),
              Text(
                date == null
                    ? '—'
                    : ClientGoal.formatDateForApi(date),
                style: const TextStyle(
                  color: _primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.calendar_today_outlined, size: 18, color: _primary),
            ],
          ),
        ),
      ),
    );
  }
}
