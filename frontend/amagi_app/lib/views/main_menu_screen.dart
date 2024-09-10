// main_menu_screen.dart
import 'package:flutter/material.dart';
import '../controllers/side_menu_controller.dart';
import '../controllers/tickets_controller.dart';
import '../controllers/main_menu_controller.dart';
import '../views/side_menu.dart'; 
import 'package:flutter/cupertino.dart';

class MainMenuScreen extends StatefulWidget {
  @override
  _MainMenuScreenState createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen> {
  final SideMenuController _sideMenuController = SideMenuController();
  final TicketsController _ticketsController = TicketsController();
  final MainMenuController _mainMenuController = MainMenuController();
  Future<Map<String, String>>? _userNameFuture;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _userNameFuture = _sideMenuController.getUserName();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color(0xFF005586), // Set the background color for the entire screen
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: Colors.transparent, // Make the Scaffold background transparent
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.menu, color: Colors.white), // Set the icon color to white
            onPressed: () {
              _scaffoldKey.currentState?.openDrawer();
            },
          ),
          title: Text(
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
          child: Column(
            children: [
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2, // Two buttons per row
                  crossAxisSpacing: 16.0,
                  mainAxisSpacing: 16.0,
                  children: [
                    _buildMenuButton(
                      context,
                      icon: CupertinoIcons.doc_text_search,
                      label: 'Consulta de Tickets',
                      onPressed: () {
                        _ticketsController.navigateToTicketsScreen(context);
                      },
                    ),
                    _buildMenuButton(
                      context,
                      icon: CupertinoIcons.doc_richtext,
                      label: 'Crear Ticket',
                      onPressed: () {
                        _mainMenuController.navigateToCreateTicketScreen(context);
                      },
                    ),
                    _buildMenuButton(
                      context,
                      icon: CupertinoIcons.doc_checkmark,
                      label: 'Tickets Resueltos',
                      onPressed: () {
                        _ticketsController.navigateToTicketsScreen(context, filters: {'status': 5});
                      },
                    ),
                    // Add more buttons here if needed
                  ],
                ),
              ),
              Center(
                child: Image.asset(
                  'assets/Amagi logo blanco.png', // Replace with your image path
                  width: 100, // Set the width of the image
                  height: 100, // Set the height of the image
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuButton(BuildContext context, {required IconData icon, required String label, required VoidCallback onPressed}) {
    return Column(
      children: [
        Container(
          width: 112, // Double the default size (56 * 2)
          height: 112, // Double the default size (56 * 2)
          child: FloatingActionButton(
            onPressed: onPressed,
            backgroundColor: Colors.white,
            child: Icon(icon, color: Colors.black, size: 48), // Icon
          ),
        ),
        SizedBox(height: 8), // Space between button and text
        Container(
          width: 112, // Ensure the text container has the same width as the button
          child: Text(
            label,
            style: TextStyle(
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