import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../config/environment.dart';

/// Servicio para manejar operaciones relacionadas con el usuario.

class UserService {
  final String url = Environment.apiUrl;
  static const _storage = FlutterSecureStorage();
  static const _sessionTokenKey = 'session_token';

  static int? _cachedUserId; // cache en memoria
  static DateTime? _cachedAt;
  static const Duration _userIdTtl = Duration(minutes: 10);

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
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200 || response.statusCode == 206) {
        final userInfo = jsonDecode(response.body);
        Map otrasEntidadesActivas;
        if (userInfo['session']['glpiactiveentities'] is Map) {
          otrasEntidadesActivas = Map<String, dynamic>.from(
              userInfo['session']['glpiactiveentities']);
        } else if (userInfo['session']['glpiactiveentities'] is List) {
          otrasEntidadesActivas = {
            for (var i = 0;
                i < userInfo['session']['glpiactiveentities'].length;
                i++)
              i.toString(): userInfo['session']['glpiactiveentities'][i]
          };
        } else {
          otrasEntidadesActivas = {};
        }

        usuario.setUser(
          idUsuario: userInfo['session']['glpiID'] ?? 0,
          nombreUsuario: userInfo['session']['glpiname'] ?? '',
          nombreCompleto: userInfo['session']['glpifriendlyname'] ?? '',
          idEntidadActiva: userInfo['session']['glpiactive_entity'] ?? 0,
          idPerfilActivo: userInfo['session']['glpiactiveprofile']['id'] ?? 0,
          perfiles: Map<String, Map<String, dynamic>>.from(
              userInfo['session']['glpiprofiles'] ?? {}),
          perfilActivo: userInfo['session']['glpiactiveprofile']['name'] ?? '',
          tokenSesion: sessionToken,
          nombreEntidadActiva:
              userInfo['session']['glpiactive_entity_shortname'] ?? '',
          otrasEntidadesActivas: otrasEntidadesActivas.cast<String, dynamic>(),
        );
        return true;
      } else {
        throw Exception(
            "Error al obtener informacion del usuario: ${response.body}");
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
    if (id == 0) {
      return 'Usuario Desconocido';
    }
    final sessionToken = await _storage.read(key: _sessionTokenKey);
    final userUrl = Uri.parse('$url/User/$id');
    try {
      final response = await http.get(
        userUrl,
        headers: <String, String>{
          'Session-Token': sessionToken!,
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 15));

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

  /// Obtiene el userId desde getFullSession y lo almacena en caché.
  ///
  /// Realiza una solicitud a la API para obtener el userId.
  /// Si la solicitud es exitosa, almacena el userId en SharedPreferences y lo retorna.
  /// Si ocurre un error, retorna null.
  Future<int?> fetchUserIdAndCache() async {
    final sessionToken = await _storage.read(key: _sessionTokenKey);
    if (sessionToken == null) return null;
    final fullSessionUrl = Uri.parse('$url/getFullSession');
    try {
      final response = await http.get(
        fullSessionUrl,
        headers: <String, String>{
          'Session-Token': sessionToken,
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200 || response.statusCode == 206) {
        final data = jsonDecode(response.body);
        int? extracted;
        try {
          if (data is Map) {
            // GLPI expone glpiID dentro de session
            final session = data['session'];
            if (session is Map) {
              extracted = int.tryParse(session['glpiID']?.toString() ?? '');
              extracted ??= int.tryParse(session['user_id']?.toString() ?? '');
              extracted ??= int.tryParse(session['users_id']?.toString() ?? '');
            }
            // Fallbacks adicionales
            extracted ??= int.tryParse(data['id']?.toString() ?? '');
            final userObj = data['user'];
            if (userObj is Map) {
              extracted ??= int.tryParse(userObj['id']?.toString() ?? '');
            }
          }
        } catch (_) {}
        if (extracted != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setInt('userId', extracted);
          return extracted;
        }
      }
      return null;
    } on TimeoutException {
      return null;
    } catch (_) {
      return null;
    }
  }

  // Intento centralizado para obtener userId desde cache o red
  Future<int?> getCachedOrFetchUserId() async {
    if (_cachedUserId != null && _cachedAt != null) {
      if (DateTime.now().difference(_cachedAt!) < _userIdTtl) {
        return _cachedUserId;
      }
    }
    final prefs = await SharedPreferences.getInstance();
    final local = prefs.getInt('userId');
    if (local != null) {
      _cachedUserId = local;
      _cachedAt = DateTime.now();
      return local;
    }
    final fetched = await fetchUserIdAndCache();
    if (fetched != null) {
      _cachedUserId = fetched;
      _cachedAt = DateTime.now();
    }
    return fetched;
  }
}
