import 'package:flutter/material.dart';
import '../controllers/registration_request_controller.dart'; // Importa el controlador

class RegistrationRequestScreen extends StatefulWidget {
  @override
  _RegistrationRequestScreenState createState() => _RegistrationRequestScreenState();
}

class _RegistrationRequestScreenState extends State<RegistrationRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _registrationRequestController = RegistrationRequestController();

  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _apellidoController = TextEditingController();
  final TextEditingController _empresaController = TextEditingController();
  final TextEditingController _correoController = TextEditingController();
  final TextEditingController _telefonoController = TextEditingController();
  final TextEditingController _cedulaController = TextEditingController();

  @override
  void dispose() {
    _nombreController.dispose();
    _apellidoController.dispose();
    _empresaController.dispose();
    _correoController.dispose();
    _telefonoController.dispose();
    _cedulaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context); // Regresa a la vista de login
          },
        ),
        title: Text(
          'Solicitud de Registro',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Color(0xFF005586),
        elevation: 0,
        centerTitle: true,
      ),
      body: Container(
        padding: EdgeInsets.all(16.0),
        color: Colors.white,
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildTextField(
                controller: _nombreController,
                label: 'Nombre',
                validator: (value) {
                  if (value == null || value.isEmpty || !RegExp(r'^[a-zA-Z]+$').hasMatch(value)) {
                    return 'Por favor ingrese un nombre válido';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.0),
              _buildTextField(
                controller: _apellidoController,
                label: 'Apellido',
                validator: (value) {
                  if (value == null || value.isEmpty || !RegExp(r'^[a-zA-Z]+$').hasMatch(value)) {
                    return 'Por favor ingrese un apellido válido';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.0),
              _buildTextField(
                controller: _empresaController,
                label: 'Empresa',
                validator: (value) {
                  if (value == null || value.isEmpty || !RegExp(r'^[a-zA-Z0-9]+$').hasMatch(value)) {
                    return 'Por favor ingrese una empresa válida';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.0),
              _buildTextField(
                controller: _correoController,
                label: 'Correo Electrónico',
                validator: (value) {
                  if (value == null || value.isEmpty || !RegExp(r'^[a-zA-Z0-9@.]+$').hasMatch(value)) {
                    return 'Por favor ingrese un correo electrónico válido';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.0),
              _buildTextField(
                controller: _telefonoController,
                label: 'Número de Teléfono',
                validator: (value) {
                  if (value == null || value.isEmpty || !RegExp(r'^[0-9+]+$').hasMatch(value)) {
                    return 'Por favor ingrese un número de teléfono válido';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.0),
              _buildTextField(
                controller: _cedulaController,
                label: 'Cédula',
                validator: (value) {
                  if (value == null || value.isEmpty || !RegExp(r'^[0-9]+[a-zA-Z]$').hasMatch(value)) {
                    return 'Por favor ingrese una cédula válida';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.0),
              Align(
                alignment: Alignment.center,
                child: SizedBox(
                  width: 150,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState?.validate() ?? false) {
                        _registrationRequestController.submitRegistrationRequest(
                          context,
                          _nombreController.text,
                          _apellidoController.text,
                          _empresaController.text,
                          _correoController.text,
                          _telefonoController.text,
                          _cedulaController.text,
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor : Color(0xFF005586), 
                      foregroundColor: Colors.white, 
                    ),
                    child: Text('Enviar'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.grey[200],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(color: Colors.black),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(color: Colors.black),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(color: Colors.black),
        ),
      ),
      validator: validator,
    );
  }
}