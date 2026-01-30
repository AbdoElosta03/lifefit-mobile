import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/auth_provider.dart';
import '../../features/client/home/client_home_screen.dart';
import '../../features/client/login/login_screen.dart';


class AppEntry extends ConsumerWidget {
  const AppEntry({super.key});

@override
Widget build(BuildContext context, WidgetRef ref) {
  final authState = ref.watch(authProvider);
  final user = authState.user;

  if (user == null) {
    return const LoginScreen();
  }

  return const ClientHomeScreen();
}

}