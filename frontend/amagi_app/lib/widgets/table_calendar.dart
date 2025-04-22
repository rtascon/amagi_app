import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

/// Widget personalizado que muestra un calendario en un diálogo,
/// permitiendo la selección de un rango de fechas.

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
  late TextEditingController _startDayController;
  late TextEditingController _startMonthController;
  late TextEditingController _startYearController;
  late TextEditingController _endDayController;
  late TextEditingController _endMonthController;
  late TextEditingController _endYearController;
  bool _showDateFields = true;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('es', null);
    _focusedDay = widget.focusedDay;
    _rangeStart = widget.rangeStart;
    _rangeEnd = widget.rangeEnd;
    _calendarFormat = CalendarFormat.month;
    _rangeSelectionMode = widget.rangeSelectionMode;
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
      _rangeEnd = end ?? start;
      _focusedDay = focusedDay;
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
    widget.onRangeSelected(start, end?.add(const Duration(days: 1)).subtract(const Duration(seconds: 1)), focusedDay);
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
    return Builder(
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.white,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 500,
            height: 450,
            margin: const EdgeInsets.all(10),
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
                  availableCalendarFormats: const {CalendarFormat.month: 'Month'},
                  rangeSelectionMode: _rangeSelectionMode,
                  headerStyle: HeaderStyle(
                    formatButtonVisible: false,
                    titleCentered: true,
                    titleTextFormatter: (date, locale) => DateFormat.yMMMM(locale).format(date).replaceFirst(' de ', ' ').replaceFirstMapped(RegExp(r'^\w'), (match) => match.group(0)!.toUpperCase()),
                  ),
                  locale: 'es_ES',
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      _focusedDay = focusedDay;

                      if (_rangeStart == _rangeEnd && _rangeStart != null) {
                        _rangeStart = null; 
                        _rangeEnd = null;
                        _rangeSelectionMode = RangeSelectionMode.toggledOff;
                        _endDayController.text = selectedDay.day.toString();
                        _endMonthController.text = selectedDay.month.toString();
                        _endYearController.text = selectedDay.year.toString();
                      }

                      else if (_rangeStart != null && _rangeEnd == null) {
                        _rangeStart = _rangeStart;
                        _rangeEnd = selectedDay;
                        _rangeSelectionMode = RangeSelectionMode.toggledOn;
                        _endDayController.text = selectedDay.day.toString();
                        _endMonthController.text = selectedDay.month.toString();
                        _endYearController.text = selectedDay.year.toString();
                      }

                      else {
                        _rangeStart = selectedDay;
                        _rangeEnd = null;
                        _rangeSelectionMode = RangeSelectionMode.toggledOff;
                        _startDayController.text = selectedDay.day.toString();
                        _startMonthController.text = selectedDay.month.toString();
                        _startYearController.text = selectedDay.year.toString();
                      }
                    });

                    widget.onRangeSelected(_rangeStart, _rangeEnd, _focusedDay);
                  },
                  enabledDayPredicate: (day) {
                    
                    if (_rangeStart == _rangeEnd) {
                      return true; 
                    } else if (_rangeStart != null) { 
                      return day.isAfter(_rangeStart!.subtract(const Duration(days: 1))); 
                    } 
                    return true; 
                  },
                  calendarStyle: const CalendarStyle(
                    todayDecoration: BoxDecoration(
                      color: Color(0xFFE98300),
                      shape: BoxShape.circle,
                    ),
                    selectedDecoration: BoxDecoration(
                      color: Color(0xFF005586),
                      shape: BoxShape.circle,
                    ),
                    weekendTextStyle: TextStyle(
                      color: Color(0xFFE98300),
                    ),
                    defaultTextStyle: TextStyle(
                      color: Colors.black,
                    ),
                    rangeStartDecoration: BoxDecoration(
                      color: Color(0xFF005586),
                      shape: BoxShape.circle,
                    ),
                    rangeEndDecoration: BoxDecoration(
                      color: Color(0xFF005586),
                      shape: BoxShape.circle,
                    ),
                    withinRangeTextStyle: TextStyle(color: Colors.white),
                    rangeHighlightColor: Color.fromARGB(255, 0, 105, 167),
                    cellMargin: const EdgeInsets.all(1.0),
                  ),
                  daysOfWeekStyle: const DaysOfWeekStyle(
                    weekdayStyle: TextStyle(fontSize: 12.0),
                    weekendStyle: TextStyle(fontSize: 12.0, color: Color(0xFFE98300)),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 10),
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
