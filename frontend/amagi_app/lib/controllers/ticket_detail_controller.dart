import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:open_filex/open_filex.dart';
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

  /// Prepara un archivo para previsualización, asegurando su ubicación en carpeta temporal
  /// (necesario en iOS 17/18). Devuelve la ruta lista para usar con PDFView/visores.
  Future<String?> prepareFileForPreview(
      String pathOrUrl, String fileName) async {
    try {
      final isLocal = File(pathOrUrl).existsSync();

      if (isLocal) {
        if (Platform.isIOS) {
          final tmpDir = await getTemporaryDirectory();
          final safeName = _ensureExtension(fileName, pathOrUrl);
          final tmpPath = '${tmpDir.path}/$safeName';
          await File(pathOrUrl).copy(tmpPath);
          return tmpPath;
        } else {
          return pathOrUrl;
        }
      }

      final uri = Uri.tryParse(pathOrUrl);
      if (uri == null || !uri.isAbsolute) return null;

      final tmpDir = await getTemporaryDirectory();
      final safeName = _ensureExtension(fileName, pathOrUrl);
      final savePath = '${tmpDir.path}/$safeName';
      await Dio().download(pathOrUrl, savePath);
      return savePath;
    } catch (_) {
      return null;
    }
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
  Future<void> downloadFile(
      BuildContext context, String pathOrUrl, String fileName) async {
    try {
      final bool isLocal = File(pathOrUrl).existsSync();

      if (isLocal) {
        final src = File(pathOrUrl);
        if (Platform.isIOS) {
          // iOS 17/18: Abrir desde carpeta temporal
          final tmpDir = await getTemporaryDirectory();
          final String safeName = _ensureExtension(fileName, src.path);
          final String tmpPath = '${tmpDir.path}/$safeName';
          await src.copy(tmpPath);
          await OpenFilex.open(tmpPath);
        } else {
          await OpenFilex.open(src.path);
        }
        return;
      }

      // Si no es archivo local, debe ser URL válida
      final uri = Uri.tryParse(pathOrUrl);
      if (uri == null || !uri.isAbsolute) return;

      // En iOS no se piden permisos de almacenamiento
      if (Platform.isAndroid) {
        var status = await Permission.storage.status;
        if (!status.isGranted) {
          status = await Permission.storage.request();
          if (!status.isGranted) return;
        }
      }

      final dir = Platform.isIOS
          ? await getTemporaryDirectory() // iOS: usar carpeta temporal
          : await getApplicationDocumentsDirectory();

      final String safeName = _ensureExtension(fileName, pathOrUrl);
      final String savePath = '${dir.path}/$safeName';

      await Dio().download(pathOrUrl, savePath);
      await OpenFilex.open(savePath);
    } catch (e) {
      // Silencioso para evitar crash; opcional: mostrar SnackBar/log
    }
  }

  String _ensureExtension(String desiredName, String sourcePath) {
    if (desiredName.contains('.')) return desiredName;

    final inferred = _inferExtensionFromPathOrUrl(sourcePath);
    // Si no se puede inferir, por compatibilidad con iOS, asumir .pdf
    return inferred != null ? '$desiredName$inferred' : '$desiredName.pdf';
  }

  String? _inferExtensionFromPathOrUrl(String p) {
    try {
      final uri = Uri.tryParse(p);
      final path = uri?.path ?? p;
      final fname = path.split('/').last;
      final dot = fname.lastIndexOf('.');
      if (dot != -1 && dot < fname.length - 1) {
        final ext = fname.substring(dot);
        // Validar que parezca una extensión
        if (RegExp(r'^\.[A-Za-z0-9]+$').hasMatch(ext)) return ext;
      }
      // Intentos básicos por palabras clave en el path
      final lower = path.toLowerCase();
      if (lower.contains('.pdf') || lower.endsWith('pdf')) return '.pdf';
      if (lower.contains('.jpg') || lower.endsWith('jpg')) return '.jpg';
      if (lower.contains('.jpeg') || lower.endsWith('jpeg')) return '.jpeg';
      if (lower.contains('.png') || lower.endsWith('png')) return '.png';
      if (lower.contains('.gif') || lower.endsWith('gif')) return '.gif';
    } catch (_) {}
    return null;
  }
}
