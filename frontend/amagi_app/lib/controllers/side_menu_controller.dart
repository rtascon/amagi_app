import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';
import '../views/loading_screen.dart';
import '../models/user.dart'; 

/// Controlador para manejar las acciones del menú lateral.
class SideMenuController {
  final AuthService _authService = AuthService();
  final User _usuario = User();

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
      await prefs.remove('isLoggedIn');
      await prefs.remove('username');
      await prefs.remove('sessionToken');
      Navigator.of(context).pop(); 
      Navigator.of(context).pushReplacementNamed('/login'); // Redirige a la pantalla de inicio de sesión
    } catch (e) {
      Navigator.of(context).pop(); 
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
        builder: (BuildContext context) {
          return LoadingScreen();
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
    Navigator.of(context).pushNamed('/create-ticket');
  }

  /// Navega a la pantalla del menú principal.
  /// 
  /// Parámetros:
  /// - [context]: El contexto de la aplicación.
  void navigateToMainMenuScreen(BuildContext context) {
    Navigator.of(context).pushReplacementNamed('/mainMenu');
  }
}