import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'user_service.dart';
import '../models/user.dart';
import '../config/environment.dart';
import 'dart:async';
import '../controllers/side_menu_controller.dart';

/// Servicio de autenticación para manejar el inicio y cierre de sesión.
class AuthService {
  final String url = Environment.apiUrl;
  final String internalDbAuthSource = Environment.glpiInternalDbAuthSource;
  static const _storage = FlutterSecureStorage();
  static const _sessionTokenKey = 'session_token';

  /// Inicia sesión con el [username] y [password] proporcionados.
  ///
  /// Si la autenticación es exitosa, almacena el token de sesión de forma segura
  /// y retorna la información del usuario.
  ///
  /// Lanza una excepción si ocurre un error durante el proceso de inicio de sesión.
  Future<bool> login(String username, String password) async {
    final loginUrl = Uri.parse('$url/initSession');
    try {
      var response = await http
          .post(
            loginUrl,
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
            },
            body: jsonEncode(<String, String>{
              'login': username,
              'password': password,
            }),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 401) {
        response = await http
            .post(
              loginUrl,
              headers: <String, String>{
                'Content-Type': 'application/json; charset=UTF-8',
              },
              body: jsonEncode(<String, String>{
                'login': username,
                'password': password,
              }),
            )
            .timeout(const Duration(seconds: 15));

        if (response.statusCode == 200) {
          final responseBody = jsonDecode(response.body);
          await _storage.write(
              key: _sessionTokenKey, value: responseBody['session_token']);
          UserService userService = UserService();
          User usuario = User();
          final success = await userService.getUserInfo(usuario);

          final sideMenuController = SideMenuController();
          final userProfile = await sideMenuController.getUserProfile();
          SharedPreferences prefs = await SharedPreferences.getInstance();
          userProfile.forEach((key, value) {
            prefs.setString(key, value.toString());
          });
          // userId centralizado ahora en UserService
          await UserService().getCachedOrFetchUserId();
          return success;
        } else {
          throw Exception("Error al iniciar sesión: ${response.body}");
        }
      }

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        await _storage.write(
            key: _sessionTokenKey, value: responseBody['session_token']);
        UserService userService = UserService();
        User usuario = User();
        final success = await userService.getUserInfo(usuario);

        final sideMenuController = SideMenuController();
        final userProfile = await sideMenuController.getUserProfile();
        SharedPreferences prefs = await SharedPreferences.getInstance();
        userProfile.forEach((key, value) {
          prefs.setString(key, value.toString());
        });
        await UserService().getCachedOrFetchUserId();
        return success;
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
      final response = await http.post(
        logoutUrl,
        headers: <String, String>{
          'Session-Token': sessionToken!,
        },
      ).timeout(const Duration(seconds: 15));

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
