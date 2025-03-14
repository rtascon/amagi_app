import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
// Importar intl para la localización
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

class CalendarDialog extends StatefulWidget {
  final DateTime focusedDay;
  final DateTime? rangeStart;
  final DateTime? rangeEnd;
  final CalendarFormat calendarFormat;
  final RangeSelectionMode rangeSelectionMode;
  final Function(DateTime?, DateTime?, DateTime) onRangeSelected;

  CalendarDialog({
    required this.focusedDay,
    required this.rangeStart,
    required this.rangeEnd,
    required this.calendarFormat,
    required this.rangeSelectionMode,
    required this.onRangeSelected,
  });

  @override
  _CalendarDialogState createState() => _CalendarDialogState();
}

class _CalendarDialogState extends State<CalendarDialog> {
  late DateTime _focusedDay;
  DateTime? _rangeStart;
  DateTime? _rangeEnd;
  late CalendarFormat _calendarFormat;
  late RangeSelectionMode _rangeSelectionMode;
  late TextEditingController _startDateController;
  late TextEditingController _endDateController;
  late TextEditingController _startDayController;
  late TextEditingController _startMonthController;
  late TextEditingController _startYearController;
  late TextEditingController _endDayController;
  late TextEditingController _endMonthController;
  late TextEditingController _endYearController;
  bool _showDateFields = true; // Mostrar los campos de fecha por defecto

  @override
  void initState() {
    super.initState();
    // Inicializar localización en español
    initializeDateFormatting('es', null);
    _focusedDay = widget.focusedDay;
    _rangeStart = widget.rangeStart;
    _rangeEnd = widget.rangeEnd;
    _calendarFormat = CalendarFormat.month; // Establecer formato a mes
    _rangeSelectionMode = widget.rangeSelectionMode;
    _startDateController = TextEditingController();
    _endDateController = TextEditingController();
    _startDayController = TextEditingController();
    _startMonthController = TextEditingController();
    _startYearController = TextEditingController();
    _endDayController = TextEditingController();
    _endMonthController = TextEditingController();
    _endYearController = TextEditingController();
  }

  void _onRangeSelected(DateTime? start, DateTime? end, DateTime focusedDay) {
    setState(() {
      _rangeStart = start;
      _rangeEnd = end ?? start; // Asignar start a _rangeEnd si end es null
      _focusedDay = focusedDay;
      // Actualizar los campos de texto cuando se selecciona un rango
      if (_rangeStart != null) {
        _startDayController.text = _rangeStart!.day.toString();
        _startMonthController.text = _rangeStart!.month.toString();
        _startYearController.text = _rangeStart!.year.toString();
      }
      if (_rangeEnd != null) {
        _endDayController.text = _rangeEnd!.day.toString();
        _endMonthController.text = _rangeEnd!.month.toString();
        _endYearController.text = _rangeEnd!.year.toString();
      }
    });
    widget.onRangeSelected(start, end, focusedDay);
  }

  bool _isValidDay(String value) {
    final day = int.tryParse(value);
    return day != null && day >= 1 && day <= 31;
  }

  bool _isValidMonth(String value) {
    final month = int.tryParse(value);
    return month != null && month >= 1 && month <= 12;
  }

  bool _isValidYear(String value) {
    final year = int.tryParse(value);
    return year != null && year >= 2020 && year <= 2025;
  }

  String _formatDateRange(DateTime? start, DateTime? end) {
    final startDate = start != null ? DateFormat('d MMM', 'es').format(start) : 'Inicio';
    final endDate = end != null ? DateFormat('d MMM', 'es').format(end) : 'Fin';
    return '$startDate - $endDate';
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white, 
      content: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: MediaQuery.of(context).size.width * 0.6, 
        height: MediaQuery.of(context).size.height * 0.55,
        child: Column(
          children: [
            TableCalendar(
              firstDay: DateTime(2020),
              lastDay: DateTime.now(),
              focusedDay: _focusedDay,
              calendarFormat: _calendarFormat,
              rangeStartDay: _rangeStart,
              rangeEndDay: _rangeEnd,
              onRangeSelected: _onRangeSelected,
              // Deshabilitar cambio de formato
              availableCalendarFormats: const {CalendarFormat.month: 'Month'},
              rangeSelectionMode: _rangeSelectionMode,
              headerStyle: HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true, // Centrar el mes y el año
                titleTextFormatter: (date, locale) => DateFormat.yMMMM(locale).format(date).replaceFirst(' de ', ' ').replaceFirstMapped(RegExp(r'^\w'), (match) => match.group(0)!.toUpperCase()),
              ),
              locale: 'es_ES', // Configurar localización a español
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _focusedDay = focusedDay;
                  if (_rangeStart != null && _rangeStart == selectedDay) {
                    _rangeEnd = selectedDay; 
                    _rangeSelectionMode = RangeSelectionMode.toggledOff;
                    _endDayController.text = selectedDay.day.toString();
                    _endMonthController.text = selectedDay.month.toString();
                    _endYearController.text = selectedDay.year.toString();
                  } else if (_rangeStart != null && _rangeEnd == null && _rangeStart != selectedDay) {
                    _rangeEnd = selectedDay;
                    _rangeSelectionMode = RangeSelectionMode.toggledOff;
                    _endDayController.text = selectedDay.day.toString();
                    _endMonthController.text = selectedDay.month.toString();
                    _endYearController.text = selectedDay.year.toString();
                  } else{
                    _rangeStart = selectedDay;
                    _rangeEnd = null; // Asignar la misma fecha a _rangeEnd
                    _rangeSelectionMode = RangeSelectionMode.toggledOn;
                    _startDayController.text = selectedDay.day.toString();
                    _startMonthController.text = selectedDay.month.toString();
                    _startYearController.text = selectedDay.year.toString();
                    _endDayController.text = selectedDay.day.toString(); // Actualizar _endDayController
                    _endMonthController.text = selectedDay.month.toString(); // Actualizar _endMonthController
                    _endYearController.text = selectedDay.year.toString(); // Actualizar _endYearController
                  }
                });
              },
            ),
            // Botones para abrir la ventana emergente de selección de fechas y cerrar el diálogo
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween, // Alinear a los extremos
              children: [
                Text(
                  _formatDateRange(_rangeStart, _rangeEnd),
                  style: TextStyle(
                    color: (_rangeStart == null || _rangeEnd == null) ? Colors.grey : Colors.black,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Listo', style: TextStyle(color: Colors.black)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
