import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/enviroment.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class GlpiGeneralService {
  final String url = Environment.apiUrl;
  static final _storage = FlutterSecureStorage();
  static const _sessionTokenKey = 'session_token';

  GlpiGeneralService();

  Future<List<dynamic>> getRequestType() async {
    final sessionToken = await _storage.read(key: _sessionTokenKey);
    if (sessionToken == null) {
      throw Exception("No session token found");
    }
    final headers = {
      'Session-Token': sessionToken,
    };

    final response = await http.get(Uri.parse('$url/RequestType'), headers: headers);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load request type');
    }
  }
}