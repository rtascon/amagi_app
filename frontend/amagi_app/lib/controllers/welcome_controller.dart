import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../services/user_service.dart';
import '../services/glpi_general_service.dart';
import '../views/common_pop_ups.dart';
import 'dart:async';

/// Controlador para manejar la lógica de la pantalla de bienvenida.
class WelcomeController {
  final BuildContext context;

  /// Constructor que recibe el [context] de la aplicación.
  WelcomeController(this.context);

  /// Verifica el estado de inicio de sesión del usuario.
  /// 
  /// Si el usuario está logueado, navega al menú principal después de un retraso de 3 segundos.
  /// Si no está logueado, navega a la pantalla de inicio de sesión.
  Future<void> checkLoginStatus() async {
    bool isLoggedIn = await _checkLoginStatus();
    await Future.delayed(Duration(seconds: 3)); 
    if (isLoggedIn) {
      Navigator.pushReplacementNamed(context, '/mainMenu');
    } else {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  /// Verifica el estado de inicio de sesión almacenado en las preferencias compartidas.
  /// 
  /// Si el usuario está logueado, intenta obtener la información del usuario y cambiar la entidad activa.
  /// Si ocurre un error, limpia las preferencias y muestra un mensaje de error.
  /// 
  /// Retorna `true` si el usuario está logueado, `false` en caso contrario.
  Future<bool> _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

    if (isLoggedIn) {
      try {
        User usuario = User();
        UserService userService = UserService();
        await userService.getUserInfo(usuario);
        GlpiGeneralService glpiGeneralService = GlpiGeneralService();
        await glpiGeneralService.changeActiveEntity(prefs.getInt('root_entity') ?? 0);
      } catch (e) {
        isLoggedIn = false;
        await prefs.clear();
        if (e is TimeoutException) {
          showTimeoutMessage(context); 
        } else {
          _showErrorMessage(context);
        }
      }
    }

    return isLoggedIn;
  }

  /// Muestra un mensaje de error cuando ocurre un problema al verificar el estado de inicio de sesión.
  /// 
  /// Parámetros:
  /// - [context]: El contexto de la aplicación.
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
              Text('Hubo un error al verificar el estado de inicio de sesión'),
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