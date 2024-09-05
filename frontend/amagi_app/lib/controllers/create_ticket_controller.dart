import 'package:flutter/material.dart';
import '../services/ticket_service.dart';
import '../models/user.dart';

class CreateTicketController {
  final TicketService _ticketService = TicketService();
  final user = User();

  void navigateBack(BuildContext context) {
    Navigator.of(context).pop();
  }

  void submitTicket(BuildContext context, Map<String, dynamic> ticketData) async {
    try {
      ticketData['_users_id_requester'] = await user.getIdUsuario;
      final response = await _ticketService.crearTicket(ticketData);
  
      if (response['success']) {
        _showSuccessMessage(context, response);
      } else {
        _showErrorMessage(context);
      }
    } catch (e) {
      _showErrorMessage(context);
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
                  style: Theme.of(context).textTheme.headlineSmall, // Usa el estilo de texto principal
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