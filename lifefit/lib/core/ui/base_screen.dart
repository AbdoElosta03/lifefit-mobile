import 'package:flutter/material.dart';

class BaseScreen extends StatelessWidget {
  final PreferredSizeWidget? appBar;
  final Widget body;
  final Widget? drawer;
  final Widget? bottomNavigationBar;
  final Color? backgroundColor;

  const BaseScreen({
    super.key,
    this.appBar,
    required this.body,
    this.drawer,
    this.bottomNavigationBar,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar,
      body: body,
      endDrawer: drawer,
      bottomNavigationBar: bottomNavigationBar,
      backgroundColor: backgroundColor ?? const Color(0xFFF5F5F5),
    );
  }
}
