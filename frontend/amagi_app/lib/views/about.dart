import 'dart:async';
import 'package:flutter/material.dart';
import '../views/main_menu_screen.dart';

/// Pantalla de "Acerca de" que muestra información sobre la aplicación y sus características.

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> with SingleTickerProviderStateMixin {

  Future<bool> _onWillPop(BuildContext context) async {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const MainMenuScreen()),
      (route) => false,
    );
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => _onWillPop(context),
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text(
            'Acerca de',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: const Color(0xFF005586),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => _onWillPop(context),
          ),
        ),
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 15.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: const Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: 'GIA App  ',
                          style: TextStyle(
                            fontSize: 22.0,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF005586),
                          ),
                        ),
                        TextSpan(
                          text: 'Versión 1.1.0\n\n',
                          style: TextStyle(
                            fontSize: 15.0,
                            color: Color(0xFF005586),
                          ),
                        ),
                        TextSpan(
                          text: 'Aplicación de autogestión para usuarios del servicio GIA de Amagi Group.\n\n'
                              '✨ Características clave\n\n'
                              '📝 Creación de tickets.\n'
                              '📋 Visualización detallada de todos los casos del usuario.\n'
                              '🔍 Acceso al historial, seguimiento y soluciones de cada ticket.\n'
                              '💬 Comunicación mediante chat integrado con el equipo de asistencia.\n'
                              '📎 Posibilidad de agregar comentarios, archivos y fotos.\n'
                              '✅ Validación o rechazo de soluciones.',
                          style: TextStyle(
                            fontSize: 15.0,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.left, 
                  ),
                ),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '   ¡Estamos en constante evolución y mejora!\n',
                      style: TextStyle(
                        fontSize: 15.0,
                        color: Color(0xFF005586),
                      ),
                    ),
                    SizedBox(width: 5), 
                    Icon(
                      Icons.flutter_dash,
                      color: Color(0xFF005586),
                    ),
                  ],
                ),
                const Divider(
                  thickness: 0.5,
                  color: Colors.grey,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
