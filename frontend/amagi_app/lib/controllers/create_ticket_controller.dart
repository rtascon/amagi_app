import 'package:flutter/material.dart';
import 'package:startup_namer/views/main_menu_screen.dart';
import '../services/ticket_service.dart';
import '../models/user.dart';
import '../config/enviroment.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../views/common_pop_ups.dart';
import 'dart:async';
import 'dart:convert';
import '../services/glpi_general_service.dart';

class CreateTicketController {
  final TicketService _ticketService = TicketService();
  final GlpiGeneralService _glpiGeneralService = GlpiGeneralService();
  final User _user = User();

  Future<bool> submitCreateTicketController(
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

      // Asigna el ID del usuario solicitante, la entidad y origente la solicitud.
      ticketData['_users_id_requester'] = _user.getIdUsuario;
      ticketData['entities_id'] = 64; //Centro de gestión
      ticketData['requesttypes_id'] = 8; //Origen de la solicitud GIA_App

      final response = await _ticketService.createTicket(
          ticketData, _user.getIdUsuario.toString());

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
