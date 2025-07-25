import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../controllers/side_menu_controller.dart';
import '../controllers/tickets_controller.dart';
import '../controllers/main_menu_controller.dart';
import '../views/side_menu.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import '../services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  final AuthService _authService = AuthService();
  DateTime? _lastPressedAt;

  Future<void> _saveSelectedOption(String option) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedOption', option);
  }

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
        if (_lastPressedAt == null ||
            now.difference(_lastPressedAt!) > const Duration(seconds: 2)) {
          _lastPressedAt = now;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Pulse otra vez para salir de la aplicación'),
              duration: Duration(seconds: 2),
            ),
          );
          return false;
        }
        await _authService.logOut();
        SystemNavigator.pop();
        return true;
      },
      child: Container(
        color: const Color(0xFF005586),
        child: Scaffold(
          key: _scaffoldKey,
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.menu, color: Colors.white),
              onPressed: () async {
                await _saveSelectedOption('Inicio');
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
            centerTitle: true,
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
                alignment: Alignment.topCenter,
                child: LayoutBuilder(builder: (context, constraints) {
                  final containerWidth = constraints.maxWidth > 600
                      ? 500.0
                      : constraints.maxWidth * 0.9;
                  final containerHeight = containerWidth * 1.33;
                  final buttonSize = containerWidth * 0.4;
                  final horizontalPadding =
                      (containerWidth - buttonSize * 2) / 6;

                  return SizedBox(
                    width: containerWidth,
                    height: containerHeight,
                    child: Stack(
                      children: [
                        Positioned(
                          top: 0,
                          left: horizontalPadding,
                          child: _buildMenuButton(
                            context,
                            icon: Symbols.document_search,
                            label: 'Consulta de Tickets',
                            onPressed: () async {
                              await _saveSelectedOption('Consulta de Tickets');
                              _ticketsController
                                  .navigateToTicketsScreen(context);
                            },
                            buttonSize: buttonSize,
                          ),
                        ),
                        Positioned(
                          top: 0,
                          right: horizontalPadding,
                          child: _buildMenuButton(
                            context,
                            icon: Symbols.note_add,
                            label: 'Crear Ticket',
                            onPressed: () async {
                              await _saveSelectedOption('Crear Ticket');
                              _mainMenuController
                                  .navigateToCreateTicketScreen(context);
                            },
                            buttonSize: buttonSize,
                          ),
                        ),
                        Positioned(
                          bottom: constraints.maxHeight * 0.070,
                          left: horizontalPadding,
                          child: _buildMenuButton(
                            context,
                            icon: Symbols.unknown_document,
                            label: 'Tickets Resueltos',
                            onPressed: () async {
                              await _saveSelectedOption('Tickets Resueltos');
                              _ticketsController
                                  .navigateToTicketsResolvedScreen(context,
                                      filters: {'status': 5});
                            },
                            buttonSize: buttonSize,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuButton(BuildContext context,
      {required IconData icon,
      required String label,
      required VoidCallback onPressed,
      required double buttonSize}) {
    final iconSize = buttonSize * 0.60;

    return Column(
      children: [
        SizedBox(
          width: buttonSize,
          height: buttonSize,
          child: FloatingActionButton(
            onPressed: onPressed,
            backgroundColor: Colors.white,
            child: Icon(icon, color: Colors.blueGrey, size: iconSize),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: buttonSize,
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}
