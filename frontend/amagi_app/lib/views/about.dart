import 'dart:async';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../views/main_menu_screen.dart';

/// Pantalla de "Acerca de" que muestra información sobre la aplicación y sus características.

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> with SingleTickerProviderStateMixin {
  String _version = '';

  Future<bool> _onWillPop(BuildContext context) async {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const MainMenuScreen()),
      (route) => false,
    );
    return false;
  }

  @override
  void initState() {
    super.initState();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      _version = info.version;
    });
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
                  child: Text.rich(
                    TextSpan(
                      children: [
                        const TextSpan(
                          text: 'GIA App  ',
                          style: TextStyle(
                            fontSize: 22.0,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF005586),
                          ),
                        ),
                        TextSpan(
                          text: 'Versión ${_version.isNotEmpty ? _version : "..."}\n\n',
                          style: const TextStyle(
                            fontSize: 15.0,
                            color: Color(0xFF005586),
                          ),
                        ),
                        const TextSpan(
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
