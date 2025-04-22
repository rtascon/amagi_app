// ignore: unused_import
import 'package:flutter/material.dart';

/// Controlador para manejar la lógica de la pantalla principal del menú.
class MainMenuController {
  void navigateToCreateTicketScreen(BuildContext context) {
    Navigator.of(context).pushNamed('/create-ticket');
  }
}