import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/app_state.dart';
import '../../l10n/app_localizations.dart';
import '../buscar/buscar_tab.dart';
import '../crear/crear_tab.dart';
import '../empresas/empresas_tab.dart';
import '../exportar/exportar_tab.dart';

class MainShell extends ConsumerWidget {
  const MainShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context);
    final selectedTab = ref.watch(selectedTabProvider);

    final destinations = <_TabDestination>[
      _TabDestination(
        label: t.tabBusinesses,
        icon: Icons.business_outlined,
        selectedIcon: Icons.business,
        page: const EmpresasTab(),
      ),
      _TabDestination(
        label: t.tabCreate,
        icon: Icons.add_circle_outline,
        selectedIcon: Icons.add_circle,
        page: const CrearTab(),
      ),
      _TabDestination(
        label: t.tabExport,
        icon: Icons.description_outlined,
        selectedIcon: Icons.description,
        page: const ExportarTab(),
      ),
      _TabDestination(
        label: t.tabSearch,
        icon: Icons.search_outlined,
        selectedIcon: Icons.search,
        page: const BuscarTab(),
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 750;

        if (wide) {
          return Scaffold(
            body: Row(
              children: [
                NavigationRail(
                  extended: constraints.maxWidth >= 1000,
                  selectedIndex: selectedTab,
                  onDestinationSelected: (i) =>
                      ref.read(selectedTabProvider.notifier).set(i),
                  destinations: destinations
                      .map((d) => NavigationRailDestination(
                            icon: Icon(d.icon),
                            selectedIcon: Icon(d.selectedIcon),
                            label: Text(d.label),
                          ))
                      .toList(),
                ),
                const VerticalDivider(thickness: 1, width: 1),
                Expanded(
                  child: IndexedStack(
                    index: selectedTab,
                    children: destinations.map((d) => d.page).toList(),
                  ),
                ),
              ],
            ),
          );
        }

        return Scaffold(
          body: IndexedStack(
            index: selectedTab,
            children: destinations.map((d) => d.page).toList(),
          ),
          bottomNavigationBar: NavigationBar(
            selectedIndex: selectedTab,
            onDestinationSelected: (i) =>
                ref.read(selectedTabProvider.notifier).set(i),
            destinations: destinations
                .map((d) => NavigationDestination(
                      icon: Icon(d.icon),
                      selectedIcon: Icon(d.selectedIcon),
                      label: d.label,
                    ))
                .toList(),
          ),
        );
      },
    );
  }
}

class _TabDestination {
  final String label;
  final IconData icon;
  final IconData selectedIcon;
  final Widget page;

  _TabDestination({
    required this.label,
    required this.icon,
    required this.selectedIcon,
    required this.page,
  });
}
