import 'package:flutter/material.dart';
import '../controllers/create_ticket_controller.dart';

/// Esta vista permite a los usuarios crear un nuevo ticket, proporcionando un título,
/// tipo y descripción del problema o solicitud.

class CreateTicketScreen extends StatefulWidget {
  @override
  _CreateTicketScreenState createState() => _CreateTicketScreenState();
}

class _CreateTicketScreenState extends State<CreateTicketScreen> {
  final CreateTicketController _createTicketController = CreateTicketController();
  final _formKey = GlobalKey<FormState>();
  String? _titulo;
  String? _tipo;
  String? _descripcion;

  // Mapa para almacenar los datos del ticket
  Map<String, dynamic> ticketData = {
    "status": 1,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            _createTicketController.navigateBack(context);
          },
        ),
        title: Text(
          'Crear Ticket',
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
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Título',
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
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese un título';
                  }
                  return null;
                },
                onSaved: (value) {
                  ticketData['name'] = value;
                },
              ),
              SizedBox(height: 16.0),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Tipo',
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
                items: [
                  DropdownMenuItem(
                    value: 'Requerimiento',
                    child: Row(
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: Color(0xFF009FDA),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '?',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 8.0),
                        Text(
                          'Requerimiento',
                          style: TextStyle(
                            color: Color(0xFF009FDA),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  DropdownMenuItem(
                    value: 'Incidente',
                    child: Row(
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: Color(0xFFE98300),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '!',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 8.0),
                        Text(
                          'Incidente',
                          style: TextStyle(
                            color: Color(0xFFE98300),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    _tipo = value;
                    ticketData['type'] = value == 'Requerimiento' ? 2 : 1;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Por favor seleccione un tipo';
                  }
                  return null;
                },
                selectedItemBuilder: (BuildContext context) {
                  return ['Requerimiento', 'Incidente'].map<Widget>((String value) {
                    return Row(
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: value == 'Requerimiento' ? Color(0xFF009FDA) : Color(0xFFE98300),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              value == 'Requerimiento' ? '?' : '!',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 8.0),
                        Text(
                          value,
                          style: TextStyle(
                            color: value == 'Requerimiento' ? Color(0xFF009FDA) : Color(0xFFE98300),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    );
                  }).toList();
                },
              ),
              SizedBox(height: 16.0),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Descripción',
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
                maxLines: 5,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese una descripción';
                  }
                  return null;
                },
                onSaved: (value) {
                  ticketData['content'] = value;
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
                        _formKey.currentState?.save();
                        _createTicketController.submitTicket(
                          context,
                          ticketData,
                        );
                      }
                    },
                    child: Text('Enviar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF005586),
                      foregroundColor: Colors.white,
                    ),
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