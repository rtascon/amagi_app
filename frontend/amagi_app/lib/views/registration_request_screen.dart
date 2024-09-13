import 'package:flutter/material.dart';
import 'package:slider_captcha/slider_captcha.dart';
import '../controllers/registration_request_controller.dart'; 

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
  final TextEditingController _confirmCorreoController = TextEditingController();
  final TextEditingController _telefonoController = TextEditingController();
  final TextEditingController _cedulaController = TextEditingController();

  bool _isCaptchaValid = false;
  final SliderController _sliderController = SliderController();


  @override
  void dispose() {
    _nombreController.dispose();
    _apellidoController.dispose();
    _empresaController.dispose();
    _correoController.dispose();
    _confirmCorreoController.dispose();
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
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(16.0),
          color: Colors.white,
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        controller: _nombreController,
                        label: 'Nombre',
                        validator: (value) {
                          value = value?.trim();
                          if (value == null || value.isEmpty || !RegExp(r'^[a-zA-Z]+$').hasMatch(value)) {
                            return 'Por favor ingrese un nombre válido';
                          }
                          return null;
                        },
                      ),
                    ),
                    SizedBox(width: 16.0),
                    Expanded(
                      child: _buildTextField(
                        controller: _apellidoController,
                        label: 'Apellido',
                        validator: (value) {
                          value = value?.trim();
                          if (value == null || value.isEmpty || !RegExp(r'^[a-zA-Z]+$').hasMatch(value)) {
                            return 'Por favor ingrese un apellido válido';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.0),
                _buildTextField(
                  controller: _empresaController,
                  label: 'Empresa',
                  validator: (value) {
                    value = value?.trim();
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
                    value = value?.trim();
                    if (value == null || value.isEmpty || !RegExp(r'^[a-zA-Z0-9@.]+$').hasMatch(value) || !value.contains('@') || !value.contains('.')) {
                      return 'Por favor ingrese un correo electrónico válido';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.0),
                _buildTextField(
                  controller: _confirmCorreoController,
                  label: 'Confirmación de Correo Electrónico',
                  validator: (value) {
                    value = value?.trim();
                    if (value == null || value.isEmpty || value != _correoController.text.trim()) {
                      return 'El correo electrónico no coincide';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.0),
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        controller: _telefonoController,
                        label: 'Número de Teléfono',
                        validator: (value) {
                          value = value?.trim();
                          if (value == null || value.isEmpty || !RegExp(r'^[0-9+]+$').hasMatch(value)) {
                            return 'Por favor ingrese un número de teléfono válido';
                          }
                          return null;
                        },
                      ),
                    ),
                    SizedBox(width: 16.0),
                    Expanded(
                      child: _buildTextField(
                        controller: _cedulaController,
                        label: 'Cédula',
                        validator: (value) {
                          value = value?.trim();
                          if (value == null || value.isEmpty || !RegExp(r'^[0-9+]+$').hasMatch(value)) {
                            return 'Por favor ingrese una cédula válida';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.0),
                Divider(color: Colors.black),
                SizedBox(height: 16.0),
                SliderCaptcha(
                  controller: _sliderController,
                  title: 'Deslice para confirmar que no es un robot',
                  image: Image.asset(
                    'assets/captcha_image.png',
                    fit: BoxFit.fitWidth,
                  ),
                  colorBar: Colors.grey,
                  colorCaptChar: Colors.grey,
                  onConfirm: (value) async {
                    await Future.delayed(const Duration(seconds: 1));
                    if (value) {
                      setState(() {
                        _isCaptchaValid = true;
                      });
                    } else {
                      _sliderController.create();
                      setState(() {
                        _isCaptchaValid = false;
                      });
                    }
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
                          if (_isCaptchaValid) {
                            _registrationRequestController.submitRegistrationRequest(
                              context,
                              _nombreController.text.trim(),
                              _apellidoController.text.trim(),
                              _empresaController.text.trim(),
                              _correoController.text.trim(),
                              _telefonoController.text.trim(),
                              _cedulaController.text.trim(),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Por favor, complete el CAPTCHA')),
                            );
                          }
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