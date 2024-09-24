import 'package:flutter/material.dart';
import '../services/ticket_service.dart';
import '../services/auth_service.dart'; 
import '../models/user.dart';
import '../views/login_screen.dart';
import '../config/enviroment.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../views/common_pop_ups.dart'; 
import 'dart:async';

class RegistrationRequestController {
  final TicketService _ticketService = TicketService();
  final AuthService _authService = AuthService();
  final String _appServiceCredentialUsername = Environment.appServiceCredentialUsername;
  final String _appServiceCredentialPassword = Environment.appServiceCredentialPassword;
  final User _user = User();

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
      showNoInternetMessage(context); 
      return false;
    }

    try {
      final success = await _authService.logIn(_appServiceCredentialUsername, _appServiceCredentialPassword);
      
      if (success) {
        final Map<String, dynamic> ticketData = {
          "_users_id_requester": _user.getIdUsuario,
          "entities_id": 0,
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

        final response = await _ticketService.createTicket(ticketData);

        if (response['success']) {
          await _showSuccessMessage(context);
        } else {
          throw Exception('Error al crear la solicitud');
        }

        _authService.logOut();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
        );
        return true;
      } else {
        _showErrorMessage(context, 'No pudimos enviar su solicitud de registro. Por favor, intente más tarde.');
        return false;
      }
    } catch (e) {
      Navigator.of(context).pop(); 
      if (e is TimeoutException) {
        showTimeoutMessage(context); 
      } else {
        _showErrorMessage(context,'Hubo un error al enviar su solicitud de registro. Por favor, intente de nuevo.');
      }
      return false;
    }
  }

  void _showErrorMessage(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: Column(
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

  Future<void> _showSuccessMessage(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: Column(
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 40),
              SizedBox(height: 10),
              Text('Registro Exitoso'),
            ],
          ),
          content: Text('Su solicitud de registro ha sido enviada.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop(); // Regresa a la vista de login
              },
              child: Text('Aceptar',style: TextStyle(color: Theme.of(context).primaryColor),),
            ),
          ],
        );
      },
    );
  }
}