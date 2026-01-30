import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/log_meal.dart';
import '../../../core/services/api_service.dart';
import 'log_meal_provider.dart';

class LogMealScreen extends ConsumerStatefulWidget {
  const LogMealScreen({super.key});

  @override
  ConsumerState<LogMealScreen> createState() => _LogMealScreenState();
}

class _LogMealScreenState extends ConsumerState<LogMealScreen> {
  final ApiService _apiService = ApiService();
  bool _isSaving = false;

  // حساب الإجماليات بشكل سريع
  Map<String, double> _totals(List<LogMeal> items) {
    double cal = 0, p = 0, c = 0, f = 0;
    for (final item in items) {
      cal += item.totalCalories;
      p += item.totalProtein;
      c += item.totalCarbs;
      f += item.totalFat;
    }
    return {'cal': cal, 'p': p, 'c': c, 'f': f};
  }

  String _todayYmd() {
    final today = DateTime.now();
    return '${today.year.toString().padLeft(4, '0')}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
  }

  // دالة الحفظ المحسنة مع معالجة أخطاء السيرفر
  Future<void> _save(List<LogMeal> items) async {
    if (_isSaving || items.isEmpty) return;

    final mealId = items
        .firstWhere((e) => e.mealId != null, orElse: () => items.first)
        .mealId;

    if (mealId == null) {
      _showSnackBar('تعذر تحديد رقم الوجبة لإرسال البيانات', isError: true);
      return;
    }

    setState(() => _isSaving = true);

    try {
      final payloadItems = items
          .map((e) => {...e.toMap(), 'unit': 'g'})
          .toList();

      final response = await _apiService.saveDailyIntakeMealLog(
        logDate: _todayYmd(),
        mealId: mealId,
        items: payloadItems,
      );

      if (!mounted) return;

      // فحص النجاح (200 أو 201)
      if (response != null &&
          (response.statusCode == 200 || response.statusCode == 201)) {
        ref.read(logMealProvider.notifier).clear();
        _showSnackBar('تم حفظ الوجبة بنجاح');
        int count = 0;
        Navigator.of(context).popUntil((_) => count++ >= 2);
      }
      // فحص الفشل واستخراج الرسالة من السيرفر
      else {
        final serverMsg = (response?.data is Map)
            ? (response?.data['message'] ?? response?.data['error'])
            : 'فشل حفظ الوجبة، حاول مرة أخرى';
        throw serverMsg; // سيتم التقاطها في catch أدناه
      }
    } catch (e) {
      if (!mounted) return;
      // عرض رسالة الخطأ الحقيقية القادمة من السيرفر (مثل مشكلة الـ SQL التي واجهتها)
      _showSnackBar(e.toString().replaceAll('Exception:', ''), isError: true);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.redAccent : Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<LogMeal> logItems = ref.watch(logMealProvider);
    final totals = _totals(logItems);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFB),
      appBar: AppBar(
        title: const Text(
          'تسجيل الوجبة الفعلية',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildLiveSummary(totals),
          Expanded(
            child: logItems.isEmpty
                ? _buildEmptyState()
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: logItems.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) =>
                        _buildLogItemCard(item: logItems[index], index: index),
                  ),
          ),
          _buildActionButtons(logItems),
        ],
      ),
    );
  }

  Widget _buildLiveSummary(Map<String, double> totals) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _stat(
            'سعرة',
            totals['cal']!.toStringAsFixed(0),
            Icons.local_fire_department,
            Colors.orange,
          ),
          _stat(
            'بروتين',
            '${totals['p']!.toStringAsFixed(1)}g',
            Icons.fitness_center,
            Colors.blue,
          ),
          _stat(
            'كارب',
            '${totals['c']!.toStringAsFixed(1)}g',
            Icons.grain,
            Colors.cyan,
          ),
          _stat(
            'دهون',
            '${totals['f']!.toStringAsFixed(1)}g',
            Icons.opacity,
            Colors.brown,
          ),
        ],
      ),
    );
  }

  Widget _buildLogItemCard({required LogMeal item, required int index}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  '${item.totalCalories.toStringAsFixed(0)} kcal',
                  style: TextStyle(color: Colors.orange[800], fontSize: 12),
                ),
              ],
            ),
          ),
          _quantityPicker(item, index),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
            onPressed: () =>
                ref.read(logMealProvider.notifier).removeItem(index),
          ),
        ],
      ),
    );
  }

  Widget _quantityPicker(LogMeal item, int index) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.remove, size: 18),
            onPressed: () => ref
                .read(logMealProvider.notifier)
                .updateQuantity(index, item.quantity - 10),
          ),
          Text(
            '${item.quantity.toStringAsFixed(0)}g',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          IconButton(
            icon: const Icon(Icons.add, size: 18),
            onPressed: () => ref
                .read(logMealProvider.notifier)
                .updateQuantity(index, item.quantity + 10),
          ),
        ],
      ),
    );
  }

  Widget _stat(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_basket_outlined,
            size: 50,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 10),
          Text(
            'لا توجد عناصر مضافة بعد',
            style: TextStyle(color: Colors.grey[400]),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(List<LogMeal> items) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blueAccent,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 55),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: (items.isEmpty || _isSaving) ? null : () => _save(items),
        child: _isSaving
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : const Text(
                'حفظ الوجبة في السجل',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
      ),
    );
  }
}
