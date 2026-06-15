import 'package:flutter/material.dart';

import '../api/api_client.dart';
import '../models/cuadre_caja.dart';

class HistorialScreen extends StatefulWidget {
  const HistorialScreen({super.key});

  @override
  State<HistorialScreen> createState() => _HistorialScreenState();
}

class _HistorialScreenState extends State<HistorialScreen> {
  List<CuadreCaja> _cuadres = [];
  bool _cargando = true;
  String? _error;
  String _usuarioFiltro = '';

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
      final data = await APIClient.shared.get('cuadres', query: {
        'limit': '200',
        if (_usuarioFiltro.isNotEmpty) 'usuario': _usuarioFiltro,
      }) as List<dynamic>;
      setState(() => _cuadres = [for (final json in data) CuadreCaja.fromJson(json)]);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_cargando && _cuadres.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null && _cuadres.isEmpty) {
      return Center(child: Text(_error!));
    }
    return Column(children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
        child: TextField(
          decoration: const InputDecoration(
            labelText: 'Filtrar por usuario',
            prefixIcon: Icon(Icons.filter_alt),
            border: OutlineInputBorder(),
            isDense: true,
          ),
          onSubmitted: (texto) {
            _usuarioFiltro = texto;
            _cargar();
          },
        ),
      ),
      Expanded(
        child: RefreshIndicator(
          onRefresh: _cargar,
          child: ListView.separated(
            itemCount: _cuadres.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, indice) {
              final cuadre = _cuadres[indice];
              final positivo = cuadre.sobranteFaltante >= 0;
              return ListTile(
                title: Text('Turno ${cuadre.numeroTurno}'),
                subtitle: Text(
                    '${cuadre.usuarioNombre ?? "—"} · ${cuadre.jornada} · ${cuadre.fecha}'),
                trailing: Text(
                  pesos(cuadre.sobranteFaltante),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: positivo ? Colors.green.shade700 : Colors.red.shade700,
                  ),
                ),
                onTap: () => _mostrarDetalle(cuadre),
              );
            },
          ),
        ),
      ),
    ]);
  }

  void _mostrarDetalle(CuadreCaja cuadre) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (_) => ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Turno ${cuadre.numeroTurno}',
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          _fila('Fecha', '${cuadre.fecha} ${cuadre.hora}'),
          _fila('Usuario', cuadre.usuarioNombre ?? '—'),
          _fila('Jornada', cuadre.jornada),
          const Divider(),
          _fila('Ventas netas', pesos(cuadre.ventasNetas)),
          _fila('Entregas', pesos(cuadre.entregas)),
          _fila('Tarjetas', pesos(cuadre.tarjetas)),
          _fila('Bonos', pesos(cuadre.bonos)),
          _fila('Nequi o QR', pesos(cuadre.nequiQr)),
          _fila('Fact. crédito', pesos(cuadre.factElectronicaCredito)),
          _fila('Base del día', pesos(cuadre.baseDelDia)),
          _fila('Base anterior', pesos(cuadre.baseAnterior)),
          _fila('Total denominaciones', pesos(cuadre.totalDenominaciones)),
          const Divider(),
          _fila(
            cuadre.sobranteFaltante >= 0 ? 'SOBRANTE' : 'FALTANTE',
            pesos(cuadre.sobranteFaltante),
          ),
        ],
      ),
    );
  }

  Widget _fila(String etiqueta, String valor) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(children: [Text(etiqueta), const Spacer(), Text(valor)]),
      );
}
