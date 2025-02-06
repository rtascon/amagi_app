import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user.dart';
import '../config/enviroment.dart';

/// Servicio para manejar operaciones relacionadas con el usuario.
class UserService {
  final String url = Environment.apiUrl;
  static final _storage = FlutterSecureStorage();
  static const _sessionTokenKey = 'session_token';

  /// Obtiene la información completa del usuario y la almacena en el objeto [usuario].
  /// 
  /// Lanza una excepción si ocurre un error durante la solicitud.
  Future<bool> getUserInfo(User usuario) async {
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
          idPerfilActivo: userInfo['session']['glpiactiveprofile']['id'] ?? 0,
          perfiles: Map<String, Map<String, dynamic>>.from(userInfo['session']['glpiprofiles'] ?? {}),
          perfilActivo: userInfo['session']['glpiactiveprofile']['name'] ?? '',
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

  /// Obtiene el nombre completo del usuario dado su [id].
  /// 
  /// Realiza una solicitud a la API para obtener la información del usuario.
  /// Si la solicitud es exitosa, retorna el nombre completo del usuario.
  /// Si ocurre un error, lanza una excepción o retorna 'Usuario desconocido'.
  /// 
  /// Lanza una excepción si ocurre un error durante la solicitud.
  Future<String> getUserName(int id) async {
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