import 'dart:io';

import 'package:collection/collection.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/app_state.dart';
import '../../data/firestore/empresa_repository.dart';
import '../../data/firestore/producto_repository.dart';
import '../../l10n/app_localizations.dart';
import '../../models/empresa.dart';
import '../../models/producto.dart';
import '../../models/producto_conflicto.dart';
import '../../models/producto_import.dart';
import '../../services/xml_factura_parser.dart';
import '../empresas/empresa_detalle.dart';
import '../producto/preview_producto.dart';

class AgregarXmlScreen extends ConsumerStatefulWidget {
  final Empresa? empresaPreseleccionada;
  const AgregarXmlScreen({super.key, this.empresaPreseleccionada});

  @override
  ConsumerState<AgregarXmlScreen> createState() => _AgregarXmlScreenState();
}

class _AgregarXmlScreenState extends ConsumerState<AgregarXmlScreen> {
  final List<ProductoImport> _productosNuevos = [];
  final List<ProductoConflicto> _productosConflicto = [];
  Empresa? _empresaActual;
  bool _mostrarExito = false;
  int _productosGuardados = 0;
  String? _errorMensaje;

  bool get _hayProductos =>
      _productosNuevos.isNotEmpty || _productosConflicto.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _empresaActual = widget.empresaPreseleccionada;
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);

    return Shortcuts(
      shortcuts: const <LogicalKeySet, Intent>{},
      child: Focus(
        autofocus: true,
        onKeyEvent: (node, event) {
          if (event is KeyDownEvent &&
              event.logicalKey == LogicalKeyboardKey.escape &&
              _hayProductos) {
            ref.read(appStateProvider.notifier).setShowCancelButton(true);
            return KeyEventResult.handled;
          }
          return KeyEventResult.ignored;
        },
        child: Builder(
          builder: (context) {
            if (_mostrarExito) return _buildExito(t);
            if (!_hayProductos) return _buildInicial(t);
            return _buildRevision(t);
          },
        ),
      ),
    );
  }

  Widget _buildInicial(AppLocalizations t) {
    return Scaffold(
      appBar: AppBar(
        title: Text(t.importBusiness),
        actions: [
          TextButton(
            onPressed: () =>
                ref.read(selectedTabProvider.notifier).set(0),
            child: Text(t.cancel),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(t.addBusinessAndProducts),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _pickXml,
              icon: const Icon(Icons.upload_file),
              label: Text(t.addXml),
            ),
            if (_errorMensaje != null) ...[
              const SizedBox(height: 24),
              Text(_errorMensaje!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRevision(AppLocalizations t) {
    return Scaffold(
      appBar: AppBar(
        leading: TextButton(
          onPressed: () => ref
              .read(appStateProvider.notifier)
              .setShowCancelButton(true),
          child: Text(t.cancel),
        ),
        leadingWidth: 100,
        title: Text(t.reviewProducts),
        actions: [
          TextButton(
            onPressed: _guardarProductosNuevos,
            child: Text(t.confirm),
          ),
        ],
      ),
      body: Consumer(builder: (context, ref, _) {
        final appState = ref.watch(appStateProvider);
        if (appState.showCancelButton) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _mostrarConfirmacionCancelar(t);
          });
        }
        return ListView(
          children: [
            if (_productosNuevos.isNotEmpty) ...[
              _sectionHeader(t.newProducts(_productosNuevos.length)),
              ..._productosNuevos.asMap().entries.map((entry) {
                final i = entry.key;
                final p = entry.value;
                return ListTile(
                  title: Text(p.nombre),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(p.codigo,
                          style: Theme.of(context).textTheme.bodySmall),
                      if (p.codigoInterno.isNotEmpty)
                        Text(t.internCodeColon(p.codigoInterno),
                            style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                  onTap: () async {
                    final updated = await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => PreviewProducto(
                          producto: p,
                          onEliminar: () {
                            setState(() {
                              _productosNuevos.removeAt(i);
                            });
                          },
                        ),
                      ),
                    );
                    if (updated is ProductoImport) {
                      setState(() => _productosNuevos[i] = updated);
                    }
                  },
                );
              }),
            ],
            if (_productosConflicto.isNotEmpty) ...[
              _sectionHeader(t.existingProducts(_productosConflicto.length)),
              ..._productosConflicto.map((c) {
                final db = c.productoEnDB;
                final nombreCambio = db.nombre != c.datosNuevos.nombre;
                return ListTile(
                  title: Text(db.nombre),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (nombreCambio)
                        Text(
                          t.xmlPrefixColon(c.datosNuevos.nombre),
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.tertiary),
                        ),
                      Text(db.codigoFactura,
                          style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                );
              }),
            ],
          ],
        );
      }),
    );
  }

  Widget _buildExito(AppLocalizations t) {
    return Scaffold(
      appBar: AppBar(
        title: Text(t.success),
        automaticallyImplyLeading: false,
        actions: [
          TextButton(
            onPressed: _reiniciar,
            child: Text(t.close),
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_circle,
                  size: 80, color: Theme.of(context).colorScheme.primary),
              const SizedBox(height: 16),
              Text(t.importSuccessful,
                  style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 8),
              Text(t.productsImportedSuccessfully(_productosGuardados)),
              if (_empresaActual != null) ...[
                const SizedBox(height: 4),
                Text(t.businessColon(_empresaActual!.nombre),
                    style: Theme.of(context).textTheme.bodySmall),
              ],
              const SizedBox(height: 32),
              if (_empresaActual != null)
                FilledButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) =>
                          EmpresaDetalle(empresa: _empresaActual!),
                    ));
                  },
                  icon: const Icon(Icons.arrow_forward),
                  label: Text(t.done),
                ),
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: _reiniciar,
                icon: const Icon(Icons.add),
                label: Text(t.importAnotherXml),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionHeader(String text) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        text,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
      ),
    );
  }

  Future<void> _mostrarConfirmacionCancelar(AppLocalizations t) async {
    ref.read(appStateProvider.notifier).setShowCancelButton(false);
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(t.areYouSureCancel),
        content: Text(t.allDataWillBeLost),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(t.back),
          ),
          FilledButton.tonal(
            style: FilledButton.styleFrom(
              foregroundColor: Theme.of(ctx).colorScheme.error,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(t.cancel),
          ),
        ],
      ),
    );
    if (result == true) {
      setState(() {
        _productosNuevos.clear();
        _productosConflicto.clear();
        _empresaActual = null;
      });
    }
  }

  Future<void> _pickXml() async {
    setState(() => _errorMensaje = null);

    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xml'],
    );
    if (result == null || result.files.single.path == null) return;

    try {
      final file = File(result.files.single.path!);
      final contenido = await file.readAsString();

      final parser = XMLFacturaParser();
      final parsed = parser.parseContenidoXML(contenido);
      if (parsed == null) {
        setState(() {
          _errorMensaje = 'There was an error parsing the XML (no CDATA tag)';
        });
        return;
      }

      // Buscar/crear empresa
      final empresaRepo = ref.read(empresaRepositoryProvider);
      var empresa = await empresaRepo.findByNit(parsed.nit);
      if (empresa == null) {
        empresa = await empresaRepo.create(Empresa(
          nombre: parsed.nombreEmpresa,
          nit: parsed.nit,
        ));
      }

      final productosEmpresa = empresa.id != null
          ? await ref
              .read(productoRepositoryProvider)
              .getByEmpresa(empresa.id!)
          : <Producto>[];

      // Conteo para limpiar duplicados dentro del mismo XML
      final codigosBarrasCount = groupBy(parsed.productos, (p) => p.codigoBarras);
      final codigosFacturaCount = groupBy(parsed.productos, (p) => p.codigo);

      final nuevos = <ProductoImport>[];
      final conflictos = <ProductoConflicto>[];

      for (final p in parsed.productos) {
        if (p.codigo.isNotEmpty) {
          final existente = productosEmpresa
              .firstWhereOrNull((e) => e.codigoFactura == p.codigo);
          if (existente != null) {
            conflictos.add(ProductoConflicto(
              productoEnDB: existente,
              datosNuevos: _toImport(p),
            ));
            continue;
          }
        }
        if (p.codigoBarras.isNotEmpty) {
          final existente = productosEmpresa
              .firstWhereOrNull((e) => e.codigoBarras == p.codigoBarras);
          if (existente != null) {
            conflictos.add(ProductoConflicto(
              productoEnDB: existente,
              datosNuevos: _toImport(p),
            ));
            continue;
          }
        }
        final codigoBarrasLimpio =
            (codigosBarrasCount[p.codigoBarras]?.length ?? 0) > 1
                ? ''
                : p.codigoBarras;
        final codigoFacturaLimpio =
            (codigosFacturaCount[p.codigo]?.length ?? 0) > 1
                ? ''
                : p.codigo;

        nuevos.add(ProductoImport.create(
          codigo: codigoFacturaLimpio,
          codigoBarras: codigoBarrasLimpio,
          nombre: p.nombre,
          cantidad: p.cantidad,
          precioSinIVA: p.precioSinIVA,
          codigoBarrasAutomatico: codigoBarrasLimpio.isNotEmpty,
          porcentajeDescuento: p.porcentajeDescuento,
        ));
      }

      setState(() {
        _empresaActual = empresa;
        _productosNuevos
          ..clear()
          ..addAll(nuevos);
        _productosConflicto
          ..clear()
          ..addAll(conflictos);
      });
    } catch (e) {
      setState(() => _errorMensaje = 'Error leyendo el archivo: $e');
    }
  }

  ProductoImport _toImport(XMLProductoData p) {
    return ProductoImport.create(
      codigo: p.codigo,
      codigoBarras: p.codigoBarras,
      nombre: p.nombre,
      cantidad: p.cantidad,
      precioSinIVA: p.precioSinIVA,
      codigoBarrasAutomatico: p.codigoBarras.isNotEmpty,
      tieneDescuento: p.tieneDescuento,
      porcentajeDescuento: p.porcentajeDescuento,
    );
  }

  Future<void> _guardarProductosNuevos() async {
    if (_empresaActual == null) return;
    final empresaId = _empresaActual!.id;
    if (empresaId == null) return;

    final productosACrear = _productosNuevos.map((p) {
      return Producto(
        empresaId: empresaId,
        codigoFactura: p.codigo,
        codigoBarras: p.codigoBarras,
        nombre: p.nombre,
        codigoDeBarrasAutomatico: p.codigoBarras.isNotEmpty,
        vieneEnPaquetes: p.vieneEnPaquetes,
        cantidadPaquetes: p.cantidadPaquetes,
        codigoInterno: p.codigoInterno,
      );
    }).toList();

    await ref.read(productoRepositoryProvider).createBatch(productosACrear);

    setState(() {
      _productosGuardados = productosACrear.length;
      _mostrarExito = true;
    });
  }

  void _reiniciar() {
    setState(() {
      _productosNuevos.clear();
      _productosConflicto.clear();
      _empresaActual = null;
      _mostrarExito = false;
      _productosGuardados = 0;
    });
    ref.read(selectedTabProvider.notifier).set(0);
  }
}
