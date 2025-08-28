import 'package:flutter/material.dart';
import '../views/loading_screen.dart';

/// Controlador para manejar la lógica de la pantalla de carga.
class SomeController {
  Future<void> fetchData(BuildContext context) async {
    bool dialogOpen = true;
    showDialog(
      context: context,
      barrierDismissible: false,
      useRootNavigator: true,
      builder: (BuildContext context) {
        return const LoadingScreen();
      },
    ).then((_) {
      dialogOpen = false;
    });

    try {
      // Llama a tus servicios pasando context para que cancelen y muestren el popup
      // await TicketService().getUserTicketFilterDefault(userId, context: context);
      await Future.delayed(const Duration(seconds: 2));
    } finally {
      if (context.mounted && dialogOpen) {
        Navigator.of(context, rootNavigator: true).pop();
      }
    }
  }
}
