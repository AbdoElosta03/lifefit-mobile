import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/models/nutrition/today_meals_response.dart';
import '../../../core/models/nutrition/meal_schedule.dart';
import '../../../core/services/nutrition_service.dart';

/// Central state for [NutritionScreen] and [LogMealSheet].
/// Holds [TodayMealsResponse]; optimistic updates on log/skip.
class NutritionNotifier extends StateNotifier<AsyncValue<TodayMealsResponse>> {
  final NutritionService _service;

  NutritionNotifier(this._service) : super(const AsyncValue.loading()) {
    fetch();
  }

  /// Fetches the user's meals for today.
  Future<void> fetch() async {
    state = const AsyncValue.loading();
    try {
      final data = await _service.fetchTodayMeals();
      state = AsyncValue.data(data);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  /// Refreshes the meal data.
  Future<void> refresh() => fetch();

  /// Logs a meal as eaten. 
  /// Performs an optimistic update first, then syncs with the server.
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

  /// Patches one [MealSchedule] by [scheduleId] and rebuilds [TodayMealsResponse].
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

/// Watched by [NutritionScreen]; written by [LogMealSheet] via logMeal/skipMeal.
final nutritionProvider = StateNotifierProvider<NutritionNotifier, AsyncValue<TodayMealsResponse>>(
  (ref) => NutritionNotifier(NutritionService()),
);
