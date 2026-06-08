import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/main_shell/main_shell.dart';
import '../features/welcome/first_launch_provider.dart';
import '../features/welcome/welcome_screen.dart';

/// Decide entre WelcomeScreen y MainShell según el flag isFirstLaunch.
/// Equivalente a la lógica de FacturaInventApp.swift.
class RootScreen extends ConsumerWidget {
  const RootScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFirstLaunch = ref.watch(firstLaunchProvider);

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      child: isFirstLaunch.when(
        loading: () => const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
        error: (e, _) => Scaffold(
          body: Center(child: Text('Error: $e')),
        ),
        data: (first) {
          return first ? const WelcomeScreen() : const MainShell();
        },
      ),
    );
  }
}
