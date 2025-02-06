import 'package:flutter/material.dart';
import 'package:startup_namer/config/enviroment.dart';
import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TestTicketService extends StatefulWidget {
  const TestTicketService({super.key});

  @override
  _TestTicketServiceState createState() => _TestTicketServiceState();
}

class _TestTicketServiceState extends State<TestTicketService> {
  final _loginFormKey = GlobalKey<FormState>();
  final _ticketFormKey = GlobalKey<FormState>();
  final _loginController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _contentController = TextEditingController();
  final _storage = const FlutterSecureStorage();
  String? _sessionToken;

  static const String url = 'http://172.20.1.55/soportegia/apirest.php';

  Future<void> _login() async {
    if (_loginFormKey.currentState!.validate()) {
      try {
        final loginUrl = Uri.parse('$url/initSession');
        final response = await http.post(
          loginUrl,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'login': _loginController.text,
            'password': _passwordController.text,
          }),
        );

        if (response.statusCode == 200) {
          final responseBody = jsonDecode(response.body);
          _sessionToken = responseBody['session_token'];
          await _storage.write(key: 'session_token', value: _sessionToken);
          setState(() {}); // Update the UI to show the ticket form
        } else {
          throw Exception('Failed to login: ${response.body}');
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to login: $e')),
        );
      }
    }
  }

  Future<void> _createTicket() async {
    if (_ticketFormKey.currentState!.validate()) {
      try {
        final sessionToken = await _storage.read(key: 'session_token');
        if (sessionToken == null) {
          throw Exception("No session token found");
        }

        TicketService ticketService = TicketService();
        Map<String, dynamic> ticketData = {
          'name': _nameController.text,
          'content': _contentController.text,
          'itilcategories_id': 1, // Valor predeterminado
          'entities_id': 15, // Valor predeterminado
          'urgency': 3, // Valor predeterminado
          'impact': 2, // Valor predeterminado
          'priority': 4, // Valor predeterminado
        };

        var ticketResponse =
            await ticketService.createTicket(ticketData, sessionToken);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Ticket created successfully: ${ticketResponse['ticketId']}')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create ticket: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Ticket'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _sessionToken == null ? _buildLoginForm() : _buildTicketForm(),
      ),
    );
  }

  Widget _buildLoginForm() {
    return Form(
      key: _loginFormKey,
      child: ListView(
        children: [
          TextFormField(
            controller: _loginController,
            decoration: const InputDecoration(labelText: 'Login'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your login';
              }
              return null;
            },
          ),
          TextFormField(
            controller: _passwordController,
            decoration: const InputDecoration(labelText: 'Password'),
            obscureText: true,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your password';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _login,
            child: const Text('Login'),
          ),
        ],
      ),
    );
  }

  Widget _buildTicketForm() {
    return Form(
      key: _ticketFormKey,
      child: ListView(
        children: [
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'Title'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter the title';
              }
              return null;
            },
          ),
          TextFormField(
            controller: _contentController,
            decoration: const InputDecoration(labelText: 'Description'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter the description';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _createTicket,
            child: const Text('Create Ticket'),
          ),
        ],
      ),
    );
  }
}

class TicketService {
  final String url = Environment.apiUrl;
  static const _storage = FlutterSecureStorage();
  static const _sessionTokenKey = 'session_token';

  Future<Map<String, dynamic>> createTicket(
      Map<String, dynamic> ticketData, String sessionToken) async {
    final ticketUrl = Uri.parse('$url/Ticket');
    final headers = {
      'Session-Token': sessionToken,
      //'Session-Token': 'bl1iu0rfodlu7djfprpln8knl5',
      'Content-Type': 'application/json',
    };
    final body = jsonEncode({
      "input": {
        "name": ticketData['name'],
        "content": ticketData['content'],
        "_users_id_requester": ticketData['_users_id_requester'],
        "status": ticketData['status'],
        "type": ticketData['type'],
        "requesttypes_id": ticketData['requesttypes_id'],
        "entities_id": ticketData['entities_id'],
      }
    });

    try {
      final response = await http
          .post(ticketUrl, headers: headers, body: body)
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200 || response.statusCode == 201) {
        final resp = jsonDecode(response.body);
        return {
          'success': true,
          'ticketId': resp['id'],
        };
      } else {
        throw Exception("Error al crear ticket: ${response.body}");
      }
    } on TimeoutException catch (e) {
      throw Exception("La solicitud ha excedido el tiempo de espera: $e");
    } catch (e) {
      throw Exception("Error al crear ticket: $e");
    }
  }
}
