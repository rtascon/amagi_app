import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:startup_namer/controllers/create_ticket_controller.dart';


class CreateTicketScreen extends StatefulWidget {
  const CreateTicketScreen({super.key});

  @override
  _CreateTicketScreenState createState() => _CreateTicketScreenState();
}

class _CreateTicketScreenState extends State<CreateTicketScreen> {
  final _formKey = GlobalKey<FormState>();
  final createTicketController = CreateTicketController();

  final TextEditingController _tituloController = TextEditingController();
  final TextEditingController _descripcionController = TextEditingController();
  final TextEditingController _tipoController = TextEditingController();
  String? _tipo;
  bool _isLoading = false;

  final List<Map<String, dynamic>> tipoItems = [
    {'value': '2', 'label': 'Requerimiento', 'icon': Icons.help, 'color': Color(0xFF009FDA)},
    {'value': '1', 'label': 'Incidente', 'icon': Icons.error, 'color': Color(0xFFE98300)},
  ];

  String? selectedTipo;

  @override
  void dispose() {
    _tituloController.dispose();
    _descripcionController.dispose();
    _tipoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: const Text(
          'Crear Ticket',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF005586),
        elevation: 0,
        centerTitle: true,
      ),
      body: Container(
        color: Colors.white, // Asegurar que el fondo sea blanco y ocupe toda la pantalla
        height: MediaQuery.of(context).size.height, // Asegurar que el contenedor ocupe toda la altura de la pantalla
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16.0), // Margen del formulario
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Icon(Icons.edit_square, color: Colors.grey[600]), // Ajustar ícono
                            const SizedBox(width: 4.0),
                            Text(
                              'Título',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0), // Margen del campo de texto
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        child: TextFormField(
                          controller: _tituloController,
                          decoration: InputDecoration(
                            hintText: 'Ingrese un título', // Texto de marcador de posición
                            hintStyle: TextStyle(color: Colors.grey[600], fontSize: 17), // Tamaño de letra igual al de título
                            filled: true,
                            fillColor: Colors.grey[200], // Ajustar el fondo del texto
                            border: InputBorder.none, // Eliminar el borde del campo de texto
                            contentPadding: const EdgeInsets.symmetric(vertical: 10.0), // Reducir altura
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor ingrese un título';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(height: 16.0),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Icon(Icons.edit_square, color: Colors.grey[600]), // Ajustar ícono
                            const SizedBox(width: 4.0),
                            Text(
                              'Tipo',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0), // Margen del campo de texto
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        child: DropdownButtonFormField<String>(
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.grey[200], // Ajustar el fondo del texto
                            border: InputBorder.none, // Eliminar el borde del campo de texto
                            contentPadding: const EdgeInsets.symmetric(vertical: 10.0), // Ajustar el padding vertical
                          ),
                           dropdownColor: Colors.grey[200],
                          hint: const Text(
                            'Seleccione una opción',
                            style: TextStyle(fontSize: 17), // Tamaño de letra igual al de título
                          ),
                          items: tipoItems.map((item) {
                            return DropdownMenuItem<String>(
                              value: item['value'],
                              child: Row(
                                children: [
                                  Icon(item['icon'], color: item['color']),
                                  const SizedBox(width: 8),
                                  Text(
                                    item['label'],
                                    style: TextStyle(fontSize: 16, color: item['color']),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                          validator: (value) {
                            if (value == null) {
                              return 'Por favor seleccione un tipo.';
                            }
                            return null;
                          },
                          onChanged: (value) {
                            setState(() {
                              _tipoController.text = value ?? '';
                            });
                          },
                          onSaved: (value) {
                            selectedTipo = value;
                          },
                        ),
                      ),
                      const SizedBox(height: 16.0),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Icon(Icons.edit_square, color: Colors.grey[600]), // Ajustar ícono
                            const SizedBox(width: 4.0),
                            Text(
                              'Descripción',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0), // Margen del campo de texto
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        child: TextFormField(
                          controller: _descripcionController,
                          decoration: InputDecoration(
                            hintText: 'Ingrese una descripción', // Texto de marcador de posición
                            hintStyle: TextStyle(color: Colors.grey[600], fontSize: 17), // Tamaño de letra igual al de título
                            filled: true,
                            fillColor: Colors.grey[200], // Ajustar el fondo del texto
                            border: InputBorder.none, // Eliminar el borde del campo de texto
                            contentPadding: const EdgeInsets.symmetric(vertical: 10.0), // Ajustar el padding vertical
                          ),
                          maxLines: 10,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor ingrese una descripción';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(height: 15.0),
                      Align(
                        alignment: Alignment.center,
                        child: SizedBox(
                          width: 150,
                          child: ElevatedButton(
                            onPressed: _isLoading
                                ? null
                                : () async {
                                    if (_formKey.currentState?.validate() ?? false) {
                                      if (mounted) {
                                        setState(() {
                                          _isLoading = true;
                                        });
                                      }

                                      await createTicketController.submitCrearticketController(
                                        context,
                                        _tituloController.text.trim(),
                                        _descripcionController.text.trim(),
                                        int.parse(_tipoController.text.trim()),
                                      );

                                      if (mounted) {
                                        setState(() {
                                          _isLoading = false;
                                        });
                                      }
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF005586),
                              foregroundColor: Colors.white,
                            ),
                            child: _isLoading
                                ? const CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF005586)),
                                  )
                                : const Text('Enviar'),
                          ),
                        ),
                      ),
                    ],
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