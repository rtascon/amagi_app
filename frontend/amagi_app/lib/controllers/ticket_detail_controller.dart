import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';

class TicketDetailController {
  void navigateBack(BuildContext context) {
    Navigator.pop(context);
  }

  Future<void> downloadFile(String pathOrUrl, String fileName) async {
    // Verificar si es una ruta local
    if (File(pathOrUrl).existsSync()) {
      print("File already exists at: $pathOrUrl");
      await _saveFileToDeviceStorage(pathOrUrl, fileName);
      return;
    }

    // Verificar si la URL es válida
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
      String savePath = "${dir.path}/$fileName";
      await dio.download(pathOrUrl, savePath);
      print("File downloaded to $savePath");
      await _saveFileToDeviceStorage(savePath, fileName);
    } catch (e) {
      print("Error downloading file: $e");
    }
  }

  Future<void> _saveFileToDeviceStorage(String localPath, String fileName) async {
    try {
      var status = await Permission.storage.status;
      if (!status.isGranted) {
        status = await Permission.storage.request();
        if (!status.isGranted) {
          print("Storage permission denied");
          return;
        }
      }

      Directory? externalDir = await getExternalStorageDirectory();
      if (externalDir != null) {
        String newPath = "${externalDir.path}/$fileName";
        File localFile = File(localPath);
        await localFile.copy(newPath);
        print("File saved to device storage at: $newPath");
      } else {
        print("Unable to access external storage directory");
      }
    } catch (e) {
      print("Error saving file to device storage: $e");
    }
  }
}