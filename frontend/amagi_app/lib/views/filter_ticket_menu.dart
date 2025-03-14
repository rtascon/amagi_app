import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import '../widgets/table_calendar.dart';
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
  DateTime _focusedDay = DateTime.now();
  DateTime? _rangeStart;
  DateTime? _rangeEnd;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  RangeSelectionMode _rangeSelectionMode = RangeSelectionMode.toggledOff;

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

  void _onRangeSelected(DateTime? start, DateTime? end, DateTime focusedDay) {
    setState(() {
      _rangeStart = start;
      _rangeEnd = end ?? start; // Asignar start a _rangeEnd si end es null
      _focusedDay = focusedDay;
      _selectedDateRange = start != null ? DateTimeRange(start: start, end: _rangeEnd!) : null;
    });
  }

  void _showDateRangePicker() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CalendarDialog(
          focusedDay: _focusedDay,
          rangeStart: _rangeStart,
          rangeEnd: _rangeEnd,
          calendarFormat: _calendarFormat,
          rangeSelectionMode: _rangeSelectionMode,
          onRangeSelected: (start, end, focusedDay) {
            _onRangeSelected(start, end, focusedDay);
            setState(() {
              _selectedDateRange = start != null ? DateTimeRange(start: start, end: end ?? start) : null;
            });
          },
        );
      },
    );
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
                const SizedBox(height: 32), // Mover contenido hacia abajo
                const Text(
                  'Filtrar Tickets',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _ticketIdController,
                  decoration: const InputDecoration(
                    labelText: 'ID de Ticket',
                    labelStyle: TextStyle(fontSize: 12), // Tamaño del texto
                  ),
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
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Tipo',
                    labelStyle: TextStyle(fontSize: 12), // Tamaño del texto
                  ),
                  dropdownColor: Colors.grey[200], // Color de fondo del menú desplegable
                  items: ['Requerimiento', 'Incidente'].map((String type) {
                    return DropdownMenuItem<String>(
                      value: type,
                      child: Text(type, style: const TextStyle(fontSize: 12)), // Tamaño del texto
                    );
                  }).toList(),
                  onChanged: _ticketIdController.text.isEmpty ? (value) {
                    setState(() {
                      _selectedType = value;
                    });
                  } : null,
                  value: _selectedType,
                  icon: null, // Eliminar el icono de la lista desplegable
                  disabledHint: const Text('Deshabilitado'),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Estado',
                    labelStyle: TextStyle(fontSize: 12), // Tamaño del texto
                  ),
                  dropdownColor: Colors.grey[200], // Color de fondo del menú desplegable
                  items: ['Nuevo', 'En curso (asignado)', 'En curso (Planificado)', 'En espera','Resuelto','Cerrado'].map((String status) {
                    return DropdownMenuItem<String>(
                      value: status,
                      child: Text(status, style: const TextStyle(fontSize: 12)), // Tamaño del texto
                    );
                  }).toList(),
                  onChanged: _ticketIdController.text.isEmpty ? (value) {
                    setState(() {
                      _selectedStatus = value;
                    });
                  } : null,
                  value: _selectedStatus,
                  icon: null, // Eliminar el icono de la lista desplegable
                  disabledHint: const Text('Deshabilitado'),
                ),
                const SizedBox(height: 16),
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.center, // Centrar el botón
                  children: [
                    SizedBox(
                      width: 200, // Ajusta este valor para cambiar el ancho del botón
                      child: ElevatedButton(
                        onPressed: _ticketIdController.text.isEmpty ? _showDateRangePicker : null,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          backgroundColor: Colors.red,  // Color del botón
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          elevation: 5,
                          shadowColor: Colors.black.withOpacity(0.2),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              ' Fecha de apertura ',
                              style: TextStyle(fontSize: 12, color: Colors.white), 
                            ),
                            Icon(Icons.edit_calendar_rounded, color: Colors.white),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                if (_selectedDateRange != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Text('Inicio:', style: TextStyle(fontSize: 12)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildDateCube(DateFormat('dd').format(_selectedDateRange!.start)),
                            const Text('/'),
                            _buildDateCube(DateFormat('MM').format(_selectedDateRange!.start)),
                            const Text('/'),
                            _buildDateCube(DateFormat('yyyy').format(_selectedDateRange!.start)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Text('Fin:', style: TextStyle(fontSize: 12)),
                      const SizedBox(width: 25),
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildDateCube(DateFormat('dd').format(_selectedDateRange!.end)),
                            const Text('/'),
                            _buildDateCube(DateFormat('MM').format(_selectedDateRange!.end)),
                            const Text('/'),
                            _buildDateCube(DateFormat('yyyy').format(_selectedDateRange!.end)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _applyFilters,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          backgroundColor: const Color(0xFF005586), // Color del botón
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          elevation: 5,
                          shadowColor: Colors.black.withOpacity(0.2),
                        ),
                        child: const Text(
                          'Filtrar',
                          style: TextStyle(color: Colors.white), // Color de la fuente
                        ),
                      ),
                    ),
                    const SizedBox(width: 8), // Espacio entre los botones
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _clearFilters,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          backgroundColor: Colors.red, // Color del botón
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          elevation: 5,
                          shadowColor: Colors.black.withOpacity(0.2),
                        ),
                        child: const Icon(
                          Icons.cleaning_services, // Icono de limpiar
                          color: Colors.white,
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

  Widget _buildDateCube(String text) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      margin: const EdgeInsets.symmetric(horizontal: 4.0),
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(4.0),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 14),
      ),
    );
  }
}