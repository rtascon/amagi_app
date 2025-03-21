import 'package:flutter/material.dart';
import 'package:slider_captcha/slider_captcha.dart';
import 'package:startup_namer/views/login_screen.dart';
import '../controllers/registration_request_controller.dart';

/// Esta vista permite a los usuarios solicitar el registro en la aplicación,
/// proporcionando información personal y verificando un captcha.

class RegistrationRequestScreen extends StatefulWidget {
  const RegistrationRequestScreen({super.key});

  @override
  RegistrationRequestScreenState createState() =>
      RegistrationRequestScreenState();
}

class RegistrationRequestScreenState extends State<RegistrationRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _registrationRequestController = RegistrationRequestController();

  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _apellidoController = TextEditingController();
  final TextEditingController _empresaController = TextEditingController();
  final TextEditingController _correoController = TextEditingController();
  final TextEditingController _confirmCorreoController =
      TextEditingController();
  final TextEditingController _telefonoController = TextEditingController();
  final TextEditingController _cedulaController = TextEditingController();

  bool _isCaptchaValid = false;
  final SliderController _sliderController = SliderController();
  bool _isLoading = false;
  
  bool _hasChanges() {
    return _nombreController.text.isNotEmpty || _apellidoController.text.isNotEmpty || _empresaController.text.isNotEmpty || _correoController.text.isNotEmpty || _confirmCorreoController.text.isNotEmpty || _telefonoController.text.isNotEmpty || _cedulaController.text.isNotEmpty;
  }

Future<bool> _onWillPop() async {
    if (!_hasChanges()) {
      return true;
    }
    return (await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Center(
          child: Icon(
            Icons.warning,
            color: Colors.orange,
            size: 50,
          ),
        ),
        content: const Text('Si abandona el formulario, perderá los cambios realizados. ¿Desea continuar?'),
        actions: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancelar', style: TextStyle(color: Colors.black)),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Aceptar', style: TextStyle(color: Colors.black)),
              ),
            ],
          ),
        ],
      ),
    )) ?? false;
  }

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
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () async {
              if (await _onWillPop()) {
            Navigator.pop(context);
              }
          },
        ),
        title: const Text(
          'Solicitud de Registro',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF005586),
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(16.0),
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
                        icon: Icons.person, // Icono para Nombre
                        validator: (value) {
                          value = value?.trim();
                          if (value == null ||
                              value.isEmpty ||
                              !RegExp(r'^[a-zA-ZñÑáéíóúÁÉÍÓÚ\s]+$')
                                  .hasMatch(value)) {
                            return 'Por favor ingrese un nombre válido';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 16.0),
                    Expanded(
                      child: _buildTextField(
                        controller: _apellidoController,
                        label: 'Apellido',
                        icon: Icons.person, // Icono para Apellido
                        validator: (value) {
                          value = value?.trim();
                          if (value == null ||
                              value.isEmpty ||
                              !RegExp(r'^[a-zA-ZñÑáéíóúÁÉÍÓÚ\s]+$')
                                  .hasMatch(value)) {
                            return 'Por favor ingrese un apellido válido';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16.0),
                _buildTextField(
                  controller: _empresaController,
                  label: 'Empresa',
                  icon: Icons.apartment,
                  validator: (value) {
                    value = value?.trim();
                    if (value == null ||
                        value.isEmpty ||
                        !RegExp(r'^[a-zA-Z0-9\s]+$').hasMatch(value)) {
                      return 'Por favor ingrese una empresa válida';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),
                _buildTextField(
                  controller: _correoController,
                  label: 'Correo Electrónico',
                  icon: Icons.mail, // Icono para Correo Electrónico
                  validator: (value) {
                    value = value?.trim();
                    if (value == null ||
                        value.isEmpty ||
                        !RegExp(r'^[a-zA-Z0-9@.]+$').hasMatch(value) ||
                        !value.contains('@') ||
                        !value.contains('.')) {
                      return 'Por favor ingrese un correo electrónico válido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),
                _buildTextField(
                  controller: _confirmCorreoController,
                  label: 'Confirmación de Correo Electrónico',
                  icon: Icons.mail, // Icono para Confirmación de Correo Electrónico
                  validator: (value) {
                    value = value?.trim();
                    if (value == null ||
                        value.isEmpty ||
                        value != _correoController.text.trim()) {
                      return 'El correo electrónico no coincide';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        controller: _telefonoController,
                        label: 'Teléfono',
                        icon: Icons.phone_android, // Icono para Teléfono
                        validator: (value) {
                          value = value?.trim();
                          if (value == null ||
                              value.isEmpty ||
                              !RegExp(r'^[0-9+]+$').hasMatch(value)) {
                            return 'Por favor ingrese un número de teléfono válido';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 16.0),
                    Expanded(
                      child: _buildTextField(
                        controller: _cedulaController,
                        label: 'Cédula',
                        icon: Icons.badge, // Icono para Cédula
                        validator: (value) {
                          value = value?.trim();
                          if (value == null ||
                              value.isEmpty ||
                              !RegExp(r'^[0-9+]+$').hasMatch(value)) {
                            return 'Por favor ingrese una cédula válida';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16.0),
                const Divider(color: Colors.black),
                const SizedBox(height: 16.0),
                SliderCaptcha(
                  controller: _sliderController,
                  title: 'Deslice para confirmar que no es un robot',
                  image: SizedBox(
                    width: 400, // Ajusta el ancho según tus necesidades
                    height: 180, // Ajusta la altura según tus necesidades
                    child: Image.asset(
                      'assets/captcha_image.png',
                      fit: BoxFit.fitWidth,
                    ),
                  ),
                  colorBar: Colors.white70,
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
                const SizedBox(height: 16.0),
                Align(
                  alignment: Alignment.center,
                  child: SizedBox(
                    width: 150,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState?.validate() ?? false) {
                          if (_isCaptchaValid) {
                            setState(() {
                              _isLoading = true;
                            });

                            await _registrationRequestController
                                .submitRegistrationRequest(
                              context,
                              _nombreController.text.trim(),
                              _apellidoController.text.trim(),
                              _empresaController.text.trim(),
                              _correoController.text.trim(),
                              _telefonoController.text.trim(),
                              _cedulaController.text.trim(),
                            );

                            setState(() {
                              _isLoading = false;
                            });
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content:
                                      Text('Por favor, complete el CAPTCHA')),
                            );
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF005586),
                        foregroundColor: Colors.white,
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            )
                          : const Text('Enviar'),
                    ),
                  ),
                ),
              ],
            ),
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
    IconData? icon,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.grey[200] ?? Colors.grey,
        prefixIcon: icon != null ? Icon(icon, color: Colors.grey[600]) : null, // Ajustar ícono
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide.none, 
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide.none, 
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide.none, 
        ),
      ),
      validator: validator,
    );
  }
}
