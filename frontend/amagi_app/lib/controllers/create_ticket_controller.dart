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
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: Column(
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 40),
              SizedBox(height: 10),
              Text('Solicitud registrada con éxito'),
            ],
          ),
          content: RichText(
            text: TextSpan(
              text: 'El ticket ha sido creado correctamente con el ID: ',
              style: TextStyle(
                fontSize: 14, // Tamaño de fuente más pequeño
                color: Colors.black, // Color negro
              ),
              children: <TextSpan>[
                TextSpan(
                  text: '${resp['ticketId']}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14, // Mantener el mismo tamaño de fuente
                  ),
                ),
                TextSpan(
                  text: '.',
                  style: TextStyle(
                    fontSize: 14, // Tamaño de fuente más pequeño
                    color: Colors.black, // Color negro
                  ),
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
              child: Text('Aceptar'),
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
              child: Text('Aceptar'),
            ),
          ],
        );
      },
    );
  }
}