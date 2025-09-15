import 'ticket_impl.dart';
import 'ticket.dart';

// Clase TicketFactory que implementa el patrón de diseño fábrica
class TicketFactory {
  static Ticket createTicket({
    required int id,
    required String titulo,
    required String descripcion,
    required DateTime fechaCreacion,
    required DateTime fechaActualizacion,
    required int tipo,
    required int estado,
    required String entidadAsociada,
    required int prioridad,
    List<Map<String, dynamic>>? historicos,
  }) {
    return TicketImpl(
      id: id,
      titulo: titulo,
      descripcion: descripcion,
      fechaCreacion: fechaCreacion,
      fechaActualizacion: fechaActualizacion,
      tipo: tipo,
      estado: estado,
      entidadAsociada: entidadAsociada,
      prioridad: prioridad,
      historicos: historicos,
    );
  }

  // Nuevo: crea un TicketImpl a partir de los resultados de search/Ticket
  static Ticket createFromSearchMap(Map raw) {
    int parseInt(dynamic v) => int.tryParse(v?.toString() ?? '') ?? 0;
    DateTime parseDate(dynamic v) {
      if (v == null) return DateTime.fromMillisecondsSinceEpoch(0);
      try {
        return DateTime.parse(v.toString());
      } catch (_) {
        return DateTime.fromMillisecondsSinceEpoch(0);
      }
    }

    return TicketImpl(
      id: parseInt(raw['2'] ?? raw['id'] ?? raw['ID']),
      titulo: (raw['1'] ?? '').toString(),
      descripcion: (raw['21'] ?? '').toString(),
      estado: parseInt(raw['12'] ?? raw['status']),
      fechaCreacion: parseDate(raw['15']),
      fechaActualizacion: parseDate(raw['19']),
      entidadAsociada: (raw['80'] ?? '').toString(),
      prioridad: parseInt(raw['3'] ?? raw['priority']),
      tipo: parseInt(raw['14'] ?? raw['type']),
    );
  }
}
