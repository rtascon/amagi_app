import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';
import '../views/main_menu_screen.dart';
import '../views/loading_screen.dart';
import '../views/registration_request_screen.dart';
import '../views/common_pop_ups.dart'; 
import 'dart:async';

class LoginController {
  final AuthService _authService = AuthService();

  void login(String username, String password, BuildContext context) async {
    final connectivityResult = await (Connectivity().checkConnectivity());

    if (connectivityResult == ConnectivityResult.none) {
      showNoInternetMessage(context); 
      return;
    }

    _showLoadingScreen(context); 

    try {
      final formattedUsername = username.toLowerCase().trim();
      final success = await _authService.iniciarSesion(formattedUsername, password);

      Navigator.of(context).pop(); 

      if (success) {
        // Guardar el estado de inicio de sesión
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);
        await prefs.setString('username', formattedUsername);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MainMenuScreen()),
        );
      } else {
        _showErrorMessage(context);
      }
    } catch (e) {
      Navigator.of(context).pop(); 
      if (e is TimeoutException) {
        showTimeoutMessage(context); 
      } else {
        _showErrorMessage(context);
      }
    }
  }

  void redirectToRegistration(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => RegistrationRequestScreen()),
    );
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
    Color defaultTextButtonColor = TextButton.styleFrom().foregroundColor?.resolve({}) ?? Theme.of(context).primaryColor;
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
              child: Text('Aceptar', style: TextStyle(color: defaultTextButtonColor)),
            ),
          ],
        );
      },
    );
  }
}