import 'package:flutter/material.dart';
import '../controllers/side_menu_controller.dart';

/// Widget que permite salir de la aplicación al hacer doble tap
/// en la pantalla, mostrando un mensaje de confirmación.

class DoubleBackToExitApp extends StatefulWidget {
  final Widget child;
  final String exitMessage;

  const DoubleBackToExitApp({
    super.key,
    required this.child,
    this.exitMessage = "Presiona de nuevo para salir",
  });

  @override
  DoubleBackToExitAppState createState() => DoubleBackToExitAppState();
}

class DoubleBackToExitAppState extends State<DoubleBackToExitApp> {
  DateTime? _lastPressedAt;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        final now = DateTime.now();
        if (_lastPressedAt == null ||
            now.difference(_lastPressedAt!) > const Duration(seconds: 2)) {
          _lastPressedAt = now;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(widget.exitMessage)),
          );
          return false;
        }

        SideMenuController().logOut(context);
        return false;
      },
      child: widget.child,
    );
  }
}
