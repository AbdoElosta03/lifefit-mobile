import 'meal_schedule.dart';

class TodayMealsResponse {
  final List<MealSchedule> meals;
  final String? planName;
  final int? intakeLogId;
  final String? intakeLogStatus;

  const TodayMealsResponse({
    required this.meals,
    this.planName,
    this.intakeLogId,
    this.intakeLogStatus,
  });

  double get totalTargetCalories =>
      meals.fold(0, (sum, m) => sum + m.targetCalories);

  double get totalConsumedCalories =>
      meals.where((m) => m.isEaten).fold(0, (sum, m) => sum + (m.actualCalories ?? m.targetCalories));

  double get totalTargetProtein =>
      meals.fold(0, (sum, m) => sum + m.targetProtein);

  double get totalConsumedProtein =>
      meals.where((m) => m.isEaten).fold(0, (sum, m) => sum + (m.actualProtein ?? m.targetProtein));

  double get totalTargetCarbs =>
      meals.fold(0, (sum, m) => sum + m.targetCarbs);

  double get totalConsumedCarbs =>
      meals.where((m) => m.isEaten).fold(0, (sum, m) => sum + (m.actualCarbs ?? m.targetCarbs));

  double get totalTargetFat =>
      meals.fold(0, (sum, m) => sum + m.targetFat);

  double get totalConsumedFat =>
      meals.where((m) => m.isEaten).fold(0, (sum, m) => sum + (m.actualFat ?? m.targetFat));

  factory TodayMealsResponse.fromJson(Map<String, dynamic> json) {
    final dataList = json['data'];
    final meals = dataList is List
        ? dataList
            .whereType<Map>()
            .map((e) => MealSchedule.fromJson(Map<String, dynamic>.from(e)))
            .toList()
        : <MealSchedule>[];

    final intakeLog = json['intake_log'];
    return TodayMealsResponse(
      meals: meals,
      planName: json['plan_name']?.toString(),
      intakeLogId: intakeLog is Map ? (intakeLog['id'] as num?)?.toInt() : null,
      intakeLogStatus: intakeLog is Map ? intakeLog['status']?.toString() : null,
    );
  }

  TodayMealsResponse withUpdatedMeal(MealSchedule updated) {
    return TodayMealsResponse(
      meals: meals.map((m) => m.scheduleId == updated.scheduleId ? updated : m).toList(),
      planName: planName,
      intakeLogId: intakeLogId,
      intakeLogStatus: intakeLogStatus,
    );
  }
}
