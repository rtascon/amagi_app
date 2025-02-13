import 'package:flutter/material.dart';
import 'package:startup_namer/config/environment.dart';
import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TestTicketSatis extends StatefulWidget {
  const TestTicketSatis({super.key});

  @override
  _TestTicketSatisState createState() => _TestTicketSatisState();
}

class _TestTicketSatisState extends State<TestTicketSatis> {
  final _loginFormKey = GlobalKey<FormState>();
  final _ticketFormKey = GlobalKey<FormState>();
  final _loginController = TextEditingController();
  final _passwordController = TextEditingController();
  final _ticketIdController = TextEditingController();
  final _commentController = TextEditingController();
  final _satisfactionController = TextEditingController();
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
          setState(() {}); // Update the UI to show the satisfaction form
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

  Future<void> _updateSatisfaction() async {
    if (_ticketFormKey.currentState!.validate()) {
      try {
        final sessionToken = await _storage.read(key: 'session_token');
        if (sessionToken == null) {
          throw Exception("No session token found");
        }

        TicketService ticketService = TicketService();
        int ticketId = int.parse(_ticketIdController.text);
        String comment = _commentController.text;
        int satisfaction = int.parse(_satisfactionController.text);

        var satisfactionData = await ticketService.getSatisfactionTicket(
          sessionToken,
          Environment.apiUrl,
          ticketId,
        );

        var satisfactionResponse = await ticketService.postSatisfactionTicket(
          sessionToken,
          Environment.apiUrl,
          ticketId,
          satisfactionData['id'],
          comment,
          satisfaction,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Satisfaction updated successfully: ${satisfactionResponse['id']}')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update satisfaction: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Update Satisfaction'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _sessionToken == null ? _buildLoginForm() : _buildSatisfactionForm(),
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

  Widget _buildSatisfactionForm() {
    return Form(
      key: _ticketFormKey,
      child: ListView(
        children: [
          TextFormField(
            controller: _ticketIdController,
            decoration: const InputDecoration(labelText: 'Ticket ID'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter the ticket ID';
              }
              return null;
            },
          ),
          TextFormField(
            controller: _commentController,
            decoration: const InputDecoration(labelText: 'Comment'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter the comment';
              }
              return null;
            },
          ),
          TextFormField(
            controller: _satisfactionController,
            decoration: const InputDecoration(labelText: 'Satisfaction (1-5)'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter the satisfaction level';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _updateSatisfaction,
            child: const Text('Update Satisfaction'),
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

  Future<Map<String, dynamic>> getSatisfactionTicket(
      String sessionToken, String apiUrl, int ticketId) async {
    final headers = {
      'Session-Token': sessionToken,
    };
    final url = Uri.parse('http://172.20.1.55/soportegia/apirest.php/TicketSatisfaction/$ticketId');
    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Error al obtener la satisfacción del ticket: ${response.body}");
    }
  }

  Future<Map<String, dynamic>> postSatisfactionTicket(
      String sessionToken, String apiUrl, int ticketId, int satisfactionId, String comment, int satisfaction) async {
    final headers = {
      'Session-Token': sessionToken,
      'Content-Type': 'application/json',
    };
    final url = Uri.parse('$apiUrl/Ticket/$ticketId/TicketSatisfaction/$satisfactionId');
    final body = jsonEncode({
      "input": {
        "comment": comment,
        "satisfaction": satisfaction,
      }
    });

    final response = await http.put(url, headers: headers, body: body);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Error al enviar la satisfacción del ticket: ${response.body}");
    }
  }
}
