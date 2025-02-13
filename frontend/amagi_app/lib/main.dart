import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:startup_namer/views/TESTencuesta_screen.dart';
import 'views/main_menu_screen.dart';
import 'views/welcome_screen.dart';
import 'views/login_screen.dart';
import 'views/create_ticket_screen.dart';
import 'views/registration_request_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';

/// Punto de entrada principal de la aplicación.
void main() async {
  // Asegura que los widgets se inicialicen correctamente antes de ejecutar el código.
  WidgetsFlutterBinding.ensureInitialized();

  // Carga las variables de entorno desde el archivo "general.env".
  await dotenv.load(fileName: "general.env");

  // Establece la orientación preferida de la aplicación a solo vertical.
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]).then((_) async {
    // Obtiene una instancia de SharedPreferences para acceder a los datos almacenados localmente.
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // Recupera el token de sesión almacenado, si existe.
    String? sessionToken = prefs.getString('sessionToken');

    // Si hay un token de sesión, lo guarda de forma segura usando FlutterSecureStorage.
    if (sessionToken != null) {
      const storage = FlutterSecureStorage();
      await storage.write(key: 'session_token', value: sessionToken);
    }

    // Ejecuta la aplicación.
    runApp(const MyApp());
  });
}

/// Clase principal de la aplicación.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GIA App',
      theme: ThemeData(
        primarySwatch: createMaterialColor(const Color(0xFF000000)),
        primaryColor: const Color(0xFF000000), 
        textTheme: GoogleFonts.notoSansTextTheme(), // Usa la tipografía Noto Sans
        textSelectionTheme: const TextSelectionThemeData(
          cursorColor: Color(0xFF005586), // Cambia el color del cursor
          selectionColor: Color(0xFF009FDA), // Cambia el color de la selección
          selectionHandleColor:
              Color(0xFF747678), // Cambia el color del handle de selección
        ),
        inputDecorationTheme: const InputDecorationTheme(
          filled: true,
          fillColor: Colors.white, // Color de fondo del campo de texto
          labelStyle: TextStyle(color: Colors.black), // Color del label
          border: UnderlineInputBorder(), // Línea debajo del campo
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(
                color: Color(
                    0xFF005586)), // Color de la línea cuando está enfocado
          ),
        ),
      ),
      home: const WelcomeScreen(),
      //home: MainMenuScreen(),
      //home: TestTicketService(),
      //home: TestTicketSatis(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/mainMenu': (context) => const MainMenuScreen(),
        '/create-ticket': (context) => const CreateTicketScreen(),
        '/register': (context) => const RegistrationRequestScreen(),
      },
    );
  }
}

/// Crea un MaterialColor a partir de un Color dado.
MaterialColor createMaterialColor(Color color) {
  List strengths = <double>[.05];
  Map<int, Color> swatch = {};
  final int r = color.red, g = color.green, b = color.blue;

  for (int i = 1; i < 10; i++) {
    strengths.add(0.1 * i);
  }
  for (var strength in strengths) {
    final double ds = 0.5 - strength;
    swatch[(strength * 1000).round()] = Color.fromRGBO(
      r + ((ds < 0 ? r : (255 - r)) * ds).round(),
      g + ((ds < 0 ? g : (255 - g)) * ds).round(),
      b + ((ds < 0 ? b : (255 - b)) * ds).round(),
      1,
    );
  }
  return MaterialColor(color.value, swatch);
}
