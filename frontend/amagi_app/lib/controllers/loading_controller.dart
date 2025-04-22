import 'package:flutter/material.dart';
import '../views/loading_screen.dart';

/// Controlador para manejar la lógica de la pantalla de carga.
class SomeController {
  Future<void> fetchData(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const LoadingScreen();
      },
    );
    await Future.delayed(const Duration(seconds: 2));
    if (context.mounted) {
      Navigator.of(context).pop();
    }
  }
}
