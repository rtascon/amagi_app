import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  final String url = 'http://172.20.1.55/soportegiades/apirest.php';
  static final _storage = FlutterSecureStorage();
  static const _sessionTokenKey = 'session_token';

  Future<bool> iniciarSesion(String username, String password) async {
    final loginUrl = Uri.parse('$url/initSession');
    //PRUEBA DE CONEXION
    print('loginUrl: $loginUrl');
    print('username: $username');
    print('password: $password');
    final response = await http.post(
      loginUrl,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'login': username,
        'password': password,
      }),
    );

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');
    
    if (response.statusCode == 200) {
      final responseBody = jsonDecode(response.body);
      await _storage.write(key: _sessionTokenKey, value: responseBody['session_token']);
      return true;
    } else {
      throw Exception("Error al iniciar sesion: ${response.body}");
    }
  }

  Future<Map<String, dynamic>> obtenerUsuarioInfo() async {
    final sessionToken = await _storage.read(key: _sessionTokenKey);
    final userUrl = Uri.parse('$url/getFullSession');
    final response = await http.get(
      userUrl,
      headers: <String, String>{
        'Session-Token': sessionToken!,
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200 || response.statusCode == 206) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Error al obtener informacion del usuario: ${response.body}");
    }
  }

  Future<Map<String, dynamic>> obtenerPermisos(int idPerfil) async {
    final sessionToken = await _storage.read(key: _sessionTokenKey);
    final userUrl = Uri.parse('$url/Profile/$idPerfil/getActiveProfile');
    final response = await http.get(
      userUrl,
      headers: <String, String>{
        'Session-Token': sessionToken!,
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200 || response.statusCode == 206) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Error al obtener permisos: ${response.body}");
    }
  }

  Future<void> cerrarSesion() async {
    final sessionToken = await _storage.read(key: _sessionTokenKey);
    final logoutUrl = Uri.parse('$url/killSession');
    final response = await http.post(
      logoutUrl,
      headers: <String, String>{
        'Session-Token': sessionToken!,
      },
    );

    if (response.statusCode != 200) {
      throw Exception("Error al cerrar sesión: ${response.body}");
    }
  }

  Future<List<dynamic>> obtenerTicketsUsuario(int userId) async {
  final sessionToken = await _storage.read(key: _sessionTokenKey);
  if (sessionToken == null) {
    throw Exception("No session token found");
  }

  final ticketsUrl = Uri.parse('$url/search/Ticket');
  final headers = {
    'Session-Token': sessionToken,
    'Content-Type': 'application/json',
  };
  final params = {
    'criteria[0][field]': '4',  // 5 es el campo para el ID del solicitante (requester)
    'criteria[0][searchtype]': 'equals',
    'criteria[0][value]': userId.toString(),
    'criteria[1][link]': 'AND NOT',
    'criteria[1][field]': '12', 
    'criteria[1][searchtype]': 'equals',
    'criteria[1][value]': '6',  // 6 es el estado de los tickets cerrados
    'criteria[2][link]': 'AND NOT',
    'criteria[2][field]': '12', 
    'criteria[2][searchtype]': 'equals',
    'criteria[2][value]': '5',  // es el estado de los tickets resueltos
    'forcedisplay[0]': '2',  // ID del ticket
    'forcedisplay[1]': '1',  // Nombre del ticket
    'forcedisplay[2]': '21',  // Descripción del ticket
    'forcedisplay[3]': '12',  // Estado del ticket
    'forcedisplay[4]': '15',  // Fecha de creación
    'forcedisplay[5]': '19',  // Fecha de actualización
    'forcedisplay[6]': '80',  // Nombre de entidad asociada
    'forcedisplay[7]': '3',  // prioridad
    'forcedisplay[8]': '14',  // tipo
  };

  final response = await http.get(ticketsUrl.replace(queryParameters: params), headers: headers);

  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    throw Exception("Error al obtener tickets del usuario: ${response.body}");
  }
  }

  Future<List<Map<String, dynamic>>> obtenerPerfiles() async {
    final sessionToken = await _storage.read(key: _sessionTokenKey);
    final profilesUrl = Uri.parse('$url/getMyProfiles');
    final response = await http.get(
      profilesUrl,
      headers: <String, String>{
        'Session-Token': sessionToken!,
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200 || response.statusCode == 206) {
      final responseBody = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(responseBody['myprofiles']);
    } else {
      throw Exception("Error al obtener perfiles: ${response.body}");
    }
  }

  static Future<String?> get sessionToken async => await _storage.read(key: _sessionTokenKey);
}