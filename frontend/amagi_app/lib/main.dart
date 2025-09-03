import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'views/main_menu_screen.dart';
import 'views/welcome_screen.dart';
import 'views/login_screen.dart';
import 'views/create_ticket_screen.dart';
import 'views/registration_request_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'theme/app_theme.dart';
import 'services/ticket_service.dart';
import 'dart:io' show Platform;
import 'package:workmanager/workmanager.dart';
import 'notifications/estado.dart';

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
      const storage = FlutterSecureStorage();
      await storage.write(key: 'session_token', value: sessionToken);
    }

    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarDividerColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
      systemNavigationBarContrastEnforced: false,
    ));

    // Inicializar notificaciones locales
    await TicketNotifications.init();

    // Test de notificaciones locales en primer arranque
    final tested = prefs.getBool('local_notification_tested') ?? false;
    if (!tested) {
      await TicketNotifications.showTestNotification();
      await prefs.setBool('local_notification_tested', true);
    }

    // Inicializar y registrar tarea periódica (Android)
    if (Platform.isAndroid) {
      await Workmanager().initialize(callbackDispatcher, isInDebugMode: false);
      await Workmanager().registerPeriodicTask(
        'giaTicketPoll', // uniqueName
        'gia.ticket.poll', // taskName
        frequency: const Duration(minutes: 15),
        existingWorkPolicy: ExistingPeriodicWorkPolicy.keep,
        constraints: Constraints(
          networkType: NetworkType.connected,
        ),
        backoffPolicy: BackoffPolicy.exponential,
        backoffPolicyDelay: const Duration(minutes: 10),
      );
    }

    // Configurar keys globales y TicketService antes de ejecutar la app
    final navKey = GlobalKey<NavigatorState>();
    final smKey = GlobalKey<ScaffoldMessengerState>();
    TicketService.configureGlobalKeys(navKey: navKey, smKey: smKey);

    // Ejecuta la aplicación con las keys
    runApp(MyApp(
      navigatorKey: navKey,
      scaffoldMessengerKey: smKey,
    ));
  });
}

class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
    required this.navigatorKey,
    required this.scaffoldMessengerKey,
  });

  final GlobalKey<NavigatorState> navigatorKey;
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GIA App',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      navigatorKey: navigatorKey,
      scaffoldMessengerKey: scaffoldMessengerKey,
      builder: (context, child) {
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: const SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.dark,
            statusBarBrightness: Brightness.light,
            systemNavigationBarColor: Colors.transparent,
            systemNavigationBarDividerColor: Colors.transparent,
            systemNavigationBarIconBrightness: Brightness.dark,
            systemNavigationBarContrastEnforced: false,
          ),
          child: child!,
        );
      },
      home: const WelcomeScreen(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/mainMenu': (context) => const MainMenuScreen(),
        '/create-ticket': (context) => const CreateTicketScreen(),
        '/register': (context) => const RegistrationRequestScreen(),
      },
    );
  }
}

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
