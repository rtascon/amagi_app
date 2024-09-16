import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../config/enviroment.dart';
import 'package:intl/intl.dart';

class TicketService {
  final String url = Environment.apiUrl;
  static final _storage = FlutterSecureStorage();
  static const _sessionTokenKey = 'session_token';
  static final Map<String, String> criteriaBaseTicketAutogestion = {
    'criteria[0][field]': '4',  // 5 es el campo para el ID del solicitante (requester)
    'criteria[0][searchtype]': 'equals',
    'criteria[0][value]': ''//Id de usuario
  };
  static const Map<String, String> forceDisplayTicket = {
      'forcedisplay[0]': '2',  // ID del ticket
      'forcedisplay[1]': '1',  // Nombre del ticket
      'forcedisplay[2]': '21',  // Descripción del ticket
      'forcedisplay[3]': '12',  // Estado del ticket
      'forcedisplay[4]': '15',  // Fecha de creación
      'forcedisplay[5]': '19',  // Fecha de actualización
      'forcedisplay[6]': '80',  // Nombre de entidad asociada
      'forcedisplay[7]': '3',  // prioridad
      'forcedisplay[8]': '14',  // tipo
  };


  Future<List<dynamic>> obtenerTicketsUsuarioFiltroPorDefecto(int userId) async {
    final sessionToken = await _storage.read(key: _sessionTokenKey);
    if (sessionToken == null) {
      throw Exception("No session token found");
    }

    final ticketsUrl = Uri.parse('$url/search/Ticket');
    final headers = {
      'Session-Token': sessionToken,
      'Content-Type': 'application/json',
    };
    criteriaBaseTicketAutogestion['criteria[0][value]'] = userId.toString();
    Map<String, String> criteriaBodyAutogestion = {
      'criteria[1][link]': 'AND NOT',
      'criteria[1][field]': '12', 
      'criteria[1][searchtype]': 'equals',
      'criteria[1][value]': '6',  // 6 es el estado de los tickets cerrados
      'criteria[2][link]': 'AND NOT',
      'criteria[2][field]': '12', 
      'criteria[2][searchtype]': 'equals',
      'criteria[2][value]': '5',  // es el estado de los tickets resueltos
    };
    final params = {...criteriaBaseTicketAutogestion, ...criteriaBodyAutogestion, ...forceDisplayTicket};

    final response = await http.get(ticketsUrl.replace(queryParameters: params), headers: headers);

    if (response.statusCode == 200) {
      return jsonDecode(response.body)['data'];
    } else {
      throw Exception("Error al obtener tickets: ${response.body}");
    }
  }

  Future<List<dynamic>> obtenerTicketsUsuarioFiltrado(int userId, Map<String, dynamic> filters) async {
    final sessionToken = await _storage.read(key: _sessionTokenKey);
    if (sessionToken == null) {
      throw Exception("No session token found");
    }

    final ticketsUrl = Uri.parse('$url/search/Ticket');
    final headers = {
      'Session-Token': sessionToken,
      'Content-Type': 'application/json',
    };
    criteriaBaseTicketAutogestion['criteria[0][value]'] = userId.toString();
    // Base criteria
    Map<String, String> criteria = criteriaBaseTicketAutogestion;

    // Add additional filters
    int criteriaIndex = 1;
    if (filters['ticketId'] != null) {
      criteria['criteria[$criteriaIndex][link]'] = 'AND';
      criteria['criteria[$criteriaIndex][field]'] = '2';
      criteria['criteria[$criteriaIndex][searchtype]'] = 'equals';
      criteria['criteria[$criteriaIndex][value]'] = filters['ticketId'].toString();
      criteriaIndex++;
    }
    if (filters['status'] != null) {
      criteria['criteria[$criteriaIndex][link]'] = 'AND';
      criteria['criteria[$criteriaIndex][field]'] = '12';
      criteria['criteria[$criteriaIndex][searchtype]'] = 'equals';
      criteria['criteria[$criteriaIndex][value]'] = filters['status'].toString();
      criteriaIndex++;
    }
    if (filters['type'] != null) {
      criteria['criteria[$criteriaIndex][link]'] = 'AND';
      criteria['criteria[$criteriaIndex][field]'] = '14';
      criteria['criteria[$criteriaIndex][searchtype]'] = 'equals';
      criteria['criteria[$criteriaIndex][value]'] = filters['type'].toString();
      criteriaIndex++;
    }
    if (filters['dateRange'] != null) {
      final DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm:ss');
      criteria['criteria[$criteriaIndex][link]'] = 'AND';
      criteria['criteria[$criteriaIndex][field]'] = '15';
      criteria['criteria[$criteriaIndex][searchtype]'] = 'morethan';
      criteria['criteria[$criteriaIndex][value]'] = formatter.format(filters['dateRange'].start);
      criteriaIndex++;
      criteria['criteria[$criteriaIndex][link]'] = 'AND';
      criteria['criteria[$criteriaIndex][field]'] = '15';
      criteria['criteria[$criteriaIndex][searchtype]'] = 'lessthan';
      criteria['criteria[$criteriaIndex][value]'] = formatter.format(filters['dateRange'].end);
      criteriaIndex++;
    }

    final params = {...criteria, ...forceDisplayTicket};

    final response = await http.get(ticketsUrl.replace(queryParameters: params), headers: headers);

    if (response.statusCode == 200) {
      return jsonDecode(response.body)['data'];
    } else {
      throw Exception("Error al obtener tickets: ${response.body}");
    }
  }

  Future<void> updateTicket(int ticketId, Map<String, dynamic> updateData) async {
    final sessionToken = await _storage.read(key: _sessionTokenKey);
    if (sessionToken == null) {
      throw Exception("No session token found");
    }

    final ticketUrl = Uri.parse('$url/Ticket/$ticketId');
    final headers = {
      'Session-Token': sessionToken,
      'Content-Type': 'application/json',
    };
    final body = jsonEncode({
      "input": updateData,
    });

    final response = await http.put(ticketUrl, headers: headers, body: body);
    if (response.statusCode != 200) {
      throw Exception("Error al actualizar el ticket: ${response.body}");
    }
  }

  Future<void> sendRatings(int ticketId, int rating, String comentarios) async {
    final sessionToken = await _storage.read(key: _sessionTokenKey);
    if (sessionToken == null) {
      throw Exception("No session token found");
    }

    final calificacionUrl = Uri.parse('$url/Ticket/$ticketId/');
    final headers = {
      'Session-Token': sessionToken,
      'Content-Type': 'application/json',
    };
    final body = jsonEncode({
      "rating": rating,
      "comentarios": comentarios,
    });

    final response = await http.post(calificacionUrl, headers: headers, body: body);
    if (response.statusCode != 200) {
      throw Exception("Error al enviar la calificación: ${response.body}");
    }
  }


  Future<List<dynamic>> obtenerHistoricosTicket(int idTicket) async {
    final sessionToken = await _storage.read(key: _sessionTokenKey);
    if (sessionToken == null) {
      throw Exception("No session token found");
    }

    final comentariosUrl = Uri.parse('$url/Ticket/$idTicket/ITILFollowup');
    final headers = {
      'Session-Token': sessionToken,
      'Content-Type': 'application/json',
    };

    final response = await http.get(comentariosUrl, headers: headers);

    if (response.statusCode == 200 || response.statusCode == 206) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Error al obtener comentarios del ticket: ${response.body}");
    }
  }

  Future<Map<String, dynamic>> obtenerDocumentoHistorico(int docId) async {
    final sessionToken = await _storage.read(key: _sessionTokenKey);
    if (sessionToken == null) {
      throw Exception("No session token found");
    }

    final documentoUrl = Uri.parse('$url/Document/$docId');
    final headers = {
      'Session-Token': sessionToken,
      'Content-Type': 'application/json',
    };

    final response = await http.get(documentoUrl, headers: headers);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Error al obtener documento del ticket: ${response.body}");
    }
  }

  Future<String> obtenerDocumentoCrudo(int docId, {String? appToken}) async {
    final sessionToken = await _storage.read(key: _sessionTokenKey);
    if (sessionToken == null) {
      throw Exception("No session token found");
    }

    final documentoUrl = Uri.parse('$url/Document/$docId').replace(queryParameters: {'alt': 'media'});
    final headers = {
      'Session-Token': sessionToken,
      'Accept': 'application/octet-stream',
    };

    if (appToken != null) {
      headers['App-Token'] = appToken;
    }

    final response = await http.get(documentoUrl, headers: headers);

    if (response.statusCode == 200) {
      final directory = await getTemporaryDirectory();
      final filePath = '${directory.path}/document_$docId';
      final file = File(filePath);
      await file.writeAsBytes(response.bodyBytes);
      return filePath;
    } else {
      throw Exception("Error al obtener documento del ticket: ${response.body}");
    }
  }



  Future<List<dynamic>> obtenerDetalleComentario(int ticketCommentId) async {

    final sessionToken = await _storage.read(key: _sessionTokenKey);
    if (sessionToken == null) {
      throw Exception("No session token found");
    }

    final comentarioUrl = Uri.parse('$url/ITILFollowup/$ticketCommentId/Document_Item');
    final headers = {
      'Session-Token': sessionToken,
      'Content-Type': 'application/json',
    };

    final response = await http.get(comentarioUrl, headers: headers);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Error al obtener detalle del comentario: ${response.body}");
    }

  }

  Future<Map<String, dynamic>> crearTicket(Map<String, dynamic> ticketData) async {
    final sessionToken = await _storage.read(key: _sessionTokenKey);
    if (sessionToken == null) {
      throw Exception("No session token found");
    }

    final ticketUrl = Uri.parse('$url/Ticket');
    final headers = {
      'Session-Token': sessionToken,
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
      }
    });

    final response = await http.post(ticketUrl, headers: headers, body: body);
    if (response.statusCode == 200 || response.statusCode == 201) {
      final resp = jsonDecode(response.body);
      return {
        'success': true,
        'ticketId': resp['id'], 
      };
    } else {
      throw Exception("Error al crear ticket: ${response.body}");
    }
  }


}
