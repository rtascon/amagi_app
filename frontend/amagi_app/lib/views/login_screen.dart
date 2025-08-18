import 'package:flutter/material.dart';
import '../controllers/login_controller.dart';
import '../theme/app_theme.dart';
import 'dart:io';
import 'package:package_info_plus/package_info_plus.dart';

/// Esta vista permite a los usuarios iniciar sesión en la aplicación, proporcionando su nombre
/// de usuario y contraseña. También incluye opciones para mostrar u ocultar la contraseña.

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _loginController = LoginController();
  bool _obscureText = true;
  String _version = '';

  final FocusNode _usernameFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();

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
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _usernameFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        exit(0);
      },
      child: Scaffold(
        backgroundColor: AppColors.darkBlue,
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 20),
                    Form(
                      key: _formKey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          SizedBox(
                            width: 150,
                            height: 150,
                            child: Image.asset(
                                'assets/picture/shared_logo_gia_blanco.png'),
                          ),
                          const SizedBox(height: 50),
                          Container(
                            padding: const EdgeInsets.all(16.0),
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              children: [
                                SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * 0.8,
                                  child: TextFormField(
                                    controller: _usernameController,
                                    focusNode: _usernameFocusNode,
                                    style:
                                        const TextStyle(color: AppColors.black),
                                    decoration: InputDecoration(
                                      filled: true,
                                      fillColor: AppColors.white,
                                      labelText: 'Usuario',
                                      labelStyle: const TextStyle(
                                          color: AppColors.black),
                                      prefixIcon: Padding(
                                        padding:
                                            const EdgeInsets.only(right: 8.0),
                                        child: Icon(
                                          Icons.person,
                                          color: AppColors.black,
                                          size: _usernameFocusNode.hasFocus
                                              ? 20
                                              : 24,
                                        ),
                                      ),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              vertical: 15),
                                      border: const UnderlineInputBorder(),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Por favor, introduzca su usuario';
                                      }
                                      return null;
                                    },
                                    onTap: () {
                                      setState(() {});
                                    },
                                  ),
                                ),
                                const SizedBox(height: 20),
                                SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * 0.8,
                                  child: TextFormField(
                                    controller: _passwordController,
                                    focusNode: _passwordFocusNode,
                                    style:
                                        const TextStyle(color: AppColors.black),
                                    decoration: InputDecoration(
                                      filled: true,
                                      fillColor: AppColors.white,
                                      labelText: 'Contraseña',
                                      labelStyle: const TextStyle(
                                          color: AppColors.black),
                                      prefixIcon: Padding(
                                        padding:
                                            const EdgeInsets.only(right: 8.0),
                                        child: Icon(
                                          Icons.vpn_key,
                                          color: AppColors.black,
                                          size: _passwordFocusNode.hasFocus
                                              ? 20
                                              : 24,
                                        ),
                                      ),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              vertical: 15),
                                      border: const UnderlineInputBorder(),
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          _obscureText
                                              ? Icons.visibility
                                              : Icons.visibility_off,
                                          color: AppColors.black,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            _obscureText = !_obscureText;
                                          });
                                        },
                                      ),
                                    ),
                                    obscureText: _obscureText,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Por favor, introduzca su contraseña';
                                      }
                                      return null;
                                    },
                                    onTap: () {
                                      setState(() {});
                                    },
                                  ),
                                ),
                                const SizedBox(height: 20),
                                ElevatedButton(
                                  onPressed: () {
                                    final username = _usernameController.text;
                                    final password = _passwordController.text;
                                    _loginController.login(
                                        username, password, context);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.orange,
                                    foregroundColor: AppColors.white,
                                    minimumSize: Size(
                                        MediaQuery.of(context).size.width * 0.5,
                                        40),
                                  ),
                                  child: const Text('Iniciar sesión'),
                                ),
                                const SizedBox(height: 5),
                                ElevatedButton(
                                  onPressed: () {
                                    _loginController
                                        .redirectToRegistration(context);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.blueGrey,
                                    foregroundColor: AppColors.white,
                                    minimumSize: Size(
                                        MediaQuery.of(context).size.width * 0.2,
                                        30),
                                  ),
                                  child: const Text('Registrarse'),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 5),
                    Column(
                      children: [
                        const SizedBox(height: 10),
                        Image.asset(
                          'assets/picture/shared_logo_completo_digital_blanco.png',
                          alignment: Alignment.bottomCenter,
                          width: 200,
                          height: 100,
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'V ${_version.isNotEmpty ? _version : "..."}',
                          style: const TextStyle(color: AppColors.white),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
