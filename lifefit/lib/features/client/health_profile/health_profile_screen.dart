import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'health_profile_provider.dart';

class HealthProfileScreen extends ConsumerStatefulWidget {
  const HealthProfileScreen({super.key});

  @override
  ConsumerState<HealthProfileScreen> createState() => _HealthProfileScreenState();
}

class _HealthProfileScreenState extends ConsumerState<HealthProfileScreen> {
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  final _goalNotesController = TextEditingController();
  String? selectedActivity;
  DateTime? selectedBirthDate;

  final List<Map<String, String>> activityOptions = const [
    {'value': 'sedentary', 'label': 'خامل'},
    {'value': 'low', 'label': 'خفيف'},
    {'value': 'moderate', 'label': 'متوسط'},
    {'value': 'active', 'label': 'نشط'},
    {'value': 'athlete', 'label': 'رياضي جداً'},
  ];

  @override
  void dispose() {
    _heightController.dispose();
    _weightController.dispose();
    _goalNotesController.dispose();
    super.dispose();
  }

  Future<void> _pickBirthDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedBirthDate ?? DateTime(2000),
      firstDate: DateTime(1940),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => selectedBirthDate = picked);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(healthProfileProvider);
    // الاستماع للتغييرات ووضع البيانات في الـ Controllers
    ref.listen<HealthProfileState>(healthProfileProvider, (prev, next) {
      if (next.profile != null && prev?.profile == null) {
        _heightController.text = next.profile?.heightCm?.toString() ?? '';
        _weightController.text = next.profile?.targetWeightKg?.toString() ?? '';
        _goalNotesController.text = next.profile?.goalNotes ?? '';
        setState(() {
          selectedActivity = next.profile?.activityLevel;
          if (next.profile?.birthDate != null) {
            selectedBirthDate = DateTime.tryParse(next.profile!.birthDate!);
          }
        });
      }
    });

    

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('الملف الصحي', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true, backgroundColor: Colors.white, elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.black), onPressed: () => Navigator.pop(context)),
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _buildSectionHeader('القياسات الأساسية'),
                  // استخدام Row مع Expanded لضمان توزيع المساحة ومنع الـ Overflow
                  Row(
                    children: [
                      Expanded(child: _buildDateCard('الميلاد')),
                      const SizedBox(width: 8),
                      Expanded(child: _buildInputCard('الهدف (كجم)', _weightController)),
                      const SizedBox(width: 8),
                      Expanded(child: _buildInputCard('الطول (سم)', _heightController)),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildSectionHeader('مستوى النشاط'),
                  _buildDropdownCard(),
                  const SizedBox(height: 20),
                  _buildSectionHeader('ملاحظات صحية'),
                  _buildNotesField(),
                  const SizedBox(height: 30),
                  _buildSaveButton(state),
                ],
              ),
            ),
    );
  }

  // --- مكونات الواجهة الصغيرة لتبسيط الـ Build ---

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF2D3142))),
    );
  }

  Widget _buildInputCard(String label, TextEditingController controller) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          FittedBox(child: Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 11))),
          TextField(
            controller: controller,
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            decoration: const InputDecoration(border: InputBorder.none, isDense: true, hintText: '0'),
          ),
        ],
      ),
    );
  }

  Widget _buildDateCard(String label) {
    return InkWell(
      onTap: () => _pickBirthDate(context),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
        child: Column(
          children: [
            Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 11)),
            const SizedBox(height: 10),
            FittedBox(
              child: Text(
                selectedBirthDate == null ? 'اختر' : "${selectedBirthDate!.year}/${selectedBirthDate!.month}",
                style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF00D9D9)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdownCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedActivity,
          isExpanded: true,
          hint: const Align(alignment: Alignment.centerRight, child: Text("اختر مستوى النشاط")),
          items: activityOptions.map((item) => DropdownMenuItem(
            value: item['value'],
            child: Align(alignment: Alignment.centerRight, child: Text(item['label']!)),
          )).toList(),
          onChanged: (val) => setState(() => selectedActivity = val),
        ),
      ),
    );
  }

  Widget _buildNotesField() {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: TextField(
        controller: _goalNotesController,
        maxLines: 3, textAlign: TextAlign.right,
        decoration: const InputDecoration(
          hintText: 'إصابات سابقة أو ملاحظات...',
          border: InputBorder.none, contentPadding: EdgeInsets.all(12),
        ),
      ),
    );
  }

  Widget _buildSaveButton(HealthProfileState state) {
    return SizedBox(
      width: double.infinity, height: 50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00D9D9), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
        onPressed: () async {
          final res = await ref.read(healthProfileProvider.notifier).save(
            heightCm: double.tryParse(_heightController.text),
            targetWeightKg: double.tryParse(_weightController.text),
            goalNotes: _goalNotesController.text,
            activity: selectedActivity,
            birthDate: selectedBirthDate?.toIso8601String().split('T').first,
          );
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res ?? 'تم الحفظ بنجاح')));
          }
        },
        child: const Text('حفظ البيانات', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    );
  }
}