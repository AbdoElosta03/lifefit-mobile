import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/meal_entry.dart';
import '../../../core/models/log_meal.dart'; // الموديل الجديد
import 'log_meal_provider.dart'; // البروفايدر الجديد
import 'log_meal_screen.dart'; // شاشة التسجيل

class MealDetailsScreen extends ConsumerStatefulWidget {
  final MealEntry meal;
  final String imgUrl;

  const MealDetailsScreen({
    super.key,
    required this.meal,
    this.imgUrl =
        'https://images.unsplash.com/photo-1504674900247-0877df9cc836?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8Mnx8Zm9vZHxlbnwwfHwwfHx8MA%3D%3D&auto=format&fit=crop&w=800&q=60',
  });

  @override
  ConsumerState<MealDetailsScreen> createState() => _MealDetailsScreenState();
}

class _MealDetailsScreenState extends ConsumerState<MealDetailsScreen> {
  void _navigateToLogMeal() {
    final initialLogItems = widget.meal.ingredients.map((ing) {
      final qty = ing.amountG ?? 100.0;
      final safeQty = qty <= 0 ? 1.0 : qty;
      final per100Calories = ((ing.calories ?? 0.0) / safeQty) * 100.0;
      final per100Protein = ((ing.protein ?? 0.0) / safeQty) * 100.0;
      final per100Carbs = ((ing.carbs ?? 0.0) / safeQty) * 100.0;
      final per100Fat = ((ing.fat ?? 0.0) / safeQty) * 100.0;

      return LogMeal(
        foodId: ing.foodId,
        mealId: widget.meal.id,
        name: ing.name ?? 'صنف غير معروف',

        quantity: qty,
        baseCalories: per100Calories,
        baseProtein: per100Protein,
        baseCarbs: per100Carbs,
        baseFat: per100Fat,
      );
    }).toList();
    // 2. تزويد البروفايدر بالبيانات المبدئية
    ref.read(logMealProvider.notifier).initializeFromMeal(initialLogItems);

    // 3. الانتقال للشاشة التالية
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LogMealScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: const Text(
          'تفاصيل الوجبة',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeaderImage(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    widget.meal.type ?? 'وجبة',
                    style: const TextStyle(
                      color: Color(0xFF00D9D9),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    widget.meal.name,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildNutritionCard(),
                  const SizedBox(height: 20),
                  _buildSectionTitle('المكونات', Icons.restaurant_menu),
                  _buildWhiteCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: widget.meal.ingredients.isEmpty
                          ? [const Text('لا توجد تفاصيل للمكونات')]
                          : widget.meal.ingredients
                                .map(
                                  (item) => Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 4,
                                    ),
                                    child: Text(
                                      '• ${item.name ?? 'صنف غير معروف'} (${item.amountG == null ? '--' : item.amountG!.toStringAsFixed(0)} جم)',
                                      style: const TextStyle(
                                        fontSize: 15,
                                        height: 1.5,
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildSectionTitle('وصف الوجبة', Icons.info_outline),
                  _buildWhiteCard(
                    child: Text(
                      widget.meal.instructions ??
                          'تعليمات التحضير غير متوفرة لهذه الوجبة.',
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        fontSize: 15,
                        height: 1.6,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  _buildConfirmButton(),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- أدوات بناء الواجهة (Helper Methods) ---

  Widget _buildHeaderImage() {
    return Container(
      margin: const EdgeInsets.all(16),
      height: 250,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
        ],
        image: DecorationImage(
          image: NetworkImage(widget.imgUrl),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildNutritionCard() {
    return _buildWhiteCard(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNutriItem(
            'دهون',
            '${widget.meal.fat.toStringAsFixed(0)}g',
            Colors.brown,
          ),
          _buildNutriItem(
            'بروتين',
            '${widget.meal.protein.toStringAsFixed(0)}g',
            Colors.blue,
          ),
          _buildNutriItem(
            'كارب',
            '${widget.meal.carbs.toStringAsFixed(0)}g',
            const Color(0xFF00D9D9),
          ),
          _buildNutriItem(
            'سعرة',
            widget.meal.calories.toStringAsFixed(0),
            Colors.orange,
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmButton() {
  // التحقق من حالة الاكتمال من الموديل
  final bool isAlreadyCompleted = widget.meal.isCompleted;

  return SizedBox(
    width: double.infinity,
    height: 55,
    child: ElevatedButton(
      style: ElevatedButton.styleFrom(
        // تغيير اللون إلى الرمادي إذا كانت مكتملة للإشارة إلى التعطيل
        backgroundColor: isAlreadyCompleted 
            ? Colors.grey.shade400 
            : const Color(0xFF00D9D9),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        elevation: isAlreadyCompleted ? 0 : 2,
      ),
      // إذا كانت مكتملة، نمرر null لتعطيل الضغط (Disable)
      onPressed: isAlreadyCompleted ? null : _navigateToLogMeal, 
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (isAlreadyCompleted) ...[
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 10),
          ],
          Text(
            isAlreadyCompleted ? 'تم تسجيل هذه الوجبة' : 'تسجيل الوجبة (تعديل/إضافة)',
            style: const TextStyle(
              fontSize: 18,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    ),
  );
}
  Widget _buildWhiteCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildNutriItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, right: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 8),
          Icon(icon, color: const Color(0xFF00D9D9), size: 18),
        ],
      ),
    );
  }
}
