import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../services/ticket_service.dart';
import 'tickets_controller.dart';
import '../models/ticket.dart';

class CreateHistoricalController {
  final TicketService _ticketService = TicketService();

  void submitHistorical(BuildContext context, int ticketId, String descripcion, List<PlatformFile> selectedFiles,Ticket ticket) async {
    try {

      int followupId = await _ticketService.addFollowupToTicket(ticketId, descripcion);

      await _ticketService.uploadFiles(selectedFiles, followupId);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Histórico enviado con éxito')),
      );
      // Navegar a la pantalla de detalles del ticket actualizada
      final TicketsController ticketsController = TicketsController();
      await ticketsController.navigateToTicketDetailScreen(context, ticket);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al enviar el histórico: $e')),
      );
    }
  }
}