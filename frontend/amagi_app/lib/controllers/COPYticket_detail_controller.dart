import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'dart:io';

/// Controlador para manejar las acciones en la pantalla de detalles del ticket.
class TicketDetailController {
  /// Navega hacia atrás en la pila de navegación.
  void navigateBack(BuildContext context) {
    Navigator.pop(context);
  }

  /// Descarga un archivo desde una URL o copia uno local, lo almacena temporalmente y lo abre.
  ///
  /// Parámetros:
  /// - [context]: El contexto de la aplicación.
  /// - [pathOrUrl]: La ruta o URL del archivo a descargar o abrir.
  /// - [fileName]: El nombre del archivo a guardar temporalmente.
  Future<void> downloadFile(BuildContext context, String pathOrUrl, String fileName) async {
    try {
      final tempDir = await getTemporaryDirectory();

      // Verifica o infiere la extensión del archivo
      if (!fileName.contains('.')) {
        final uri = Uri.parse(pathOrUrl);
        final lastSegment = uri.pathSegments.isNotEmpty ? uri.pathSegments.last : '';
        final hasExtension = lastSegment.contains('.');
        final inferredExtension = hasExtension ? lastSegment.split('.').last : 'bin';
        fileName += '.$inferredExtension';
        print("Nombre de archivo ajustado: $fileName");
      }

      final tempPath = "${tempDir.path}/$fileName";
      File file;

      if (File(pathOrUrl).existsSync()) {
        // Copia archivo local
        file = await File(pathOrUrl).copy(tempPath);
        print("Archivo local copiado a temporal: ${file.path}");
      } else if (Uri.parse(pathOrUrl).isAbsolute) {
        // Descarga archivo desde URL
        Dio dio = Dio();
        await dio.download(pathOrUrl, tempPath);
        file = File(tempPath);
        print("Archivo descargado a temporal: ${file.path}");
      } else {
        print("Ruta o URL inválida: $pathOrUrl");
        return;
      }

      // Abrir archivo usando open_file
      final result = await OpenFile.open(file.path);
      print("Resultado al abrir archivo: ${result.message}");
    } catch (e) {
      print("Error al descargar o abrir el archivo: $e");
    }
  }
}
