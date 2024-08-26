import 'package:flutter/material.dart';
import '../controllers/main_menu_controller.dart';
import '../controllers/tickets_controller.dart';

class MainMenuScreen extends StatefulWidget {
  @override
  _MainMenuScreenState createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen> {
  final MainMenuController _mainMenuController = MainMenuController();
  final TicketsController _ticketsController = TicketsController();
  Future<Map<String, String>>? _userNameFuture;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _userNameFuture = _mainMenuController.getUserName();
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
        drawer: Drawer(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.75, // 75% of screen width
            color: Colors.white,
            child: Column(
              children: <Widget>[
                SizedBox(height: 50), // Reduce the space above the image and icon
                Container(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Image.asset(
                            'assets/A logo azul_sin_Digital (1).png', // Replace with your image path
                            width: 50,
                            height: 50,
                          ),
                          SizedBox(width: 8), // Add some space between the image and the text
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              FutureBuilder<Map<String, String>>(
                                future: _userNameFuture,
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState == ConnectionState.waiting) {
                                    return CircularProgressIndicator();
                                  } else if (snapshot.hasError) {
                                    return Text('Error: ${snapshot.error}');
                                  } else {
                                    return Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          snapshot.data?['glpifriendlyname'] ?? '',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18, // Make the font size larger
                                          ),
                                        ),
                                        Text(
                                          snapshot.data?['glpiname'] ?? '',
                                          style: TextStyle(
                                            fontSize: 16, // Slightly smaller font size
                                          ),
                                        ),
                                      ],
                                    );
                                  }
                                },
                              ),
                            ],
                          ),
                          Spacer(),
                          IconButton(
                            icon: Icon(Icons.settings),
                            onPressed: () {
                              // Handle settings button tap
                            },
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Divider(
                          thickness: 1,
                          color: Colors.grey,
                        ),
                      ),
                      Row(
                        children: [
                          Icon(Icons.confirmation_number, color: Colors.black), // Ticket icon
                          SizedBox(width: 8), // Space between icon and text
                          TextButton(
                            onPressed: () {
                              _ticketsController.navigateToTicketsScreen(context);
                            },
                            child: Text(
                              'Tickets',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Stack(
                            children: [
                              Icon(Icons.confirmation_number, color: Colors.black, size: 24), // Ticket icon
                              Positioned(
                                right: 0,
                                bottom: 0,
                                child: Icon(Icons.add, color: Colors.black, size: 12), // Plus icon
                              ),
                            ],
                          ),
                          SizedBox(width: 8), // Space between icon and text
                          TextButton(
                            onPressed: () {
                              // Handle button press
                            },
                            child: Text(
                              'Crear Ticket',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Divider(
                          thickness: 1,
                          color: Colors.grey,
                        ),
                      ),
                      Row(
                        children: [
                          Icon(Icons.logout, color: Colors.black),
                          SizedBox(width: 8), // Space between icon and text
                          TextButton(
                            onPressed: () {
                              _mainMenuController.cerrarSesion(context);
                            },
                            child: Text(
                              'Cerrar Sesión',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
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
                      child: Icon(Icons.confirmation_number, color: Colors.black, size: 48), // Ticket icon
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