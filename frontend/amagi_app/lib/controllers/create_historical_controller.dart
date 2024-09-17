import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../services/ticket_service.dart';

class CreateHistoricalController {
  final TicketService _ticketService = TicketService();

  void submitHistorical(BuildContext context, int ticketId, String descripcion, List<PlatformFile> selectedFiles) async {
    try {
      // Subir archivos y obtener sus IDs
      List<int> documentIds = await _ticketService.uploadFiles(selectedFiles);

      // Añadir el comentario/histórico al ticket con los IDs de los documentos subidos
      await _ticketService.addFollowupToTicket(ticketId, descripcion, documentIds);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Histórico enviado con éxito')),
      );
      Navigator.pop(context); 
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al enviar el histórico: $e')),
      );
    }
  }
}