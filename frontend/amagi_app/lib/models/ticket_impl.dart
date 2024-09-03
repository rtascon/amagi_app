import 'ticket.dart';

// Clase concreta TicketImpl que extiende de Ticket
class TicketImpl extends Ticket {
  TicketImpl({
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
  }) : super(
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