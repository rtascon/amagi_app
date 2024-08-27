// side_menu.dart
import 'package:flutter/material.dart';
import '../controllers/side_menu_controller.dart';
import '../controllers/tickets_controller.dart';

class SideMenu extends StatelessWidget {
  final SideMenuController sideMenuController;
  final TicketsController ticketsController;
  final Future<Map<String, String>>? userNameFuture;

  SideMenu({
    required this.sideMenuController,
    required this.ticketsController,
    required this.userNameFuture,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
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
                            future: userNameFuture,
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
                          ticketsController.navigateToTicketsScreen(context);
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
                            child: Icon(Icons.add, color: Colors.white, size: 12), // Plus icon
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
                          sideMenuController.cerrarSesion(context);
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
            Spacer(), // Pushes the image to the bottom
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Image.asset(
                  'assets/Amagi logo azul_sin_Digital.png', // Replace with your image path
                  width: 100, // Set the desired width
                  height: 100, // Set the desired height
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}