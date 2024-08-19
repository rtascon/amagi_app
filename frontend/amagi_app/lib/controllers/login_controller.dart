import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../views/main_menu_screen.dart';
import '../views/loading_screen.dart';

class LoginController {
  final AuthService _authService = AuthService();

  void login(String username, String password, BuildContext context) async {
    _showLoadingScreen(context); // Mostrar pantalla de carga

    try {
      final success = await _authService.iniciarSesion(username, password);

      Navigator.of(context).pop(); // Ocultar pantalla de carga

      if (success) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MainMenuScreen()),
        );
      } else {
        _showErrorMessage(context);
      }
    } catch (e) {
      Navigator.of(context).pop(); // Ocultar pantalla de carga en caso de error
      _showErrorMessage(context);
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

  void _showErrorMessage(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: Column(
            children: [
              Icon(Icons.error, color: Colors.red, size: 40),
              SizedBox(height: 10),
              Text('Fallo al iniciar sesión'),
            ],
          ),
          content: Text('Por favor intente de nuevo.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Aceptar'),
            ),
          ],
        );
      },
    );
  }
}