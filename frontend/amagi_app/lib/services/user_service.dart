import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user.dart';
import '../config/enviroment.dart';

class UserService {
  final String url = Environment.apiUrl;
  static final _storage = FlutterSecureStorage();
  static const _sessionTokenKey = 'session_token';
  
  Future<bool> obtenerUsuarioInfo(User usuario) async {
    final sessionToken = await _storage.read(key: _sessionTokenKey);
    final userUrl = Uri.parse('$url/getFullSession');
    try {
      final response = await http.get(
        userUrl,
        headers: <String, String>{
          'Session-Token': sessionToken!,
          'Content-Type': 'application/json',
        },
      ).timeout(Duration(seconds: 15)); 

      if (response.statusCode == 200 || response.statusCode == 206) {
        final userInfo = jsonDecode(response.body);
        var otrasEntidadesActivas;
        if (userInfo['session']['glpiactiveentities'] is Map) {
          otrasEntidadesActivas = Map<String, dynamic>.from(userInfo['session']['glpiactiveentities']);
        } else if (userInfo['session']['glpiactiveentities'] is List) {
          otrasEntidadesActivas = {
            for (var i = 0; i < userInfo['session']['glpiactiveentities'].length; i++)
              i.toString(): userInfo['session']['glpiactiveentities'][i]
          };
        } else {
          otrasEntidadesActivas = {};
        }

        // Configurar el objeto Usuario
        usuario.setUser(
          idUsuario: userInfo['session']['glpiID'] ?? 0,
          nombreUsuario: userInfo['session']['glpiname'] ?? '',
          nombreCompleto: userInfo['session']['glpifriendlyname'] ?? '',
          idEntidadActiva: userInfo['session']['glpiactive_entity'] ?? 0,
          perfiles: Map<String, Map<String, dynamic>>.from(userInfo['session']['glpiprofiles'] ?? {}),
          idPerfilActivo: userInfo['session']['glpiactiveprofile'][0] ?? 0,
          perfilActivo: userInfo['session']['glpiactiveprofile'][1] ?? '',
          tokenSesion: sessionToken,
          nombreEntidadActiva: userInfo['session']['glpiactive_entity_shortname'] ?? '',
          otrasEntidadesActivas: otrasEntidadesActivas,
        );
        return true;
      } else {
        throw Exception("Error al obtener informacion del usuario: ${response.body}");
      }
    } on TimeoutException catch (e) {
      throw Exception("La solicitud ha excedido el tiempo de espera: $e");
    } catch (e) {
      throw Exception("Error al obtener informacion del usuario: $e");
    }
  }

  Future<String> obtenerNombreUsuario(int id) async {
    final sessionToken = await _storage.read(key: _sessionTokenKey);
    final userUrl = Uri.parse('$url/User/$id');
    try {
      final response = await http.get(
        userUrl,
        headers: <String, String>{
          'Session-Token': sessionToken!,
          'Content-Type': 'application/json',
        },
      ).timeout(Duration(seconds: 15)); // Configurar el tiempo de espera a 15 segundos

      if (response.statusCode == 200 || response.statusCode == 206) {
        final userInfo = jsonDecode(response.body);
        return userInfo['firstname'] + ' ' + userInfo['realname'];
      } else {
        return 'Usuario desconocido';
      }
    } on TimeoutException catch (e) {
      throw Exception("La solicitud ha excedido el tiempo de espera: $e");
    } catch (e) {
      throw Exception("Error al obtener el nombre del usuario: $e");
    }
  }
}