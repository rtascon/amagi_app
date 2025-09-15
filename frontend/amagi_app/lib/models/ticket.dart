// Clase abstracta Ticket
abstract class Ticket {
  int id;
  String titulo;
  String descripcion;
  DateTime fechaCreacion;
  DateTime fechaActualizacion;
  int tipo;
  int estado;
  String entidadAsociada;
  int prioridad;
  List<Map<String, dynamic>>? historicos;
  List<Map<String, dynamic>> soluciones;

  Ticket({
    required this.id,
    required this.titulo,
    required this.descripcion,
    required this.fechaCreacion,
    required this.fechaActualizacion,
    required this.tipo,
    required this.estado,
    required this.entidadAsociada,
    required this.prioridad,
    this.historicos,
    List<Map<String, dynamic>>? soluciones,
  }) : soluciones = soluciones ?? [];
}
