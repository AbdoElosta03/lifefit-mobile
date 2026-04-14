import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/auth_provider.dart';
import '../../features/client/home/client_home_screen.dart';
import '../../features/client/login/login_screen.dart';

const Color _kPrimary = Color(0xFF00D9D9);

/// Resolves session from secure storage on launch, then shows login or home.
class AppEntry extends ConsumerStatefulWidget {
  const AppEntry({super.key});

  @override
  ConsumerState<AppEntry> createState() => _AppEntryState();
}

class _AppEntryState extends ConsumerState<AppEntry> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(authProvider.notifier).restoreSession();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    if (authState.isInitializing) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: _kPrimary, strokeWidth: 2.5),
        ),
      );
    }

    if (authState.user == null) {
      return const LoginScreen();
    }

    return const ClientHomeScreen();
  }
}
