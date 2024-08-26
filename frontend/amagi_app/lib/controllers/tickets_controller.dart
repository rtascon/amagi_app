import 'package:flutter/material.dart';
import '../services/ticket_service.dart';
import '../models/usuario.dart'; // Importar Usuario
import '../views/tickets_screen.dart';

class TicketsController {
  final TicketService _ticketService = TicketService();
  final Map<String, String> tickets = {};
  final usuario = Usuario();

  int getUserId() {
    return usuario.idUsuario;
  }

  Future<Map<String, String>> obtenerListaTickets(BuildContext context) async {
    try {
      // Obtener el ID del usuario
      final userId = getUserId();

      // Obtener los tickets del usuario
      List<dynamic> tickets = await _ticketService.obtenerTicketsUsuario(userId);

      return {
        'tickets': tickets.toString()
      };
    } catch (e) {
      // Manejar error
      return {
        'error': e.toString()
      };
    }
  }

  void navigateToTicketsScreen(BuildContext context) async {
    Map<String, String> tickets = await obtenerListaTickets(context);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TicketsScreen(tickets: [tickets]),
      ),
    );
  }

  String getPrioridad(int prioridad) {
    switch (prioridad) {
      case 1:
        return 'Baja';
      case 2:
        return 'Media';
      case 3:
        return 'Alta';
      default:
        return 'Desconocida';
    }
  }

  String getEstado(int estado) {
    switch (estado) {
      case 1:
        return 'Nuevo';
      case 2:
        return 'En curso (asignado)';
      case 3:
        return 'En curso (Planificado)';
      case 4:
        return 'En espera';
      case 5:
        return 'Resuelto';
      case 6:
        return 'Cerrado';
      default:
        return 'Desconocido';
    }
  }
}