import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:window_manager/window_manager.dart';

import 'app/router.dart';
import 'app/theme.dart';
import 'l10n/app_localizations.dart';
import 'services/auth_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (_isDesktop) {
    await windowManager.ensureInitialized();
    await windowManager.waitUntilReadyToShow(
      const WindowOptions(
        size: Size(1000, 650),
        minimumSize: Size(750, 550),
        title: 'FacturaInvent',
      ),
      () async {
        await windowManager.show();
        await windowManager.focus();
      },
    );
  }

  // Firebase: requiere `flutterfire configure` para generar firebase_options.dart.
  // Mientras tanto se intenta inicializar y se degrada gracefully si no hay config.
  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint('Firebase no inicializado (correr `flutterfire configure`): $e');
  }

  try {
    if (FirebaseAuth.instance.currentUser == null) {
      await FirebaseAuth.instance.signInAnonymously();
    }
  } catch (e) {
    debugPrint('Firebase Auth falló: $e');
    debugPrint('Causas comunes:');
    debugPrint('  - macOS: falta entitlement com.apple.security.network.client');
    debugPrint('  - Anonymous Auth no está habilitado en Firebase Console');
    debugPrint('  - Sin conexión a internet');
  }

  runApp(const ProviderScope(child: FacturaInventApp()));
}

bool get _isDesktop {
  if (kIsWeb) return false;
  return Platform.isMacOS || Platform.isWindows || Platform.isLinux;
}

class FacturaInventApp extends ConsumerWidget {
  const FacturaInventApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(authStateProvider, (prev, next) {
      next.whenData((user) async {
        if (user == null) {
          try {
            await ref.read(authServiceProvider).ensureSignedIn();
          } catch (_) {/* sin Firebase */}
        }
      });
    });

    return MaterialApp(
      title: 'FacturaInvent',
      debugShowCheckedModeBanner: false,
      theme: buildLightTheme(),
      darkTheme: buildDarkTheme(),
      themeMode: ThemeMode.system,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const RootScreen(),
    );
  }
}
