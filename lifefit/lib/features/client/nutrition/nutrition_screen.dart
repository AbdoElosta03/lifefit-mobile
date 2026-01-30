import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/meal_entry.dart';
import '../../../core/models/nutrition_day.dart';
import 'meal_details_screen.dart';
import 'nutrition_provider.dart';

class NutritionScreen extends ConsumerWidget {
  const NutritionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
   
    final nutritionAsync = ref.watch(nutritionProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: nutritionAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: Color(0xFF00D9D9)),
        ),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 50),
              const SizedBox(height: 10),
              Text('خطأ: ${error.toString()}', textAlign: TextAlign.center),
              TextButton(
                onPressed: () => ref.read(nutritionProvider.notifier).refresh(),
                child: const Text('إعادة المحاولة'),
              ),
            ],
          ),
        ),
        data: (day) {
          if (day == null || day.meals.isEmpty) {
          return _buildEmptyState(context, ref);  
                  }
          return _buildContent(context, ref, day);
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, WidgetRef ref, NutritionDay day) {
    return RefreshIndicator(
      color: const Color(0xFF00D9D9),
      onRefresh: () => ref.read(nutritionProvider.notifier).refresh(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(), // تعطي شعور السحب المرن مثل iOS
      ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const Text('التغذية', style: TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.bold)),
            Text(
             day.planName ?? 'خطة التغذية',
            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            // التعديل 1: تمرير الكائن 'day' كاملاً لاستخدام الحقول الجديدة
            _buildCaloriesSummary(day),
            const SizedBox(height: 30),
            const Text('وجبات اليوم', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ...day.meals.map((meal) => _buildMealCard(context, meal: meal)),
          ],
        ),
      ),
    );
  }

  Widget _buildCaloriesSummary(NutritionDay day) {
    // التعديل 2: ربط السعرات بالحقول القادمة من الباك-أند
    final consumed = day.consumedTotalCalories; // السعرات المستهلكة فعلياً
    final target = day.totalCalories; // الهدف المخطط له
    final double progress = target > 0 ? (consumed / target).clamp(0.0, 1.0) : 0.0;
    
    // حساب المتبقي
    final double remaining = (target - consumed) > 0 ? (target - consumed) : 0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  Text(consumed.toStringAsFixed(0),
                      style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF00D9D9))),
                  const Text('سعرة مستهلكة', style: TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text('المتبقي لليوم', style: TextStyle(color: Colors.grey)),
                  Text('${remaining.toStringAsFixed(0)} سعرة',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.orange)),
                  Text('الهدف: ${target.toStringAsFixed(0)}', 
                      style: const TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 15),
          LinearProgressIndicator(
            value: progress,
            minHeight: 10,
            borderRadius: BorderRadius.circular(5),
            backgroundColor: const Color(0xFFE0E0E0),
            valueColor: AlwaysStoppedAnimation<Color>(
              progress >= 1.0 ? Colors.green : const Color(0xFF00D9D9)
            ),
          ),
        ],
      ),
    );
  }
Widget _buildMealCard(BuildContext context, {required MealEntry meal}) {
  const imgUrl = 'https://images.unsplash.com/photo-1490645935967-10de6ba17061';
  
  return Container(
    margin: const EdgeInsets.only(bottom: 15),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      border: meal.isCompleted 
          ? Border.all(color: Colors.green.withOpacity(0.5), width: 1) 
          : null,
      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8)],
    ),
    child: InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => MealDetailsScreen(meal: meal, imgUrl: imgUrl)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            const Icon(Icons.arrow_back_ios_new, size: 16, color: Color(0xFF00D9D9)),
            const SizedBox(width: 8),
            
            // Expanded لضمان أن النصوص تأخذ المساحة المتاحة فقط
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // اسم الوجبة في الأعلى مع خاصية النقاط
                  Text(
                    meal.name,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.right,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  
                  // إذا كانت مكتملة، تظهر تحت الاسم مباشرة
                  if (meal.isCompleted)
                    const Padding(
                      padding: EdgeInsets.only(top: 2.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text('مكتمل', style: TextStyle(color: Colors.green, fontSize: 11, fontWeight: FontWeight.bold)),
                          SizedBox(width: 4),
                          Icon(Icons.check_circle, color: Colors.green, size: 12),
                        ],
                      ),
                    ),
                  
                  const SizedBox(height: 8),
                  
                  // سطر الـ Tags (السعرات، البروتين، إلخ)
                  // نستخدم Wrap بدلاً من Row لحماية إضافية من الـ Overflow في الشاشات الصغيرة جداً
                  Wrap(
                    spacing: 5,
                    runSpacing: 5,
                    alignment: WrapAlignment.end,
                    children: [
                      _tag('${meal.calories.toStringAsFixed(0)} سعرة', Colors.orange),
                      _tag('P: ${meal.protein.toStringAsFixed(0)}g', Colors.blue),
                      _tag('C: ${meal.carbs.toStringAsFixed(0)}g', Colors.green),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(width: 12),
            
            // صورة الوجبة
            ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Stack(
                children: [
                  Image.network(imgUrl, width: 70, height: 70, fit: BoxFit.cover),
                  if (meal.isCompleted)
                    Container(
                      width: 70,
                      height: 70,
                      color: Colors.black.withOpacity(0.2),
                      child: const Icon(Icons.done_all, color: Colors.white, size: 24),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
Widget _buildEmptyState(BuildContext context, WidgetRef ref) {
  return Center(
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // أيقونة تعبيرية (مثلاً تقويم أو كوب قهوة)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF00D9D9).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.calendar_today_outlined,
              size: 80,
              color: Color(0xFF00D9D9),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'يوم راحة غذائية',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'لا توجد وجبات مجدولة لخطة التغذية اليوم. استمتع بيومك أو حاول تحديث الصفحة.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 32),
          // زر إعادة المحاولة/التحديث بشكل أنيق
          ElevatedButton.icon(
            onPressed: () => ref.read(nutritionProvider.notifier).refresh(),
            icon: const Icon(Icons.refresh, size: 20),
            label: const Text('تحديث البيانات'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00D9D9),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
          ),
        ],
      ),
    ),
  );
}
  Widget _tag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
      child: Text(text, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }
}