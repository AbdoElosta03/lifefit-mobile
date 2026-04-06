import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/experts.dart';
import 'expert_detail_screen.dart';
import 'experts_provider.dart';

final selectedCategoryProvider = StateProvider<String>((ref) => 'الكل');

class ExpertsScreen extends ConsumerWidget {
  const ExpertsScreen({super.key});

  static const List<String> categories = ['الكل', 'مدربين', 'أخصائيي تغذية'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedCategory = ref.watch(selectedCategoryProvider);
    final expertsAsync = ref.watch(ExpertsProvider.provider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          'الخبراء',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.black,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // 1. نظام التصفية العلوي
          _buildFilterBar(ref, selectedCategory),

          // 2. قائمة الخبراء
          Expanded(
            child: expertsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stackTrace) => Center(
                child: Text(
                  'حدث خطأ أثناء جلب الخبراء',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ),
              data: (experts) {
                final filteredExperts = _filterExperts(
                  experts,
                  selectedCategory,
                );

                if (filteredExperts.isEmpty) {
                  return Center(
                    child: Text(
                      'لا يوجد خبراء مطابقون',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredExperts.length,
                  itemBuilder: (context, index) {
                    final expert = filteredExperts[index];
                    return _buildExpertCard(context: context, expert: expert);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ويدجت شريط التصفية الديناميكي
  Widget _buildFilterBar(WidgetRef ref, String selectedCategory) {
    return Container(
      height: 65,
      width: double.infinity,
      color: Colors.white,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        reverse: true, // لتبدأ القائمة من اليمين (العربية)
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final bool isActive = selectedCategory == category;

          return GestureDetector(
            onTap: () {
              ref.read(selectedCategoryProvider.notifier).state = category;
            },
            child: Container(
              margin: const EdgeInsets.only(left: 8),
              padding: const EdgeInsets.symmetric(horizontal: 25),
              decoration: BoxDecoration(
                color: isActive ? const Color(0xFF00D9D9) : Colors.white,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: isActive ? Colors.transparent : Colors.grey[200]!,
                ),
                boxShadow: isActive
                    ? [
                        BoxShadow(
                          color: const Color(0xFF00D9D9).withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ]
                    : null,
              ),
              alignment: Alignment.center,
              child: Text(
                category,
                style: TextStyle(
                  color: isActive ? Colors.white : Colors.grey[600],
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  List<Experts> _filterExperts(List<Experts> experts, String category) {
    if (category == 'الكل') {
      return experts;
    }

    if (category == 'مدربين') {
      return experts
          .where((expert) => (expert.type ?? '').contains('trainer'))
          .toList();
    }

    if (category == 'أخصائيي تغذية') {
      return experts
          .where((expert) => (expert.type ?? '').contains('nutritionist'))
          .toList();
    }

    return experts;
  }

  Widget _buildExpertCard({
    required BuildContext context, // إضافة الـ context هنا
    required Experts expert,
  }) {
    final name = expert.name ?? 'خبير بدون اسم';
    final specialty = expert.type ?? 'تخصص غير محدد';
    final bio = expert.bio ?? 'لا توجد نبذة حالياً.';
    final avatarUrl = expert.avatarUrl ?? 'https://i.pravatar.cc/150?img=3';
    final yearsExperience = expert.yearsExperience ?? 0;
    final certifications = expert.certifications ?? '';
    final rating = (expert.yearsExperience ?? 4).toDouble();
    final isVerified = (expert.certifications ?? '').isNotEmpty;

    return InkWell(
      onTap: () {
        // الانتقال لصفحة التفاصيل وتمرير البيانات
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ExpertDetailsScreen(
              name: name,
              specialty: specialty,
              bio: bio,
              rating: rating,
              avatarUrl: avatarUrl,
              certifications: certifications,
              yearsExperience: yearsExperience,
            ),
          ),
        );
      },
      borderRadius: BorderRadius.circular(
        20,
      ), // لضمان بقاء تأثير الضغط داخل حدود الكارد
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // التقييم في أقصى اليسار
            Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.amber[50],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Text(
                        '$rating',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: Colors.amber,
                        ),
                      ),
                      const Icon(
                        Icons.star_rounded,
                        color: Colors.amber,
                        size: 16,
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(width: 15),

            // المحتوى النصي
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                      color: Color(0xFF2D3142),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    specialty,
                    style: const TextStyle(
                      color: Color(0xFF00D9D9),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    bio,
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 13,
                      height: 1.5,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'خبرة: $yearsExperience سنوات',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                  const SizedBox(height: 4),
                  // أيقونات النجوم الزرقاء
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: List.generate(
                      5,
                      (index) => const Icon(
                        Icons.star_rounded,
                        color: Color(0xFF00D9D9),
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 15),

            // الصورة الشخصية مع شارة التوثيق
            Stack(
              alignment: Alignment.bottomLeft,
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF00D9D9).withOpacity(0.2),
                      width: 2,
                    ),
                  ),
                  child: CircleAvatar(
                    radius: 38,
                    backgroundColor: const Color(0xFFF0F0F0),
                    child: ClipOval(
                      child: Image.network(
                        avatarUrl,
                        width: 76,
                        height: 76,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(
                            Icons.person,
                            size: 45,
                            color: Colors.grey,
                          );
                        },
                      ),
                    ),
                  ),
                ),
                if (isVerified)
                  const CircleAvatar(
                    radius: 11,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.verified, color: Colors.blue, size: 18),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
