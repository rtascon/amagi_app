import 'dart:async';
import 'package:flutter/material.dart';
import 'package:gia_app/views/about.dart';
import '../controllers/side_menu_controller.dart';
import '../controllers/tickets_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

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

class _SideMenuState extends State<SideMenu>
    with SingleTickerProviderStateMixin {
  late ValueNotifier<String> selectedOptionMenu;
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;
  bool _showAnimatedImage = false;

  @override
  void initState() {
    super.initState();
    selectedOptionMenu = ValueNotifier<String>('');
    _loadSelectedOptionMenu();

    _controller = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    );

    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.0),
      end: const Offset(1.5, 0.0),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutSine,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadSelectedOptionMenu() async {
    final prefs = await SharedPreferences.getInstance();
    selectedOptionMenu.value = prefs.getString('selectedOption') ?? '';
  }

  Future<void> _saveSelectedOptionMenu(String option) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedOption', option);
  }

  Future<Map<String, dynamic>> _getUserProfileFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'glpifriendlyname': prefs.getString('glpifriendlyname') ?? '',
      'glpiname': prefs.getString('glpiname') ?? '',
      'glpiactiveprofile': prefs.getString('glpiactiveprofile') ?? '',
      'glpiactive_entity_name': prefs.getString('glpiactive_entity_name') ?? '',
    };
  }

  void _onLogoTapped() {
    setState(() {
      _showAnimatedImage = true;
    });

    _controller.forward();

    Timer(_controller.duration!, () {
      setState(() {
        _showAnimatedImage = false;
      });
      _controller.reset();
    });
  }

  /// Abrevia el nombre si tiene más de 25 caracteres, usando las iniciales de cada palabra.
  String abbreviateName(String name) {
    if (name.length <= 25) return name;
    final words = name.split(' ');
    return words.map((w) => w.isNotEmpty ? w[0] : '').join();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    final horizontalPadding = screenWidth * 0.04;
    final verticalPadding = screenHeight * 0.02;
    final avatarSize = screenWidth * 0.18;
    final logoWidth = screenWidth * 0.38;
    final logoHeight = isPortrait ? screenHeight * 0.13 : screenHeight * 0.20;

    return WillPopScope(
      onWillPop: () async => true,
      child: Drawer(
        child: Container(
          width: screenWidth * 0.75,
          color: Colors.white,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isSmallScreen = constraints.maxWidth < 400;
              final fontSizeTitle = isSmallScreen ? 17.0 : 22.0;
              final fontSize = isSmallScreen ? 17.0 : 22.0;
              final iconSize = isSmallScreen ? 28.0 : 32.0;
              const iconColor = Color(0xFF005586);

              return Column(
                children: <Widget>[
                  SizedBox(height: screenHeight * 0.06),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: horizontalPadding,
                      vertical: verticalPadding,
                    ),
                    child: Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Image.asset(
                              'assets/Solo la a (1).png',
                              width: 80,
                              height: 120,
                              fit: BoxFit.contain,
                            ),
                            SizedBox(width: screenWidth * 0.02),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                FutureBuilder<Map<String, dynamic>>(
                                  future: _getUserProfileFromPrefs(),
                                  builder: (context, snapshot) {
                                    if (snapshot.hasError) {
                                      return Text('Error: ${snapshot.error}');
                                    } else {
                                      return Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            abbreviateName(snapshot.data?[
                                                    'glpifriendlyname'] ??
                                                ''),
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: fontSizeTitle,
                                            ),
                                          ),
                                          Row(
                                            children: [
                                              Icon(Icons.person_outline,
                                                  color: iconColor,
                                                  size: iconSize),
                                              const SizedBox(width: 2),
                                              Text(
                                                snapshot.data?['glpiname'] ??
                                                    '',
                                                style: TextStyle(
                                                  fontSize: fontSize,
                                                  color: iconColor,
                                                ),
                                              ),
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              Icon(Icons.badge_outlined,
                                                  color: iconColor,
                                                  size: iconSize),
                                              const SizedBox(width: 2),
                                              Text(
                                                snapshot.data?[
                                                            'glpiactiveprofile']
                                                        ?.replaceAll(
                                                            '_', ' ') ??
                                                    '',
                                                style: TextStyle(
                                                  fontSize: fontSize - 2,
                                                  color: iconColor,
                                                ),
                                              ),
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              Icon(Icons.work_outline,
                                                  color: iconColor,
                                                  size: iconSize),
                                              const SizedBox(width: 2),
                                              Text(
                                                snapshot.data?[
                                                            'glpiactive_entity_name']
                                                        ?.substring(0, 3) ??
                                                    '',
                                                style: TextStyle(
                                                  fontSize: fontSize - 2,
                                                  color: iconColor,
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
                        Padding(
                          padding: EdgeInsets.symmetric(
                              vertical: verticalPadding * 0.5),
                          child: const Divider(
                            thickness: 1,
                            color: Colors.grey,
                          ),
                        ),
                        Column(
                          children: [
                            Row(
                              children: [
                                Icon(Icons.home_outlined,
                                    color: iconColor, size: iconSize),
                                SizedBox(width: screenWidth * 0.02),
                                Expanded(
                                  child: ValueListenableBuilder<String>(
                                    valueListenable: selectedOptionMenu,
                                    builder: (context, value, child) {
                                      return TextButton(
                                        onPressed: () async {
                                          selectedOptionMenu.value = 'Inicio';
                                          await _saveSelectedOptionMenu(
                                              'Inicio');
                                          widget.sideMenuController
                                              .navigateToMainMenuScreen(
                                                  context);
                                        },
                                        child: Align(
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                            'Inicio',
                                            style: TextStyle(
                                              color: value == 'Inicio'
                                                  ? const Color(0xFF005586)
                                                  : Colors.black,
                                              fontSize: fontSize,
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Icon(Symbols.document_search,
                                    color: iconColor, size: iconSize),
                                SizedBox(width: screenWidth * 0.02),
                                Expanded(
                                  child: ValueListenableBuilder<String>(
                                    valueListenable: selectedOptionMenu,
                                    builder: (context, value, child) {
                                      return TextButton(
                                        onPressed: () async {
                                          selectedOptionMenu.value =
                                              'Consulta de Tickets';
                                          await _saveSelectedOptionMenu(
                                              'Consulta de Tickets');
                                          widget.ticketsController
                                              .navigateToTicketsScreen(context);
                                        },
                                        child: Align(
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                            'Consulta de Tickets',
                                            style: TextStyle(
                                              color:
                                                  value == 'Consulta de Tickets'
                                                      ? const Color(0xFF005586)
                                                      : Colors.black,
                                              fontSize: fontSize,
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Stack(
                                  children: [
                                    Icon(Symbols.note_add,
                                        color: iconColor, size: iconSize),
                                  ],
                                ),
                                SizedBox(width: screenWidth * 0.02),
                                Expanded(
                                  child: ValueListenableBuilder<String>(
                                    valueListenable: selectedOptionMenu,
                                    builder: (context, value, child) {
                                      return TextButton(
                                        onPressed: () async {
                                          selectedOptionMenu.value =
                                              'Crear Ticket';
                                          await _saveSelectedOptionMenu(
                                              'Crear Ticket');
                                          widget.sideMenuController
                                              .navigateToCreateTicketScreen(
                                                  context);
                                        },
                                        child: Align(
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                            'Crear Ticket',
                                            style: TextStyle(
                                              color: value == 'Crear Ticket'
                                                  ? const Color(0xFF005586)
                                                  : Colors.black,
                                              fontSize: fontSize,
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Icon(Symbols.unknown_document,
                                    color: iconColor, size: iconSize),
                                SizedBox(width: screenWidth * 0.02),
                                Expanded(
                                  child: ValueListenableBuilder<String>(
                                    valueListenable: selectedOptionMenu,
                                    builder: (context, value, child) {
                                      return TextButton(
                                        onPressed: () async {
                                          selectedOptionMenu.value =
                                              'Tickets Resueltos';
                                          await _saveSelectedOptionMenu(
                                              'Tickets Resueltos');
                                          widget.ticketsController
                                              .navigateToTicketsResolvedScreen(
                                                  context,
                                                  filters: {'status': 5});
                                        },
                                        child: Align(
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                            'Tickets Resueltos',
                                            style: TextStyle(
                                              color:
                                                  value == 'Tickets Resueltos'
                                                      ? const Color(0xFF005586)
                                                      : Colors.black,
                                              fontSize: fontSize,
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(
                              vertical: verticalPadding * 0.5),
                          child: const Divider(
                            thickness: 1,
                            color: Colors.grey,
                          ),
                        ),
                        Row(
                          children: [
                            Icon(Icons.info_outline,
                                color: iconColor, size: iconSize),
                            SizedBox(width: screenWidth * 0.02),
                            Expanded(
                              child: TextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const AboutScreen()),
                                  );
                                },
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    'Acerca de',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: fontSize,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Icon(Icons.logout,
                                color: iconColor, size: iconSize),
                            SizedBox(width: screenWidth * 0.02),
                            Expanded(
                              child: TextButton(
                                onPressed: () {
                                  widget.sideMenuController.logOut(context);
                                },
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    'Cerrar Sesión',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: fontSize,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: GestureDetector(
                      onTap: _onLogoTapped,
                      child: Stack(
                        alignment: const Alignment(0.0, -2),
                        children: [
                          Image.asset(
                            'assets/Amagi logo azul_Pequeño(3).png',
                            alignment: const Alignment(0.0, -2),
                            width: 150,
                            height: 100,
                          ),
                          if (!_showAnimatedImage)
                            Image.asset(
                              'assets/Amagi logo azul_Pequeño(2).png',
                              alignment: const Alignment(0.0, -2),
                              width: 150,
                              height: 61,
                            ),
                          if (_showAnimatedImage)
                            SlideTransition(
                              position: _offsetAnimation,
                              child: Image.asset(
                                'assets/Amagi logo azul_Pequeño(2).png',
                                width: 150,
                                height: 61,
                                alignment: const Alignment(0.0, -2),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
