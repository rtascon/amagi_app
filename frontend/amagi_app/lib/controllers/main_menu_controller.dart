import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../views/loading_screen.dart';

class MainMenuController {
  final AuthService _authService = AuthService();

  Future<Map<String, String>> getUserName(BuildContext context) async {
    _showLoadingScreen(context);

    final userInfo = await _authService.obtenerUsuarioInfo();
    Navigator.of(context).pop(); // Oculta la pantalla de carga

    return {
      'glpifriendlyname': userInfo['session']['glpifriendlyname'],
      'glpiname': userInfo['session']['glpiname'],
    };
  }

  Future<List<String>> obtenerNombresPerfiles(BuildContext context) async {
    _showLoadingScreen(context);

    final perfiles = await _authService.obtenerPerfiles();
    Navigator.of(context).pop(); // Oculta la pantalla de carga

    return perfiles
      .map<String>((perfil) => perfil['name'] != null ? perfil['name'] as String : 'Nombre no disponible')
      .toList();
  }

  void fetchUserInfo(BuildContext context) {
    _showLoadingScreen(context);

    // Aquí puedes agregar la lógica adicional que necesites
    Navigator.of(context).pop(); // Oculta la pantalla de carga
  }

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
}