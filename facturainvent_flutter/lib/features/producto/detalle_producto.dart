import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/firestore/producto_repository.dart';
import '../../l10n/app_localizations.dart';
import '../../models/producto.dart';

class DetalleProducto extends ConsumerStatefulWidget {
  final Producto producto;
  const DetalleProducto({super.key, required this.producto});

  @override
  ConsumerState<DetalleProducto> createState() => _DetalleProductoState();
}

class _DetalleProductoState extends ConsumerState<DetalleProducto> {
  late Producto _producto;

  final _nombreCtrl = TextEditingController();
  final _barrasCtrl = TextEditingController();
  final _internoCtrl = TextEditingController();
  final _paquetesCtrl = TextEditingController();

  bool _editingName = false;
  bool _editingBarcode = false;
  bool _editingPaquetes = false;

  @override
  void initState() {
    super.initState();
    _producto = widget.producto;
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _barrasCtrl.dispose();
    _internoCtrl.dispose();
    _paquetesCtrl.dispose();
    super.dispose();
  }

  Future<void> _persist() async {
    if (_producto.id == null) return;
    await ref.read(productoRepositoryProvider).update(_producto);
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(t.modifyProduct)),
      body: ListView(
        children: [
          _section(
            title: t.productInfoAndBarcode,
            children: [
              _editingName
                  ? _editableName(t)
                  : ListTile(
                      title: Text(_producto.nombre,
                          style: Theme.of(context).textTheme.titleMedium),
                      trailing: TextButton(
                        onPressed: () {
                          setState(() {
                            _nombreCtrl.text = _producto.nombre;
                            _editingName = true;
                          });
                        },
                        child: Text(t.change),
                      ),
                    ),
              ListTile(
                title: Text(t.foundInBill(
                    _producto.codigoDeBarrasAutomatico ? t.yes : t.no)),
              ),
              if (_producto.codigoBarras.isNotEmpty && !_editingBarcode)
                ListTile(
                  title: Text(t.barcodeColon(_producto.codigoBarras)),
                  trailing: TextButton(
                    onPressed: () => setState(() => _editingBarcode = true),
                    child: Text(t.change),
                  ),
                ),
              if (_producto.codigoInterno.isNotEmpty && !_editingBarcode)
                ListTile(
                  title: Text(t.internCodeColon(_producto.codigoInterno)),
                  trailing: TextButton(
                    onPressed: () => setState(() => _editingBarcode = true),
                    child: Text(t.change),
                  ),
                ),
              if (_editingBarcode ||
                  (_producto.codigoBarras.isEmpty &&
                      _producto.codigoInterno.isEmpty))
                _editableBarcodeInterno(t),
            ],
          ),
          _section(
            title: t.advanced,
            children: [
              SwitchListTile(
                title: Text(t.packageToUnit),
                value: _producto.vieneEnPaquetes,
                onChanged: (v) async {
                  setState(() {
                    _producto = _producto.copyWith(
                      vieneEnPaquetes: v,
                      cantidadPaquetes: v ? _producto.cantidadPaquetes : 1,
                    );
                  });
                  await _persist();
                },
              ),
              if (_producto.vieneEnPaquetes)
                _editingPaquetes
                    ? _editablePaquetes(t)
                    : ListTile(
                        title: Text(t.unitsPerPackage(_producto.cantidadPaquetes)),
                        trailing: TextButton(
                          onPressed: () {
                            setState(() {
                              _paquetesCtrl.text =
                                  _producto.cantidadPaquetes.toString();
                              _editingPaquetes = true;
                            });
                          },
                          child: Text(t.change),
                        ),
                      ),
            ],
          ),
          _section(
            title: t.delete,
            children: [
              ListTile(
                title: Text(t.thisActionCantBeUndone),
                trailing: IconButton.filledTonal(
                  onPressed: _confirmDelete,
                  icon: const Icon(Icons.delete_outline),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _editableName(AppLocalizations t) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _nombreCtrl,
              maxLines: null,
            ),
          ),
          IconButton.filledTonal(
            onPressed: () async {
              setState(() {
                _producto = _producto.copyWith(nombre: _nombreCtrl.text);
                _editingName = false;
              });
              await _persist();
            },
            icon: const Icon(Icons.check_circle),
          ),
        ],
      ),
    );
  }

  Widget _editableBarcodeInterno(AppLocalizations t) {
    _barrasCtrl.text = _producto.codigoBarras;
    _internoCtrl.text = _producto.codigoInterno;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _barrasCtrl,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  decoration: InputDecoration(labelText: t.barcode),
                ),
              ),
              IconButton.filledTonal(
                onPressed: () async {
                  setState(() {
                    _producto =
                        _producto.copyWith(codigoBarras: _barrasCtrl.text);
                    _editingBarcode = false;
                  });
                  await _persist();
                },
                icon: const Icon(Icons.check_circle),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _internoCtrl,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  decoration: InputDecoration(labelText: t.internCode),
                ),
              ),
              IconButton.filledTonal(
                onPressed: () async {
                  setState(() {
                    _producto =
                        _producto.copyWith(codigoInterno: _internoCtrl.text);
                    _editingBarcode = false;
                  });
                  await _persist();
                },
                icon: const Icon(Icons.check_circle),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _editablePaquetes(AppLocalizations t) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Text(t.unitsPerPackageLabel),
          Expanded(
            child: TextField(
              controller: _paquetesCtrl,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(labelText: t.quantity),
            ),
          ),
          IconButton.filledTonal(
            onPressed: () async {
              final n = int.tryParse(_paquetesCtrl.text);
              if (n != null && n > 0) {
                setState(() {
                  _producto = _producto.copyWith(cantidadPaquetes: n);
                  _editingPaquetes = false;
                });
                await _persist();
              }
            },
            icon: const Icon(Icons.check_circle),
          ),
        ],
      ),
    );
  }

  Widget _section({required String title, required List<Widget> children}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Text(title,
                    style: Theme.of(context).textTheme.labelLarge),
              ),
              ...children,
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
    if (result == true && _producto.id != null) {
      await ref.read(productoRepositoryProvider).delete(_producto.id!);
      if (mounted) Navigator.of(context).pop();
    }
  }
}
