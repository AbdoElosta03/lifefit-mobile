import 'meal_entry.dart';

class NutritionDay {
  final String date;
  final String? planName;
  final double totalCalories;
  final double totalProtein;
  final double totalCarbs;
  final double totalFat;
  final double consumedTotalCalories;
  final List<MealEntry> meals;

  NutritionDay({
    required this.date,
    required this.planName,
    required this.totalCalories,
    required this.totalProtein,
    required this.totalCarbs,
    required this.totalFat,
    required this.consumedTotalCalories,
    required this.meals,
  });

  factory NutritionDay.fromJson(Map<String, dynamic> json) {
    final totals = (json['planned_totals'] as Map?) ?? {};
    final mealsJson = (json['meals'] as List?) ?? [];
    return NutritionDay(
      date: json['date'] ?? '',
      planName: json['plan_name'] as String?,
      totalCalories: _toDouble(totals['calories']) ?? 0,
      totalProtein: _toDouble(totals['protein']) ?? 0,
      totalCarbs: _toDouble(totals['carbs']) ?? 0,
      totalFat: _toDouble(totals['fat']) ?? 0,
      consumedTotalCalories: _toDouble(json['consumed_total_calories']) ?? 0,
      meals: mealsJson
          .map((e) => MealEntry.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

double? _toDouble(dynamic v) {
  if (v == null) return null;
  if (v is num) return v.toDouble();
  return double.tryParse(v.toString());
}
