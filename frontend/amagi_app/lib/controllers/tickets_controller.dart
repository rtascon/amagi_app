import 'package:flutter/material.dart';
import '../views/tickets_screen.dart';

class TicketsController {
  void navigateToTicketsScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => TicketsScreen()),
    );
  }
}