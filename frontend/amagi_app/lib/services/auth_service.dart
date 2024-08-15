import 'package:http/http.dart' as http;
import 'dart:convert';

class AuthService {
  final String url = 'http://172.20.1.55/soportegiades/apirest.php';
  String? _sessionToken;

  Future<bool> iniciarSesion(String username, String password) async {
    final loginUrl = Uri.parse('$url/initSession');
    final response = await http.post(
      loginUrl,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'login': username,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final responseBody = jsonDecode(response.body);
      _sessionToken = responseBody['session_token'];
      return true;
    } else {
      throw Exception("Error al iniciar sesion: ${response.body}");
    }
  }

  Future<Map<String, dynamic>> obtenerGetFullSession() async {
    final userUrl = Uri.parse('$url/getFullSession');
    final response = await http.get(
      userUrl,
      headers: <String, String>{
        'Session-Token': _sessionToken!,
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200 || response.statusCode == 206) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Error al obtener informacion del usuario: ${response.body}");
    }
  }

  Future<Map<String, dynamic>> obtenerPermisos(int idPerfil) async {
    final userUrl = Uri.parse('$url/Profile/$idPerfil/getActiveProfile');
    final response = await http.get(
      userUrl,
      headers: <String, String>{
        'Session-Token': _sessionToken!,
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200 || response.statusCode == 206) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Error al obtener informacion del usuario: ${response.body}");
    }
  }

  Future<Map<String, dynamic>> obtenerGetMyProfiles() async {
    final userUrl = Uri.parse('$url/getMyProfiles');
    final response = await http.get(
      userUrl,
      headers: <String, String>{
        'Session-Token': _sessionToken!,
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200 || response.statusCode == 206) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Error al obtener informacion del usuario: ${response.body}");
    }
  }

  Future<Map<String, dynamic>> listarUsuarios() async {
    final userUrl = Uri.parse('$url/User');
    final response = await http.get(
      userUrl,
      headers: <String, String>{
        'Session-Token': _sessionToken!,
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200 || response.statusCode == 206) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Error al obtener informacion del usuario: ${response.body}");
    }
  }

  Future<Map<String, dynamic>> obtenerUsuarioInfo() async {
    final userUrl = Uri.parse('$url/getCurrentUser');
    final response = await http.get(
      userUrl,
      headers: <String, String>{
        'Session-Token': _sessionToken!,
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Error al obtener informacion del usuario: ${response.body}");
    }
  }

  Future<void> cerrarSesion() async {
    final logoutUrl = Uri.parse('$url/killSession');
    final response = await http.post(
      logoutUrl,
      headers: <String, String>{
        'Session-Token': _sessionToken!,
      },
    );

    if (response.statusCode != 200) {
      throw Exception("Error al cerrar sesion: ${response.body}");
    }
  }

  String? get sessionToken => _sessionToken;
}