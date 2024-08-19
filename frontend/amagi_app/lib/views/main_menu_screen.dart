
import 'package:flutter/material.dart';
import '../controllers/main_menu_controller.dart';

class MainMenuScreen extends StatefulWidget {
  @override
  _MainMenuScreenState createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen> {
  final MainMenuController _mainMenuController = MainMenuController();
  Future<String>? _userNameFuture;
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
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        drawer: Drawer(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.75, // 75% of screen width
            color: Colors.white,
            child: Column(
              children: <Widget>[
                SizedBox(height: 20), // Add some space above the image and icon
                Container(
                  padding: EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Image.asset(
                        'assets/A logo azul_sin_Digital (1).png', // Replace with your image path
                        width: 50,
                        height: 50,
                      ),
                      SizedBox(width: 8), // Add some space between the image and the text
                      FutureBuilder<String>(
                        future: _userNameFuture,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return CircularProgressIndicator();
                          } else if (snapshot.hasError) {
                            return Text('Error: ${snapshot.error}');
                          } else {
                            return Text(
                              snapshot.data ?? '',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18, // Make the font size larger
                              ),
                            );
                          }
                        },
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
                ),
              ],
            ),
          ),
        ),
        body: Center(
          child: Container(), // Remove the "Welcome, ..." text
        ),
      ),
    );
  }
}