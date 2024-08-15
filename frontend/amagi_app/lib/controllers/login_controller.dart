import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class LoginController {
  final AuthService _authService = AuthService();

  void login(String username, String password, BuildContext context) async {
    final success = await _authService.iniciarSesion(username, password);
    if (success) {
      // Navega a la siguiente pantalla o muestra un mensaje de éxito
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      // Muestra un mensaje de error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login failed. Please try again.')),
      );
    }
  }
}
