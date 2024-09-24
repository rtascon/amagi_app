import 'package:flutter/material.dart';
import '../services/ticket_service.dart';
import '../models/user.dart';
import '../views/main_menu_screen.dart';
import '../services/glpi_general_service.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../views/common_pop_ups.dart'; 
import 'dart:async';

class CreateTicketController {
  final TicketService _ticketService = TicketService();
  final GlpiGeneralService _glpiGeneralService = GlpiGeneralService();
  final user = User();

  void navigateBack(BuildContext context) {
    Navigator.of(context).pop();
  }


  void navigateBackToMainMenu(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => MainMenuScreen()),
      (Route<dynamic> route) => false,
    );
  }


  void submitTicket(BuildContext context, Map<String, dynamic> ticketData) async {
    final connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      showNoInternetMessage(context); 
      return;
    }
    try {
      ticketData['_users_id_requester'] = await user.getIdUsuario;
      ticketData['entities_id'] = 0;
      List<dynamic> requestTypes = await _glpiGeneralService.getRequestType();

      var requestType = requestTypes.firstWhere(
        (element) => element['name'] == 'App Amagi',
        orElse: () => null,
      );

      if (requestType != null) {
        ticketData['requesttypes_id'] = requestType['id'];
      } else {
        throw Exception('Request type "App Amagi" not found');
      }
      
      final response = await _ticketService.createTicket(ticketData);
  
      if (response['success']) {
        _showSuccessMessage(context, response);
      } else {
        _showErrorMessage(context);
      }
    } catch (e) {
      Navigator.of(context).pop(); 
      if (e is TimeoutException) {
        showTimeoutMessage(context); 
      } else {
        _showErrorMessage(context);
      }
    }
  }

  void _showSuccessMessage(BuildContext context, Map<String, dynamic> resp) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        Color defaultTextButtonColor = TextButton.styleFrom().foregroundColor?.resolve({}) ?? Theme.of(context).primaryColor;
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: Column(
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 40),
              SizedBox(height: 10),
              Center(
                child: Text(
                  'Solicitud registrada con éxito',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          content: RichText(
            text: TextSpan(
              text: 'El ticket ha sido creado con el ID: ',
              style: Theme.of(context).textTheme.bodyMedium, // Usa el estilo de texto principal
              children: <TextSpan>[
                TextSpan(
                  text: '${resp['ticketId']}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextSpan(
                  text: '.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cerrar el diálogo
                Navigator.of(context).pushNamedAndRemoveUntil('/mainMenu', (Route<dynamic> route) => false); // Navegar al menú principal
              },
              child: Text('Aceptar', style: TextStyle(color: defaultTextButtonColor)),
            ),
          ],
        );
      },
    );
  }

  void _showErrorMessage(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        Color defaultTextButtonColor = TextButton.styleFrom().foregroundColor?.resolve({}) ?? Theme.of(context).primaryColor;
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: Column(
            children: [
              Icon(Icons.error, color: Colors.red, size: 40),
              SizedBox(height: 10),
              Text('Error al enviar el ticket'),
            ],
          ),
          content: Text('Hubo un problema al crear el ticket. Por favor intente de nuevo.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Aceptar',style: TextStyle(color: defaultTextButtonColor)),
            ),
          ],
        );
      },
    );
  }
}