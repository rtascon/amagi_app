import 'package:http/http.dart' as http;
import 'dart:convert';

class AuthService {
  String? _sessionToken;

  Future<bool> authenticate(String username, String password) async {
    final url = Uri.parse('http://tu-backend.com/api/auth/login');
    final response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'username': username,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final responseBody = jsonDecode(response.body);
      _sessionToken = responseBody['token']; // Suponiendo que el token está en el campo 'token'
      // Guarda el token de sesión o realiza las acciones necesarias
      return true;
    } else {
      return false;
    }
  }

  String? get sessionToken => _sessionToken;
}