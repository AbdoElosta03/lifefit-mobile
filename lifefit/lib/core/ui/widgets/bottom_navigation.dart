import 'package:flutter/material.dart';

import '../app_colors.dart';

/// BottomNavigationWidget — main client tab bar (home, workouts, nutrition, progress).
class BottomNavigationWidget extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNavigationWidget({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  static const _tabs = <_TabConfig>[
    _TabConfig(
      outlined: Icons.home_outlined,
      filled: Icons.home_rounded,
      label: 'الرئيسية',
    ),
    _TabConfig(
      outlined: Icons.fitness_center_outlined,
      filled: Icons.fitness_center_rounded,
      label: 'التمارين',
    ),
    _TabConfig(
      outlined: Icons.restaurant_outlined,
      filled: Icons.restaurant_rounded,
      label: 'التغذية',
    ),
    _TabConfig(
      outlined: Icons.trending_up_outlined,
      filled: Icons.trending_up_rounded,
      label: 'التقدم',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return // Widget: Bar shell
        DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
        border: Border(
          top: BorderSide(
            color: Colors.black.withValues(alpha: 0.04),
          ),
        ),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        child: SafeArea(
          top: false,
          child: Theme(
            data: Theme.of(context).copyWith(
              navigationBarTheme: NavigationBarThemeData(
                height: 68,
                backgroundColor: Colors.white,
                indicatorColor: AppColors.primary.withValues(alpha: 0.14),
                indicatorShape: const StadiumBorder(),
                iconTheme: WidgetStateProperty.resolveWith((states) {
                  final selected = states.contains(WidgetState.selected);
                  return IconThemeData(
                    color: selected ? AppColors.primary : Colors.grey.shade500,
                    size: 24,
                  );
                }),
                labelTextStyle: WidgetStateProperty.resolveWith((states) {
                  final selected = states.contains(WidgetState.selected);
                  return TextStyle(
                    fontSize: 12,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                    color: selected ? AppColors.primary : Colors.grey.shade500,
                  );
                }),
              ),
            ),
            child: // Widget: Navigation destinations
                NavigationBar(
              surfaceTintColor: Colors.transparent,
              shadowColor: Colors.transparent,
              elevation: 0,
              labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
              selectedIndex: currentIndex,
              onDestinationSelected: onTap,
              animationDuration: const Duration(milliseconds: 280),
              destinations: [
                for (final tab in _tabs)
                  NavigationDestination(
                    icon: Icon(tab.outlined),
                    selectedIcon: Icon(tab.filled),
                    label: tab.label,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TabConfig {
  final IconData outlined;
  final IconData filled;
  final String label;

  const _TabConfig({
    required this.outlined,
    required this.filled,
    required this.label,
  });
}
