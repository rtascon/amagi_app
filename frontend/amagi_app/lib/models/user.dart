class User {
  static final User _instance = User._internal();
  
  User._internal();
  factory User() {
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

  void setUser({
    required int idUsuario,
    required String nombreUsuario,
    required String tokenSesion,
    String nombreCompleto = '',
    int idEntidadActiva = 0,
    Map<String, Map<String, dynamic>> perfiles = const {},
    int idPerfilActivo = 0,
    String perfilActivo = '',
    String nombreEntidadActiva = '',
    Map<String, dynamic> otrasEntidadesActivas = const {},
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