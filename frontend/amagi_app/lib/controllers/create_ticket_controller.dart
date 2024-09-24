import 'package:flutter/material.dart';
import '../services/ticket_service.dart';
import '../models/user.dart';
import '../views/main_menu_screen.dart';
import '../services/glpi_general_service.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../views/common_pop_ups.dart'; 
import 'dart:async';

/// Controlador para manejar la creación de tickets.
class CreateTicketController {
  final TicketService _ticketService = TicketService();
  final GlpiGeneralService _glpiGeneralService = GlpiGeneralService();
  final user = User();

  /// Navega hacia atrás en la pila de navegación.
  void navigateBack(BuildContext context) {
    Navigator.of(context).pop();
  }

  /// Navega de vuelta al menú principal, eliminando todas las rutas anteriores.
  void navigateBackToMainMenu(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => MainMenuScreen()),
      (Route<dynamic> route) => false,
    );
  }

  /// Envía un ticket con los datos proporcionados en [ticketData].
  /// 
  /// Parámetros:
  /// - [context]: El contexto de la aplicación.
  /// - [ticketData]: Un mapa con los datos del ticket.
  /// 
  /// Verifica la conectividad antes de enviar el ticket. Si no hay conexión, muestra un mensaje de error.
  /// Si hay conexión, intenta enviar el ticket y maneja las respuestas y errores adecuadamente.
  void submitTicket(BuildContext context, Map<String, dynamic> ticketData) async {
    final connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      showNoInternetMessage(context); 
      return;
    }
    try {
      // Asigna el ID del usuario solicitante y la entidad.
      ticketData['_users_id_requester'] = await user.getIdUsuario;
      ticketData['entities_id'] = 0;

      // Obtiene los tipos de solicitud.
      List<dynamic> requestTypes = await _glpiGeneralService.getRequestType();

      // Busca el tipo de solicitud "App Amagi".
      var requestType = requestTypes.firstWhere(
        (element) => element['name'] == 'App Amagi',
        orElse: () => null,
      );

      // Si se encuentra el tipo de solicitud, lo asigna al ticket.
      if (requestType != null) {
        ticketData['requesttypes_id'] = requestType['id'];
      } else {
        throw Exception('Request type "App Amagi" not found');
      }
      
      // Intenta crear el ticket.
      final response = await _ticketService.createTicket(ticketData);
  
      // Muestra un mensaje de éxito o error basado en la respuesta.
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

  /// Muestra un mensaje de éxito cuando el ticket se crea correctamente.
  /// 
  /// Parámetros:
  /// - [context]: El contexto de la aplicación.
  /// - [resp]: La respuesta de la creación del ticket.
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
              style: Theme.of(context).textTheme.bodyMedium, 
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
                Navigator.of(context).pop(); 
                Navigator.of(context).pushNamedAndRemoveUntil('/mainMenu', (Route<dynamic> route) => false); // Navegar al menú principal
              },
              child: Text('Aceptar', style: TextStyle(color: defaultTextButtonColor)),
            ),
          ],
        );
      },
    );
  }

  /// Muestra un mensaje de error cuando ocurre un problema al crear el ticket.
  /// 
  /// Parámetros:
  /// - [context]: El contexto de la aplicación.
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