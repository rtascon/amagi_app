import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import '../config/enviroment.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Servicio general para interactuar con la API de GLPI.
class GlpiGeneralService {
  final String url = Environment.apiUrl;
  static final _storage = FlutterSecureStorage();
  static const _sessionTokenKey = 'session_token';

  GlpiGeneralService();

  /// Obtiene el tipo de solicitud desde la API.
  /// 
  /// Lanza una excepción si no se encuentra el token de sesión o si ocurre un error durante la solicitud.
  Future<List<dynamic>> getRequestType() async {
    final sessionToken = await _storage.read(key: _sessionTokenKey);
    if (sessionToken == null) {
      throw Exception("No session token found");
    }
    final headers = {
      'Session-Token': sessionToken,
    };

    try {
      final response = await http
          .get(Uri.parse('$url/RequestType'), headers: headers)
          .timeout(Duration(seconds: 15)); // Configurar el tiempo de espera a 15 segundos

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Error al cargar el tipo de solicitud');
      }
    } on TimeoutException catch (e) {
      throw Exception("La solicitud ha excedido el tiempo de espera: $e");
    } catch (e) {
      throw Exception("Error al cargar el tipo de solicitud: $e");
    }
  }

  /// Obtiene las entidades del usuario desde la API.
  /// 
  /// Lanza una excepción si no se encuentra el token de sesión o si ocurre un error durante la solicitud.
  Future<Map<String, dynamic>> getMyEntities() async {
    final sessionToken = await _storage.read(key: _sessionTokenKey);
    if (sessionToken == null) {
      throw Exception("No session token found");
    }
    final headers = {
      'Session-Token': sessionToken,
    };

    try {
      final response = await http
          .get(Uri.parse('$url/getMyEntities'), headers: headers)
          .timeout(Duration(seconds: 15)); // Configurar el tiempo de espera a 15 segundos

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Error al obtener mis entidades');
      }
    } on TimeoutException catch (e) {
      throw Exception("La solicitud ha excedido el tiempo de espera: $e");
    } catch (e) {
      throw Exception("Error al obtener mis entidades: $e");
    }
  }

  /// Cambia la entidad activa del usuario en la API.
  /// 
  /// Lanza una excepción si no se encuentra el token de sesión o si ocurre un error durante la solicitud.
  Future<void> changeActiveEntity(int entityId) async {
    final sessionToken = await _storage.read(key: _sessionTokenKey);
    if (sessionToken == null) {
      throw Exception("No session token found");
    }
    final headers = {
      'Session-Token': sessionToken,
      'Content-Type': 'application/json',
    };
    final body = json.encode({
      'entities_id': entityId,
      "is_recursive": true,
    });

    try {
      final response = await http
          .post(Uri.parse('$url/changeActiveEntities'), headers: headers, body: body)
          .timeout(Duration(seconds: 15)); // Configurar el tiempo de espera a 15 segundos

      if (response.statusCode != 200) {
        throw Exception('Error al cambiar la entidad activa');
      }
    } on TimeoutException catch (e) {
      throw Exception("La solicitud ha excedido el tiempo de espera: $e");
    } catch (e) {
      throw Exception("Error al cambiar la entidad activa: $e");
    }
  }
}