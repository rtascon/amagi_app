import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../controllers/tickets_controller.dart';
import '../models/ticket.dart'; 
import '../models/type_conversion.dart';

/// Esta vista proporciona una interfaz para filtrar tickets según diferentes criterios,
/// como el ID del ticket, el tipo, el estado y el rango de fechas.

class FilterTicketMenu extends StatefulWidget {
  final Function(Map<String, dynamic>) onFilterChanged;

  FilterTicketMenu({required this.onFilterChanged});

  @override
  _FilterTicketMenuState createState() => _FilterTicketMenuState();
}

class _FilterTicketMenuState extends State<FilterTicketMenu> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _ticketIdController = TextEditingController();
  String? _selectedType;
  String? _selectedStatus;
  DateTimeRange? _selectedDateRange;
  final TypeConversion _typeConversion = TypeConversion();

  @override
  void initState() {
    super.initState();
    // Initialize the controllers with the current state values
    _ticketIdController.text = _selectedType ?? '';
  }

  void _applyFilters() {
    if (_formKey.currentState!.validate()) {
      Map<String, dynamic> filters = {
        'ticketId': _ticketIdController.text.isNotEmpty ? int.parse(_ticketIdController.text) : null,
        'type': _selectedType != null ?  _typeConversion.getTipoReversa(_selectedType!) : null,
        'status': _selectedStatus != null ?  _typeConversion.getEstadoReversa(_selectedStatus!) : null,
        'dateRange': _selectedDateRange,
      };
      widget.onFilterChanged(filters);
      Navigator.of(context).pop();
    }
  }

  void _clearFilters() async{
    setState(() {
      _ticketIdController.clear();
      _selectedType = null;
      _selectedStatus = null;
      _selectedDateRange = null;
    });
    List<Ticket> tickets = await TicketsController().getTicketsList(context, true);
    widget.onFilterChanged({
      'ticketId': null,
      'type': null,
      'status': null,
      'dateRange': null,
      'tickets': tickets,
    });
    Navigator.of(context).pop();
  }

  void _toggleFilters() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.60,
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 32), // Mover contenido hacia abajo
                Text(
                  'Filtrar Tickets',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _ticketIdController,
                  decoration: InputDecoration(labelText: 'ID de Ticket'),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    _toggleFilters();
                  },
                  validator: (value) {
                    if (value != null && value.isNotEmpty && int.tryParse(value) == null) {
                      return 'Por favor ingrese un número válido';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(labelText: 'Tipo'),
                  dropdownColor: Colors.grey[200], // Color de fondo del menú desplegable
                  items: ['Requerimiento', 'Incidente'].map((String type) {
                    return DropdownMenuItem<String>(
                      value: type,
                      child: Text(type),
                    );
                  }).toList(),
                  onChanged: _ticketIdController.text.isEmpty ? (value) {
                    setState(() {
                      _selectedType = value;
                    });
                  } : null,
                  value: _selectedType,
                  disabledHint: Text('Deshabilitado'),
                ),
                SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(labelText: 'Estado'),
                  dropdownColor: Colors.grey[200], // Color de fondo del menú desplegable
                  items: ['Nuevo', 'En curso (asignado)', 'En curso (Planificado)', 'En espera','Resuelto','Cerrado'].map((String status) {
                    return DropdownMenuItem<String>(
                      value: status,
                      child: Text(status),
                    );
                  }).toList(),
                  onChanged: _ticketIdController.text.isEmpty ? (value) {
                    setState(() {
                      _selectedStatus = value;
                    });
                  } : null,
                  value: _selectedStatus,
                  disabledHint: Text('Deshabilitado'),
                ),
                SizedBox(height: 16),
                Text(
                  'Fecha',
                  style: TextStyle(fontSize: 16),
                ),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _ticketIdController.text.isEmpty ? () async {
                          DateTimeRange? picked = await showDateRangePicker(
                            context: context,
                            firstDate: DateTime(2000),
                            lastDate: DateTime.now(),
                          );
                          if (picked != null) {
                            // Ajustar el rango de fechas
                            DateTime start = DateTime(picked.start.year, picked.start.month, picked.start.day, 0, 0);
                            DateTime end = DateTime(picked.end.year, picked.end.month, picked.end.day, 23, 59);
                            setState(() {
                              _selectedDateRange = DateTimeRange(start: start, end: end);
                            });
                          }
                        } : null,
                        child: Text(
                          _selectedDateRange == null
                              ? 'Seleccionar rango de fechas'
                              : '${DateFormat('yyyy-MM-dd').format(_selectedDateRange!.start)} - ${DateFormat('yyyy-MM-dd').format(_selectedDateRange!.end)}',
                          style: TextStyle(color: Theme.of(context).primaryColor), // Color de la fuente
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[200], // Color del botón
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _applyFilters,
                        child: Text(
                          'Filtrar',
                          style: TextStyle(color: Colors.white), // Color de la fuente
                        ),
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 16.0),
                          backgroundColor: Color(0xFF005586), // Color del botón
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          elevation: 5,
                          shadowColor: Colors.black.withOpacity(0.2),
                        ),
                      ),
                    ),
                    SizedBox(width: 8), // Espacio entre los botones
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _clearFilters,
                        child: Icon(
                          Icons.cleaning_services, // Icono de limpiar
                          color: Colors.white,
                        ),
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 16.0),
                          backgroundColor: Colors.red, // Color del botón
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          elevation: 5,
                          shadowColor: Colors.black.withOpacity(0.2),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}