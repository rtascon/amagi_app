import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:startup_namer/config/environment.dart';
import '../controllers/side_menu_controller.dart';
import '../controllers/tickets_controller.dart';
import 'package:flutter/cupertino.dart';

/// Esta vista representa el menú lateral de la aplicación, que permite a los usuarios
/// navegar a diferentes secciones de la aplicación, como la creación y consulta de tickets.

class SideMenu extends StatelessWidget {
  final SideMenuController sideMenuController;
  final TicketsController ticketsController;
  final Future<Map<String, String>>? userNameFuture;

    final String url = Environment.apiUrl;
  static const _storage = FlutterSecureStorage();
  static const _sessionTokenKey = 'session_token';

  SideMenu({super.key, 
    required this.sideMenuController,
    required this.ticketsController,
    required this.userNameFuture,
  });

  Future<Map<String, dynamic>> getUserProfile() async {
    final sessionToken = await _storage.read(key: _sessionTokenKey);
    final userUrl = Uri.parse('$url/getFullSession');
    try {
      final response = await http.get(
        userUrl,
        headers: <String, String>{
          'Session-Token': sessionToken!,
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200 || response.statusCode == 206) {
        final userInfo = jsonDecode(response.body);
        return {
          'glpifriendlyname': userInfo['session']['glpifriendlyname'] ?? '',
          'glpiname': userInfo['session']['glpiname'] ?? '',
          'glpiactiveprofile': userInfo['session']['glpiactiveprofile']['name'] ?? '',
          'glpiactive_entity_name': userInfo['session']['glpiactive_entity_name'] ?? '',
          'glpiactive_entity': userInfo['session']['glpiactive_entity'] ?? 0,
        };
      } else {
        throw Exception("Error al obtener el perfil del usuario: ${response.body}");
      }
    } on TimeoutException catch (e) {
      throw Exception("La solicitud ha excedido el tiempo de espera: $e");
    } catch (e) {
      throw Exception("Error al obtener el perfil del usuario: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.75, // 75% of screen width
        color: Colors.white,
        child: Column(
          children: <Widget>[
            const SizedBox(height: 50), // Reduce the space above the image and icon
            Container(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      Image.asset(
                        'assets/Solo la a (1).png', // Replace with your image path
                        width: 50,
                        height: 50,
                      ),
                      const SizedBox(width: 8), // Add some space between the image and the text
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          FutureBuilder<Map<String, dynamic>>(
                            future: getUserProfile(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return const CircularProgressIndicator();
                              } else if (snapshot.hasError) {
                                return Text('Error: ${snapshot.error}');
                              } else {
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      snapshot.data?['glpifriendlyname'] ?? '',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18, // Make the font size larger
                                      ),
                                    ),
                                    Text(
                                      snapshot.data?['glpiname'] ?? '',
                                      style: const TextStyle(
                                        fontSize: 16, // Slightly smaller font size
                                      ),
                                    ),
                                    Text(
                                      snapshot.data?['glpiactiveprofile']?.replaceAll('_', ' ') ?? '',
                                      style: const TextStyle(
                                        fontSize: 14, // Slightly smaller font size
                                        color: Color.fromARGB(255, 0, 0, 0), // Different color for profile name
                                      ),
                                    ),
                                    Text(
                                      snapshot.data?['glpiactive_entity_name']?.substring(0, 3) ?? '',
                                      style: const TextStyle(
                                        fontSize: 14, // Slightly smaller font size
                                        color: Color.fromARGB(255, 0, 0, 0), // Different color for entity name
                                      ),
                                    ),

                                  ],
                                );
                              }
                            },
                          ),
                        ],
                      ),
                      const Spacer(),
                      /*
                      IconButton(
                        icon: Icon(Icons.settings),
                        onPressed: () {
                          // Handle settings button tap
                        },
                      ),
                      */
                    ],
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Divider(
                      thickness: 1,
                      color: Colors.grey,
                    ),
                  ),
                  Row(
                    children: [
                      const Icon(Icons.home, color: Colors.black), // Home icon
                      const SizedBox(width: 8), // Space between icon and text
                      TextButton(
                        onPressed: () {
                          sideMenuController.navigateToMainMenuScreen(context);
                        },
                        child: const Text(
                          'Inicio',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const Icon(CupertinoIcons.doc_text_search, color: Colors.black), // Ticket icon
                      const SizedBox(width: 8), // Space between icon and text
                      TextButton(
                        onPressed: () {
                          ticketsController.navigateToTicketsScreen(context);
                        },
                        child: const Text(
                          'Consulta de Tickets',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const Stack(
                        children: [
                          Icon(CupertinoIcons.doc_richtext, color: Colors.black, size: 24), 
                        ],
                      ),
                      const SizedBox(width: 8), 
                      TextButton(
                        onPressed: () {
                          sideMenuController.navigateToCreateTicketScreen(context);
                        },
                        child: const Text(
                          'Crear Ticket',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const Icon(CupertinoIcons.doc_checkmark, color: Colors.black), // Resolved tickets icon
                      const SizedBox(width: 8), // Space between icon and text
                      TextButton(
                        onPressed: () {
                          ticketsController.navigateToTicketsScreen(context, filters: {'status': 5});
                        },
                        child: const Text(
                          'Tickets Resueltos',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Divider(
                      thickness: 1,
                      color: Colors.grey,
                    ),
                  ),
                  Row(
                    children: [
                      const Icon(Icons.logout, color: Colors.black),
                      const SizedBox(width: 8), // Space between icon and text
                      TextButton(
                        onPressed: () {
                          sideMenuController.logOut(context);
                        },
                        child: const Text(
                          'Cerrar Sesión',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Spacer(), // Pushes the image to the bottom
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Image.asset(
                  'assets/Amagi logo azul_Pequeño.png', // Replace with your image path
                  width: 100, // Set the desired width
                  height: 100, // Set the desired height
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}