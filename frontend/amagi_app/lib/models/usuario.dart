class Usuario {
  static final Usuario _instance = Usuario._internal();
  
  Usuario._internal();
  factory Usuario() {
    return _instance;
  }

  late int idUsuario;
  late String nombreUsuario;
  late String nombreCompleto;
  late int idEntidadActiva;
  late Map<String, Map<String, dynamic>> perfiles;
  late int idPerfilActivo;
  late String perfilActivo;
  late String tokenSesion;
  late String nombreEntidadActiva;
  late Map<String, dynamic> otrasEntidadesActivas;

  void setUsuario({
    required int idUsuario,
    required String nombreUsuario,
    required String nombreCompleto,
    required int idEntidadActiva,
    required Map<String, Map<String, dynamic>> perfiles,
    required int idPerfilActivo,
    required String perfilActivo,
    required String tokenSesion,
    required String nombreEntidadActiva,
    required Map<String, dynamic> otrasEntidadesActivas,
  }) {
    this.idUsuario = idUsuario;
    this.nombreUsuario = nombreUsuario;
    this.nombreCompleto = nombreCompleto;
    this.idEntidadActiva = idEntidadActiva;
    this.perfiles = perfiles;
    this.perfilActivo = perfilActivo;
    this.tokenSesion = tokenSesion;
    this.nombreEntidadActiva = nombreEntidadActiva;
    this.otrasEntidadesActivas = otrasEntidadesActivas;
  }

  int get getIdUsuario => idUsuario;
  String get getNombreUsuario => nombreUsuario;
  String get getNombreCompleto => nombreCompleto;
  int get getIdEntidadActiva => idEntidadActiva;
  Map<String, Map<String, dynamic>> get getPerfiles => perfiles;
  int get getIdPerfilActivo => idPerfilActivo;
  String get getPerfilActivo => perfilActivo;
  String get getTokenSesion => tokenSesion;
  String get getNombreEntidadActiva => nombreEntidadActiva;
  Map<String, dynamic> get getOtrasEntidadesActivas => otrasEntidadesActivas;

}