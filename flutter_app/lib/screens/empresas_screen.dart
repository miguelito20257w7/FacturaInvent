import 'package:flutter/material.dart';

import '../api/api_client.dart';
import '../models/cuadre_caja.dart' show pesos;
import '../models/empresa.dart';
import '../models/producto.dart';

class EmpresasScreen extends StatefulWidget {
  const EmpresasScreen({super.key});

  @override
  State<EmpresasScreen> createState() => _EmpresasScreenState();
}

class _EmpresasScreenState extends State<EmpresasScreen> {
  List<Empresa> _empresas = [];
  bool _cargando = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    setState(() {
      _cargando = true;
      _error = null;
    });
    try {
      final data = await APIClient.shared.get('empresas') as List<dynamic>;
      setState(() => _empresas = [for (final json in data) Empresa.fromJson(json)]);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_cargando && _empresas.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null && _empresas.isEmpty) {
      return Center(child: Text(_error!));
    }
    return RefreshIndicator(
      onRefresh: _cargar,
      child: ListView.separated(
        itemCount: _empresas.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, indice) {
          final empresa = _empresas[indice];
          return ListTile(
            title: Text(empresa.nombre),
            subtitle: Text('NIT: ${empresa.nit}'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => ProductosScreen(empresa: empresa)),
            ),
          );
        },
      ),
    );
  }
}

class ProductosScreen extends StatefulWidget {
  const ProductosScreen({super.key, required this.empresa});
  final Empresa empresa;

  @override
  State<ProductosScreen> createState() => _ProductosScreenState();
}

class _ProductosScreenState extends State<ProductosScreen> {
  List<Producto> _productos = [];
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    try {
      final data = await APIClient.shared
          .get('empresas/${widget.empresa.id}/productos') as List<dynamic>;
      setState(() => _productos = [for (final json in data) Producto.fromJson(json)]);
    } catch (_) {
      // se muestra la lista vacía
    } finally {
      setState(() => _cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.empresa.nombre)),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : ListView.separated(
              itemCount: _productos.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, indice) {
                final producto = _productos[indice];
                return ListTile(
                  title: Text(producto.nombre),
                  subtitle: Text(producto.codigoFactura ?? ''),
                  trailing: Text('${pesos(producto.precio)} × ${producto.cantidadProductos}'),
                );
              },
            ),
    );
  }
}
