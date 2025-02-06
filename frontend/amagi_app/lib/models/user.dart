/// Clase que representa un usuario en el sistema.
///
/// Esta clase sigue el patrón Singleton para asegurar que solo exista una instancia de usuario
/// en toda la aplicación.
class User {
  // Constructor interno privado.
  User._internal();

  /// Constructor de fábrica que retorna la instancia única de la clase User.
  factory User() {
    return _instance;
  }

  static final User _instance = User._internal();

  late int idUsuario = 0;
  late String nombreUsuario = '';
  late String nombreCompleto = '';
  late int idEntidadActiva = 0;
  late Map<String, Map<String, dynamic>> perfiles = {};
  late int idPerfilActivo = 0;
  late String perfilActivo = '';
  late String tokenSesion = '';
  late String nombreEntidadActiva;
  late Map<String, dynamic> otrasEntidadesActivas;

  // Método para inicializar el usuario
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
    this.idPerfilActivo = idPerfilActivo;
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