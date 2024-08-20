import 'package:flutter/material.dart';
import '../controllers/main_menu_controller.dart';

class MainMenuScreen extends StatefulWidget {
  @override
  _MainMenuScreenState createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen> {
  final MainMenuController _mainMenuController = MainMenuController();
  Future<Map<String, String>>? _userNameFuture;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _userNameFuture = _mainMenuController.getUserName(context);
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
            icon: Icon(Icons.menu),
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
                      ListTile(
                        leading: Icon(Icons.logout),
                        title: Text('Cerrar Sesión'),
                        onTap: () {
                          _mainMenuController.cerrarSesion(context);
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        body: Container(), // Empty body to avoid duplication
      ),
    );
  }
}