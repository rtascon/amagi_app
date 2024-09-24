import 'package:flutter/material.dart';
import '../controllers/side_menu_controller.dart';
import '../controllers/tickets_controller.dart';
import 'package:flutter/cupertino.dart';

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
                        'assets/Solo la a (1).png', // Replace with your image path
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
                      /*
                      IconButton(
                        icon: Icon(Icons.settings),
                        onPressed: () {
                          // Handle settings button tap
                        },
                      ),
                      */
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
                      Icon(Icons.home, color: Colors.black), // Home icon
                      SizedBox(width: 8), // Space between icon and text
                      TextButton(
                        onPressed: () {
                          sideMenuController.navigateToMainMenuScreen(context);
                        },
                        child: Text(
                          'Inicio',
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
                      Icon(CupertinoIcons.doc_text_search, color: Colors.black), // Ticket icon
                      SizedBox(width: 8), // Space between icon and text
                      TextButton(
                        onPressed: () {
                          ticketsController.navigateToTicketsScreen(context);
                        },
                        child: Text(
                          'Consulta de Tickets',
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
                          Icon(CupertinoIcons.doc_richtext, color: Colors.black, size: 24), 
                        ],
                      ),
                      SizedBox(width: 8), 
                      TextButton(
                        onPressed: () {
                          sideMenuController.navigateToCreateTicketScreen(context);
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
                  Row(
                    children: [
                      Icon(CupertinoIcons.doc_checkmark, color: Colors.black), // Resolved tickets icon
                      SizedBox(width: 8), // Space between icon and text
                      TextButton(
                        onPressed: () {
                          ticketsController.navigateToTicketsScreen(context, filters: {'status': 5});
                        },
                        child: Text(
                          'Tickets Resueltos',
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
                          sideMenuController.logOut(context);
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
                  'assets/Amagi logo azul_Pequeño.png', // Replace with your image path
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