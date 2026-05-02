import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/nutrition/meal_schedule.dart';
import 'nutrition_provider.dart';

/// Bottom sheet for logging or skipping a meal.
class LogMealSheet extends ConsumerStatefulWidget {
  final MealSchedule schedule;

  const LogMealSheet({super.key, required this.schedule});

  static Future<void> show(BuildContext context, MealSchedule schedule) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => LogMealSheet(schedule: schedule),
    );
  }

  @override
  ConsumerState<LogMealSheet> createState() => _LogMealSheetState();
}

class _LogMealSheetState extends ConsumerState<LogMealSheet> {
  late TextEditingController _weightController;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _weightController = TextEditingController(
      text: widget.schedule.referenceWeightG.toStringAsFixed(0),
    );
  }

  @override
  void dispose() {
    _weightController.dispose();
    super.dispose();
  }

  MealSchedule get schedule => widget.schedule;

  @override
  Widget build(BuildContext context) {
    final meal = schedule.meal;
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(20, 12, 20, 24 + bottomPadding),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Meal name + type badge
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF00D9D9).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  schedule.mealTypeLabel,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF00D9D9),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  meal?.name ?? 'وجبة',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Macro summary row
          if (meal != null) _MacroRow(schedule: schedule),

          const SizedBox(height: 20),

          // Ingredients list (if any)
          if (meal != null && meal.ingredients.isNotEmpty) ...[
            const Text(
              'المكونات',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1E293B),
              ),
              textAlign: TextAlign.right,
            ),
            const SizedBox(height: 8),
            ...meal.ingredients.map(
              (ing) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${ing.amountG.toStringAsFixed(0)}غ',
                      style: const TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                    Text(
                      ing.foodName,
                      style: const TextStyle(fontSize: 13, color: Color(0xFF1E293B)),
                    ),
                  ],
                ),
              ),
            ),
            const Divider(height: 24),
          ],

          // Weight input
          Text(
            'الكمية المُتناولة (غرام)',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1E293B),
            ),
            textAlign: TextAlign.right,
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _weightController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            decoration: InputDecoration(
              suffix: const Text('غ', style: TextStyle(color: Colors.grey)),
              hintText: schedule.referenceWeightG.toStringAsFixed(0),
              filled: true,
              fillColor: const Color(0xFFF5F5F5),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'حجم الوجبة الكاملة: ${schedule.referenceWeightG.toStringAsFixed(0)} غ',
            style: const TextStyle(fontSize: 12, color: Colors.grey),
            textAlign: TextAlign.right,
          ),

          const SizedBox(height: 20),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _loading ? null : _skip,
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48),
                    side: const BorderSide(color: Colors.grey),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text('تخطى', style: TextStyle(color: Colors.grey)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: _loading ? null : _log,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00D9D9),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 48),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: _loading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'تأكيد التناول',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _log() async {
    final raw = double.tryParse(_weightController.text.trim());
    if (raw == null || raw <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('أدخل كمية صحيحة')),
      );
      return;
    }

    setState(() => _loading = true);
    final success = await ref.read(nutritionProvider.notifier).logMeal(
          scheduleId: schedule.scheduleId,
          mealId: schedule.meal!.id,
          mealType: schedule.mealType,
          actualWeightGrams: raw,
          referenceWeightG: schedule.referenceWeightG,
        );
    if (!mounted) return;
    setState(() => _loading = false);

    if (success) {
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('حدث خطأ، حاول مجدداً')),
      );
    }
  }

  Future<void> _skip() async {
    setState(() => _loading = true);
    await ref.read(nutritionProvider.notifier).skipMeal(
          scheduleId: schedule.scheduleId,
          mealId: schedule.meal!.id,
          mealType: schedule.mealType,
          referenceWeightG: schedule.referenceWeightG,
        );
    if (!mounted) return;
    Navigator.pop(context);
  }
}

class _MacroRow extends StatelessWidget {
  final MealSchedule schedule;
  const _MacroRow({required this.schedule});

  @override
  Widget build(BuildContext context) {
    final cal = schedule.targetCalories;
    final prot = schedule.targetProtein;
    final carbs = schedule.targetCarbs;
    final fat = schedule.targetFat;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _MacroItem(value: cal.toStringAsFixed(0), unit: 'سعرة', color: const Color(0xFF00D9D9)),
          _MacroItem(value: '${prot.toStringAsFixed(0)}غ', unit: 'بروتين', color: const Color(0xFF3ABEF9)),
          _MacroItem(value: '${carbs.toStringAsFixed(0)}غ', unit: 'كارب', color: const Color(0xFFF59E0B)),
          _MacroItem(value: '${fat.toStringAsFixed(0)}غ', unit: 'دهون', color: const Color(0xFFEF4444)),
        ],
      ),
    );
  }
}

class _MacroItem extends StatelessWidget {
  final String value;
  final String unit;
  final Color color;
  const _MacroItem({required this.value, required this.unit, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
        Text(unit, style: const TextStyle(fontSize: 11, color: Colors.grey)),
      ],
    );
  }
}
