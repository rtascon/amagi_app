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
}