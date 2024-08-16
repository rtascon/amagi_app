import 'package:flutter/material.dart';
import '../controllers/main_menu_controller.dart';

class MainMenuScreen extends StatefulWidget {
  @override
  _MainMenuScreenState createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen> {
  final MainMenuController _mainMenuController = MainMenuController();
  Future<String>? _userNameFuture;

  @override
  void initState() {
	super.initState();
  }

  @override
  void didChangeDependencies() {
	super.didChangeDependencies();
	_userNameFuture = _mainMenuController.getUserName(context);
  }

  @override
  Widget build(BuildContext context) {
	return Scaffold(
	  appBar: AppBar(
		title: Text('Main Menu'),
	  ),
	  body: Center(
		child: FutureBuilder<String>(
		  future: _userNameFuture,
		  builder: (context, snapshot) {
			if (snapshot.connectionState == ConnectionState.waiting) {
			  return CircularProgressIndicator();
			} else if (snapshot.hasError) {
			  return Text('Error: ${snapshot.error}');
			} else {
			  return Text('Welcome, ${snapshot.data}');
			}
		  },
		),
	  ),
	);
  }
}