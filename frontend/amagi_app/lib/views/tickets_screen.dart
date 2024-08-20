import 'package:flutter/material.dart';

class TicketsScreen extends StatelessWidget {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
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
        backgroundColor: Color(0xFF747678), // Set the background color
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
                            Text(
                              'Usuario', // Replace with actual user name
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18, // Make the font size larger
                              ),
                            ),
                            Text(
                              'Email', // Replace with actual user email
                              style: TextStyle(
                                fontSize: 16, // Slightly smaller font size
                              ),
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
                        Icon(Icons.person, color: Colors.black), // Profile icon
                        SizedBox(width: 8), // Space between icon and text
                        Text(
                          'Mis perfiles',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8), // Add space between the title and the profiles
                    // Add profiles list here
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
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => TicketsScreen()),
                            );
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
                            // Handle logout
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
      body: Container(
        color: Colors.white, // Set the background color to white
        child: Center(
          child: Text('Lista de Tickets'), // Placeholder for the list of tickets
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Handle button press
        },
        backgroundColor: Color(0xFFE98300),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Icon(Icons.add, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}