class TypeConversion {
  final Map<int, String> prioridadMap = {
    2: 'Baja',
    3: 'Media',
    4: 'Alta',
    5: 'Muy Alta',
    6: 'Mayor'
  };

  final Map<int, String> tipoMap = {
    1: 'Incidente',
    2: 'Requerimiento'
  };

  final Map<int, String> estadoMap = {
    1: 'Nuevo',
    2: 'En curso (asignado)',
    3: 'En curso (Planificado)',
    4: 'En espera',
    5: 'Resuelto',
    6: 'Cerrado'
  };

  final Map<String, int> prioridadReversaMap = {
    'Baja': 2,
    'Media': 3,
    'Alta': 4,
    'Muy Alta': 5,
    'Mayor': 6
  };

  final Map<String, int> tipoReversaMap = {
    'Incidente': 1,
    'Requerimiento': 2
  };

  final Map<String, int> estadoReversaMap = {
    'Nuevo': 1,
    'En curso (asignado)': 2,
    'En curso (Planificado)': 3,
    'En espera': 4,
    'Resuelto': 5,
    'Cerrado': 6
  };

  String getPrioridad(int prioridad) {
    return prioridadMap[prioridad] ?? 'Desconocida';
  }

  String getTipo(int tipo) {
    return tipoMap[tipo] ?? 'Desconocido';
  }

  String getEstado(int estado) {
    return estadoMap[estado] ?? 'Desconocido';
  }

  int getPrioridadReversa(String prioridad) {
    return prioridadReversaMap[prioridad] ?? -1;
  }

  int getTipoReversa(String tipo) {
    return tipoReversaMap[tipo] ?? -1;
  }

  int getEstadoReversa(String estado) {
    return estadoReversaMap[estado] ?? -1;
  }
}