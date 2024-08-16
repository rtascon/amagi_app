import 'package:flutter/material.dart';
import '../controllers/login_controller.dart'; // Importa el controlador

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _loginController = LoginController();
  bool _obscureText = true; // Estado para controlar la visibilidad de la contraseña

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
      backgroundColor: Color(0xFF747678),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Spacer(flex: 1), // Reduce el espacio superior
                Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        width: 250, // Ajusta el ancho de la imagen
                        height: 250, // Ajusta la altura de la imagen
                        child: Image.asset('assets/GIA IOT BLANCO.png'), // Asegúrate de que la ruta sea correcta
                      ),
                      SizedBox(height: 10), // Reduce el espacio entre la imagen y el cuadro
                      Container(
                        padding: EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            Container(
                              width: MediaQuery.of(context).size.width * 0.8, // Reduce el ancho
                              child: TextFormField(
                                controller: _usernameController,
                                focusNode: _usernameFocusNode,
                                style: TextStyle(color: Colors.black), // Color del texto
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: Colors.white, // Color de fondo del campo de texto
                                  labelText: 'Usuario',
                                  labelStyle: TextStyle(color: Colors.black), // Color del label
                                  prefixIcon: Padding(
                                    padding: const EdgeInsets.only(right: 8.0),
                                    child: Icon(
                                      Icons.person,
                                      color: Colors.black,
                                      size: _usernameFocusNode.hasFocus ? 20 : 24,
                                    ),
                                  ), // Icono de usuario
                                  contentPadding: EdgeInsets.symmetric(vertical: 15), // Ajusta el padding
                                  border: UnderlineInputBorder(), // Línea debajo del campo
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
                            SizedBox(height: 20),
                            Container(
                              width: MediaQuery.of(context).size.width * 0.8, // Reduce el ancho
                              child: TextFormField(
                                controller: _passwordController,
                                focusNode: _passwordFocusNode,
                                style: TextStyle(color: Colors.black), // Color del texto
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: Colors.white, // Color de fondo del campo de texto
                                  labelText: 'Contraseña',
                                  labelStyle: TextStyle(color: Colors.black), // Color del label
                                  prefixIcon: Padding(
                                    padding: const EdgeInsets.only(right: 8.0),
                                    child: Icon(
                                      Icons.lock,
                                      color: Colors.black,
                                      size: _passwordFocusNode.hasFocus ? 20 : 24,
                                    ),
                                  ), // Icono de llave
                                  contentPadding: EdgeInsets.symmetric(vertical: 15), // Ajusta el padding
                                  border: UnderlineInputBorder(), // Línea debajo del campo
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscureText ? Icons.visibility : Icons.visibility_off,
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
                            SizedBox(height: 20),
                            ElevatedButton(
                              onPressed: () {
                                if (_formKey.currentState?.validate() ?? false) {
                                  _loginController.login(
                                    _usernameController.text,
                                    _passwordController.text,
                                    context,
                                  );
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFF009FDA), // Color del botón
                                foregroundColor: Colors.white, // Color del texto
                              ),
                              child: Text('Iniciar sesión'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Spacer(flex: 2), // Aumenta el espacio inferior
                Image.asset(
                  'assets/Amagi logo azul_Pequeño.png', // Asegúrate de que la ruta sea correcta
                  alignment: Alignment.bottomCenter,
                  width: 100, // Ajusta el ancho de la imagen
                  height: 100, // Ajusta la altura de la imagen
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 10,
            left: 10,
            child: Text(
              'V 1.0.0',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}