import 'package:flutter/material.dart';

/// Este archivo contiene funciones para mostrar mensajes emergentes comunes,
/// como mensajes de error de conexión a Internet y mensajes de tiempo de espera agotado.

void _dismissActivePopups(BuildContext context) {
  // Cierra cualquier PopupRoute (incluye LoadingScreen) y vuelve a la anterior
  final navigator = Navigator.of(context, rootNavigator: true);
  navigator.popUntil((route) => route is! PopupRoute);
}

void showNoInternetMessage(BuildContext context) {
  if (!context.mounted) return;
  Color defaultTextButtonColor =
      TextButton.styleFrom().foregroundColor?.resolve({}) ??
          Theme.of(context).primaryColor;

  _dismissActivePopups(context);

  showDialog(
    context: context,
    useRootNavigator: true,
    builder: (BuildContext context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        title: const Column(
          children: [
            Icon(Icons.wifi_off, color: Colors.red, size: 40),
            SizedBox(height: 10),
            Text('Sin conexión a Internet'),
          ],
        ),
        content: const Text(
            'Por favor, verifique su conexión a Internet e intente de nuevo.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context, rootNavigator: true).pop();
            },
            child: Text('Aceptar',
                style: TextStyle(color: defaultTextButtonColor)),
          ),
        ],
      );
    },
  );
}

void showTimeoutMessage(BuildContext context) {
  if (!context.mounted) return;
  Color defaultTextButtonColor =
      TextButton.styleFrom().foregroundColor?.resolve({}) ??
          Theme.of(context).primaryColor;

  _dismissActivePopups(context);

  showDialog(
    context: context,
    useRootNavigator: true,
    builder: (BuildContext context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        title: const Column(
          children: [
            Icon(Icons.timer_off, color: Colors.red, size: 40),
            SizedBox(height: 10),
            Text('Tiempo de espera agotado'),
          ],
        ),
        content: const Text(
            'La solicitud ha tardado demasiado. Por favor, intente de nuevo.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context, rootNavigator: true).pop();
            },
            child: Text('Aceptar',
                style: TextStyle(color: defaultTextButtonColor)),
          ),
        ],
      );
    },
  );
}
