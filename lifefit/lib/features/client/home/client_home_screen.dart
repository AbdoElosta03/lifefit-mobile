import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/ui/base_screen.dart';
import '../../../core/ui/widgets/custom_app_bar.dart';
import '../../../core/ui/widgets/bottom_navigation.dart';
import '../../../core/ui/widgets/client_drawer.dart';
import '../dashboard/client_dashboard_widget.dart';

import '../notifications/notification_provider.dart';
import '../workouts/workouts_screen.dart';
import '../progrees/progress_screen.dart';

class ClientHomeScreen extends ConsumerStatefulWidget {
  const ClientHomeScreen({super.key});

  @override
  ConsumerState<ClientHomeScreen> createState() => _ClientHomeScreenState();
}

class _ClientHomeScreenState extends ConsumerState<ClientHomeScreen>
    with WidgetsBindingObserver {
  int _currentIndex = 0;
  Timer? _notificationPollTimer;

  final List<Widget> _pages = const [
    ClientDashboardWidget(),
    WorkoutsScreen(),
    ProgressScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _notificationPollTimer = Timer.periodic(
      const Duration(seconds: 45),
      (_) => ref.read(notificationsProvider.notifier).pollForNewNotifications(),
    );
  }

  @override
  void dispose() {
    _notificationPollTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref.read(notificationsProvider.notifier).pollForNewNotifications();
    }
  }

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
          setState(() {
            _currentIndex = index;
          });
        },
      ),
      body: _pages[_currentIndex],
    );
  }
}