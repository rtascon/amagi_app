import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../controllers/tickets_controller.dart';
import '../models/ticket.dart';
import '../models/type_conversion.dart';
import 'package:intl/intl.dart';

/// Controlador para manejar la lógica de los filtros de tickets.
class FilterTicketMenuController {
  final TypeConversion _typeConversion = TypeConversion();

  Future<void> loadSavedSelections(
    BuildContext context,
    TextEditingController ticketIdController,
    Function(String?) setType,
    Function(String?) setStatus,
    Function(DateTimeRange?) setDateRange,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    ticketIdController.text = prefs.getString('ticketId') ?? '';
    final savedType = prefs.getString('selectedType');
    setType(['Requerimiento', 'Incidente'].contains(savedType) ? savedType : null);
    final savedStatus = prefs.getString('selectedStatus');
    setStatus([
      'Nuevo',
      'En curso (asignado)',
      'En curso (Planificado)',
      'En espera',
      'Resuelto',
      'Cerrado'
    ].contains(savedStatus) ? savedStatus : null);
    final startDate = prefs.getString('rangeStart');
    final endDate = prefs.getString('rangeEnd');
    setDateRange(startDate != null && endDate != null
        ? DateTimeRange(start: DateTime.parse(startDate), end: DateTime.parse(endDate))
        : null);
  }

  Future<void> saveSelections(
    String ticketId,
    String? selectedType,
    String? selectedStatus,
    DateTimeRange? selectedDateRange,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('ticketId', ticketId);
    await prefs.setString('selectedType', selectedType ?? '');
    await prefs.setString('selectedStatus', selectedStatus ?? '');
    if (selectedDateRange != null) {
      await prefs.setString('rangeStart', selectedDateRange.start.toIso8601String());
      await prefs.setString('rangeEnd', selectedDateRange.end.toIso8601String());
    } else {
      await prefs.remove('rangeStart');
      await prefs.remove('rangeEnd');
    }
  }

  Future<List<Ticket>> fetchInitialTickets(BuildContext context) async {
    return await TicketsController().getTicketsList(context, true);
  }

  Future<Map<String, dynamic>?> applyFilters(
    BuildContext context,
    String ticketId,
    String? selectedType,
    String? selectedStatus,
    DateTimeRange? selectedDateRange,
    List<Ticket> initialTickets,
  ) async {
    List<Ticket> filteredTickets = initialTickets;

    if (ticketId.isNotEmpty) {
      int ticketIdInt = int.parse(ticketId);
      try {
        final ticketsData = await TicketsController().getTicketsList(
          context,
          false,
          filters: {'ticketId': ticketIdInt},
        );
        filteredTickets = ticketsData;
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al obtener el ticket filtrado')),
        );
        return null;
      }
    }

    if (selectedStatus == 'Resuelto' || selectedStatus == 'Cerrado') {
      try {
        final ticketsData = await TicketsController().getTicketsList(
          context,
          false,
          filters: {'status': _typeConversion.getEstadoReversa(selectedStatus!)},
        );
        filteredTickets = ticketsData;
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al obtener tickets por estado')),
        );
        return null;
      }
    } else if (selectedStatus != null) {
      filteredTickets = filteredTickets
          .where((ticket) => ticket.estado == _typeConversion.getEstadoReversa(selectedStatus))
          .toList();
    }

    if (selectedType != null) {
      filteredTickets = filteredTickets
          .where((ticket) => ticket.tipo == _typeConversion.getTipoReversa(selectedType))
          .toList();
    }

    if (selectedDateRange != null) {
      final formattedRange = _formatDateRange(selectedDateRange.start, selectedDateRange.end);
      filteredTickets = filteredTickets.where((ticket) {
        return 
        ticket.fechaCreacion.isAfter(selectedDateRange.start.subtract(const Duration(seconds: 1))) &&
        ticket.fechaCreacion.isBefore(selectedDateRange.end.add(const Duration(days: 1)));
      }).toList();
    }

    return {
      'ticketId': ticketId.isNotEmpty ? int.parse(ticketId) : null,
      'type': selectedType != null ? _typeConversion.getTipoReversa(selectedType) : null,
      'status': selectedStatus != null ? _typeConversion.getEstadoReversa(selectedStatus) : null,
      'dateRange': selectedDateRange,
      'tickets': filteredTickets,
    };
  }

  String _formatDateRange(DateTime? start, DateTime? end) {
    final startDate = start != null ? DateFormat('d MMM', 'es').format(start) : 'Inicio';
    final endDate = end != null ? DateFormat('d MMM', 'es').format(end) : 'Fin';
    return '$startDate - $endDate';
  }

  Future<void> clearFilters(
    BuildContext context,
    TextEditingController ticketIdController,
    Function resetState,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('ticketId');
    await prefs.remove('selectedType');
    await prefs.remove('selectedStatus');
    await prefs.remove('rangeStart');
    await prefs.remove('rangeEnd');
    ticketIdController.clear();
    resetState();
  }

}
