import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/progress/client_goal.dart';
import '../profile_web/profile_provider_web.dart';
import 'measurements_provider.dart';

const Color _kPrimary = Color(0xFF00D9D9);

Future<void> showAddMeasurementSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => const _AddMeasurementSheetBody(),
  );
}

class _AddMeasurementSheetBody extends ConsumerStatefulWidget {
  const _AddMeasurementSheetBody();

  @override
  ConsumerState<_AddMeasurementSheetBody> createState() =>
      _AddMeasurementSheetBodyState();
}

class _AddMeasurementSheetBodyState extends ConsumerState<_AddMeasurementSheetBody> {
  late DateTime _date;
  final _weightCtrl = TextEditingController();
  final _fatCtrl = TextEditingController();
  final _muscleCtrl = TextEditingController();
  final _waistCtrl = TextEditingController();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _date = DateTime.now();
  }

  @override
  void dispose() {
    _weightCtrl.dispose();
    _fatCtrl.dispose();
    _muscleCtrl.dispose();
    _waistCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (d != null) setState(() => _date = d);
  }

  Future<void> _submit() async {
    final body = <String, dynamic>{
      'date': ClientGoal.formatDateForApi(_date),
    };

    final w = double.tryParse(_weightCtrl.text.trim());
    final f = double.tryParse(_fatCtrl.text.trim());
    final m = double.tryParse(_muscleCtrl.text.trim());
    final waist = double.tryParse(_waistCtrl.text.trim());

    if (w != null) body['weight_kg'] = w;
    if (f != null) body['body_fat_pct'] = f;
    if (m != null) body['muscle_mass_kg'] = m;
    if (waist != null) body['waist_cm'] = waist;

    setState(() => _saving = true);
    try {
      await ref.read(measurementsProvider.notifier).submit(body);
      await ref.read(clientProfileWebProvider.notifier).refresh();
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم حفظ القياس'),
          backgroundColor: _kPrimary,
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
                  'قياس جديد',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'التاريخ مطلوب. يمكن ترك الحقول الفارغة لاستخدام آخر قيمة مسجّلة قبل هذا التاريخ.',
                  textAlign: TextAlign.right,
                  style: TextStyle(fontSize: 12, color: Colors.grey[700], height: 1.35),
                ),
                const SizedBox(height: 16),
                _dateTile(),
                const SizedBox(height: 12),
                _field('الوزن (كجم)', _weightCtrl, Icons.monitor_weight_outlined),
                const SizedBox(height: 10),
                _field('نسبة الدهون (%)', _fatCtrl, Icons.pie_chart_outline),
                const SizedBox(height: 10),
                _field('كتلة العضلات (كجم)', _muscleCtrl, Icons.fitness_center_outlined),
                const SizedBox(height: 10),
                _field('محيط الخصر (سم)', _waistCtrl, Icons.straighten_outlined),
                const SizedBox(height: 22),
                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _saving ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _kPrimary,
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
                            'حفظ القياس',
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
        ),
      ),
    );
  }

  Widget _dateTile() {
    return Material(
      color: const Color(0xFFF8F9FA),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: _pickDate,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'تاريخ القياس',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                  textAlign: TextAlign.right,
                ),
              ),
              Text(
                ClientGoal.formatDateForApi(_date),
                style: const TextStyle(
                  color: _kPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.calendar_today_outlined, size: 18, color: _kPrimary),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field(String label, TextEditingController ctrl, IconData icon) {
    return TextField(
      controller: ctrl,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      textAlign: TextAlign.right,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: _kPrimary),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
