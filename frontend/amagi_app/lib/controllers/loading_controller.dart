import 'package:flutter/material.dart';
import '../views/loading_screen.dart';

class SomeController {
  Future<void> fetchData(BuildContext context) async {
    // Muestra la pantalla de carga
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const LoadingScreen();
      },
    );

    // Simula una operación de red
    await Future.delayed(const Duration(seconds: 2));

    // Oculta la pantalla de carga
    if (context.mounted) {
      Navigator.of(context).pop();
    }
  }
}
