class LogMeal {
  final int? foodId;      // معرف الصنف من جدول foods
  final int? mealId;      // معرف الوجبة إذا كانت من الخطة
  final String name;      // اسم الطعام للعرض في القائمة
  double quantity;        // الكمية التي سيدخلها المستخدم (الجرامات)
  
  // القيم الغذائية لكل 100 جرام (تُجلب من جدول foods ولا يراها المستخدم)
  final double baseCalories; 
  final double baseProtein;
  final double baseCarbs;
  final double baseFat;

  LogMeal({
    this.foodId,
    this.mealId,
    required this.name,
    required this.quantity,
    required this.baseCalories,
    required this.baseProtein,
    required this.baseCarbs,
    required this.baseFat,
  });

  // الحسابات التلقائية التي تظهر للمستخدم فور تغيير الكمية
  double get totalCalories => (baseCalories / 100) * quantity;
  double get totalProtein => (baseProtein / 100) * quantity;
  double get totalCarbs => (baseCarbs / 100) * quantity;
  double get totalFat => (baseFat / 100) * quantity;

  // تحويل البيانات إلى Map لإرسالها لجدول daily_intake_log_items
  Map<String, dynamic> toMap() {
    return {
      'food_id': foodId,
      'meal_id': mealId,
      'quantity': quantity,
      'calories': totalCalories,
      'protein': totalProtein,
      'carbs': totalCarbs,
      'fat': totalFat,
    };
  }
}