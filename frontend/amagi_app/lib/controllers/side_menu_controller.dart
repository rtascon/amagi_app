import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';
import '../views/loading_screen.dart';
import '../models/user.dart';
import 'dart:async';
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import '../config/environment.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../views/common_pop_ups.dart';
import 'dart:io';

/// Controlador para manejar las acciones del menú lateral.
class SideMenuController {
  final AuthService _authService = AuthService();
  final User _usuario = User();
  static const _storage = FlutterSecureStorage();
  static const _sessionTokenKey = 'session_token';
  final String url = Environment.apiUrl;

  /// Cierra la sesión del usuario.
  ///
  /// Parámetros:
  /// - [context]: El contexto de la aplicación.
  ///
  /// Muestra una pantalla de carga mientras se realiza el cierre de sesión.
  /// Si el cierre de sesión es exitoso, elimina las preferencias de sesión y redirige a la pantalla de inicio de sesión.
  /// Si ocurre un error, muestra un mensaje de error.
  void logOut(BuildContext context) async {
    _showLoadingScreen(context);

    try {
      await _authService.logOut();
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      await _storage.delete(key: _sessionTokenKey);
      if (!context.mounted) return;
      Navigator.of(context, rootNavigator: true)
          .pop(); // cerrar loading en root
      Navigator.of(context, rootNavigator: true).pushReplacementNamed('/login');
    } catch (e) {
      if (!context.mounted) return;
      Navigator.of(context, rootNavigator: true)
          .pop(); // cerrar loading en root
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cerrar sesión: $e')),
      );
    }
  }

  /// Muestra una pantalla de carga.
  ///
  /// Parámetros:
  /// - [context]: El contexto de la aplicación.
  void _showLoadingScreen(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showDialog(
        context: context,
        barrierDismissible: false,
        useRootNavigator: true, // asegurar root
        builder: (BuildContext context) {
          return const LoadingScreen();
        },
      );
    });
  }

  /// Obtiene el nombre del usuario.
  ///
  /// Retorna un mapa con el nombre completo y el nombre de usuario.
  Future<Map<String, String>> getUserName() async {
    return {
      'glpifriendlyname': _usuario.nombreCompleto,
      'glpiname': _usuario.nombreUsuario,
    };
  }

  /// Navega a la pantalla de creación de tickets.
  ///
  /// Parámetros:
  /// - [context]: El contexto de la aplicación.
  void navigateToCreateTicketScreen(BuildContext context) {
    Navigator.of(context, rootNavigator: true).pushNamed('/create-ticket');
  }

  /// Navega a la pantalla del menú principal.
  ///
  /// Parámetros:
  /// - [context]: El contexto de la aplicación.
  void navigateToMainMenuScreen(BuildContext context) {
    Navigator.of(context, rootNavigator: true)
        .pushReplacementNamed('/mainMenu');
  }

  /// Obtiene el perfil del usuario.
  ///
  /// Retorna un mapa con la información del perfil del usuario.
  Future<Map<String, dynamic>> getUserProfile({BuildContext? context}) async {
    final sessionToken = await _storage.read(key: _sessionTokenKey);
    final userUrl = Uri.parse('$url/getFullSession');

    // Chequeo previo de conectividad -> muestra "sin internet" y aborta
    final connectivity = await Connectivity().checkConnectivity();
    if (connectivity == ConnectivityResult.none) {
      if (context != null) showNoInternetMessage(context);
      throw const SocketException('No Internet connection');
    }

    try {
      final response = await http.get(
        userUrl,
        headers: <String, String>{
          'Session-Token': sessionToken!,
          'Content-Type': 'application/json',
        },
      ).timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          if (context != null) showTimeoutMessage(context);
          throw TimeoutException("Solicitud cancelada por timeout");
        },
      );

      if (response.statusCode == 200 || response.statusCode == 206) {
        final userInfo = jsonDecode(response.body);
        return {
          'glpifriendlyname': userInfo['session']['glpifriendlyname'] ?? '',
          'glpiname': userInfo['session']['glpiname'] ?? '',
          'glpiactiveprofile':
              userInfo['session']['glpiactiveprofile']['name'] ?? '',
          'glpiactive_entity_name':
              userInfo['session']['glpiactive_entity_name'] ?? '',
          'glpiactive_entity': userInfo['session']['glpiactive_entity'] ?? 0,
        };
      } else {
        throw Exception(
            "Error al obtener el perfil del usuario: ${response.body}");
      }
    } on SocketException {
      if (context != null)
        showTimeoutMessage(context); // conexión cayó en medio
      throw Exception("Conexión interrumpida durante la solicitud");
    } on TimeoutException catch (e) {
      // ya se mostró el popup en onTimeout
      throw Exception("La solicitud ha excedido el tiempo de espera: $e");
    } catch (e) {
      throw Exception("Error al obtener el perfil del usuario: $e");
    }
  }
}
