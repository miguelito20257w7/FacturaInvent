// URL del servidor configurable en caliente, persistida en SharedPreferences.
// Equivalente a ServerConfig.swift de la app iOS.

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

enum EstadoConexion { desconocido, probando, conectado, sinConexion }

class ServerConfig {
  ServerConfig._();
  static final ServerConfig shared = ServerConfig._();

  static const _claveUrl = 'servidor.url';
  static const _claveConfigurado = 'servidor.configurado';

  String urlServidor = 'http://localhost:8000';
  bool configurado = false;
  EstadoConexion estado = EstadoConexion.desconocido;

  Future<void> cargar() async {
    final prefs = await SharedPreferences.getInstance();
    urlServidor = prefs.getString(_claveUrl) ?? 'http://localhost:8000';
    configurado = prefs.getBool(_claveConfigurado) ?? false;
  }

  Future<void> guardar({String? url, bool? marcarConfigurado}) async {
    final prefs = await SharedPreferences.getInstance();
    if (url != null) {
      urlServidor = url;
      await prefs.setString(_claveUrl, url);
    }
    if (marcarConfigurado != null) {
      configurado = marcarConfigurado;
      await prefs.setBool(_claveConfigurado, marcarConfigurado);
    }
  }

  Uri get baseUri {
    var texto = urlServidor.trim();
    while (texto.endsWith('/')) {
      texto = texto.substring(0, texto.length - 1);
    }
    if (!texto.startsWith('http://') && !texto.startsWith('https://')) {
      texto = 'http://$texto';
    }
    return Uri.parse(texto);
  }

  /// Ping a GET /health (sin auth).
  Future<bool> probarConexion() async {
    estado = EstadoConexion.probando;
    try {
      final respuesta = await http
          .get(baseUri.replace(path: '/health'))
          .timeout(const Duration(seconds: 5));
      estado = respuesta.statusCode == 200
          ? EstadoConexion.conectado
          : EstadoConexion.sinConexion;
    } catch (_) {
      estado = EstadoConexion.sinConexion;
    }
    return estado == EstadoConexion.conectado;
  }
}
