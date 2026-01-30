import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/log_meal.dart';

class LogMealNotifier extends StateNotifier<List<LogMeal>> {
  LogMealNotifier() : super([]);

  // تهيئة القائمة من وجبة موجودة
  void initializeFromMeal(List<LogMeal> initialItems) {
    state = initialItems;
  }

  // إضافة صنف جديد (من الخطة أو من البحث)
  void addItem(LogMeal item) {
    state = [...state, item];
  }

  // تحديث الكمية (الجرامات) التي يدخلها المستخدم
  void updateQuantity(int index, double newQty) {
    if (index < 0 || index >= state.length) return;

    final clampedQty = newQty < 0 ? 0.0 : newQty;
    final newState = [...state];
    newState[index].quantity = clampedQty;
    state = newState;
  }

  // حذف صنف من القائمة المؤقتة
  void removeItem(int index) {
    if (index < 0 || index >= state.length) return;
    final newState = [...state]..removeAt(index);
    state = newState;
  }

  void clear() {
    state = [];
  }
}

final logMealProvider = StateNotifierProvider<LogMealNotifier, List<LogMeal>>((
  ref,
) {
  return LogMealNotifier();
});
