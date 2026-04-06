import 'package:flutter/material.dart';

class ExpertDetailsScreen extends StatefulWidget {
  // حولناها لـ StatefulWidget للتحكم في الاختيار
  final String name;
  final String specialty;
  final String bio;
  final double rating;
  final String certifications;
  final int yearsExperience;
  final String avatarUrl;

  const ExpertDetailsScreen({
    super.key,
    required this.name,
    required this.specialty,
    required this.certifications,
    required this.yearsExperience,
    required this.bio,
    required this.rating,
    required this.avatarUrl,
  });

  @override
  State<ExpertDetailsScreen> createState() => _ExpertDetailsScreenState();
}

class _ExpertDetailsScreenState extends State<ExpertDetailsScreen> {
  // متغير لتخزين الباقة المختارة (بشكل افتراضي نختار باقة 3 أشهر)
  int selectedPlanIndex = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          widget.name,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
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
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildCircularProfileImage(),
                const SizedBox(height: 15),
                Text(
                  widget.name,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  widget.specialty,
                  style: const TextStyle(
                    color: Color(0xFF00D9D9),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${widget.rating} ',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const Icon(
                      Icons.star_rounded,
                      color: Colors.amber,
                      size: 24,
                    ),
                  ],
                ),
                const SizedBox(height: 25),
                _buildSectionHeader('عن الخبير'),
                Text(
                  widget.bio,
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                    height: 1.6,
                  ),
                ),
                _buildSectionHeader('سنوات الخبرة'),
                Text(
                  '${widget.yearsExperience} ',
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
                _buildSectionHeader('الشهادات'),
                Text(
                  "${widget.certifications} ",
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
                const SizedBox(height: 5),

                const SizedBox(height: 25),
                _buildSectionHeader('باقات الاشتراك'),

                // قائمة الباقات القابلة للاختيار
                _buildPriceCard(
                  0,
                  'باقة الشهر الواحد',
                  '150 د.ل',
                  'أفضل لتجربة الخدمة',
                ),
                _buildPriceCard(
                  1,
                  'باقة 3 أشهر',
                  '400 د.ل',
                  'خصم 15% - الأكثر طلباً',
                ),
                _buildPriceCard(
                  2,
                  'باقة السنة كاملة',
                  '1200 د.ل',
                  'وفر 600 د.ل سنوياً',
                ),

                const SizedBox(height: 120),
              ],
            ),
          ),
          _buildSubscribeButton(),
        ],
      ),
    );
  }

  Widget _buildCircularProfileImage() {
    final avatarUrl = widget.avatarUrl.trim();
    final hasAvatar = avatarUrl.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: const Color(0xFF00D9D9).withOpacity(0.2),
          width: 2,
        ),
      ),
      child: CircleAvatar(
        radius: 50,
        backgroundColor: Colors.grey[200],
        child: ClipOval(
          child: SizedBox(
            width: 100,
            height: 100,
            child: hasAvatar
                ? Image.network(
                    avatarUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(
                        Icons.person,
                        size: 45,
                        color: Colors.grey,
                      );
                    },
                  )
                : const Icon(Icons.person, size: 45, color: Colors.grey),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Align(
      alignment: Alignment.centerRight,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 15),
        child: Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  // ميثود الكارد المعدلة لتصبح قابلة للاختيار (Selection Card)
  Widget _buildPriceCard(int index, String title, String price, String note) {
    bool isSelected = selectedPlanIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedPlanIndex = index;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF00D9D9).withOpacity(0.05)
              : Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: isSelected ? const Color(0xFF00D9D9) : Colors.grey[200]!,
            width: isSelected ? 2.5 : 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF00D9D9).withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Row(
          children: [
            // أيقونة الاختيار (التي تشبه الشيك بوكس أو الراديو)
            Icon(
              isSelected
                  ? Icons.check_circle_rounded
                  : Icons.radio_button_unchecked_rounded,
              color: isSelected ? const Color(0xFF00D9D9) : Colors.grey[400],
            ),
            const SizedBox(width: 15),
            Text(
              price,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF00D9D9),
              ),
            ),
            const Spacer(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                Text(
                  note,
                  style: TextStyle(color: Colors.grey[500], fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubscribeButton() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: () {
            // هنا يمكنك معرفة أي باقة تم اختيارها عبر المتغير selectedPlanIndex
            print("تم اختيار الباقة رقم: $selectedPlanIndex");
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF00D9D9),
            minimumSize: const Size(double.infinity, 55),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            elevation: 0,
          ),
          child: const Text(
            'تأكيد الاشتراك',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
