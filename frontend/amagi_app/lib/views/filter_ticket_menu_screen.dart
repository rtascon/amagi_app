import 'dart:core';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import '../widgets/table_calendar.dart';
import '../models/ticket.dart'; 
import '../controllers/filter_ticket_menu_controller.dart';

/// Este archivo contiene la pantalla de menú de filtro de tickets, que permite a los usuarios filtrar tickets
/// según diferentes criterios, como ID de ticket, tipo, estado y rango de fechas.

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
  final FilterTicketMenuController _controller = FilterTicketMenuController();
  List<Ticket> _initialTickets = [];
  String? selectedOptionFilter;

  @override
  void initState() {
    super.initState();
    _fetchInitialTickets();
    _controller.loadSavedSelections(
      context,
      _ticketIdController,
      (type) => setState(() => _selectedType = type),
      (status) => setState(() => _selectedStatus = status),
      (dateRange) => setState(() => _selectedDateRange = dateRange),
    );
  }

  Future<void> _fetchInitialTickets() async {
    _initialTickets = await _controller.fetchInitialTickets(context);
  }

  void _applyFilters() async {
    if (_formKey.currentState!.validate()) {
      await _controller.saveSelections(
        _ticketIdController.text,
        _selectedType,
        _selectedStatus,
        _selectedDateRange,
      );
      final filteredData = await _controller.applyFilters(
        context,
        _ticketIdController.text,
        _selectedType,
        _selectedStatus,
        _selectedDateRange,
        _initialTickets,
      );
      if (filteredData != null) {
        widget.onFilterChanged(filteredData);
        Navigator.of(context).pop();
      }
    }
  }

  void _clearFilters() async {
    await _controller.clearFilters(
      context,
      _ticketIdController,
      () => setState(() {
        _selectedType = null;
        _selectedStatus = null;
        _selectedDateRange = null;
      }),
    );
    widget.onFilterChanged({
      'ticketId': null,
      'type': null,
      'status': null,
      'dateRange': null,
      'tickets': _initialTickets,
    });
    Navigator.of(context).pop();
  }

  void _toggleFilters() {
    setState(() {});
  }

  void _onRangeSelected(DateTime? start, DateTime? end, DateTime focusedDay) {
    setState(() {
      _selectedDateRange = start != null ? DateTimeRange(start: start, end: end ?? start) : null;
      if (_selectedDateRange != null) {
        final formattedRange = _formatDateRange(_selectedDateRange!.start, _selectedDateRange!.end);
        print('Rango formateado: $formattedRange');
      }
    });
  }

  String _formatDateRange(DateTime? start, DateTime? end) {
    final startDate = start != null ? DateFormat('d MMM', 'es').format(start) : 'Inicio';
    final endDate = end != null ? DateFormat('d MMM', 'es').format(end) : 'Fin';
    return '$startDate - $endDate';
  }

  void _showDateRangePicker() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CalendarDialog(
          focusedDay: DateTime.now(),
          rangeStart: _selectedDateRange?.start,
          rangeEnd: _selectedDateRange?.end,
          calendarFormat: CalendarFormat.month,
          rangeSelectionMode: RangeSelectionMode.toggledOff,
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
                const SizedBox(height: 32),
                const Text(
                  'Filtrar Tickets',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _ticketIdController,
                  decoration: const InputDecoration(
                    labelText: 'ID de Ticket',
                    labelStyle: TextStyle(fontSize: 16),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    setState(() {
                      if (value.isNotEmpty) {
                        _selectedType = null;
                        _selectedStatus = null;
                        _selectedDateRange = null;
                      }
                    });
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
                    labelStyle: TextStyle(fontSize: 16),
                  ),
                  dropdownColor: Colors.grey[200],
                  items: const [
                    DropdownMenuItem<String>(
                      value: 'Requerimiento',
                      child: Row(
                        children: [
                          Icon(Icons.help, color: Color(0xFF009FDA), size: 12),
                          SizedBox(width: 8),
                          Text('Requerimiento', style: TextStyle(fontSize: 14)),
                        ],
                      ),
                    ),
                    DropdownMenuItem<String>(
                      value: 'Incidente',
                      child: Row(
                        children: [
                          Icon(Icons.error, color: Color(0xFFE98300), size: 12),
                          SizedBox(width: 8),
                          Text('Incidente', style: TextStyle(fontSize: 14)), 
                        ],
                      ),
                    ),
                  ],
                  onChanged: _ticketIdController.text.isEmpty ? (value) {
                    setState(() {
                      _selectedType = value;
                    });
                  } : null,
                  value: _selectedType,
                  icon: null,
                  disabledHint: const Text('Deshabilitado'),
                  isExpanded: true,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Estado',
                    labelStyle: TextStyle(fontSize: 16),
                  ),
                  dropdownColor: Colors.grey[200], 
                  items: const [
                    DropdownMenuItem<String>(
                      value: 'Nuevo',
                      child: Row(
                        children: [
                          Icon(Icons.circle, color: Colors.green, size: 12),
                          SizedBox(width: 8),
                          Text('Nuevo', style: TextStyle(fontSize: 14)),
                        ],
                      ),
                    ),
                    DropdownMenuItem<String>(
                      value: 'En curso (asignado)',
                      child: Row(
                        children: [
                          Icon(Icons.circle_outlined, color: Colors.green, size: 12),
                          SizedBox(width: 8),
                          Text('En curso (asignado)', style: TextStyle(fontSize: 14)),
                        ],
                      ),
                    ),
                    DropdownMenuItem<String>(
                      value: 'En curso (Planificado)',
                      child: Row(
                        children: [
                          Icon(Icons.calendar_today, color: Colors.black, size: 12),
                          SizedBox(width: 8),
                          Text('En curso (Planificado)', style: TextStyle(fontSize: 13)),
                        ],
                      ),
                    ),
                    DropdownMenuItem<String>(
                      value: 'En espera',
                      child: Row(
                        children: [
                          Icon(Icons.circle, color: Color(0xFFE98300), size: 12),
                          SizedBox(width: 8),
                          Text('En espera', style: TextStyle(fontSize: 14)),
                        ],
                      ),
                    ),
                    DropdownMenuItem<String>(
                      value: 'Resuelto',
                      child: Row(
                        children: [
                          Icon(Icons.check_circle_outline, color: Colors.green, size: 12),
                          SizedBox(width: 8),
                          Text('Resuelto', style: TextStyle(fontSize: 14)),
                        ],
                      ),
                    ),
                    DropdownMenuItem<String>(
                      value: 'Cerrado',
                      child: Row(
                        children: [
                          Icon(Icons.circle, color: Colors.black, size: 12),
                          SizedBox(width: 8),
                          Text('Cerrado', style: TextStyle(fontSize: 14)),
                        ],
                      ),
                    ),
                  ],
                  onChanged: _ticketIdController.text.isEmpty ? (value) {
                    setState(() {
                      _selectedStatus = value;
                    });
                  } : null,
                  value: _selectedStatus,
                  icon: null, 
                  disabledHint: const Text('Deshabilitado'),
                  isExpanded: true, 
                ),
                const SizedBox(height: 16),
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.center, 
                  children: [
                    SizedBox(
                      child: ElevatedButton(
                        onPressed: _ticketIdController.text.isEmpty ? _showDateRangePicker : null,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 4.0),
                          backgroundColor: Colors.red,
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
                              ' Seleccionar rango de fechas ',
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
                      const Text('Inicio:', style: TextStyle(fontSize: 16),),
                      const SizedBox(width: 8),
                      const Icon(Icons.today, color: Colors.grey),
                      Expanded(
                        child: Row(
                          children: [
                            Text(
                              DateFormat('dd/MM/yyyy').format(_selectedDateRange!.start),
                              style: const TextStyle(fontSize: 16),
                            ),
                            const SizedBox(width: 8),
                            ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Text('Fin:', style: TextStyle(fontSize: 16),),
                      const SizedBox(width: 27),
                      const Icon(Icons.event, color: Colors.grey),
                      Expanded(
                        child: Row(
                          children: [
                            Text(
                              DateFormat('dd/MM/yyyy').format(_selectedDateRange!.end),
                              style: const TextStyle(fontSize: 16),
                            ),
                            const SizedBox(width: 8),
                            
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 8),
                const Divider(
                  color: Colors.black,
                  thickness: 0.8,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _applyFilters,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          backgroundColor: const Color(0xFF005586),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          elevation: 5,
                          shadowColor: Colors.black.withOpacity(0.2),
                        ),
                        child: const Text(
                          'Filtrar',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: (_ticketIdController.text.isEmpty &&
                                    _selectedType == null &&
                                    _selectedStatus == null &&
                                    _selectedDateRange == null)
                            ? null
                            : _clearFilters,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          backgroundColor: (_ticketIdController.text.isEmpty &&
                                            _selectedType == null &&
                                            _selectedStatus == null &&
                                            _selectedDateRange == null)
                              ? Colors.grey[300]
                              : Colors.red,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          elevation: 5,
                          shadowColor: Colors.black.withOpacity(0.2),
                        ),
                        child: const Icon(
                          Icons.cleaning_services,
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