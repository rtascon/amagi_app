import 'ticket.dart';

// Clase concreta TicketImpl que extiende de Ticket
class TicketImpl extends Ticket {
  TicketImpl({
    required super.id,
    required super.titulo,
    required super.descripcion,
    required super.fechaCreacion,
    required super.fechaActualizacion,
    required super.tipo,
    required super.estado,
    required super.entidadAsociada,
    required super.prioridad,
    super.historicos,
  });
}
