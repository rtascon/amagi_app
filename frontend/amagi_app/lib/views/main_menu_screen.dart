// main_menu_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../controllers/side_menu_controller.dart';
import '../controllers/tickets_controller.dart';
import '../controllers/main_menu_controller.dart';
import '../views/side_menu.dart';
import 'package:flutter/cupertino.dart';
import '../services/auth_service.dart'; // Importar AuthService

/// Esta vista representa el menú principal de la aplicación, desde donde los usuarios
/// pueden navegar a diferentes secciones, como la creación y consulta de tickets.

class MainMenuScreen extends StatefulWidget {
  const MainMenuScreen({super.key});

  @override
  MainMenuScreenState createState() => MainMenuScreenState();
}

class MainMenuScreenState extends State<MainMenuScreen> {
  final SideMenuController _sideMenuController = SideMenuController();
  final TicketsController _ticketsController = TicketsController();
  final MainMenuController _mainMenuController = MainMenuController();
  Future<Map<String, String>>? _userNameFuture;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final AuthService _authService = AuthService(); // Instanciar AuthService
  DateTime? _lastPressedAt;

  @override
  void initState() {
    super.initState();
    _userNameFuture = _sideMenuController.getUserName();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        final now = DateTime.now();
        if (_lastPressedAt == null || now.difference(_lastPressedAt!) > const Duration(seconds: 2)) {
          _lastPressedAt = now;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Pulse otra vez para salir de la aplicación'),
              duration: Duration(seconds: 2),
            ),
          );
          return false;
        }
        await _authService.logOut(); // Llamar a logOut
        SystemNavigator.pop(); // Cerrar la aplicación
        return true;
      },
      child: Container(
        color: const Color(0xFF005586), // Set the background color for the entire screen
        child: Scaffold(
          key: _scaffoldKey,
          backgroundColor: Colors.transparent, // Make the Scaffold background transparent
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.menu, color: Colors.white), // Set the icon color to white
              onPressed: () {
                _scaffoldKey.currentState?.openDrawer();
              },
            ),
            title: const Text(
              'Servicio GIA',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true, // Ensure the title is centered
          ),
          drawer: SideMenu(
            sideMenuController: _sideMenuController,
            ticketsController: _ticketsController,
            userNameFuture: _userNameFuture,
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: Align(
                alignment: Alignment.topCenter, // Centrar en la parte superior
                child: Container(
                  width: 300, // Ajusta el tamaño del contenedor central según sea necesario
                  height: 400,
                  child: Stack(
                    children: [
                      Positioned(
                        top: 0,
                        left: 10,
                        height: 200, // Altura del botón
                        child: _buildMenuButton(
                          context,
                          icon: CupertinoIcons.doc_text_search,
                          label: 'Consulta de Tickets',
                          onPressed: () {
                            _ticketsController.navigateToTicketsScreen(context);
                          },
                        ),
                      ),
                      Positioned(
                        top: 0,
                        right: 10,
                        height: 200, // Altura del botón
                        child: _buildMenuButton(
                          context,
                          icon: CupertinoIcons.doc_append,
                          label: 'Crear Ticket',
                          onPressed: () {
                            _mainMenuController.navigateToCreateTicketScreen(context);
                          },
                        ),
                      ),
                      Positioned(
                        bottom: 0, // Aumentar el espacio desde la parte inferior
                        left: 10,
                        height: 200, // Altura del botón
                        child: _buildMenuButton(
                          context,
                          icon: CupertinoIcons.doc_checkmark,
                          label: 'Tickets Resueltos',
                          onPressed: () {
                            _ticketsController.navigateToTicketsScreen(context, filters: {'status': 5});
                          },
                        ),
                      ),
                      // Añadir más botones aquí si es necesario
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuButton(BuildContext context, {required IconData icon, required String label, required VoidCallback onPressed}) {
    return Column(
      children: [
        SizedBox(
          width: 112, // Double the default size (56 * 2)
          height: 112, // Double the default size (56 * 2)
          child: FloatingActionButton(
            onPressed: onPressed,
            backgroundColor: Colors.white,
            child: Icon(icon, color: Colors.blueGrey, size: 48), // Icon
          ),
        ),
        const SizedBox(height: 8), // Space between button and text
        SizedBox(
          width: 112, // Ensure the text container has the same width as the button
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
            textAlign: TextAlign.center, // Center the text
          ),
        ),
      ],
    );
  }
}
