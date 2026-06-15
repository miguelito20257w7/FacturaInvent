import 'package:flutter/material.dart';

import 'api/api_client.dart';
import 'api/server_config.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/onboarding_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ServerConfig.shared.cargar();
  await APIClient.shared.cargar();
  runApp(const FacturaInventApp());
}

class FacturaInventApp extends StatefulWidget {
  const FacturaInventApp({super.key});

  @override
  State<FacturaInventApp> createState() => _FacturaInventAppState();
}

class _FacturaInventAppState extends State<FacturaInventApp> {
  @override
  Widget build(BuildContext context) {
    final Widget pantalla;
    if (!ServerConfig.shared.configurado) {
      pantalla = OnboardingScreen(onListo: () => setState(() {}));
    } else if (!APIClient.shared.sesionActiva) {
      pantalla = LoginScreen(onLogin: () => setState(() {}));
    } else {
      pantalla = HomeScreen(onLogout: () => setState(() {}));
    }

    return MaterialApp(
      title: 'FacturaInvent 2',
      theme: ThemeData(
        colorSchemeSeed: Colors.teal,
        useMaterial3: true,
      ),
      home: pantalla,
    );
  }
}
