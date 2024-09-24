import 'package:flutter/material.dart';
import '../controllers/welcome_controller.dart'; // Importar el controlador

/// Esta vista muestra una pantalla de bienvenida mientras se verifica el estado de inicio de sesión
/// del usuario. Si el usuario está logueado, se redirige al menú principal; de lo contrario, se redirige a la pantalla de inicio de sesión.

class WelcomeScreen extends StatefulWidget {
  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  late WelcomeController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WelcomeController(context);
    _controller.checkLoginStatus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Color de fondo
      body: Center(
        child: Image.asset(
          'assets/Amagi logo azul_Pequeño.png', // Asegúrate de que la ruta sea correcta
          width: 200, // Ajusta el ancho de la imagen según sea necesario
          height: 200, // Ajusta la altura de la imagen según sea necesario
        ),
      ),
    );
  }
}