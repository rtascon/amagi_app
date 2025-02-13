import 'package:flutter/material.dart';
import 'package:startup_namer/config/environment.dart';
import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;

class TESTSoluciones extends StatefulWidget {
  @override
  _TESTSolucionesState createState() => _TESTSolucionesState();
}

class _TESTSolucionesState extends State<TESTSoluciones> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _ticketIdController = TextEditingController();
  final String url = Environment.apiUrl;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _ticketIdController.dispose();
    super.dispose();
  }

  Future<String> _login(String username, String password) async {
    final loginUrl = Uri.parse('${Environment.apiUrl}/initSession');
    final headers = {
      'Content-Type': 'application/json',
    };
    final body = jsonEncode({
      'login': username,
      'password': password,
    });

    try {
      final response = await http
          .post(loginUrl, headers: headers, body: body)
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return responseData['session_token'];
      } else {
        throw Exception('Error al iniciar sesión: ${response.body}');
      }
    } on TimeoutException catch (e) {
      throw Exception("La solicitud ha excedido el tiempo de espera: $e");
    } catch (e) {
      throw Exception("Error al iniciar sesión: $e");
    }
  }

  Future<List<dynamic>> getTicketSolution(int idTicket, String sessionToken) async {
    final solucionUrl = Uri.parse('$url/Ticket/$idTicket/ITILSolution');
    final headers = {
      'Session-Token': sessionToken,
      'Content-Type': 'application/json',
    };

    try {
      final response = await http
          .get(solucionUrl, headers: headers)
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else if (response.statusCode == 404) {
        return []; // No hay solución para este ticket
      } else {
        throw Exception("Error al obtener la solución del ticket: ${response.body}");
      }
    } on TimeoutException catch (e) {
      throw Exception("La solicitud ha excedido el tiempo de espera: $e");
    } catch (e) {
      throw Exception("Error al obtener la solución del ticket: $e");
    }
  }

  void _submit() async {
    final username = _usernameController.text;
    final password = _passwordController.text;
    final ticketId = _ticketIdController.text;

    print('Username: $username');
    print('Password: $password');
    print('Ticket ID: $ticketId');

    try {
      final sessionToken = await _login(username, password);
      final solution = await getTicketSolution(int.parse(ticketId), sessionToken);
      if (solution.isNotEmpty) {
        print('Solution: ${solution[0]['content']}');
      } else {
        print('No solution found for this ticket.');
      }
    } catch (e) {
      print('Error fetching ticket solution: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Obtener Comentarios de Solución'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(labelText: 'Username'),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            TextField(
              controller: _ticketIdController,
              decoration: InputDecoration(labelText: 'Ticket ID'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submit,
              child: Text('Obtener Comentarios'),
            ),
          ],
        ),
      ),
    );
  }
}