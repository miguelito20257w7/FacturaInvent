import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../l10n/app_localizations.dart';
import '../../models/producto_import.dart';

class PreviewProducto extends StatefulWidget {
  final ProductoImport producto;
  final bool modoExcelPreview;
  final VoidCallback onEliminar;

  const PreviewProducto({
    super.key,
    required this.producto,
    this.modoExcelPreview = false,
    required this.onEliminar,
  });

  @override
  State<PreviewProducto> createState() => _PreviewProductoState();
}

class _PreviewProductoState extends State<PreviewProducto> {
  late ProductoImport _producto;

  final _nombreCtrl = TextEditingController();
  final _barrasCtrl = TextEditingController();
  final _internoCtrl = TextEditingController();
  final _paquetesCtrl = TextEditingController();
  final _cantidadCtrl = TextEditingController();
  final _descuentoCtrl = TextEditingController();

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
    _cantidadCtrl.dispose();
    _descuentoCtrl.dispose();
    super.dispose();
  }

  void _commit() {
    Navigator.of(context).pop(_producto);
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) Navigator.of(context).pop(_producto);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(t.preview),
          actions: [
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: _commit,
            ),
          ],
        ),
        body: ListView(
          children: [
            _section(t.productInfoAndBarcode, [
              _editingName ? _editableName(t) : _readonlyName(t),
              ListTile(
                title: Text(t.foundInBill(
                    _producto.codigoBarrasAutomatico ? t.yes : t.no)),
              ),
              if (_producto.codigoBarras.isNotEmpty &&
                  !_editingBarcode &&
                  _producto.codigoInterno.isNotEmpty)
                ListTile(
                  title: Text(t.barcodeColon(_producto.codigoBarras)),
                  trailing: widget.modoExcelPreview
                      ? null
                      : TextButton(
                          onPressed: () =>
                              setState(() => _editingBarcode = true),
                          child: Text(t.change),
                        ),
                ),
              if (_producto.codigoInterno.isNotEmpty && !_editingBarcode)
                ListTile(
                  title: Text(t.internCodeColon(_producto.codigoInterno)),
                  trailing: widget.modoExcelPreview
                      ? null
                      : TextButton(
                          onPressed: () =>
                              setState(() => _editingBarcode = true),
                          child: Text(t.change),
                        ),
                ),
              if (!widget.modoExcelPreview &&
                  (_editingBarcode ||
                      (_producto.codigoBarras.isEmpty &&
                          _producto.codigoInterno.isEmpty)))
                _editableBarcodeInterno(t),
            ]),
            if (widget.modoExcelPreview)
              _section(t.uploadItems, [
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _cantidadCtrl
                            ..text = _producto.cantidad.isEmpty
                                ? ''
                                : (double.tryParse(_producto.cantidad)?.toInt() ??
                                        0)
                                    .toString(),
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          decoration: InputDecoration(labelText: t.quantity),
                        ),
                      ),
                      IconButton.filledTonal(
                        onPressed: () {
                          final n = int.tryParse(_cantidadCtrl.text);
                          if (n != null && n > 0) {
                            setState(() => _producto =
                                _producto.copyWith(cantidad: n.toString()));
                          }
                        },
                        icon: const Icon(Icons.check_circle),
                      ),
                    ],
                  ),
                ),
              ]),
            _section(t.price, [
              ListTile(title: Text(t.priceColon(_producto.precioSinIVA))),
              if (widget.modoExcelPreview) ...[
                SwitchListTile(
                  title: Text(t.hasDiscount),
                  value: _producto.tieneDescuento,
                  onChanged: (v) => setState(() {
                    _producto = _producto.copyWith(tieneDescuento: v);
                  }),
                ),
                if (_producto.tieneDescuento)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    child: Row(
                      children: [
                        Text(t.discount),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: _descuentoCtrl
                              ..text = _producto.porcentajeDescuento == 0
                                  ? ''
                                  : _producto.porcentajeDescuento.toString(),
                            keyboardType:
                                const TextInputType.numberWithOptions(
                                    decimal: true),
                            textAlign: TextAlign.right,
                            decoration: const InputDecoration(suffixText: '%'),
                            onChanged: (s) {
                              final d = double.tryParse(s) ?? 0;
                              setState(() {
                                _producto = _producto.copyWith(
                                    porcentajeDescuento: d);
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                if (_producto.tieneDescuento &&
                    _producto.porcentajeDescuento > 0)
                  Builder(builder: (_) {
                    final precioBase = double.tryParse(
                            _producto.precioSinIVA.replaceAll(',', '.')) ??
                        0;
                    final precio =
                        precioBase * (1 - _producto.porcentajeDescuento / 100);
                    return ListTile(
                      title: Text(
                          t.priceWithDiscount(precio.toStringAsFixed(2))),
                      titleTextStyle: TextStyle(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurfaceVariant),
                    );
                  }),
              ],
            ]),
            _section(t.advanced, [
              SwitchListTile(
                title: Text(t.packageToUnit),
                value: _producto.vieneEnPaquetes,
                onChanged: (v) => setState(() {
                  _producto = _producto.copyWith(vieneEnPaquetes: v);
                }),
              ),
              if (_producto.vieneEnPaquetes)
                _editingPaquetes
                    ? _editablePaquetes(t)
                    : ListTile(
                        title: Text(t.unitsPerPackage(_producto.cantidadPaquetes)),
                        trailing: TextButton(
                          onPressed: () => setState(() {
                            _paquetesCtrl.text =
                                _producto.cantidadPaquetes.toString();
                            _editingPaquetes = true;
                          }),
                          child: Text(t.change),
                        ),
                      ),
            ]),
            _section(t.removeFromImport, [
              ListTile(
                title: Text(t.thisActionCantBeUndone),
                trailing: IconButton.filledTonal(
                  onPressed: () {
                    Navigator.of(context).pop();
                    widget.onEliminar();
                  },
                  icon: const Icon(Icons.delete_outline),
                ),
              ),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _readonlyName(AppLocalizations t) {
    return ListTile(
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
              enabled: !widget.modoExcelPreview,
              maxLines: null,
            ),
          ),
          IconButton.filledTonal(
            onPressed: () {
              setState(() {
                _producto = _producto.copyWith(nombre: _nombreCtrl.text);
                _editingName = false;
              });
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
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: InputDecoration(labelText: t.barcode),
                ),
              ),
              IconButton.filledTonal(
                onPressed: () => setState(() {
                  _producto =
                      _producto.copyWith(codigoBarras: _barrasCtrl.text);
                  _editingBarcode = false;
                }),
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
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: InputDecoration(labelText: t.internCode),
                ),
              ),
              IconButton.filledTonal(
                onPressed: () => setState(() {
                  _producto =
                      _producto.copyWith(codigoInterno: _internoCtrl.text);
                  _editingBarcode = false;
                }),
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
            onPressed: () {
              final n = int.tryParse(_paquetesCtrl.text);
              if (n != null && n > 0) {
                setState(() {
                  _producto = _producto.copyWith(cantidadPaquetes: n);
                  _editingPaquetes = false;
                });
              }
            },
            icon: const Icon(Icons.check_circle),
          ),
        ],
      ),
    );
  }

  Widget _section(String title, List<Widget> children) {
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
}
