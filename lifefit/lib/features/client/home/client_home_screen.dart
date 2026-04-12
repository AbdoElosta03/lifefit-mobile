import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // 1. أضف هذا السطر
import '../../../core/ui/base_screen.dart';
import '../../../core/ui/widgets/custom_app_bar.dart';
import '../../../core/ui/widgets/bottom_navigation.dart';
import '../../../core/ui/widgets/client_drawer.dart';
import '../dashboard/client_dashboard_widget.dart';
import '../nutrition/nutrition_screen.dart';
import '../workouts/workouts_screen.dart';
import '../progrees/progress_screen.dart';


// 3. تغيير StatefulWidget إلى ConsumerStatefulWidget
class ClientHomeScreen extends ConsumerStatefulWidget {
  const ClientHomeScreen({super.key});

  @override
  ConsumerState<ClientHomeScreen> createState() => _ClientHomeScreenState();
}

// 4. تغيير State إلى ConsumerState
class _ClientHomeScreenState extends ConsumerState<ClientHomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    ClientDashboardWidget(),
    WorkoutsScreen(),
    NutritionScreen(),
    ProgressScreen(),
    
  ];

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      appBar: CustomAppBar(
        title: 'lifeFit',
      ),
      drawer: const ClientDrawer(),
      bottomNavigationBar: BottomNavigationWidget(
        currentIndex: _currentIndex,
        onTap: (index) {
          // أولاً: نغير الصفحة باستخدام setState العادية
          setState(() {
            _currentIndex = index;
          });
        },
      ),
      body: _pages[_currentIndex],
    );
  }
}