import 'meal_detail.dart';

double? _dOpt(dynamic v) => v == null ? null : double.tryParse(v.toString());
double _d(dynamic v) => v == null ? 0 : double.tryParse(v.toString()) ?? 0;

class MealSchedule {
  final int scheduleId;
  final String mealType;
  final int mealOrder;
  final String status; // scheduled | eaten | skipped
  final MealDetail? meal;
  final double referenceWeightG;
  final double targetCalories;
  final double targetProtein;
  final double targetCarbs;
  final double targetFat;
  final bool logged;
  final double? actualWeightGrams;
  final double? actualCalories;
  final double? actualProtein;
  final double? actualCarbs;
  final double? actualFat;
  final int? intakeItemId;

  const MealSchedule({
    required this.scheduleId,
    required this.mealType,
    required this.mealOrder,
    required this.status,
    this.meal,
    required this.referenceWeightG,
    required this.targetCalories,
    required this.targetProtein,
    required this.targetCarbs,
    required this.targetFat,
    required this.logged,
    this.actualWeightGrams,
    this.actualCalories,
    this.actualProtein,
    this.actualCarbs,
    this.actualFat,
    this.intakeItemId,
  });

  bool get isEaten => status == 'eaten';
  bool get isSkipped => status == 'skipped';

  String get mealTypeLabel {
    switch (mealType) {
      case 'breakfast':
        return 'فطور';
      case 'lunch':
        return 'غداء';
      case 'dinner':
        return 'عشاء';
      case 'snack':
        return 'وجبة خفيفة';
      default:
        return mealType;
    }
  }

  factory MealSchedule.fromJson(Map<String, dynamic> json) {
    final mealJson = json['meal'];
    return MealSchedule(
      scheduleId: (json['schedule_id'] as num?)?.toInt() ?? 0,
      mealType: (json['meal_type'] ?? 'snack').toString(),
      mealOrder: (json['meal_order'] as num?)?.toInt() ?? 1,
      status: (json['status'] ?? 'scheduled').toString(),
      meal: mealJson is Map<String, dynamic>
          ? MealDetail.fromJson(mealJson)
          : null,
      referenceWeightG: _d(json['reference_weight_g']) > 0 ? _d(json['reference_weight_g']) : 100,
      targetCalories: _d(json['target_calories']),
      targetProtein: _d(json['target_protein']),
      targetCarbs: _d(json['target_carbs']),
      targetFat: _d(json['target_fat']),
      logged: json['logged'] == true,
      actualWeightGrams: _dOpt(json['actual_weight_grams']),
      actualCalories: _dOpt(json['actual_calories']),
      actualProtein: _dOpt(json['actual_protein']),
      actualCarbs: _dOpt(json['actual_carbs']),
      actualFat: _dOpt(json['actual_fat']),
      intakeItemId: (json['intake_item_id'] as num?)?.toInt(),
    );
  }

  MealSchedule copyWith({
    String? status,
    bool? logged,
    double? actualWeightGrams,
    double? actualCalories,
    double? actualProtein,
    double? actualCarbs,
    double? actualFat,
    int? intakeItemId,
  }) {
    return MealSchedule(
      scheduleId: scheduleId,
      mealType: mealType,
      mealOrder: mealOrder,
      status: status ?? this.status,
      meal: meal,
      referenceWeightG: referenceWeightG,
      targetCalories: targetCalories,
      targetProtein: targetProtein,
      targetCarbs: targetCarbs,
      targetFat: targetFat,
      logged: logged ?? this.logged,
      actualWeightGrams: actualWeightGrams ?? this.actualWeightGrams,
      actualCalories: actualCalories ?? this.actualCalories,
      actualProtein: actualProtein ?? this.actualProtein,
      actualCarbs: actualCarbs ?? this.actualCarbs,
      actualFat: actualFat ?? this.actualFat,
      intakeItemId: intakeItemId ?? this.intakeItemId,
    );
  }
}
