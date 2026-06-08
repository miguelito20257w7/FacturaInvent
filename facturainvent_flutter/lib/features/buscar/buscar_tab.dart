import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/firestore/empresa_repository.dart';
import '../../data/firestore/producto_repository.dart';
import '../../l10n/app_localizations.dart';
import '../empresas/empresa_detalle.dart';
import '../producto/detalle_producto.dart';

class BuscarTab extends ConsumerStatefulWidget {
  const BuscarTab({super.key});

  @override
  ConsumerState<BuscarTab> createState() => _BuscarTabState();
}

class _BuscarTabState extends ConsumerState<BuscarTab> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final empresasAsync = ref.watch(empresasStreamProvider);
    final productosAsync = ref.watch(productosStreamProvider);

    final q = _query.toLowerCase();
    final empresas = empresasAsync.maybeWhen(
      data: (list) {
        if (q.isEmpty) return list;
        return list.where((e) {
          return e.nombre.toLowerCase().contains(q) ||
              e.nit.toLowerCase().contains(q);
        }).toList();
      },
      orElse: () => [],
    );
    final productos = productosAsync.maybeWhen(
      data: (list) {
        if (q.isEmpty) return list;
        return list.where((p) {
          return p.nombre.toLowerCase().contains(q) ||
              p.codigoFactura.toLowerCase().contains(q) ||
              p.codigoBarras.toLowerCase().contains(q) ||
              p.codigoInterno.toLowerCase().contains(q);
        }).toList();
      },
      orElse: () => [],
    );

    return Scaffold(
      appBar: AppBar(title: Text(t.search)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: SearchBar(
              hintText: t.searchPrompt,
              leading: const Icon(Icons.search),
              onChanged: (v) => setState(() => _query = v),
            ),
          ),
          Expanded(
            child: ListView(
              children: [
                if (empresas.isNotEmpty) ...[
                  _SectionHeader(t.tabBusinesses),
                  ...empresas.map((e) => ListTile(
                        title: Text(e.nombre),
                        subtitle: Text(t.nitColon(e.nit)),
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (_) => EmpresaDetalle(empresa: e),
                          ));
                        },
                      )),
                ],
                if (productos.isNotEmpty) ...[
                  _SectionHeader(t.products),
                  ...productos.map((p) => ListTile(
                        title: Text(p.nombre),
                        subtitle: Text(p.codigoInterno),
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (_) => DetalleProducto(producto: p),
                          ));
                        },
                      )),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String label;
  const _SectionHeader(this.label);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        label,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
      ),
    );
  }
}
