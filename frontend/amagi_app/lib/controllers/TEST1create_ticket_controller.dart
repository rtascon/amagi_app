import 'package:flutter/material.dart';
import 'package:startup_namer/views/main_menu_screen.dart';
import '../services/ticket_service.dart';
import '../services/auth_service.dart';
import '../models/user.dart';
import '../config/enviroment.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../views/common_pop_ups.dart';
import 'dart:async';
import 'dart:convert';

class CreateTicketController {
  final TicketService _ticketService = TicketService();
  final AuthService _authService = AuthService();
  final String _appServiceCredentialUsername =
      Environment.appServiceCredentialUsername;
  final String _appServiceCredentialPassword =
      Environment.appServiceCredentialPassword;
  final User _user = User();

  Future<bool> submitCreateTicketController(
    BuildContext context,
    String titulo,
    String descripcion,
    int tipo,
  ) async {
    final connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      showNoInternetMessage(context);
      return false;
    }

    try {
      final success = await _authService.login(
          _appServiceCredentialUsername, _appServiceCredentialPassword);

      if (success) {
        final Map<String, dynamic> ticketData = {
          "_users_id_requester": _user.getIdUsuario,
          "entities_id": 0,
          'name': titulo,
          'content': descripcion,
          'type': tipo,
        };

        final response = await _ticketService.createTicket(
            ticketData, _user.getIdUsuario.toString());

        if (response['success']) {
          await _showSuccessMessage(context);
        } else {
          throw Exception('Error al crear la solicitud');
        }

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainMenuScreen()),
        );
        return true;
      } else {
        _showErrorMessage(context,
            'No pudimos enviar su solicitud. Por favor, intente más tarde.');
        return false;
      }
    } catch (e) {
      Navigator.of(context).pop();
      if (e is TimeoutException) {
        showTimeoutMessage(context);
      } else {
        _showErrorMessage(context,
            'Hubo un error al enviar su solicitud. Por favor, intente de nuevo.');
      }
      return false;
    }
  }

  void _showErrorMessage(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: const Column(
            children: [
              Icon(Icons.error, color: Colors.red, size: 40),
              SizedBox(height: 10),
              Text('Error'),
            ],
          ),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Aceptar',
                style: TextStyle(color: Theme.of(context).primaryColor),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showSuccessMessage(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: const Column(
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 40),
              SizedBox(height: 10),
              Text('Exitoso'),
            ],
          ),
          content: const Text('Su solicitud ha sido enviada.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                      builder: (context) => const MainMenuScreen()),
                );
              },
              child: Text(
                'Aceptar',
                style: TextStyle(color: Theme.of(context).primaryColor),
              ),
            ),
          ],
        );
      },
    );
  }
}
