import '../config/environment.dart';
import '../models/user.dart';
import '../views/common_pop_ups.dart';
import '../views/loading_screen.dart';
import '../views/main_menu_screen.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../services/ticket_service.dart'; // Add this line to import the ticket_service
import '../services/glpi_general_service.dart';


/// Servicio para manejar operaciones relacionadas con los tickets.
class CreateTicketController {
  final String request = Environment.requesttypes;

  final user = User();
  final TicketService _ticketService = TicketService(); // Add this line to define the _ticketService variable
  final GlpiGeneralService _glpiGeneralService = GlpiGeneralService(); // Add this line to define the _glpiGeneralService variable
  final String entity = Environment.entity;

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

      // Mostrar la pantalla de carga
      if (context.mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return const LoadingScreen();
          },
        );
      }

      final Map<String, dynamic> ticketData = {
        'name': titulo,
        'content': descripcion,
        'type': tipo,
      };
      ticketData['_users_id_requester'] = user.getIdUsuario;
      ticketData['entities_id'] = await _getEntityId();
      ticketData['requesttypes_id'] = request;

      final response = await _ticketService.createTicket(ticketData);

      if (response['success']) {
        if (context.mounted) {
          await _showSuccessMessage(context, response['ticketId']);
        }
      } else {
        throw Exception('Error al crear la solicitud');
      }

      if (context.mounted) {
      Navigator.of(context).pop();

      // Eliminar la pantalla anterior
      Navigator.of(context).pop();

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const MainMenuScreen(),
        ),
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

  Future<int> _getEntityId() async {
    Map<String, dynamic> myEntities = await _glpiGeneralService.getMyEntities();
    var myEntitiesList = myEntities['myentities'];
    if (myEntitiesList != null && myEntitiesList is List) {
      var myEntity = myEntitiesList.firstWhere(
        (element) => element['name'] == entity,
        orElse: () => null,
      );

      if (myEntity != null) {
        return int.parse(myEntity['id'].toString());
      }
    }
    throw Exception('Entidad no encontrada');
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

  Future<void> _showSuccessMessage(BuildContext context, int ticketId) async {
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
          content: Text('Su solicitud ha sido enviada con el ID: $ticketId'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => const MainMenuScreen()),
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
