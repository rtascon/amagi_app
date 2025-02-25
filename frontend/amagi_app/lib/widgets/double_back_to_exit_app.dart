import 'package:flutter/material.dart';
import 'package:double_tap_to_exit/double_tap_to_exit.dart';

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
    return DoubleTapToExit(
      snackBar: SnackBar(
        content: Text(widget.exitMessage),
      ),
      child: widget.child,
    );
  }
}
