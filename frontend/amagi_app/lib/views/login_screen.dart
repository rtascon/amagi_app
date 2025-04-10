import 'package:flutter/material.dart';
import '../controllers/login_controller.dart';

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
  bool _obscureText =
      true; // Estado para controlar la visibilidad de la contraseña

  final FocusNode _usernameFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();

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
    return Scaffold(
      backgroundColor: const Color(0xFF005586),
      body: SafeArea(
        child: Center( // Centrar el contenedor principal
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min, // Permitir que se expanda según el espacio disponible
                children: [
                  const SizedBox(height: 20), // Espacio superior
                  Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        SizedBox(
                          width: 150, // Ajusta el ancho de la imagen
                          height: 150, // Ajusta la altura de la imagen
                          child: Image.asset(
                              'assets/SOLO GIA SIN FONDO (BLANCO) (1) (1).png'), // Asegúrate de que la ruta sea correcta
                        ),
                        const SizedBox(
                            height:
                                50), // Reduce el espacio entre la imagen y el cuadro
                        Container(
                          padding: const EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              SizedBox(
                                width: MediaQuery.of(context).size.width *
                                    0.8, // Reduce el ancho
                                child: TextFormField(
                                  controller: _usernameController,
                                  focusNode: _usernameFocusNode,
                                  style: const TextStyle(
                                      color: Colors.black), // Color del texto
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: Colors
                                        .white, // Color de fondo del campo de texto
                                    labelText: 'Usuario',
                                    labelStyle: const TextStyle(
                                        color: Colors.black), // Color del label
                                    prefixIcon: Padding(
                                      padding: const EdgeInsets.only(right: 8.0),
                                      child: Icon(
                                        Icons.person,
                                        color: Colors.black,
                                        size:
                                            _usernameFocusNode.hasFocus ? 20 : 24,
                                      ),
                                    ), // Icono de usuario
                                    contentPadding: const EdgeInsets.symmetric(
                                        vertical: 15), // Ajusta el padding
                                    border:
                                        const UnderlineInputBorder(), // Línea debajo del campo
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
                                width: MediaQuery.of(context).size.width *
                                    0.8, // Reduce el ancho
                                child: TextFormField(
                                  controller: _passwordController,
                                  focusNode: _passwordFocusNode,
                                  style: const TextStyle(
                                      color: Colors.black), // Color del texto
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: Colors
                                        .white, // Color de fondo del campo de texto
                                    labelText: 'Contraseña',
                                    labelStyle: const TextStyle(
                                        color: Colors.black), // Color del label
                                    prefixIcon: Padding(
                                      padding: const EdgeInsets.only(right: 8.0),
                                      child: Icon(
                                        Icons.vpn_key,
                                        color: Colors.black,
                                        size:
                                            _passwordFocusNode.hasFocus ? 20 : 24,
                                      ),
                                    ), // Icono de llave
                                    contentPadding: const EdgeInsets.symmetric(
                                        vertical: 15), // Ajusta el padding
                                    border:
                                        const UnderlineInputBorder(), // Línea debajo del campo
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscureText
                                            ? Icons.visibility
                                            : Icons.visibility_off,
                                        color: Colors.black,
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
                                            final username =
                                                _usernameController.text;
                                            final password =
                                                _passwordController.text;
                                            _loginController.login(
                                                username, password, context);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      const Color(0xFFE98300), // Color del botón
                                  foregroundColor:
                                      Colors.white, // Color del texto
                                  minimumSize: Size(
                                      MediaQuery.of(context).size.width * 0.5,
                                      40), // Ajusta el ancho del botón
                                ),
                                child: const Text('Iniciar sesión'),
                              ),
                              const SizedBox(
                                  height: 5), // Espacio entre los botones
                              ElevatedButton(
                                onPressed: () {
                                  _loginController
                                      .redirectToRegistration(context);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      const Color(0xFF747678), // Color del botón
                                  foregroundColor:
                                      Colors.white, // Color del texto
                                  minimumSize: Size(
                                      MediaQuery.of(context).size.width * 0.2,
                                      30), // Ajusta el ancho del botón
                                ),
                                child: const Text('Registrarse'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20), // Espacio inferior
                  Column(
                    children: [
                      const SizedBox(
                          height:
                              30), 
                      Image.asset(
                        'assets/Amagi logo blanco.png',
                        alignment: Alignment.bottomCenter,
                        width: 100,
                        height: 100,
                      ),
                      const SizedBox(
                          height: 10), // Espacio inferior para el texto
                      const Text(
                        'V 1.0.0',
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}