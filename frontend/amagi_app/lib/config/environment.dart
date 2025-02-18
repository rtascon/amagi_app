import 'package:flutter_dotenv/flutter_dotenv.dart';

class Environment {
  static String get apiUrl => dotenv.env['API_URL'] ?? 'http://default.url';
  static String get appServiceCredentialUsername =>
      dotenv.env['APP_SERVICE_CREDENTIAL_USERNAME'] ?? 'default_username';
  static String get appServiceCredentialPassword =>
      dotenv.env['APP_SERVICE_CREDENTIAL_PASSWORD'] ?? 'default_password';
  static String get glpiInternalDbAuthSource =>
      dotenv.env['GLPI_INTERNAL_DB_AUTH_SOURCE'] ?? 'default_auth_source';
  static String get requesttypes =>
      dotenv.env['REQUESTTYPES'] ?? 'default_requesttypes';
  static String get profile =>
      dotenv.env['PROFILE'] ?? 'default_profile';
  static String get entity =>
      dotenv.env['ENTITY'] ?? 'default_entity';
}

//API_URL=https://mi-glpi.com/apirest.php
//APP_SERVICE_CREDENTIAL_USERNAME=tu_usuario
//APP_SERVICE_CREDENTIAL_PASSWORD=tu_contraseña
//GLPI_INTERNAL_DB_AUTH_SOURCE=tu_fuente_de_autenticación