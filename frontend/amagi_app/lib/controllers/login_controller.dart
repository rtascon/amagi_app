import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../services/auth_service.dart';
import '../services/glpi_general_service.dart';
import '../views/main_menu_screen.dart';
import '../views/loading_screen.dart';
import '../views/registration_request_screen.dart';
import '../views/common_pop_ups.dart'; 
import 'dart:async';

class LoginController {
  final AuthService _authService = AuthService();
  final GlpiGeneralService _glpiGeneralService = GlpiGeneralService();
  final _storage = FlutterSecureStorage();

  void login(String username, String password, BuildContext context) async {
    final connectivityResult = await (Connectivity().checkConnectivity());

    if (connectivityResult == ConnectivityResult.none) {
      showNoInternetMessage(context); 
      return;
    }

    _showLoadingScreen(context); 

    try {
      final formattedUsername = username.toLowerCase().trim();
      final success = await _authService.iniciarSesion(formattedUsername, password);

      Navigator.of(context).pop(); 

      if (success) {
        // Guardar el estado de inicio de sesión
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);
        await prefs.setString('username', formattedUsername);
        String? sessionToken = await _storage.read(key: 'session_token'); 
        await prefs.setString('sessionToken', sessionToken ?? '');
        
        Map<String, dynamic> myEntities = await _glpiGeneralService.getMyEntities();

        var myEntitiesList = myEntities['myentities'];
        if (myEntitiesList != null && myEntitiesList is List) {
          var myEntity = myEntitiesList.firstWhere(
            (element) => element['name'] == 'GIA',
            orElse: () => null,
          );

          if (myEntity != null) {
            int entityId = int.parse(myEntity['id'].toString());
            await _glpiGeneralService.changeActiveEntity(entityId);
            await prefs.setInt('root_entity', entityId);
          } else {
            throw Exception('Entity "GIA" not found');
          }
        } else {
          throw Exception('Invalid structure for myEntities');
        }

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MainMenuScreen()),
        );
      } else {
        _showErrorMessage(context);
      }
    } catch (e) {
      Navigator.of(context).pop(); 
      if (e is TimeoutException) {
        showTimeoutMessage(context); 
      } else {
        _showErrorMessage(context);
      }
    }
  }

  void redirectToRegistration(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => RegistrationRequestScreen()),
    );
  }

  void _showLoadingScreen(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return LoadingScreen();
        },
      );
    });
  }

  void _showErrorMessage(BuildContext context) {
    Color defaultTextButtonColor = TextButton.styleFrom().foregroundColor?.resolve({}) ?? Theme.of(context).primaryColor;
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
              Text('Fallo al iniciar sesión'),
            ],
          ),
          content: Text('Por favor intente de nuevo.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Aceptar', style: TextStyle(color: defaultTextButtonColor)),
            ),
          ],
        );
      },
    );
  }
}