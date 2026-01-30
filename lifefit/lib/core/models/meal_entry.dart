class MealIngredientModel {
  final int? foodId;
  final String? name;
  final double? amountG;
  final double? calories;
  final double? protein;
  final double? carbs;
  final double? fat;

  MealIngredientModel({
    this.foodId,
    this.name,
    this.amountG,
    this.calories,
    this.protein,
    this.carbs,
    this.fat,
  });

  factory MealIngredientModel.fromJson(Map<String, dynamic> json) {
    return MealIngredientModel(
      foodId: _toInt(json['food_id']),
      name: json['name'] as String?,
      amountG: _toDouble(json['amount_g']) ?? 0,
      calories: _toDouble(json['calories']) ?? 0,
      protein: _toDouble(json['protein']) ?? 0,
      carbs: _toDouble(json['carbs']) ?? 0,
      fat: _toDouble(json['fat']) ?? 0,
    );
  }
}

class MealEntry {
  final int id;
  final bool isCompleted;
  final String name;
  final String? type;
  final int? order;
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final String? instructions;
  final List<MealIngredientModel> ingredients;

  MealEntry({
    required this.id,
    required this.isCompleted,
    required this.name,
    this.type,
    this.order,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    this.instructions,
    this.ingredients = const [],
  });

  factory MealEntry.fromJson(Map<String, dynamic> json) {
    final ingredientsJson = (json['ingredients'] as List?) ?? [];
    return MealEntry(
      id: json['id'] ?? 0,
      isCompleted: json['is_completed'] ?? false,
      name: json['name'] ?? '',
      type: json['type'] as String?,
      order: json['order'] as int?,
      calories: _toDouble(json['calories']) ?? 0,
      protein: _toDouble(json['protein']) ?? 0,
      carbs: _toDouble(json['carbs']) ?? 0,
      fat: _toDouble(json['fat']) ?? 0,
      instructions: json['instructions'] as String?,
      ingredients: ingredientsJson
          .map((e) => MealIngredientModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

double? _toDouble(dynamic v) {
  if (v == null) return null;
  if (v is num) return v.toDouble();
  return double.tryParse(v.toString());
}

int? _toInt(dynamic v) {
  if (v == null) return null;
  if (v is int) return v;
  if (v is num) return v.toInt();
  return int.tryParse(v.toString());
}
