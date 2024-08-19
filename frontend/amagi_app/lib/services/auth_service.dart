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

  static Future<String?> get sessionToken async => await _storage.read(key: _sessionTokenKey);
}