import 'package:flutter/material.dart';

class BottomNavigationWidget extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNavigationWidget({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      // ظل ناعم جداً من الأعلى لإعطاء لمسة الفخامة
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: onTap,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        elevation: 0, // أزلنا الارتفاع الافتراضي لنعتمد على ظل الـ Container
        selectedItemColor: const Color(0xFF00D9D9),
        unselectedItemColor: Colors.grey[400],
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        unselectedLabelStyle: const TextStyle(fontSize: 12),
        items: [
          _buildItem(Icons.home_rounded, Icons.home_outlined, 'الرئيسية', 0),
          _buildItem(Icons.fitness_center_rounded, Icons.fitness_center_outlined, 'التمارين', 1),
          _buildItem(Icons.restaurant_rounded, Icons.restaurant_outlined, 'التغذية', 2),
          _buildItem(Icons.trending_up_rounded, Icons.trending_up, 'التقدم', 3),
        ],
      ),
    );
  }

  // ميثود مختصرة لبناء العناصر ومنع تكرار الكود
  BottomNavigationBarItem _buildItem(IconData activeIcon, IconData inactiveIcon, String label, int index) {
    return BottomNavigationBarItem(
      icon: Icon(currentIndex == index ? activeIcon : inactiveIcon, size: 26),
      label: label,
    );
  }
}