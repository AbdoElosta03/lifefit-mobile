import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/auth_provider.dart';
import '../ui/widgets/fitlife_boot_splash.dart';
import '../../features/client/home/client_home_screen.dart';
import '../../features/client/login/login_screen.dart';

/// AppEntry — single auth gate for the whole app (set as [MaterialApp.home] in main.dart).
///
/// Why this file exists:
/// - [main.dart] stays a thin shell (theme + [ProviderScope]); routing logic lives here.
/// - One place decides login vs home from [authProvider], so screens do not repeat session checks.
/// - Session restore runs once on cold start before showing either [LoginScreen] or [ClientHomeScreen].
///
/// Chat online presence is intentionally not started here; see [ChatDetailsScreen].
class AppEntry extends ConsumerStatefulWidget {
  const AppEntry({super.key});

  @override
  ConsumerState<AppEntry> createState() => _AppEntryState();
}

class _AppEntryState extends ConsumerState<AppEntry> {
  @override
  void initState() {
    super.initState();
    // Restore token/user from secure storage after first frame (needs [ref]).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(authProvider.notifier).restoreSession();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    // Widget: Boot splash — branded; avoids bare spinner feeling "slow".
    if (authState.isInitializing) {
      return const FitLifeBootSplash();
    }

    // Widget: Unauthenticated — no saved session or restore failed.
    if (authState.user == null) {
      return const LoginScreen();
    }

    // Widget: Authenticated client shell (tabs + drawer).
    return const ClientHomeScreen();
  }
}
