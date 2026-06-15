// Cliente HTTP base: JWT + envelope { data, error }.
// Equivalente a APIClient.swift de la app iOS.

import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/usuario.dart';
import 'server_config.dart';

class APIException implements Exception {
  APIException(this.mensaje, {this.sinConexion = false, this.noAutenticado = false});
  final String mensaje;
  final bool sinConexion;
  final bool noAutenticado;

  @override
  String toString() => mensaje;
}

class APIClient {
  APIClient._();
  static final APIClient shared = APIClient._();

  static const _claveToken = 'api.token';
  static const _claveUsuario = 'api.usuario';

  String? token;
  Usuario? usuarioActual;

  bool get sesionActiva => token != null;

  Future<void> cargar() async {
    final prefs = await SharedPreferences.getInstance();
    token = prefs.getString(_claveToken);
    final usuarioJson = prefs.getString(_claveUsuario);
    if (usuarioJson != null) {
      usuarioActual = Usuario.fromJson(jsonDecode(usuarioJson));
    }
  }

  Future<void> login(String username, String password) async {
    final data = await post(
      'auth/login',
      body: {'username': username, 'password': password},
      autenticado: false,
    );
    token = data['token'] as String;
    usuarioActual = Usuario.fromJson(data['usuario']);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_claveToken, token!);
    await prefs.setString(_claveUsuario, jsonEncode(data['usuario']));
  }

  Future<void> logout() async {
    token = null;
    usuarioActual = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_claveToken);
    await prefs.remove(_claveUsuario);
  }

  Future<dynamic> get(String path, {Map<String, String>? query}) =>
      _request('GET', path, query: query);

  Future<dynamic> post(String path, {Object? body, bool autenticado = true}) =>
      _request('POST', path, body: body, autenticado: autenticado);

  Future<dynamic> put(String path, {Object? body}) =>
      _request('PUT', path, body: body);

  Future<dynamic> delete(String path) => _request('DELETE', path);

  /// Descarga un archivo binario (ej. export .xlsx) y retorna los bytes.
  Future<List<int>> descargarArchivo(String path, {Map<String, String>? query}) async {
    final uri = _uri(path, query);
    final respuesta = await http.get(uri, headers: _headers(autenticado: true));
    if (respuesta.statusCode != 200) {
      throw APIException('Error ${respuesta.statusCode} al descargar');
    }
    return respuesta.bodyBytes;
  }

  Uri _uri(String path, Map<String, String>? query) {
    final base = ServerConfig.shared.baseUri;
    return base.replace(path: '/$path', queryParameters: query);
  }

  Map<String, String> _headers({required bool autenticado}) {
    final headers = {'Content-Type': 'application/json'};
    if (autenticado && token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  Future<dynamic> _request(
    String method,
    String path, {
    Map<String, String>? query,
    Object? body,
    bool autenticado = true,
  }) async {
    if (autenticado && token == null) {
      throw APIException('La sesión expiró, inicia sesión de nuevo', noAutenticado: true);
    }

    final uri = _uri(path, query);
    final request = http.Request(method, uri);
    request.headers.addAll(_headers(autenticado: autenticado));
    if (body != null) {
      request.body = jsonEncode(body);
    }

    http.Response respuesta;
    try {
      final streamed = await request.send().timeout(const Duration(seconds: 15));
      respuesta = await http.Response.fromStream(streamed);
    } catch (e) {
      throw APIException('Sin conexión con el servidor: $e', sinConexion: true);
    }

    if (respuesta.statusCode == 401 && autenticado) {
      await logout();
      throw APIException('La sesión expiró, inicia sesión de nuevo', noAutenticado: true);
    }

    final Map<String, dynamic> envelope;
    try {
      envelope = jsonDecode(utf8.decode(respuesta.bodyBytes));
    } catch (_) {
      throw APIException('El servidor devolvió una respuesta inesperada');
    }

    if (envelope['error'] != null) {
      throw APIException(envelope['error'] as String);
    }
    return envelope['data'];
  }
}
