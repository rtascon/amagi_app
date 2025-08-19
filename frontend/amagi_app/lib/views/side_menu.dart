import 'dart:async';
import 'package:flutter/material.dart';
import 'package:gia_app/views/about.dart';
import '../controllers/side_menu_controller.dart';
import '../controllers/tickets_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import '../theme/app_theme.dart';

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

  String abbreviateName(String name) {
    if (name.length <= 25) return name;
    final words = name.split(' ');
    return words.map((w) => w.isNotEmpty ? w[0] : '').join();
  }

  Future<void> _closeDrawerAndNavigate(
      Future<void> Function() navigateFunction) async {
    Navigator.of(context).pop();
    await navigateFunction();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final horizontalPadding = screenWidth * 0.04;
    final verticalPadding = screenHeight * 0.02;

    return WillPopScope(
      onWillPop: () async => true,
      child: Drawer(
        child: Container(
          width: screenWidth * 0.75,
          color: AppColors.white,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isSmallScreen = constraints.maxWidth < 400;
              final fontSizeTitle = isSmallScreen ? 17.0 : 22.0;
              final fontSize = isSmallScreen ? 17.0 : 22.0;
              final iconSize = isSmallScreen ? 28.0 : 32.0;
              const iconColor = AppColors.darkBlue;

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
                              'assets/picture/shared_logo_a_sola_azul.png',
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
                                              fontSize: fontSizeTitle - .5,
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
                                                style: const TextStyle(
                                                  fontSize: 10,
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
                                                style: const TextStyle(
                                                  fontSize: 10,
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
                                                style: const TextStyle(
                                                  fontSize: 10,
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
                          ],
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(
                              vertical: verticalPadding * 0.5),
                          child: const Divider(
                            thickness: 1,
                            color: AppColors.blueGrey,
                          ),
                        ),
                        // ====================== MENÚ BOTONES ======================
                        Column(
                          children: [
                            _buildMenuButton(
                              icon: Icons.home_outlined,
                              label: 'Inicio',
                              selectedValue: 'Inicio',
                              onTap: () => _closeDrawerAndNavigate(() async =>
                                  widget.sideMenuController
                                      .navigateToMainMenuScreen(context)),
                              fontSize: fontSize,
                              iconColor: iconColor,
                              iconSize: iconSize,
                            ),
                            _buildMenuButton(
                              icon: Symbols.document_search,
                              label: 'Tickets en Proceso',
                              selectedValue: 'Consulta de Tickets',
                              onTap: () => _closeDrawerAndNavigate(() async =>
                                  widget.ticketsController
                                      .navigateToTicketsScreen(context)),
                              fontSize: fontSize,
                              iconColor: iconColor,
                              iconSize: iconSize,
                            ),
                            _buildMenuButton(
                              icon: Symbols.note_add,
                              label: 'Crear Ticket',
                              selectedValue: 'Crear Ticket',
                              onTap: () => _closeDrawerAndNavigate(() async =>
                                  widget.sideMenuController
                                      .navigateToCreateTicketScreen(context)),
                              fontSize: fontSize,
                              iconColor: iconColor,
                              iconSize: iconSize,
                            ),
                            _buildMenuButton(
                              icon: Symbols.unknown_document,
                              label: 'Tickets Resueltos',
                              selectedValue: 'Tickets Resueltos',
                              onTap: () => _closeDrawerAndNavigate(() async =>
                                  widget.ticketsController
                                      .navigateToTicketsResolvedScreen(context,
                                          filters: {'status': 5})),
                              fontSize: fontSize,
                              iconColor: iconColor,
                              iconSize: iconSize,
                            ),
                            _buildMenuButton(
                              icon: Icons.info_outline,
                              label: 'Acerca de',
                              selectedValue: '',
                              onTap: () => _closeDrawerAndNavigate(() async =>
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (_) =>
                                              const AboutScreen()))),
                              fontSize: fontSize,
                              iconColor: iconColor,
                              iconSize: iconSize,
                            ),
                            _buildMenuButton(
                              icon: Icons.logout,
                              label: 'Cerrar Sesión',
                              selectedValue: '',
                              onTap: () => _closeDrawerAndNavigate(() async =>
                                  widget.sideMenuController.logOut(context)),
                              fontSize: fontSize,
                              iconColor: iconColor,
                              iconSize: iconSize,
                            ),
                          ],
                        ),
                        // ===========================================================
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
                            'assets/picture/shared_logo_completo_azul_sin_a.png',
                            alignment: const Alignment(0.0, -2),
                            width: 200,
                            height: 100,
                          ),
                          if (!_showAnimatedImage)
                            Image.asset(
                              'assets/picture/shared_logo_completo_azul_solo_a.png',
                              alignment: const Alignment(0.0, -2),
                              width: 200,
                              height: 70,
                            ),
                          if (_showAnimatedImage)
                            SlideTransition(
                              position: _offsetAnimation,
                              child: Image.asset(
                                'assets/picture/shared_logo_completo_azul_solo_a.png',
                                width: 200,
                                height: 70,
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

  Widget _buildMenuButton({
    required IconData icon,
    required String label,
    required String selectedValue,
    required Future<void> Function() onTap,
    required double fontSize,
    required Color iconColor,
    required double iconSize,
  }) {
    return Row(
      children: [
        Icon(icon, color: iconColor, size: iconSize),
        SizedBox(width: 10),
        Expanded(
          child: ValueListenableBuilder<String>(
            valueListenable: selectedOptionMenu,
            builder: (context, value, child) {
              return TextButton(
                onPressed: () async {
                  if (selectedValue.isNotEmpty) {
                    selectedOptionMenu.value = selectedValue;
                    await _saveSelectedOptionMenu(selectedValue);
                  }
                  await onTap();
                },
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    label,
                    style: TextStyle(
                      color: selectedValue.isNotEmpty && value == selectedValue
                          ? AppColors.darkBlue
                          : AppColors.black,
                      fontSize: fontSize,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
