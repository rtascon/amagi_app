import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../views/main_menu_screen.dart';
import '../views/loading_screen.dart';

class LoginController {
  final AuthService _authService = AuthService();

  void login(String username, String password, BuildContext context) async {
    _showLoadingScreen(context);

    final success = await _authService.iniciarSesion(username, password);
    Navigator.of(context).pop(); // Oculta la pantalla de carga

    if (success) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MainMenuScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login failed. Please try again.')),
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