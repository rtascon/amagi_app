import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../views/loading_screen.dart';
import '../models/usuario.dart'; // Importar Usuario

class MainMenuController {
  final AuthService _authService = AuthService();
  final Usuario _usuario = Usuario();

  void cerrarSesion(BuildContext context) async {
    _showLoadingScreen(context);

    try {
      await _authService.cerrarSesion();
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
/*
  Future<List<String>> obtenerNombresPerfiles() async {
    return _usuario.perfiles.keys.toList();
  }
  */
}