import 'package:flutter/material.dart';

class LoginScreen extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _loginController = LoginController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF747678),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Spacer(flex: 2), // Empuja el contenido hacia abajo
            Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Image.asset('assets/GIA IOT AZUL Y BLANCO.png'), // Asegúrate de que la ruta sea correcta
                  SizedBox(height: 20),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.9, // Reduce el ancho
                    child: TextFormField(
                      controller: _usernameController,
                      style: TextStyle(color: Colors.black), // Color del texto
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white, // Color de fondo del campo de texto
                        labelText: 'Usuario',
                        labelStyle: TextStyle(color: Colors.black), // Color del label
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12), // Bordes redondeados
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, introduzca su usuario';
                        }
                        return null;
                      },
                    ),
                  ),
                  SizedBox(height: 20),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.9, // Reduce el ancho
                    child: TextFormField(
                      controller: _passwordController,
                      style: TextStyle(color: Colors.black), // Color del texto
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white, // Color de fondo del campo de texto
                        labelText: 'Contraseña',
                        labelStyle: TextStyle(color: Colors.black), // Color del label
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12), // Bordes redondeados
                        ),
                      ),
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, introduzca su contraseña';
                        }
                        return null;
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
                    child: Text('Iniciar sesión'),
                  ),
                ],
              ),
            ),
            Spacer(flex: 3), // Empuja la nueva imagen hacia abajo
            Image.asset(
              'assets/Amagi logo azul_Pequeño.png', // Asegúrate de que la ruta sea correcta
              alignment: Alignment.bottomCenter,
              width: 100, // Ajusta el ancho de la imagen
              height: 100, // Ajusta la altura de la imagen
            ),
          ],
        ),
      ),
    );
  }
}

class LoginController {
  void login(String username, String password, BuildContext context) {
    // Implementación del método de login
  }
}