import 'dart:async';
import 'package:flutter/material.dart';
import '../controllers/side_menu_controller.dart';
import '../controllers/tickets_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Esta vista representa el menú lateral de la aplicación, que permite a los usuarios
/// navegar a diferentes secciones de la aplicación, como la creación y consulta de tickets.

class SideMenu extends StatefulWidget {
  final SideMenuController sideMenuController;
  final TicketsController ticketsController;
  final Future<Map<String, String>>? userNameFuture;

  const SideMenu({
    super.key,
    required this.sideMenuController,
    required this.ticketsController,
    required this.userNameFuture,
  });

  @override
  _SideMenuState createState() => _SideMenuState();
}

class _SideMenuState extends State<SideMenu> {
  late ValueNotifier<String> selectedOptionMenu;

  @override
  void initState() {
    super.initState();
    selectedOptionMenu = ValueNotifier<String>('');
    _loadSelectedOptionMenu();
  }

  Future<void> _loadSelectedOptionMenu() async {
    final prefs = await SharedPreferences.getInstance();
    selectedOptionMenu.value = prefs.getString('selectedOption') ?? '';
  }

  Future<void> _saveSelectedOptionMenu(String option) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedOption', option);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => true,
      child: Drawer(
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
                          width: 80,
                          height: 80,
                        ),
                        const SizedBox(width: 8), // Add some space between the image and the text
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            FutureBuilder<Map<String, dynamic>>(
                              future: widget.sideMenuController.getUserProfile(),
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
                                      Row(
                                        children: [
                                          const Icon(Icons.person_outline, color: Color(0xFF005586), size: 20,), // Person icon
                                          const SizedBox(width: 2), // Space between icon and text
                                          Text(
                                            snapshot.data?['glpiname'] ?? '',
                                            style: const TextStyle(
                                              fontSize: 16, // Slightly smaller font size
                                              color: Color(0xFF005586), // Color for glpiname
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          const Icon(Icons.badge_outlined, color: Color(0xFF005586), size: 20,), // Badge icon
                                          const SizedBox(width: 2), // Space between icon and text
                                          Text(
                                            snapshot.data?['glpiactiveprofile']?.replaceAll('_', ' ') ?? '',
                                            style: const TextStyle(
                                              fontSize: 14, // Slightly smaller font size
                                              color: Color(0xFF005586), // Different color for profile name
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          const Icon(Icons.work_outline, color: Color(0xFF005586), size: 20,), // Apartment icon
                                          const SizedBox(width: 2), // Space between icon and text
                                          Text(
                                            snapshot.data?['glpiactive_entity_name']?.substring(0, 3) ?? '',
                                            style: const TextStyle(
                                              fontSize: 14, // Slightly smaller font size
                                              color: Color(0xFF005586), // Different color for entity name
                                            ),
                                          ),
                                        ],
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
                        const Icon(Icons.home_outlined, color: Colors.black), 
                        const SizedBox(width: 8), 
                        ValueListenableBuilder<String>(
                          valueListenable: selectedOptionMenu,
                          builder: (context, value, child) {
                            return TextButton(
                              onPressed: () async {
                                selectedOptionMenu.value = 'Inicio';
                                await _saveSelectedOptionMenu('Inicio');
                                widget.sideMenuController.navigateToMainMenuScreen(context);
                              },
                              child: Text(
                                'Inicio',
                                style: TextStyle(
                                  color: value == 'Inicio' ? Color(0xFF005586) : Colors.black,
                                  fontSize: 16,
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        const Icon(CupertinoIcons.doc_text_search, color: Colors.black), // Ticket icon
                        const SizedBox(width: 8), // Space between icon and text
                        ValueListenableBuilder<String>(
                          valueListenable: selectedOptionMenu,
                          builder: (context, value, child) {
                            return TextButton(
                              onPressed: () async {
                                selectedOptionMenu.value = 'Consulta de Tickets';
                                await _saveSelectedOptionMenu('Consulta de Tickets');
                                widget.ticketsController.navigateToTicketsScreen(context);
                              },
                              child: Text(
                                'Consulta de Tickets',
                                style: TextStyle(
                                  color: value == 'Consulta de Tickets' ? Color(0xFF005586) : Colors.black,
                                  fontSize: 16,
                                ),
                              ),
                            );
                          },
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
                        ValueListenableBuilder<String>(
                          valueListenable: selectedOptionMenu,
                          builder: (context, value, child) {
                            return TextButton(
                              onPressed: () async {
                                selectedOptionMenu.value = 'Crear Ticket';
                                await _saveSelectedOptionMenu('Crear Ticket');
                                widget.sideMenuController.navigateToCreateTicketScreen(context);
                              },
                              child: Text(
                                'Crear Ticket',
                                style: TextStyle(
                                  color: value == 'Crear Ticket' ? Color(0xFF005586) : Colors.black,
                                  fontSize: 16,
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        const Icon(CupertinoIcons.doc_checkmark, color: Colors.black), // Resolved tickets icon
                        const SizedBox(width: 8), // Space between icon and text
                        ValueListenableBuilder<String>(
                          valueListenable: selectedOptionMenu,
                          builder: (context, value, child) {
                            return TextButton(
                              onPressed: () async {
                                selectedOptionMenu.value = 'Tickets Resueltos';
                                await _saveSelectedOptionMenu('Tickets Resueltos');
                                widget.ticketsController.navigateToTicketsResolvedScreen(context, filters: {'status': 5});
                              },
                              child: Text(
                                'Tickets Resueltos',
                                style: TextStyle(
                                  color: value == 'Tickets Resueltos' ? Color(0xFF005586) : Colors.black,
                                  fontSize: 16,
                                ),
                              ),
                            );
                          },
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
                            widget.sideMenuController.logOut(context);
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
      ),
    );
  }
}