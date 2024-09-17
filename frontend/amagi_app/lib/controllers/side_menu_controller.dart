import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';
import '../views/loading_screen.dart';
import '../models/user.dart'; 

class SideMenuController {
  final AuthService _authService = AuthService();
  final User _usuario = User();

  void cerrarSesion(BuildContext context) async {
    _showLoadingScreen(context);

    try {
      await _authService.cerrarSesion();
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove('isLoggedIn');
      await prefs.remove('username');
      Navigator.of(context).pop(); // Oculta la pantalla de carga
      Navigator.of(context).pushReplacementNamed('/login'); // Redirige a la pantalla de inicio de sesión
    } catch (e) {
      Navigator.of(context).pop(); // Oculta la pantalla de carga
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cerrar sesión: $e')),
      );
    }
  }

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

  Future<Map<String, String>> getUserName() async {
    return {
      'glpifriendlyname': _usuario.nombreCompleto,
      'glpiname': _usuario.nombreUsuario,
    };
  }

  void navigateToCreateTicketScreen(BuildContext context) {
    Navigator.of(context).pushNamed('/create-ticket');
  }

  void navigateToMainMenuScreen(BuildContext context) {
    Navigator.of(context).pushReplacementNamed('/mainMenu');
  }
}