import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/models/nutrition/today_meals_response.dart';
import '../../../core/models/nutrition/meal_schedule.dart';
import '../../../core/services/nutrition_service.dart';

class NutritionNotifier extends StateNotifier<AsyncValue<TodayMealsResponse>> {
  final NutritionService _service;

  NutritionNotifier(this._service) : super(const AsyncValue.loading()) {
    fetch();
  }

  Future<void> fetch() async {
    state = const AsyncValue.loading();
    try {
      final data = await _service.fetchTodayMeals();
      state = AsyncValue.data(data);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> refresh() => fetch();

  /// Optimistically marks meal as eaten, then confirms with API.
  Future<bool> logMeal({
    required int scheduleId,
    required int mealId,
    required String mealType,
    required double actualWeightGrams,
    required double referenceWeightG,
  }) async {
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

    // Optimistic update
    _updateMealState(scheduleId, (m) => m.copyWith(status: 'eaten', logged: true));

    try {
      final result = await _service.logSingleMeal(
        logDate: today,
        scheduleId: scheduleId,
        mealId: mealId,
        mealType: mealType,
        actualWeightGrams: actualWeightGrams,
        referenceWeightG: referenceWeightG,
      );

      // Apply actual macros returned by server
      _updateMealState(scheduleId, (m) => m.copyWith(
        status: 'eaten',
        logged: true,
        actualWeightGrams: actualWeightGrams,
        actualCalories: (result['actual_calories'] as num?)?.toDouble(),
        actualProtein: (result['actual_protein'] as num?)?.toDouble(),
        actualCarbs: (result['actual_carbs'] as num?)?.toDouble(),
        actualFat: (result['actual_fat'] as num?)?.toDouble(),
        intakeItemId: (result['intake_item_id'] as num?)?.toInt(),
      ));

      return true;
    } catch (_) {
      // Rollback
      _updateMealState(scheduleId, (m) => m.copyWith(status: 'scheduled', logged: false));
      return false;
    }
  }

  /// Marks a meal as skipped.
  Future<bool> skipMeal({
    required int scheduleId,
    required int mealId,
    required String mealType,
    required double referenceWeightG,
  }) async {
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

    _updateMealState(scheduleId, (m) => m.copyWith(status: 'skipped', logged: false));

    try {
      await _service.logSingleMeal(
        logDate: today,
        scheduleId: scheduleId,
        mealId: mealId,
        mealType: mealType,
        actualWeightGrams: 0,
        referenceWeightG: referenceWeightG,
        skipped: true,
      );
      return true;
    } catch (_) {
      _updateMealState(scheduleId, (m) => m.copyWith(status: 'scheduled'));
      return false;
    }
  }

  void _updateMealState(int scheduleId, MealSchedule Function(MealSchedule) updater) {
    state.whenData((response) {
      final updated = response.meals.map((m) {
        return m.scheduleId == scheduleId ? updater(m) : m;
      }).toList();
      state = AsyncValue.data(TodayMealsResponse(
        meals: updated,
        planName: response.planName,
        intakeLogId: response.intakeLogId,
        intakeLogStatus: response.intakeLogStatus,
      ));
    });
  }
}

final nutritionProvider = StateNotifierProvider<NutritionNotifier, AsyncValue<TodayMealsResponse>>(
  (ref) => NutritionNotifier(NutritionService()),
);
