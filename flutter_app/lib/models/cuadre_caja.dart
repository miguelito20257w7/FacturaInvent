import 'package:intl/intl.dart';

/// Denominaciones COP de mayor a menor, con su nombre de campo en la API.
const denominaciones = <MapEntry<String, int>>[
  MapEntry('billetes_20000', 20000),
  MapEntry('billetes_10000', 10000),
  MapEntry('billetes_5000', 5000),
  MapEntry('billetes_2000', 2000),
  MapEntry('billetes_1000', 1000),
  MapEntry('monedas_500', 500),
  MapEntry('monedas_200', 200),
  MapEntry('monedas_100', 100),
  MapEntry('monedas_50', 50),
];

const jornadas = ['MAÑANA', 'TARDE', 'TODO EL DIA'];

final _formatoPesos = NumberFormat('#,##0', 'es_CO');

/// "$ 1.234.567" — valores COP sin decimales.
String pesos(int valor) => '\$ ${_formatoPesos.format(valor)}';

class CuadreCaja {
  CuadreCaja({
    required this.id,
    required this.numeroTurno,
    required this.fecha,
    required this.hora,
    required this.jornada,
    required this.ventasNetas,
    required this.entregas,
    required this.tarjetas,
    required this.bonos,
    required this.nequiQr,
    required this.factElectronicaCredito,
    required this.baseDelDia,
    required this.baseAnterior,
    required this.cantidades,
    required this.totalDenominaciones,
    required this.sobranteFaltante,
    this.usuarioNombre,
  });

  final int id;
  final int numeroTurno;
  final String fecha;
  final String hora;
  final String? usuarioNombre;
  final String jornada;
  final int ventasNetas;
  final int entregas;
  final int tarjetas;
  final int bonos;
  final int nequiQr;
  final int factElectronicaCredito;
  final int baseDelDia;
  final int baseAnterior;

  /// campo de la API ("billetes_20000") → cantidad contada
  final Map<String, int> cantidades;
  final int totalDenominaciones;
  final int sobranteFaltante;

  factory CuadreCaja.fromJson(Map<String, dynamic> json) => CuadreCaja(
        id: json['id'] as int,
        numeroTurno: json['numero_turno'] as int,
        fecha: json['fecha'] as String,
        hora: json['hora'] as String,
        usuarioNombre: json['usuario_nombre'] as String?,
        jornada: json['jornada'] as String,
        ventasNetas: json['ventas_netas'] as int,
        entregas: json['entregas'] as int,
        tarjetas: json['tarjetas'] as int,
        bonos: json['bonos'] as int,
        nequiQr: json['nequi_qr'] as int,
        factElectronicaCredito: json['fact_electronica_credito'] as int,
        baseDelDia: json['base_del_dia'] as int,
        baseAnterior: json['base_anterior'] as int,
        cantidades: {
          for (final denominacion in denominaciones)
            denominacion.key: json[denominacion.key] as int? ?? 0,
        },
        totalDenominaciones: json['total_denominaciones'] as int,
        sobranteFaltante: json['sobrante_faltante'] as int,
      );
}
