import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:open_file/open_file.dart';
import 'dart:io';

/// Controlador para manejar las acciones en la pantalla de detalles del ticket.
class TicketDetailController {
  /// Navega hacia atrás en la pila de navegación.
  /// 
  /// Parámetros:
  /// - [context]: El contexto de la aplicación.
  void navigateBack(BuildContext context) {
    Navigator.pop(context);
  }

  /// Descarga un archivo desde una URL o una ruta local y lo abre.
  /// 
  /// Parámetros:
  /// - [context]: El contexto de la aplicación.
  /// - [pathOrUrl]: La ruta o URL del archivo a descargar.
  /// - [fileName]: El nombre del archivo a guardar.
  /// 
  /// Si el archivo ya existe localmente, lo abre directamente.
  /// Si es una URL, descarga el archivo y lo abre.
  Future<void> downloadFile(BuildContext context, String pathOrUrl, String fileName) async {
    String filePath = pathOrUrl;
    if (File(pathOrUrl).existsSync()) {
      print("File already exists at: $pathOrUrl");
      // Abrir el archivo directamente
      OpenFile.open(filePath);
      return;
    }
    if (!Uri.parse(pathOrUrl).isAbsolute) {
      print("Invalid URL: $pathOrUrl");
      return;
    }
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      status = await Permission.storage.request();
      if (!status.isGranted) {
        print("Storage permission denied");
        return;
      }
    }
    try {
      Dio dio = Dio();
      var dir = await getApplicationDocumentsDirectory();
      filePath = "${dir.path}/$fileName";
      await dio.download(pathOrUrl, filePath);
      print("File downloaded to $filePath");
      // Abrir el archivo descargado
      OpenFile.open(filePath);
    } catch (e) {
      print("Error downloading file: $e");
    }
  }
}