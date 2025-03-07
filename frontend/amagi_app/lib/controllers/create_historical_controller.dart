import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:connectivity_plus/connectivity_plus.dart'; // Importar el paquete de conectividad
import 'package:startup_namer/views/common_pop_ups.dart';
import '../services/ticket_service.dart';
import 'tickets_controller.dart';
import '../models/ticket.dart';

/// Controlador para manejar la creación de históricos en los tickets.
class CreateHistoricalController {
  final TicketService _ticketService = TicketService();
  final ImagePicker _imagePicker = ImagePicker();

  /// Envía un histórico para un ticket específico.
  ///
  /// Parámetros:
  /// - [context]: El contexto de la aplicación.
  /// - [ticketId]: El ID del ticket al que se añadirá el histórico.
  /// - [descripcion]: La descripción del histórico.
  /// - [selectedFiles]: Lista de archivos seleccionados para adjuntar al histórico.
  /// - [ticket]: El objeto Ticket al que se añadirá el histórico.
  ///
  /// Muestra un SnackBar con el resultado de la operación.
  Future<void> submitHistorical(
      BuildContext context,
      int ticketId,
      String descripcion,
      List<PlatformFile> selectedFiles,
      Ticket ticket) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    try {
      // Verificar la conectividad a Internet.
      final connectivityResult = await (Connectivity().checkConnectivity());
      if (connectivityResult == ConnectivityResult.none) {
        if (context.mounted) {
          showNoInternetMessage(context);
        }
        return;
      }

      // Añade un seguimiento al ticket.
      int followupId =
          await _ticketService.addFollowupToTicket(ticketId, descripcion);
      // Sube los archivos seleccionados.
      await _ticketService.uploadFiles(selectedFiles, followupId);

      // Muestra un mensaje de éxito.
      scaffoldMessenger.showSnackBar(
        const SnackBar(content: Text('Histórico enviado con éxito')),
      );

      // Navega a la pantalla de detalles del ticket actualizada.
      final TicketsController ticketsController = TicketsController();
      if (context.mounted) {
        await ticketsController.navigateEnviadoToTicketDetailScreen(context, ticket);
      }




    } catch (e) {
      // Muestra un mensaje de error.
      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text('Error al enviar el histórico: $e')),
      );
    }
  }

  /// Permite al usuario tomar una foto con la cámara y seleccionarla.
  ///
  /// Retorna un [PlatformFile] que representa la imagen seleccionada,
  /// o `null` si no se seleccionó ninguna imagen.
  Future<PlatformFile?> pickImageFromCamera() async {
    final XFile? image =
        await _imagePicker.pickImage(source: ImageSource.camera);
    if (image != null) {
      // Convierte XFile a PlatformFile.
      PlatformFile platformFile = PlatformFile(
        name: image.name,
        size: await image.length(),
        path: image.path,
      );
      return platformFile;
    }
    return null;
  }
}