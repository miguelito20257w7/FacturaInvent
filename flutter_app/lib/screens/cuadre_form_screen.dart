import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../api/api_client.dart';
import '../models/cuadre_caja.dart';

class CuadreFormScreen extends StatefulWidget {
  const CuadreFormScreen({super.key});

  @override
  State<CuadreFormScreen> createState() => _CuadreFormScreenState();
}

class _CuadreFormScreenState extends State<CuadreFormScreen> {
  int? _numeroTurno;
  int _baseAnterior = 0;
  String _jornada = jornadas.first;
  bool _sinConexion = false;
  bool _guardando = false;

  final _valores = <String, int>{
    'ventas_netas': 0,
    'entregas': 0,
    'tarjetas': 0,
    'bonos': 0,
    'nequi_qr': 0,
    'fact_electronica_credito': 0,
    'base_del_dia': 0,
  };
  final _cantidades = <String, int>{for (final d in denominaciones) d.key: 0};

  static const _etiquetas = {
    'ventas_netas': 'Ventas netas',
    'entregas': 'Entregas',
    'tarjetas': 'Tarjetas',
    'bonos': 'Bonos',
    'nequi_qr': 'Nequi o QR',
    'fact_electronica_credito': 'Fact. electrónica crédito',
    'base_del_dia': 'Base del día',
  };

  int get _totalDenominaciones => denominaciones.fold(
      0, (suma, d) => suma + d.value * (_cantidades[d.key] ?? 0));

  /// Fórmula verificada contra el Excel original (1010 cuadres).
  int get _sobranteFaltante =>
      _valores['base_del_dia']! +
      _valores['entregas']! +
      _valores['tarjetas']! +
      _valores['bonos']! +
      _valores['nequi_qr']! +
      _valores['fact_electronica_credito']! -
      _valores['ventas_netas']! -
      _baseAnterior;

  @override
  void initState() {
    super.initState();
    _cargarNuevoTurno();
  }

  Future<void> _cargarNuevoTurno() async {
    try {
      final data = await APIClient.shared.get('cuadres/nuevo-turno');
      setState(() {
        _numeroTurno = data['numero_turno'] as int;
        _baseAnterior = data['base_anterior'] as int;
        _sinConexion = false;
      });
    } catch (_) {
      setState(() => _sinConexion = true);
    }
  }

  Future<void> _guardar() async {
    setState(() => _guardando = true);
    final ahora = DateTime.now();
    final body = {
      if (!_sinConexion) 'numero_turno': _numeroTurno,
      'fecha':
          '${ahora.year}-${ahora.month.toString().padLeft(2, '0')}-${ahora.day.toString().padLeft(2, '0')}',
      'hora':
          '${ahora.hour.toString().padLeft(2, '0')}:${ahora.minute.toString().padLeft(2, '0')}:00',
      'jornada': _jornada,
      ..._valores,
      if (!_sinConexion) 'base_anterior': _baseAnterior,
      ..._cantidades,
    };
    try {
      final data = await APIClient.shared.post('cuadres', body: body);
      final registrado = CuadreCaja.fromJson(data);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
            'Turno ${registrado.numeroTurno} registrado — ${registrado.sobranteFaltante >= 0 ? "Sobrante" : "Faltante"}: ${pesos(registrado.sobranteFaltante.abs())}'),
      ));
      _limpiar();
      await _cargarNuevoTurno();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  void _limpiar() {
    setState(() {
      _valores.updateAll((_, __) => 0);
      _cantidades.updateAll((_, __) => 0);
      _jornada = jornadas.first;
    });
  }

  @override
  Widget build(BuildContext context) {
    final sobrante = _sobranteFaltante;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(children: [
              _filaDato('Turno', _numeroTurno?.toString() ?? '…'),
              _filaDato('Cajero', APIClient.shared.usuarioActual?.nombre ?? '—'),
              Row(children: [
                const Text('Jornada'),
                const Spacer(),
                DropdownButton<String>(
                  value: _jornada,
                  items: [
                    for (final jornada in jornadas)
                      DropdownMenuItem(value: jornada, child: Text(jornada)),
                  ],
                  onChanged: (valor) => setState(() => _jornada = valor!),
                ),
              ]),
              if (_sinConexion)
                const Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: Text('Sin conexión con el servidor',
                      style: TextStyle(color: Colors.orange)),
                ),
            ]),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(children: [
              for (final campo in _valores.keys)
                _CampoPesos(
                  etiqueta: _etiquetas[campo]!,
                  onCambio: (valor) => setState(() => _valores[campo] = valor),
                ),
              _filaDato('Base anterior', pesos(_baseAnterior)),
            ]),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(children: [
              for (final denominacion in denominaciones)
                Row(children: [
                  SizedBox(width: 90, child: Text(pesos(denominacion.value))),
                  Expanded(
                    child: TextField(
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      textAlign: TextAlign.right,
                      decoration: const InputDecoration(hintText: '0'),
                      onChanged: (texto) => setState(() =>
                          _cantidades[denominacion.key] = int.tryParse(texto) ?? 0),
                    ),
                  ),
                  SizedBox(
                    width: 110,
                    child: Text(
                      pesos(denominacion.value * (_cantidades[denominacion.key] ?? 0)),
                      textAlign: TextAlign.right,
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ),
                ]),
              const Divider(),
              _filaDato('Total base', pesos(_totalDenominaciones), negrita: true),
            ]),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          color: sobrante >= 0 ? Colors.green.shade50 : Colors.red.shade50,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(children: [
              Text(sobrante >= 0 ? 'SOBRANTE' : 'FALTANTE',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
              Text(
                pesos(sobrante),
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                  color: sobrante >= 0 ? Colors.green.shade700 : Colors.red.shade700,
                ),
              ),
            ]),
          ),
        ),
        const SizedBox(height: 12),
        FilledButton(
          onPressed: _guardando ? null : _guardar,
          child: _guardando
              ? const SizedBox(
                  width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
              : const Text('Registrar cuadre'),
        ),
      ],
    );
  }

  Widget _filaDato(String etiqueta, String valor, {bool negrita = false}) {
    final estilo = negrita ? const TextStyle(fontWeight: FontWeight.bold) : null;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(children: [
        Text(etiqueta, style: estilo),
        const Spacer(),
        Text(valor, style: estilo),
      ]),
    );
  }
}

class _CampoPesos extends StatelessWidget {
  const _CampoPesos({required this.etiqueta, required this.onCambio});
  final String etiqueta;
  final ValueChanged<int> onCambio;

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Expanded(child: Text(etiqueta)),
      SizedBox(
        width: 150,
        child: TextField(
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          textAlign: TextAlign.right,
          decoration: const InputDecoration(hintText: '\$ 0'),
          onChanged: (texto) => onCambio(int.tryParse(texto) ?? 0),
        ),
      ),
    ]);
  }
}
