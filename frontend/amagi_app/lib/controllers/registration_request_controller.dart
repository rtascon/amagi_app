import 'package:flutter/material.dart';
import '../services/ticket_service.dart'; 

class RegistrationRequestController {
  final TicketService _ticketService = TicketService();

  void submitRegistrationRequest(
    BuildContext context,
    String nombre,
    String apellido,
    String empresa,
    String correo,
    String telefono,
    String cedula,
  ) async {
    // Crear el mapa con los datos del formulario
    final Map<String, dynamic> ticketData = {
      'name': 'Solicitud de registro: $empresa - usuario $nombre $apellido',
      'content': '''
Nombre: $nombre
Apellido: $apellido
Empresa: $empresa
Correo Electrónico: $correo
Número de Teléfono: $telefono
Cédula: $cedula
''',
    };

    try {
      // Llamar a la función crearTicket con el mapa de datos
      final response = await _ticketService.crearTicket(ticketData);

      if (response['success']) {
        // Mostrar un diálogo de éxito
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
                  Text('Registro Exitoso'),
                ],
              ),
              content: Text('Su solicitud de registro ha sido enviada.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).pop(); // Regresa a la vista de login
                  },
                  child: Text('Aceptar'),
                ),
              ],
            );
          },
        );
      } else {
        throw Exception('Error al crear el ticket');
      }
    } catch (e) {
      // Mostrar un diálogo de error
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
                Text('Error'),
              ],
            ),
            content: Text('Hubo un error al enviar su solicitud de registro. Por favor, intente de nuevo.'),
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
}