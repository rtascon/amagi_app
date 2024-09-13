import 'dart:convert';
import 'package:http/http.dart' as http;

class GlpiGeneralService {
  final String apiUrl;

  GlpiGeneralService(this.apiUrl);

  Future<List<dynamic>> getRequestType(String sessionToken) async {
    final headers = {
      'Session-Token': sessionToken,
    };

    final response = await http.get(Uri.parse('$apiUrl/RequestType'), headers: headers);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load request type');
    }
  }
}