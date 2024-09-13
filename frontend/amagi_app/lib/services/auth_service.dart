import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'user_service.dart';
import '../models/user.dart';
import '../config/enviroment.dart';

class AuthService {
  final String url = Environment.apiUrl;
  final String internalDbAuthSource = Environment.glpiInternalDbAuthSource;
  static final _storage = FlutterSecureStorage();
  static const _sessionTokenKey = 'session_token';

  Future<bool> iniciarSesion(String username, String password) async {
    final loginUrl = Uri.parse('$url/initSession');
    var response = await http.post(
      loginUrl,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'login': username,
        'password': password,
        'auth':internalDbAuthSource
      }),
    );

    if (response.statusCode == 401) {
      response = await http.post(
        loginUrl,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'login': username,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        await _storage.write(key: _sessionTokenKey, value: responseBody['session_token']);
        UserService userService = UserService();
        User usuario = User();
        return userService.obtenerUsuarioInfo(usuario);
        
      } else {
        throw Exception("Error al iniciar sesion: ${response.body}");
      }
    }

    if (response.statusCode == 200) {
      final responseBody = jsonDecode(response.body);
      await _storage.write(key: _sessionTokenKey, value: responseBody['session_token']);
      UserService userService = UserService();
      User usuario = User();
      return userService.obtenerUsuarioInfo(usuario);
      
    } else {
      throw Exception("Error al iniciar sesion: ${response.body}");
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
}