import 'package:flutter/material.dart';

class CreateTicketController {
  void navigateBack(BuildContext context) {
    Navigator.of(context).pop();
  }

  void submitTicket(BuildContext context, String titulo, String tipo, String descripcion) {
    // Aquí puedes agregar la lógica para enviar el ticket
    // Por ahora, solo mostraremos un mensaje de éxito
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Ticket enviado con éxito')),
    );
    Navigator.of(context).pop(); // Navegar de regreso al menú principal después de enviar el ticket
  }
}