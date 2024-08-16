import 'package:flutter/material.dart';

class WelcomeScreen extends StatefulWidget {
  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToLogin();
  }

  _navigateToLogin() async {
    await Future.delayed(Duration(seconds: 3), () {});
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Color de fondo
      body: Center(
        child: Image.asset(
          'assets/Amagi logo azul_sin_Digital.png', // Asegúrate de que la ruta sea correcta
          width: 200, // Ajusta el ancho de la imagen según sea necesario
          height: 200, // Ajusta la altura de la imagen según sea necesario
        ),
      ),
    );
  }
}