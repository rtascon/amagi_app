import 'package:flutter/material.dart';
import '../services/ticket_service.dart';
import '../models/usuario.dart'; // Importar Usuario
import '../views/tickets_screen.dart';
import '../models/ticket_factory.dart'; // Importar TicketFactory
import '../models/ticket.dart'; // Importar Ticket
import '../views/ticket_detail_screen.dart';

class TicketsController {
  final TicketService _ticketService = TicketService();
  final Map<String, String> tickets = {};
  final usuario = Usuario();

  int getUserId() {
    return usuario.idUsuario;
  }

  Future<List<Ticket>> obtenerListaTickets(BuildContext context) async {
    try {
      // Obtener el ID del usuario
      final userId = getUserId();

      // Obtener los tickets del usuario
      List<dynamic> ticketsData = await _ticketService.obtenerTicketsUsuario(userId);

      // Crear instancias de Ticket usando TicketFactory
      List<Ticket> tickets = ticketsData.map((ticketData) {
        return TicketFactory.createTicket(
          id: ticketData['2'],
          titulo: ticketData['1'],
          descripcion: ticketData['21'],
          fechaCreacion: DateTime.parse(ticketData['15']),
          fechaActualizacion: DateTime.parse(ticketData['19']),
          tipo: ticketData['14'],
          estado: ticketData['12'],
          entidadAsociada: ticketData['80'],
          prioridad: ticketData['3'],
        );
      }).toList();

      return tickets;
    } catch (e) {
      // Manejar error
      return [];
    }
  }

  void navigateToTicketsScreen(BuildContext context) async {
    List<Ticket> tickets = await obtenerListaTickets(context);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TicketsScreen(tickets: tickets),
      ),
    );
  }

  Future<void> navigateToTicketDetailScreen(BuildContext context, Ticket ticket) async {
    try {
      List<dynamic> historicos = await _ticketService.obtenerHistoricosTicket(ticket.id);
      ticket.historicos = historicos.map((historico) {
        return {
          'id': historico['id'],
          'users_id': historico['users_id'],
          'date': historico['date'],
          'content': historico['content'],
        };
      }).toList();

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TicketDetailScreen(ticket: ticket),
        ),
      );
    } catch (e) {
      // Manejar error
      print("Error al obtener históricos del ticket: $e");
    }
  }

  String getPrioridad(int prioridad) {
    switch (prioridad) {
      case 2:
        return 'Baja';
      case 3:
        return 'Media';
      case 4:
        return 'Alta';
      case 5:
        return 'Muy Alta';
      case 6:
        return 'Mayor';
      default:
        return 'Desconocida';
    }
  }

  String getTipo(int tipo) {
    switch (tipo) {
      case 1:
        return 'Incidente';
      case 2:
        return 'Requerimiento';
      default:
        return 'Desconocido';
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