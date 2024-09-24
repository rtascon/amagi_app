import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'user_service.dart';
import '../models/user.dart';
import '../config/enviroment.dart';
import 'dart:async';

/// Servicio de autenticación para manejar el inicio y cierre de sesión.
class AuthService {
  final String url = Environment.apiUrl;
  final String internalDbAuthSource = Environment.glpiInternalDbAuthSource;
  static final _storage = FlutterSecureStorage();
  static const _sessionTokenKey = 'session_token';

  /// Inicia sesión con el [username] y [password] proporcionados.
  /// 
  /// Si la autenticación es exitosa, almacena el token de sesión de forma segura
  /// y retorna la información del usuario.
  /// 
  /// Lanza una excepción si ocurre un error durante el proceso de inicio de sesión.
  Future<bool> logIn(String username, String password) async {
    final loginUrl = Uri.parse('$url/initSession');
    try {
      // Realiza la solicitud de inicio de sesión.
      var response = await http.post(
        loginUrl,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'login': username,
          'password': password,
          'auth': internalDbAuthSource
        }),
      ).timeout(Duration(seconds: 15));

      // Si la autenticación falla, intenta nuevamente sin el campo 'auth'.
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
        ).timeout(Duration(seconds: 15));

        // Si la autenticación es exitosa, almacena el token de sesión y se obtiene la información del usuario.
        if (response.statusCode == 200) {
          final responseBody = jsonDecode(response.body);
          await _storage.write(key: _sessionTokenKey, value: responseBody['session_token']);
          UserService userService = UserService();
          User usuario = User();
          return userService.getUserInfo(usuario);
        } else {
          throw Exception("Error al iniciar sesión: ${response.body}");
        }
      }

      // Si la autenticación es exitosa en el primer intento, almacena el token de sesión y se obtiene la información del usuario.
      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        await _storage.write(key: _sessionTokenKey, value: responseBody['session_token']);
        UserService userService = UserService();
        User usuario = User();
        return userService.getUserInfo(usuario);
      } else {
        throw Exception("Error al iniciar sesión: ${response.body}");
      }
    } on TimeoutException catch (e) {
      throw Exception("La solicitud ha excedido el tiempo de espera: $e");
    } catch (e) {
      throw Exception("Error al iniciar sesión: $e");
    }
  }

  /// Cierra la sesión del usuario actual.
  /// 
  /// Lanza una excepción si ocurre un error durante el proceso de cierre de sesión.
  Future<void> logOut() async {
    final sessionToken = await _storage.read(key: _sessionTokenKey);
    final logoutUrl = Uri.parse('$url/killSession');
    try {
      // Realiza la solicitud de cierre de sesión.
      final response = await http.post(
        logoutUrl,
        headers: <String, String>{
          'Session-Token': sessionToken!,
        },
      ).timeout(Duration(seconds: 15));

      // Si la solicitud de cierre de sesión falla, lanza una excepción.
      if (response.statusCode != 200) {
        throw Exception("Error al cerrar sesión: ${response.body}");
      }
    } on TimeoutException catch (e) {
      throw Exception("La solicitud ha excedido el tiempo de espera: $e");
    } catch (e) {
      throw Exception("Error al cerrar sesión: $e");
    }
  }
}