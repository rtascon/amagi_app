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
        color: Theme.of(context).colorScheme.primaryContainer,
        child: Scaffold(
          key: _scaffoldKey,
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            leading: IconButton(
              icon: Icon(Icons.menu,
                  color: Theme.of(context).colorScheme.onPrimaryContainer),
              onPressed: () async {
                await _saveSelectedOption('Inicio');
                _scaffoldKey.currentState?.openDrawer();
              },
            ),
            title: Text(
              'Servicio GIA',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onPrimaryContainer,
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
                      ? 400.0
                      : constraints.maxWidth * 0.8;
                  final buttonSize = containerWidth * 0.45;
                  final squareSize = containerWidth;
                  const offset = 0.0;
                  final bottomOffset = squareSize - buttonSize;

                  return SizedBox(
                    width: squareSize,
                    height: squareSize,
                    child: Stack(
                      children: [
                        Positioned(
                          top: offset,
                          left: offset,
                          child: _buildMenuButton(
                            context,
                            icon: Symbols.document_search,
                            label: 'En Proceso',
                            onPressed: () async {
                              await _saveSelectedOption('Consulta de Tickets');
                              _ticketsController
                                  .navigateToTicketsScreen(context);
                            },
                            buttonSize: buttonSize,
                          ),
                        ),
                        Positioned(
                          top: offset,
                          right: offset,
                          child: _buildMenuButton(
                            context,
                            icon: Symbols.note_add,
                            label: 'Crear',
                            onPressed: () async {
                              await _saveSelectedOption('Crear Ticket');
                              _mainMenuController
                                  .navigateToCreateTicketScreen(context);
                            },
                            buttonSize: buttonSize,
                          ),
                        ),
                        Positioned(
                          left: offset,
                          top: bottomOffset,
                          child: _buildMenuButton(
                            context,
                            icon: Symbols.unknown_document,
                            label: 'Resuelto',
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
    final iconSize = buttonSize * 0.5 + 10;

    return SizedBox(
      width: buttonSize,
      height: buttonSize,
      child: FloatingActionButton(
        onPressed: onPressed,
        backgroundColor: Theme.of(context).colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon,
                color: Theme.of(context).colorScheme.primaryContainer,
                size: iconSize),
            const SizedBox(height: 5),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  fontSize: 16.5,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
