import 'package:startup_namer/models/user.dart';
import 'package:startup_namer/views/common_pop_ups.dart';
import 'package:startup_namer/views/main_menu_screen.dart';
import '../config/enviroment.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:startup_namer/services/ticket_service.dart'; // Add this line to import the ticket_service

/// Servicio para manejar operaciones relacionadas con los tickets.
class CreateTicketController {
  final String url = Environment.apiUrl;

  final user = User();
  final TicketService _ticketService = TicketService(); // Add this line to define the _ticketService variable

  Future<bool> submitCrearticketController(
    BuildContext context,
    String titulo,
    String descripcion,
    int tipo,
  ) async {
    final connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      if (context.mounted) {
        showNoInternetMessage(context);
      }
      return false;
    }

    try {
      final Map<String, dynamic> ticketData = {
        'name': titulo,
        'content': descripcion,
        'type': tipo,
      };
      ticketData['_users_id_requester'] = await user.getIdUsuario;
      ticketData['entities_id'] = 0;

     final response = await _ticketService.createTicket(ticketData);

      if (response['success']) {
        if (context.mounted) {
          await _showSuccessMessage(context);
        }
      } else {
        throw Exception('Error al crear la solicitud');
      }

      if (context.mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainMenuScreen()),
        );
      }
      return true;
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop();
        if (e is TimeoutException) {
          showTimeoutMessage(context);
        } else {
          _showErrorMessage(context,
              'Hubo un error al enviar su solicitud. Por favor, intente de nuevo.');
        }
      }
      // Imprime el error en la consola de depuración
      debugPrint('Error al enviar el ticket: $e');
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
