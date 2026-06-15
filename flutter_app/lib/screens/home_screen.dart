import 'package:flutter/material.dart';

import '../api/api_client.dart';
import 'ajustes_screen.dart';
import 'cuadre_form_screen.dart';
import 'empresas_screen.dart';
import 'historial_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.onLogout});
  final VoidCallback onLogout;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _seccion = 0;

  static const _titulos = ['Cuadre de Caja', 'Historial', 'Empresas'];

  @override
  Widget build(BuildContext context) {
    final pantallas = [
      const CuadreFormScreen(),
      const HistorialScreen(),
      const EmpresasScreen(),
    ];

    // En escritorio (ventana ancha) usamos NavigationRail; en Android, BottomNav.
    final esAncha = MediaQuery.of(context).size.width > 700;

    return Scaffold(
      appBar: AppBar(
        title: Text(_titulos[_seccion]),
        actions: [
          IconButton(
            tooltip: 'Ajustes',
            icon: const Icon(Icons.settings),
            onPressed: () async {
              await Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const AjustesScreen()),
              );
              if (!APIClient.shared.sesionActiva) widget.onLogout();
              setState(() {});
            },
          ),
        ],
      ),
      body: esAncha
          ? Row(
              children: [
                NavigationRail(
                  selectedIndex: _seccion,
                  onDestinationSelected: (i) => setState(() => _seccion = i),
                  labelType: NavigationRailLabelType.all,
                  destinations: const [
                    NavigationRailDestination(
                        icon: Icon(Icons.point_of_sale), label: Text('Cuadre')),
                    NavigationRailDestination(
                        icon: Icon(Icons.history), label: Text('Historial')),
                    NavigationRailDestination(
                        icon: Icon(Icons.business), label: Text('Empresas')),
                  ],
                ),
                const VerticalDivider(width: 1),
                Expanded(child: pantallas[_seccion]),
              ],
            )
          : pantallas[_seccion],
      bottomNavigationBar: esAncha
          ? null
          : NavigationBar(
              selectedIndex: _seccion,
              onDestinationSelected: (i) => setState(() => _seccion = i),
              destinations: const [
                NavigationDestination(icon: Icon(Icons.point_of_sale), label: 'Cuadre'),
                NavigationDestination(icon: Icon(Icons.history), label: 'Historial'),
                NavigationDestination(icon: Icon(Icons.business), label: 'Empresas'),
              ],
            ),
    );
  }
}
