import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'views/login_screen.dart';
import 'views/main_menu_screen.dart';
import 'views/welcome_screen.dart';
import 'views/create_ticket_screen.dart';
import 'views/registration_request_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/user.dart';
import '../services/user_service.dart';
import '../views/loading_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: "general.env");
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]).then((_) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? sessionToken = prefs.getString('sessionToken');

    if (sessionToken != null) {
      final _storage = FlutterSecureStorage();
      await _storage.write(key: 'session_token', value: sessionToken);
    }

    runApp(MyApp());
  });
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Amagi App',
      theme: ThemeData(
        primarySwatch: createMaterialColor(Color(0xFF000000)),
        primaryColor: Color(0xFF000000),
        fontFamily: 'Brandon Grotesque',
        textSelectionTheme: TextSelectionThemeData(
          cursorColor: Color(0xFF005586), // Cambia el color del cursor
          selectionColor: Color(0xFF009FDA), // Cambia el color de la selección
          selectionHandleColor: Color(0xFF747678), // Cambia el color del handle de selección
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white, // Color de fondo del campo de texto
          labelStyle: TextStyle(color: Colors.black), // Color del label
          border: UnderlineInputBorder(), // Línea debajo del campo
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Color(0xFF005586)), // Color de la línea cuando está enfocado
          ),
        ),
      ),
      home: FutureBuilder<bool>(
        future: checkLoginStatus(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return LoadingScreen();
          } else {
            return snapshot.data == true ? MainMenuScreen() : WelcomeScreen();
          }
        },
      ), 
      routes: {
        '/login': (context) => LoginScreen(),
        '/mainMenu': (context) => MainMenuScreen(),
        '/create-ticket': (context) => CreateTicketScreen(),
        '/register': (context) => RegistrationRequestScreen(),
      },
    );
  }

  Future<bool> checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

    if (isLoggedIn) {
      User usuario = User();
      UserService userService = UserService();
      await userService.obtenerUsuarioInfo(usuario);
    }

    return isLoggedIn;
  }
}

MaterialColor createMaterialColor(Color color) {
  List strengths = <double>[.05];
  Map<int, Color> swatch = {};
  final int r = color.red, g = color.green, b = color.blue;

  for (int i = 1; i < 10; i++) {
    strengths.add(0.1 * i);
  }
  strengths.forEach((strength) {
    final double ds = 0.5 - strength;
    swatch[(strength * 1000).round()] = Color.fromRGBO(
      r + ((ds < 0 ? r : (255 - r)) * ds).round(),
      g + ((ds < 0 ? g : (255 - g)) * ds).round(),
      b + ((ds < 0 ? b : (255 - b)) * ds).round(),
      1,
    );
  });
  return MaterialColor(color.value, swatch);
}
