import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../config/environment.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'package:file_picker/file_picker.dart';
import 'package:http_parser/http_parser.dart';
import 'mime_extension.dart';
import 'package:flutter/material.dart';
import '../views/common_pop_ups.dart';
import 'package:http/io_client.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

/// Servicio para manejar operaciones relacionadas con los tickets.
class TicketService {
  final String url = Environment.apiUrl;
  static const _storage = FlutterSecureStorage();
  static const _sessionTokenKey = 'session_token';

  // Toggle para logs
  static bool enableDebugLogs = true;
  void _log(String msg) {
    if (enableDebugLogs) debugPrint('[TicketService] $msg');
  }

  // Nuevas constantes para estandarizar timeouts y reintentos
  static const Duration kConnectTimeout = Duration(seconds: 5);
  static const Duration kRequestTimeout = Duration(seconds: 15);
  static const int kMaxGetRetries = 2; // total intentos = kMaxGetRetries + 1
  static const Duration kRetryBaseDelay = Duration(milliseconds: 600);

  static final Map<String, String> criteriaBaseTicketAutogestion = {
    'criteria[0][field]': '4',
    'criteria[0][searchtype]': 'equals',
    'criteria[0][value]': ''
  };
  static const Map<String, String> forceDisplayTicket = {
    'forcedisplay[0]': '2', // ID del ticket
    'forcedisplay[1]': '1', // Nombre del ticket
    'forcedisplay[2]': '21', // Descripción del ticket
    'forcedisplay[3]': '12', // Estado del ticket
    'forcedisplay[4]': '15', // Fecha de creación
    'forcedisplay[5]': '19', // Fecha de actualización
    'forcedisplay[6]': '80', // Nombre de entidad asociada
    'forcedisplay[7]': '3', // prioridad
    'forcedisplay[8]': '14', // tipo
  };

  // Client con timeout de conexión corto para evitar cuelgues al no estar en la red local
  http.Client _newClient() {
    final io = HttpClient()..connectionTimeout = kConnectTimeout;
    _log('Creating IOClient (connectTimeout=$kConnectTimeout)');
    return IOClient(io);
  }

  // Fallback globales (deben configurarse desde MaterialApp)
  static GlobalKey<NavigatorState>? navigatorKey;
  static GlobalKey<ScaffoldMessengerState>? scaffoldMessengerKey;

  // Método de conveniencia para configurar keys desde main.dart
  static void configureGlobalKeys({
    required GlobalKey<NavigatorState> navKey,
    required GlobalKey<ScaffoldMessengerState> smKey,
  }) {
    navigatorKey = navKey;
    scaffoldMessengerKey = smKey;
  }

  BuildContext? _lastKnownContext;

  // Anti-spam para SnackBars
  DateTime? _lastSnackAt;

  static bool _keysWarned = false;

  // Helpers para mostrar popups de forma segura
  void _postFrame(VoidCallback fn) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        fn();
      } catch (_) {}
    });
  }

  // Guarda un contexto si está montado para usarlo como fallback
  void _rememberContext(BuildContext? context) {
    if (context is Element && context.mounted) {
      _lastKnownContext = context;
      _log('Remembered last known context');
    }
  }

  BuildContext? _getSafeContext(BuildContext? context) {
    if (context is Element && context.mounted) {
      _log('Using provided BuildContext');
      return context;
    }
    if (_lastKnownContext is Element &&
        (_lastKnownContext as Element).mounted) {
      _log('Using lastKnownContext');
      return _lastKnownContext;
    }
    final ctx = TicketService.navigatorKey?.currentContext;
    if (ctx is Element && ctx.mounted) {
      _log('Using navigatorKey.currentContext');
      return ctx;
    }
    _log('No valid BuildContext available to show popup');
    return null;
  }

  // Advertencia única si no hay keys configuradas
  void _warnIfKeysMissing() {
    final hasNav = TicketService.navigatorKey?.currentContext != null;
    final hasSM = TicketService.scaffoldMessengerKey?.currentState != null;
    if (!hasNav && !hasSM && !_keysWarned) {
      _keysWarned = true;
      _log('Faltan navigatorKey/scaffoldMessengerKey. '
          'Configura en MaterialApp y asigna a TicketService para mostrar popups/snackbars.');
    }
  }

  // Muestra un SnackBar global (fallback cuando no hay BuildContext)
  void _showSnack(String message, {BuildContext? context}) {
    if (context is Element && context.mounted) {
      final now = DateTime.now();
      if (_lastSnackAt != null &&
          now.difference(_lastSnackAt!) < const Duration(seconds: 2)) {
        _log('SnackBar suppressed to avoid spam');
        return;
      }
      _lastSnackAt = now;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
        );
      _log('SnackBar (local) shown: $message');
      return;
    }

    final key = TicketService.scaffoldMessengerKey;
    if (key == null) {
      _warnIfKeysMissing();
      _log(
          'No ScaffoldMessengerKey set; cannot show SnackBar. Message: $message');
      return;
    }
    final now = DateTime.now();
    if (_lastSnackAt != null &&
        now.difference(_lastSnackAt!) < const Duration(seconds: 2)) {
      _log('SnackBar suppressed to avoid spam');
      return;
    }
    _lastSnackAt = now;
    key.currentState?.hideCurrentSnackBar();
    key.currentState?.showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
    _log('SnackBar (global) shown: $message');
  }

  void _tryShowDialog(
    FutureOr<void> Function(BuildContext) showFn,
    BuildContext? preferred, {
    required String fallbackMessage,
    FutureOr<void> Function(BuildContext)? overlayFn,
  }) async {
    BuildContext? ctx = _getSafeContext(preferred);

    if (ctx == null) {
      for (int i = 0; i < 15; i++) {
        final candidate = TicketService.navigatorKey?.currentContext;
        if (candidate is Element && candidate.mounted) {
          ctx = candidate;
          _log(
              'Obtained context from navigatorKey after waiting (${(i + 1) * 100}ms)');
          break;
        }
        await Future.delayed(const Duration(milliseconds: 100));
      }
    }

    if (ctx == null) {
      _warnIfKeysMissing();
      _log(
          'Cannot show dialog: no mounted context after waiting. Using SnackBar fallback.');
      _showSnack(fallbackMessage, context: _lastKnownContext);
      return;
    }

    _postFrame(() {
      try {
        showFn(ctx!);
      } catch (e) {
        _log('showDialog failed ($e). Trying overlay fallback...');
        try {
          if (overlayFn != null) {
            overlayFn(ctx!);
            return;
          }
        } catch (e2) {
          _log('Overlay fallback failed ($e2). Using SnackBar.');
        }
        _showSnack(fallbackMessage, context: ctx);
      }
    });
  }

  void _showTimeout(BuildContext? context) {
    _log('Request timeout -> trying to show Timeout dialog');
    _tryShowDialog(
      showTimeoutMessage,
      context,
      fallbackMessage: 'Tiempo de espera agotado. Intente de nuevo.',
      overlayFn: showTimeoutOverlayMessage,
    );
  }

  void _showNoInternet(BuildContext? context) {
    _log('No Internet -> trying to show NoInternet dialog');
    _tryShowDialog(
      showNoInternetMessage,
      context,
      fallbackMessage: 'Sin conexión a Internet.',
      overlayFn: showNoInternetOverlayMessage,
    );
  }

  void _maybeShowNetworkError(Object e, BuildContext? context) {
    _log('Network error detected: ${e.runtimeType}');
    if (e is TimeoutException) {
      _showTimeout(context);
      return;
    }
    if (e is SocketException ||
        e is http.ClientException ||
        e is HandshakeException ||
        e is TlsException ||
        e is HttpException ||
        e is IOException) {
      _showNoInternet(context);
    }
  }

  // Verifica conectividad básica antes de llamar a la red
  Future<void> _ensureConnectivity(BuildContext? context) async {
    _rememberContext(context);
    final connectivity = await Connectivity().checkConnectivity();
    _log('Connectivity status: $connectivity');
    if (connectivity == ConnectivityResult.none) {
      _log('No connectivity detected, aborting call');
      _showNoInternet(context);
      throw const SocketException('No Internet connection');
    }
  }

  // Backoff exponencial con tope
  Duration _backoff(int attempt) {
    final ms = kRetryBaseDelay.inMilliseconds * (1 << attempt);
    final capped = ms > 4000 ? 4000 : ms;
    return Duration(milliseconds: capped);
  }

  // GET con reintentos para fallos transitorios y timeouts
  Future<http.Response> _getWithRetry(
    Uri url,
    Map<String, String> headers,
    http.Client client, {
    BuildContext? context,
    Duration? timeout,
  }) async {
    for (var attempt = 0; attempt <= kMaxGetRetries; attempt++) {
      _log('GET $url attempt ${attempt + 1}/${kMaxGetRetries + 1}');
      try {
        final response = await client
            .get(url, headers: headers)
            .timeout(timeout ?? kRequestTimeout);
        if ((response.statusCode == 502 ||
                response.statusCode == 503 ||
                response.statusCode == 504) &&
            attempt < kMaxGetRetries) {
          final delay = _backoff(attempt);
          _log(
              'Transient HTTP ${response.statusCode}. Retrying in ${delay.inMilliseconds}ms');
          await Future.delayed(delay);
          continue;
        }
        return response;
      } on TimeoutException {
        if (attempt >= kMaxGetRetries) {
          _log('Timeout on last attempt');
          _showTimeout(context);
          rethrow;
        }
        final delay = _backoff(attempt);
        _log(
            'Timeout on attempt ${attempt + 1}. Retrying in ${delay.inMilliseconds}ms');
        await Future.delayed(delay);
      } on SocketException catch (e) {
        if (attempt >= kMaxGetRetries) {
          _log('SocketException on last attempt: $e');
          _showNoInternet(context);
          rethrow;
        }
        final delay = _backoff(attempt);
        _log(
            'SocketException on attempt ${attempt + 1}. Retrying in ${delay.inMilliseconds}ms');
        await Future.delayed(delay);
      } on http.ClientException catch (e) {
        if (attempt >= kMaxGetRetries) {
          _log('ClientException on last attempt: $e');
          _showNoInternet(context);
          rethrow;
        }
        final delay = _backoff(attempt);
        _log(
            'ClientException on attempt ${attempt + 1}. Retrying in ${delay.inMilliseconds}ms');
        await Future.delayed(delay);
      } on HandshakeException catch (e) {
        if (attempt >= kMaxGetRetries) {
          _log('HandshakeException on last attempt: $e');
          _showNoInternet(context);
          rethrow;
        }
        final delay = _backoff(attempt);
        _log(
            'HandshakeException on attempt ${attempt + 1}. Retrying in ${delay.inMilliseconds}ms');
        await Future.delayed(delay);
      } on TlsException catch (e) {
        if (attempt >= kMaxGetRetries) {
          _log('TlsException on last attempt: $e');
          _showNoInternet(context);
          rethrow;
        }
        final delay = _backoff(attempt);
        _log(
            'TlsException on attempt ${attempt + 1}. Retrying in ${delay.inMilliseconds}ms');
        await Future.delayed(delay);
      } on IOException catch (e) {
        if (attempt >= kMaxGetRetries) {
          _log('IOException on last attempt: $e');
          _showNoInternet(context);
          rethrow;
        }
        final delay = _backoff(attempt);
        _log(
            'IOException on attempt ${attempt + 1}. Retrying in ${delay.inMilliseconds}ms');
        await Future.delayed(delay);
      }
    }

    throw TimeoutException('Sin respuesta tras reintentos');
  }

  /// Obtiene los tickets del usuario con un filtro predeterminado.
  ///
  /// Lanza una excepción si ocurre un error durante la solicitud.
  Future<List<dynamic>> getUserTicketFilterDefault(int userId,
      {BuildContext? context}) async {
    _log('getUserTicketFilterDefault(userId=$userId)');
    _rememberContext(context);
    await _ensureConnectivity(context);
    final sessionToken = await _storage.read(key: _sessionTokenKey);
    if (sessionToken == null) {
      throw Exception("No session token found");
    }

    final ticketsUrl = Uri.parse('$url/search/Ticket');
    final headers = {
      'Session-Token': sessionToken,
      'Content-Type': 'application/json',
    };

    final Map<String, String> criteriaBase =
        Map<String, String>.from(criteriaBaseTicketAutogestion)
          ..['criteria[0][value]'] = userId.toString();
    Map<String, String> criteriaBodyAutogestion = {
      'criteria[1][link]': 'AND NOT',
      'criteria[1][field]': '12',
      'criteria[1][searchtype]': 'equals',
      'criteria[1][value]': '6',
      'criteria[2][link]': 'AND NOT',
      'criteria[2][field]': '12',
      'criteria[2][searchtype]': 'equals',
      'criteria[2][value]': '5',
    };
    final params = {
      ...criteriaBase,
      ...criteriaBodyAutogestion,
      ...forceDisplayTicket
    };

    final client = _newClient();
    try {
      final response = await _getWithRetry(
        ticketsUrl.replace(queryParameters: params),
        headers,
        client,
        context: context,
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body)['data'];
      } else {
        throw Exception("Error al obtener tickets: ${response.body}");
      }
    } on SocketException {
      _showNoInternet(context);
      throw Exception("Conexión interrumpida durante la solicitud");
    } on TimeoutException {
      _showTimeout(context);
      rethrow;
    } catch (e) {
      _maybeShowNetworkError(e, context);
      throw Exception("Error al obtener tickets: $e");
    } finally {
      client.close();
    }
  }

  /// Obtiene los tickets del usuario con filtros personalizados.
  ///
  /// Lanza una excepción si ocurre un error durante la solicitud.
  Future<List<dynamic>> getUserTicketFiltered(
      int userId, Map<String, dynamic> filters,
      {BuildContext? context}) async {
    _log('getUserTicketFiltered(userId=$userId, filters=$filters)');
    _rememberContext(context);
    await _ensureConnectivity(context);
    final sessionToken = await _storage.read(key: _sessionTokenKey);
    if (sessionToken == null) {
      throw Exception("No session token found");
    }

    final ticketsUrl = Uri.parse('$url/search/Ticket');
    final headers = {
      'Session-Token': sessionToken,
      'Content-Type': 'application/json',
    };
    Map<String, String> criteria =
        Map<String, String>.from(criteriaBaseTicketAutogestion)
          ..['criteria[0][value]'] = userId.toString();

    int criteriaIndex = 1;
    if (filters['ticketId'] != null) {
      criteria['criteria[$criteriaIndex][link]'] = 'AND';
      criteria['criteria[$criteriaIndex][field]'] = '2';
      criteria['criteria[$criteriaIndex][searchtype]'] = 'equals';
      criteria['criteria[$criteriaIndex][value]'] =
          filters['ticketId'].toString();
      criteriaIndex++;
    }
    if (filters['status'] != null) {
      criteria['criteria[$criteriaIndex][link]'] = 'AND';
      criteria['criteria[$criteriaIndex][field]'] = '12';
      criteria['criteria[$criteriaIndex][searchtype]'] = 'equals';
      criteria['criteria[$criteriaIndex][value]'] =
          filters['status'].toString();
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
      criteria['criteria[$criteriaIndex][value]'] =
          formatter.format(filters['dateRange'].start);
      criteriaIndex++;
      criteria['criteria[$criteriaIndex][link]'] = 'AND';
      criteria['criteria[$criteriaIndex][field]'] = '15';
      criteria['criteria[$criteriaIndex][searchtype]'] = 'lessthan';
      criteria['criteria[$criteriaIndex][value]'] =
          formatter.format(filters['dateRange'].end);
      criteriaIndex++;
    }

    final params = {...criteria, ...forceDisplayTicket};

    final client = _newClient();
    try {
      final response = await _getWithRetry(
        ticketsUrl.replace(queryParameters: params),
        headers,
        client,
        context: context,
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body)['data'];
      } else {
        throw Exception("Error al obtener tickets: ${response.body}");
      }
    } on SocketException {
      _showNoInternet(context);
      throw Exception("Conexión interrumpida durante la solicitud");
    } on TimeoutException {
      _showTimeout(context);
      rethrow;
    } catch (e) {
      _maybeShowNetworkError(e, context);
      throw Exception("Error al obtener tickets: $e");
    } finally {
      client.close();
    }
  }

  /// Actualiza un ticket con los datos proporcionados.
  ///
  /// Lanza una excepción si ocurre un error durante la solicitud.
  Future<void> updateTicket(int ticketId, Map<String, dynamic> updateData,
      {BuildContext? context}) async {
    _log('updateTicket(ticketId=$ticketId)');
    _rememberContext(context);
    await _ensureConnectivity(context);
    final sessionToken = await _storage.read(key: _sessionTokenKey);
    if (sessionToken == null) {
      throw Exception("No session token found");
    }

    final ticketUrl = Uri.parse('$url/Ticket/$ticketId');
    final headers = {
      'Session-Token': sessionToken,
      'Content-Type': 'application/json',
    };
    final body = jsonEncode({"input": updateData});

    final client = _newClient();
    try {
      final response =
          await client.put(ticketUrl, headers: headers, body: body).timeout(
        kRequestTimeout,
        onTimeout: () {
          _log('updateTicket timeout');
          _showTimeout(context);
          throw TimeoutException("Solicitud cancelada por timeout");
        },
      );

      if (response.statusCode != 200) {
        throw Exception("Error al actualizar el ticket: ${response.body}");
      }
    } on SocketException {
      _showNoInternet(context);
      throw Exception("Conexión interrumpida durante la solicitud");
    } on TimeoutException {
      _showTimeout(context);
      rethrow;
    } catch (e) {
      _maybeShowNetworkError(e, context);
      throw Exception("Error al actualizar el ticket: $e");
    } finally {
      client.close();
    }
  }

  //El siguiente fragmento de código es un ejemplo de cómo se puede implementar la función para enviar una calificación a un ticket.
  //Estado: No funciona
/*
  Future<void> sendRatings(int ticketId, int rating, String comentarios) async {
    final sessionToken = await _storage.read(key: _sessionTokenKey);
    if (sessionToken == null) {
      throw Exception("No session token found");
    }
  
    final calificacionUrl = Uri.parse('$url/TicketSatisfaction/$ticketId/');
    final headers = {
      'Session-Token': sessionToken,
      'Content-Type': 'application/json',
    };
    final body = jsonEncode({
      "satisfaction": rating,
      "comment": comentarios,
    });
  
    try {
      final response = await http.post(calificacionUrl, headers: headers, body: body)
          .timeout(Duration(seconds: 15)); // Configurar el tiempo de espera a 15 segundos
  
      if (response.statusCode != 200) {
        throw Exception("Error al enviar la calificación: ${response.body}");
      }
    } on TimeoutException catch (e) {
      throw Exception("La solicitud ha excedido el tiempo de espera: $e");
    } catch (e) {
      throw Exception("Error al enviar la calificación: $e");
    }
  }
*/

  /// Obtiene los comentarios de seguimiento de un ticket.
  ///
  /// Lanza una excepción si ocurre un error durante la solicitud.
  Future<List<dynamic>> getTicketFollowup(int idTicket,
      {BuildContext? context}) async {
    _log('getTicketFollowup(idTicket=$idTicket)');
    _rememberContext(context);
    await _ensureConnectivity(context);
    final sessionToken = await _storage.read(key: _sessionTokenKey);
    if (sessionToken == null) {
      throw Exception("No session token found");
    }

    final comentariosUrl = Uri.parse('$url/Ticket/$idTicket/ITILFollowup');
    final headers = {
      'Session-Token': sessionToken,
      'Content-Type': 'application/json',
    };

    final client = _newClient();
    try {
      final response = await _getWithRetry(
        comentariosUrl,
        headers,
        client,
        context: context,
      );

      if (response.statusCode == 200 || response.statusCode == 206) {
        return jsonDecode(response.body);
      } else {
        throw Exception(
            "Error al obtener comentarios del ticket: ${response.body}");
      }
    } on SocketException {
      _showNoInternet(context);
      throw Exception("Conexión interrumpida durante la solicitud");
    } on TimeoutException {
      _showTimeout(context);
      rethrow;
    } catch (e) {
      _maybeShowNetworkError(e, context);
      throw Exception("Error al obtener comentarios del ticket: $e");
    } finally {
      client.close();
    }
  }

  /// Obtiene un documento asociado a un seguimiento de ticket.
  ///
  /// Lanza una excepción si ocurre un error durante la solicitud.
  Future<Map<String, dynamic>> getDocFollowup(int docId,
      {BuildContext? context}) async {
    _log('getDocFollowup(docId=$docId)');
    _rememberContext(context);
    await _ensureConnectivity(context);
    final sessionToken = await _storage.read(key: _sessionTokenKey);
    if (sessionToken == null) {
      throw Exception("No session token found");
    }

    final documentoUrl = Uri.parse('$url/Document/$docId');
    final headers = {
      'Session-Token': sessionToken,
      'Content-Type': 'application/json',
    };

    final client = _newClient();
    try {
      final response = await _getWithRetry(
        documentoUrl,
        headers,
        client,
        context: context,
      );

      if (response.statusCode == 200) {
        final mimeType =
            response.headers['content-type'] ?? 'application/octet-stream';
        final ext = extensionFromMime(mimeType) ?? 'bin';
        final data = jsonDecode(response.body);
        data['mimeType'] = mimeType;
        data['extension'] = ext;
        return data;
      } else {
        throw Exception(
            "Error al obtener documento del ticket: ${response.body}");
      }
    } on SocketException {
      _showNoInternet(context);
      throw Exception("Conexión interrumpida durante la solicitud");
    } on TimeoutException {
      _showTimeout(context);
      rethrow;
    } catch (e) {
      _maybeShowNetworkError(e, context);
      throw Exception("Error al obtener documento del ticket: $e");
    } finally {
      client.close();
    }
  }

  /// Obtiene el contenido bruto de un documento asociado a un seguimiento de ticket.
  ///
  /// Lanza una excepción si ocurre un error durante la solicitud.
  Future<String> getRawDoc(int docId,
      {String? appToken, BuildContext? context}) async {
    _log('getRawDoc(docId=$docId)');
    _rememberContext(context);
    await _ensureConnectivity(context);
    final sessionToken = await _storage.read(key: _sessionTokenKey);
    if (sessionToken == null) {
      throw Exception("No session token found");
    }

    final documentoUrl = Uri.parse('$url/Document/$docId')
        .replace(queryParameters: {'alt': 'media'});
    final headers = {
      'Session-Token': sessionToken,
      'Accept': 'application/octet-stream',
    };
    if (appToken != null) {
      headers['App-Token'] = appToken;
    }

    final client = _newClient();
    try {
      final response = await _getWithRetry(
        documentoUrl,
        headers,
        client,
        context: context,
      );

      if (response.statusCode == 200) {
        final mimeType =
            response.headers['content-type'] ?? 'application/octet-stream';
        final ext = extensionFromMime(mimeType) ?? 'bin';
        final directory = await getTemporaryDirectory();
        final filePath = '${directory.path}/document_${docId}.$ext';
        final file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);
        return filePath;
      } else {
        throw Exception(
            "Error al obtener documento del ticket: ${response.body}");
      }
    } on SocketException {
      _showNoInternet(context);
      throw Exception("Conexión interrumpida durante la solicitud");
    } on TimeoutException {
      _showTimeout(context);
      rethrow;
    } catch (e) {
      _maybeShowNetworkError(e, context);
      throw Exception("Error al obtener documento del ticket: $e");
    } finally {
      client.close();
    }
  }

  /// Obtiene el detalle de un comentario de seguimiento de un ticket.
  ///
  /// Lanza una excepción si ocurre un error durante la solicitud.
  Future<List<dynamic>> getFollowupDetail(int ticketCommentId,
      {BuildContext? context}) async {
    _log('getFollowupDetail(ticketCommentId=$ticketCommentId)');
    _rememberContext(context);
    await _ensureConnectivity(context);
    final sessionToken = await _storage.read(key: _sessionTokenKey);
    if (sessionToken == null) {
      throw Exception("No session token found");
    }

    final comentarioUrl =
        Uri.parse('$url/ITILFollowup/$ticketCommentId/Document_Item');
    final headers = {
      'Session-Token': sessionToken,
      'Content-Type': 'application/json',
    };

    final client = _newClient();
    try {
      final response = await _getWithRetry(
        comentarioUrl,
        headers,
        client,
        context: context,
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception(
            "Error al obtener detalle del comentario: ${response.body}");
      }
    } on SocketException {
      _showNoInternet(context);
      throw Exception("Conexión interrumpida durante la solicitud");
    } on TimeoutException {
      _showTimeout(context);
      rethrow;
    } catch (e) {
      _maybeShowNetworkError(e, context);
      throw Exception("Error al obtener detalle del comentario: $e");
    } finally {
      client.close();
    }
  }

  /// Crea un nuevo ticket con los datos proporcionados.
  ///
  /// Lanza una excepción si ocurre un error durante la solicitud.
  Future<Map<String, dynamic>> createTicket(Map<String, dynamic> ticketData,
      {BuildContext? context}) async {
    _log('createTicket()');
    _rememberContext(context);
    await _ensureConnectivity(context);
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
        "type": ticketData['type'],
        "requesttypes_id": ticketData['requesttypes_id'],
        "entities_id": ticketData['entities_id'],
      }
    });

    final client = _newClient();
    try {
      final response =
          await client.post(ticketUrl, headers: headers, body: body).timeout(
        kRequestTimeout,
        onTimeout: () {
          _log('createTicket timeout');
          _showTimeout(context);
          throw TimeoutException("Solicitud cancelada por timeout");
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final resp = jsonDecode(response.body);
        return {
          'success': true,
          'ticketId': resp['id'],
        };
      } else {
        throw Exception("Error al crear ticket: ${response.body}");
      }
    } on SocketException {
      _showNoInternet(context);
      throw Exception("Conexión interrumpida durante la solicitud");
    } on TimeoutException {
      _showTimeout(context);
      rethrow;
    } catch (e) {
      _maybeShowNetworkError(e, context);
      throw Exception("Error al crear ticket: $e");
    } finally {
      client.close();
    }
  }

  /// Sube archivos asociados a un seguimiento de ticket.
  ///
  /// Lanza una excepción si ocurre un error durante la solicitud.
  Future<void> uploadFiles(List<PlatformFile> selectedFiles, int followupId,
      {BuildContext? context}) async {
    _log('uploadFiles(followupId=$followupId, count=${selectedFiles.length})');
    _rememberContext(context);
    await _ensureConnectivity(context);
    final sessionToken = await _storage.read(key: _sessionTokenKey);
    if (sessionToken == null) {
      throw Exception("No session token found");
    }

    final uploadUrl = Uri.parse('$url/Document');
    final headers = {'Session-Token': sessionToken};

    final client = _newClient();
    try {
      for (var file in selectedFiles) {
        final bytes = await File(file.path!).readAsBytes();

        final request = http.MultipartRequest('POST', uploadUrl)
          ..headers.addAll(headers)
          ..fields['uploadManifest'] = jsonEncode({
            'input': {
              'name': 'Uploaded document',
              '_filename': [file.name],
              'itemtype': 'ITILFollowup',
              'items_id': followupId,
            }
          })
          ..files.add(http.MultipartFile.fromBytes(
            'file',
            bytes,
            filename: file.name,
            contentType:
                MediaType('application', file.extension ?? 'octet-stream'),
          ));

        final streamedResponse = await client.send(request).timeout(
          kRequestTimeout,
          onTimeout: () {
            _log('uploadFiles timeout');
            _showTimeout(context);
            throw TimeoutException("Upload cancelado por timeout");
          },
        );
        final response = await http.Response.fromStream(streamedResponse);

        if (response.statusCode != 201) {
          throw Exception("Error al subir el archivo: ${response.body}");
        }
      }
    } on SocketException {
      _showNoInternet(context);
      throw Exception("Conexión interrumpida durante la solicitud");
    } on TimeoutException {
      _showTimeout(context);
      rethrow;
    } catch (e) {
      _maybeShowNetworkError(e, context);
      throw Exception("Error al subir el archivo: $e");
    } finally {
      client.close();
    }
  }

  /// Añade un seguimiento a un ticket existente.
  ///
  /// Lanza una excepción si ocurre un error durante la solicitud.
  Future<int> addFollowupToTicket(int ticketId, String descripcion,
      {BuildContext? context}) async {
    _log('addFollowupToTicket(ticketId=$ticketId)');
    _rememberContext(context);
    await _ensureConnectivity(context);
    final sessionToken = await _storage.read(key: _sessionTokenKey);
    if (sessionToken == null) {
      throw Exception("No session token found");
    }

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
        "is_private": false
      }
    });

    final client = _newClient();
    try {
      final response =
          await client.post(followupUrl, headers: headers, body: body).timeout(
        kRequestTimeout,
        onTimeout: () {
          _log('addFollowupToTicket timeout');
          _showTimeout(context);
          throw TimeoutException("Solicitud cancelada por timeout");
        },
      );

      if (response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        followupId = responseData['id'];
      }
      return followupId;
    } on SocketException {
      _showNoInternet(context);
      throw Exception("Conexión interrumpida durante la solicitud");
    } on TimeoutException {
      _showTimeout(context);
      rethrow;
    } catch (e) {
      _maybeShowNetworkError(e, context);
      throw Exception("Error al añadir el comentario/histórico: $e");
    } finally {
      client.close();
    }
  }

  /// Obtiene el comentario de la solución de un ticket.
  ///
  /// Lanza una excepción si ocurre un error durante la solicitud.
  Future<List<dynamic>> getTicketSolution(int idTicket, String sessionToken,
      {BuildContext? context}) async {
    _log('getTicketSolution(idTicket=$idTicket)');
    _rememberContext(context);
    await _ensureConnectivity(context);
    final solucionUrl = Uri.parse('$url/Ticket/$idTicket/ITILSolution');
    final headers = {
      'Session-Token': sessionToken,
      'Content-Type': 'application/json',
    };

    final client = _newClient();
    try {
      final response = await _getWithRetry(
        solucionUrl,
        headers,
        client,
        context: context,
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else if (response.statusCode == 404) {
        return [];
      } else {
        throw Exception(
            "Error al obtener la solución del ticket: ${response.body}");
      }
    } on SocketException {
      _showNoInternet(context);
      throw Exception("Conexión interrumpida durante la solicitud");
    } on TimeoutException {
      _showTimeout(context);
      rethrow;
    } catch (e) {
      _maybeShowNetworkError(e, context);
      throw Exception("Error al obtener la solución del ticket: $e");
    } finally {
      client.close();
    }
  }
}
