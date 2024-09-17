import 'package:flutter/material.dart';

void showNoInternetMessage(BuildContext context) {
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
            Icon(Icons.wifi_off, color: Colors.red, size: 40),
            SizedBox(height: 10),
            Text('Sin conexión a Internet'),
          ],
        ),
        content: Text('Por favor, verifique su conexión a Internet e intente de nuevo.'),
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

void showTimeoutMessage(BuildContext context) {
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
            Icon(Icons.timer_off, color: Colors.red, size: 40),
            SizedBox(height: 10),
            Text('Tiempo de espera agotado'),
          ],
        ),
        content: Text('La solicitud ha tardado demasiado. Por favor, intente de nuevo.'),
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