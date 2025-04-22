import 'package:flutter/material.dart';
import '../services/ticket_service.dart';
import '../services/auth_service.dart'; 
import '../models/user.dart';
import '../views/login_screen.dart';
import '../config/environment.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../views/common_pop_ups.dart'; 
import '../services/glpi_general_service.dart';
import 'dart:async';

/// Controlador para manejar las solicitudes de registro.
class RegistrationRequestController {
  final TicketService _ticketService = TicketService();
  final AuthService _authService = AuthService();
  final GlpiGeneralService _glpiGeneralService = GlpiGeneralService();
  final String _appServiceCredentialUsername = Environment.appServiceCredentialUsername;
  final String _appServiceCredentialPassword = Environment.appServiceCredentialPassword;
  final String entity = Environment.entity;
  final User _user = User();

  /// Envía una solicitud de registro con los datos proporcionados.
  /// 
  /// Parámetros:
  /// - [context]: El contexto de la aplicación.
  /// - [nombre]: Nombre del solicitante.
  /// - [apellido]: Apellido del solicitante.
  /// - [empresa]: Empresa del solicitante.
  /// - [correo]: Correo electrónico del solicitante.
  /// - [telefono]: Teléfono del solicitante.
  /// - [cedula]: Cédula del solicitante.
  /// 
  /// Verifica la conectividad antes de enviar la solicitud. Si no hay conexión, muestra un mensaje de error.
  /// Si hay conexión, intenta enviar la solicitud y maneja las respuestas y errores adecuadamente.
  Future<bool> submitRegistrationRequest(
    BuildContext context,
    String nombre,
    String apellido,
    String empresa,
    String correo,
    String telefono,
    String cedula,
  ) async {
    final connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      if (!context.mounted) return false;
      showNoInternetMessage(context); 
      return false;
    }

    try {
      final success = await _authService.login(_appServiceCredentialUsername, _appServiceCredentialPassword);
      
      if (success) {
        final Map<String, dynamic> ticketData = {
          "_users_id_requester": _user.getIdUsuario,
          'name': 'Solicitud de registro: $empresa - $nombre $apellido',
          'content': '''
          Nombre: $nombre
          Apellido: $apellido
          Empresa: $empresa
          Correo Electrónico: $correo
          Número de Teléfono: $telefono
          Cédula: $cedula
          ''',
        };
        ticketData['entities_id'] = await _getEntityId();
        // Envía la solicitud de registro.
        final response = await _ticketService.createTicket(ticketData);

        if (response['success']) {
          if (context.mounted) {
            await _showSuccessMessage(context);
          }
        } else {
          throw Exception('Error al crear la solicitud');
        }

        _authService.logOut();
        if (context.mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LoginScreen()),
          );
        }
        return true;
      } else {
        if (context.mounted) {
          _showErrorMessage(context, 'No pudimos enviar su solicitud de registro. Por favor, intente más tarde.');
        }
        return false;
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop(); 
        if (e is TimeoutException) {
          showTimeoutMessage(context); 
        } else {
          _showErrorMessage(context,'Hubo un error al enviar su solicitud de registro. Por favor, intente de nuevo.');
        }
      }
      return false;
    }
  }

  Future<int> _getEntityId() async {
    Map<String, dynamic> myEntities = await _glpiGeneralService.getMyEntities();
    var myEntitiesList = myEntities['myentities'];
    if (myEntitiesList != null && myEntitiesList is List) {
      var myEntity = myEntitiesList.firstWhere(
        (element) => element['name'] == entity,
        orElse: () => null,
      );

      if (myEntity != null) {
        return int.parse(myEntity['id'].toString());
      }
    }
    throw Exception('Entidad no encontrada');
  }

  void _showErrorMessage(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: const Column(
            children: [
              Icon(Icons.error, color: Colors.red, size: 40),
              SizedBox(height: 10),
              Text('Error'),
            ],
          ),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Aceptar',style: TextStyle(color: Theme.of(context).primaryColor),),
            ),
          ],
        );
      },
    );
  }
  /// Muestra un mensaje de éxito cuando la solicitud de registro se envía correctamente.
  /// 
  /// Parámetros:
  /// - [context]: El contexto de la aplicación.
  Future<void> _showSuccessMessage(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: const Column(
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 40),
              SizedBox(height: 10),
              Text('Registro Exitoso'),
            ],
          ),
          content: const Text('Su solicitud de registro ha sido enviada.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              child: Text('Aceptar',style: TextStyle(color: Theme.of(context).primaryColor),),
            ),
          ],
        );
      },
    );
  }
}