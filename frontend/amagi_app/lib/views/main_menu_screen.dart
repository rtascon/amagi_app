// main_menu_screen.dart
import 'package:flutter/material.dart';
import '../controllers/side_menu_controller.dart';
import '../controllers/tickets_controller.dart';
import '../views/side_menu.dart'; 
import 'package:flutter/cupertino.dart';

class MainMenuScreen extends StatefulWidget {
  @override
  _MainMenuScreenState createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen> {
  final SideMenuController _sideMenuController = SideMenuController();
  final TicketsController _ticketsController = TicketsController();
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
      color: Color(0xFF747678), // Set the background color for the entire screen
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
        body: Stack(
          children: [
            Positioned(
              top: MediaQuery.of(context).size.height * 0.1, // Position near the top
              left: MediaQuery.of(context).size.width * 0.1, // Position near the left
              child: Column(
                children: [
                  Container(
                    width: 112, // Double the default size (56 * 2)
                    height: 112, // Double the default size (56 * 2)
                    child: FloatingActionButton(
                      onPressed: () {
                        _ticketsController.navigateToTicketsScreen(context);
                      },
                      backgroundColor: Colors.white,
                      child: Icon(CupertinoIcons.doc, color: Colors.black, size: 48), // Ticket icon
                    ),
                  ),
                  SizedBox(height: 8), // Space between button and text
                  Text(
                    'Tickets',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              bottom: 16, // Position at the bottom
              left: 0,
              right: 0,
              child: Center(
                child: Image.asset(
                  'assets/Amagi logo blanco.png', // Replace with your image path
                  width: 100, // Set the width of the image
                  height: 100, // Set the height of the image
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}