import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../services/user_service.dart';

class WelcomeController {
  final BuildContext context;

  WelcomeController(this.context);

  Future<void> checkLoginStatus() async {
    bool isLoggedIn = await _checkLoginStatus();
    await Future.delayed(Duration(seconds: 3)); // Simula un tiempo de espera
    if (isLoggedIn) {
      Navigator.pushReplacementNamed(context, '/mainMenu');
    } else {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  Future<bool> _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

    if (isLoggedIn) {
      User usuario = User();
      UserService userService = UserService();
      await userService.obtenerUsuarioInfo(usuario);
    }

    return isLoggedIn;
  }
}