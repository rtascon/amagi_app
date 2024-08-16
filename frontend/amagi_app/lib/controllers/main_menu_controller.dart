import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../views/loading_screen.dart';

class MainMenuController {
  final AuthService _authService = AuthService();

  Future<String> getUserName(BuildContext context) async {
    _showLoadingScreen(context);

    final userInfo = await _authService.obtenerUsuarioInfo();
    Navigator.of(context).pop(); // Oculta la pantalla de carga

    return userInfo['session']['glpifriendlyname'];
  }

  void fetchUserInfo(BuildContext context) {
    _showLoadingScreen(context);

    // Aquí puedes agregar la lógica adicional que necesites
    Navigator.of(context).pop(); // Oculta la pantalla de carga
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