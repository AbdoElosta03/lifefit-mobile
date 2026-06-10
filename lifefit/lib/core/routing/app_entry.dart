import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/auth_provider.dart';
import '../ui/widgets/fitlife_boot_splash.dart';
import '../../features/client/home/client_home_screen.dart';
import '../../features/client/login/login_screen.dart';
import '../../features/client/onboarding/profile_onboarding_provider.dart';
import '../../features/client/onboarding/profile_onboarding_screen.dart';

/// AppEntry — single auth gate for the whole app (set as [MaterialApp.home] in main.dart).
///
/// Why this file exists:
/// - [main.dart] stays a thin shell (theme + [ProviderScope]); routing logic lives here.
/// - One place decides login vs home from [authProvider], so screens do not repeat session checks.
/// - Session restore runs once on cold start before showing either [LoginScreen] or [ClientHomeScreen].
/// - New clients without profile data see [ProfileOnboardingScreen] before [ClientHomeScreen].
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
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await ref.read(authProvider.notifier).restoreSession();
      if (ref.read(authProvider).user != null) {
        ref.read(profileGateProvider.notifier).check();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final gateState = ref.watch(profileGateProvider);

    ref.listen(authProvider, (previous, next) {
      if (next.user == null) {
        ref.read(profileGateProvider.notifier).reset();
      } else if (previous?.user?.id != next.user?.id) {
        ref.read(profileGateProvider.notifier).check();
      }
    });

    if (authState.isInitializing) {
      return const FitLifeBootSplash();
    }

    if (authState.user == null) {
      return const LoginScreen();
    }

    if (gateState.isChecking || gateState.needsOnboarding == null) {
      return const FitLifeBootSplash();
    }

    if (gateState.needsOnboarding == true) {
      return ProfileOnboardingScreen(initialBundle: gateState.bundle);
    }

    return const ClientHomeScreen();
  }
}
