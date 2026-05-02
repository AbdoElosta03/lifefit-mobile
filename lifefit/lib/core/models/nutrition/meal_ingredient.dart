double _d(dynamic v) => v == null ? 0 : double.tryParse(v.toString()) ?? 0;

class MealIngredient {
  final String foodName;
  final String? imageUrl;
  final String category;
  final double amountG;
  final double calories;
  final double protein;
  final double carbs;
  final double fat;

  const MealIngredient({
    required this.foodName,
    this.imageUrl,
    required this.category,
    required this.amountG,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
  });

  factory MealIngredient.fromJson(Map<String, dynamic> json) {
    return MealIngredient(
      foodName: (json['food_name'] ?? '').toString(),
      imageUrl: json['image_url']?.toString(),
      category: (json['category'] ?? 'عام').toString(),
      amountG: _d(json['amount_g']),
      calories: _d(json['calories']),
      protein: _d(json['protein']),
      carbs: _d(json['carbs']),
      fat: _d(json['fat']),
    );
  }
}
