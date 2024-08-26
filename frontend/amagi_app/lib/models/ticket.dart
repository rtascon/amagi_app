// Clase abstracta Ticket
abstract class Ticket {
  int _id;
  String _titulo;
  String _descripcion;
  DateTime _fechaCreacion;
  DateTime _fechaActualizacion;
  int _tipo;
  int _estado;
  String _entidadAsociada;
  int _prioridad;

  Ticket({
    required int id,
    required String titulo,
    required String descripcion,
    required DateTime fechaCreacion,
    required DateTime fechaActualizacion,
    required int tipo,
    required int estado,
    required String entidadAsociada,
    required int prioridad,
  })  : _id = id,
        _titulo = titulo,
        _descripcion = descripcion,
        _fechaCreacion = fechaCreacion,
        _fechaActualizacion = fechaActualizacion,
        _tipo = tipo,
        _estado = estado,
        _entidadAsociada = entidadAsociada,
        _prioridad = prioridad;

  // Getters
  int get id => _id;
  String get titulo => _titulo;
  String get descripcion => _descripcion;
  DateTime get fechaCreacion => _fechaCreacion;
  DateTime get fechaActualizacion => _fechaActualizacion;
  int get tipo => _tipo;
  int get estado => _estado;
  String get entidadAsociada => _entidadAsociada;
  int get prioridad => _prioridad;

  // Setters
  set id(int id) => _id = id;
  set titulo(String titulo) => _titulo = titulo;
  set descripcion(String descripcion) => _descripcion = descripcion;
  set fechaCreacion(DateTime fechaCreacion) => _fechaCreacion = fechaCreacion;
  set fechaActualizacion(DateTime fechaActualizacion) => _fechaActualizacion = fechaActualizacion;
  set tipo(int tipo) => _tipo = tipo;
  set estado(int estado) => _estado = estado;
  set entidadAsociada(String entidadAsociada) => _entidadAsociada = entidadAsociada;
  set prioridad(int prioridad) => _prioridad = prioridad;
}