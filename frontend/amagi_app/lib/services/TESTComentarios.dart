import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/environment.dart';
import 'dart:async';

/// Servicio para manejar operaciones relacionadas con los comentarios.
class ComentariosService {
  final String url = Environment.apiUrl;

  /// Obtiene los comentarios de seguimiento de un ticket.
  ///
  /// Lanza una excepción si ocurre un error durante la solicitud.
  Future<List<dynamic>> getTicketFollowup(int idTicket, String sessionToken) async {
    final comentariosUrl = Uri.parse('$url/Ticket/$idTicket/ITILFollowup');
    final headers = {
      'Session-Token': sessionToken,
      'Content-Type': 'application/json',
    };

    try {
      final response = await http
          .get(comentariosUrl, headers: headers)
          .timeout(const Duration(seconds: 15));

      // Imprimir la respuesta para depuración
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 206) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((item) => {
          'id': item['id'],
          'users_id': item['users_id'],
          'content': item['content'],
          'date_creation': item['date_creation'],
          'is_private': item['is_private'],
        }).toList();
      } else {
        throw Exception(
            "Error al obtener comentarios del ticket: ${response.body}");
      }
    } on TimeoutException catch (e) {
      throw Exception("La solicitud ha excedido el tiempo de espera: $e");
    } catch (e) {
      throw Exception("Error al obtener comentarios del ticket: $e");
    }
  }

  /// Añade un seguimiento a un ticket existente.
  ///
  /// Lanza una excepción si ocurre un error durante la solicitud.
  Future<int> addFollowupToTicket(int ticketId, String descripcion, String sessionToken) async {
    final followupUrl = Uri.parse('$url/Ticket/$ticketId/ITILFollowup');
    final headers = {
      'Session-Token': sessionToken,
      'Content-Type': 'application/json',
    };

    int followupId = 0;

    final body = jsonEncode({
      "input": {
        "items_id": ticketId,
        "itemtype": "Ticket",
        "content": descripcion,
        "is_private": false // Asegura que el comentario sea público
        
      }
    });

    try {
      final response = await http
          .post(followupUrl, headers: headers, body: body)
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        followupId = responseData['id'];
      }
      return followupId;
    } on TimeoutException catch (e) {
      throw Exception("La solicitud ha excedido el tiempo de espera: $e");
    } catch (e) {
      throw Exception("Error al añadir el comentario/histórico: $e");
    }
  }
}

/// Pantalla para ingresar usuario, contraseña y ver el histórico de un ticket.
class TicketHistoryScreen extends StatefulWidget {
  const TicketHistoryScreen({super.key});

  @override
  _TicketHistoryScreenState createState() => _TicketHistoryScreenState();
}

class _TicketHistoryScreenState extends State<TicketHistoryScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _ticketIdController = TextEditingController();
  final ComentariosService _comentariosService = ComentariosService();
  bool _isLoading = false;
    List<dynamic>? _followups;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _ticketIdController.dispose();
    super.dispose();
  }

  Future<void> _fetchTicketFollowups() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final sessionToken = await _login(_usernameController.text.trim(), _passwordController.text.trim());
      final followups = await _comentariosService.getTicketFollowup(
        int.parse(_ticketIdController.text.trim()),
        sessionToken,
      );
      setState(() {
        _followups = followups;
      });
    } catch (e) {
      print('Error: $e'); // Imprimir el error para depuración
      _showErrorMessage(context, 'Error al obtener el histórico del ticket.');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
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

      // Imprimir la respuesta para depuración
      print('Login response status: ${response.statusCode}');
      print('Login response body: ${response.body}');

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

  void _showErrorMessage(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: const Column(
            children: [
              Icon(Icons.error, color: Colors.red, size: 40),
              SizedBox(height: 10),
              Text('Error'),
            ],
          ),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Aceptar',
                style: TextStyle(color: Theme.of(context).primaryColor),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Histórico de Ticket'),
        backgroundColor: const Color(0xFF005586),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(labelText: 'Usuario'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Contraseña'),
              obscureText: true,
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _ticketIdController,
              decoration: const InputDecoration(labelText: 'ID del Ticket'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isLoading ? null : _fetchTicketFollowups,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF005586),
                foregroundColor: Colors.white,
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    )
                  : const Text('Ver Histórico'),
            ),
            const SizedBox(height: 20),
            _followups != null
                ? Expanded(
                    child: ListView.builder(
                      itemCount: _followups!.length,
                      itemBuilder: (context, index) {
                        final followup = _followups![index];
                        return ListTile(
                          title: Text(followup['content']),
                          subtitle: Text('Fecha: ${followup['date_creation']}'),
                        );
                      },
                    ),
                  )
                : const Text('Ingrese el ID del ticket para ver el histórico.'),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: TicketHistoryScreen(),
  ));
}
