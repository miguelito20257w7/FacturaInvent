import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/firestore/empresa_repository.dart';
import '../../data/firestore/producto_repository.dart';
import '../../l10n/app_localizations.dart';
import '../../models/empresa.dart';
import '../crear/agregar_xml_screen.dart';
import '../producto/detalle_producto.dart';

class EmpresaDetalle extends ConsumerWidget {
  final Empresa empresa;
  const EmpresaDetalle({super.key, required this.empresa});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context);
    final empresaId = empresa.id;
    final productosAsync = empresaId == null
        ? const AsyncValue.data([])
        : ref.watch(productosPorEmpresaProvider(empresaId));

    return Scaffold(
      appBar: AppBar(title: Text(empresa.nombre)),
      body: productosAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (productos) {
          if (productos.isEmpty) {
            return _EmptyState(empresa: empresa);
          }
          return ListView(
            children: [
              ...productos.map(
                (p) => ListTile(
                  title: Text(p.nombre),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(t.internCodeColon(p.codigoInterno)),
                      Text(t.barcodeShortColon(p.codigoBarras)),
                    ],
                  ),
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => DetalleProducto(producto: p),
                    ));
                  },
                ),
              ),
              const Divider(),
              _DangerSection(empresa: empresa),
            ],
          );
        },
      ),
    );
  }
}

class _EmptyState extends ConsumerWidget {
  final Empresa empresa;
  const _EmptyState({required this.empresa});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_2_outlined,
              size: 80, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(height: 16),
          Text(t.noProducts, style: theme.textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(t.importXmlToAddProducts,
              style: TextStyle(color: theme.colorScheme.onSurfaceVariant)),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FilledButton.icon(
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => AgregarXmlScreen(empresaPreseleccionada: empresa),
                  ));
                },
                icon: const Icon(Icons.upload_file),
                label: Text(t.addXml),
              ),
              const SizedBox(width: 12),
              IconButton.filledTonal(
                onPressed: () async {
                  if (empresa.id != null) {
                    await ref
                        .read(empresaRepositoryProvider)
                        .delete(empresa.id!);
                    if (context.mounted) Navigator.of(context).pop();
                  }
                },
                icon: const Icon(Icons.delete_outline),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DangerSection extends ConsumerStatefulWidget {
  final Empresa empresa;
  const _DangerSection({required this.empresa});

  @override
  ConsumerState<_DangerSection> createState() => _DangerSectionState();
}

class _DangerSectionState extends ConsumerState<_DangerSection> {
  final _newNameCtrl = TextEditingController();

  @override
  void dispose() {
    _newNameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(t.deleteBusinessOrChangeName,
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(child: Text(t.thisActionCantBeUndone)),
                  IconButton.filledTonal(
                    onPressed: _confirmDelete,
                    icon: const Icon(Icons.delete_outline),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: _showChangeName,
                    child: Text(t.changeName),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmDelete() async {
    final t = AppLocalizations.of(context);
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(t.deleteQuestion),
        content: Text(t.thisActionCantBeUndone),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(t.cancel),
          ),
          FilledButton.tonal(
            style: FilledButton.styleFrom(
              foregroundColor: Theme.of(ctx).colorScheme.error,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(t.delete),
          ),
        ],
      ),
    );
    if (result == true && widget.empresa.id != null) {
      await ref
          .read(empresaRepositoryProvider)
          .delete(widget.empresa.id!);
      if (mounted) Navigator.of(context).pop();
    }
  }

  Future<void> _showChangeName() async {
    final t = AppLocalizations.of(context);
    _newNameCtrl.text = widget.empresa.nombre;
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(t.changeName),
        content: TextField(
          controller: _newNameCtrl,
          decoration: InputDecoration(labelText: t.newName),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(t.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(_newNameCtrl.text),
            child: Text(t.change),
          ),
        ],
      ),
    );
    if (result != null && result.isNotEmpty && widget.empresa.id != null) {
      await ref
          .read(empresaRepositoryProvider)
          .rename(widget.empresa.id!, result);
    }
  }
}
