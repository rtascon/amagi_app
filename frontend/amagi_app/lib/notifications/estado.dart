import 'dart:async';
import 'dart:convert';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';

import '../repositories/ticket_repository.dart';
import '../models/type_conversion.dart';
import '../services/user_service.dart';
import '../models/ticket.dart';

class TicketNotifications {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const String _androidChannelId = 'gia_tickets';
  static const String _androidChannelName = 'Actualizaciones de tickets';
  static const String _androidChannelDesc =
      'Avisos de cambios de estado de tickets';

  static final TypeConversion _typeConv = TypeConversion(); // nueva instancia

  static Future<void> init() async {
    // Inicialización en la app (primer plano)
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    await _plugin.initialize(
      const InitializationSettings(android: androidInit, iOS: iosInit),
    );

    // Solicitar permiso en Android 13+
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    // Crear canal en Android
    final androidSpecific = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await androidSpecific
        ?.createNotificationChannel(const AndroidNotificationChannel(
      _androidChannelId,
      _androidChannelName,
      description: _androidChannelDesc,
      importance: Importance.defaultImportance,
    ));
  }

  // Inicialización mínima en background (sin prompts)
  static Future<void> backgroundInit() async {
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    await _plugin.initialize(
      const InitializationSettings(android: androidInit, iOS: iosInit),
    );

    final androidSpecific = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await androidSpecific
        ?.createNotificationChannel(const AndroidNotificationChannel(
      _androidChannelId,
      _androidChannelName,
      description: _androidChannelDesc,
      importance: Importance.defaultImportance,
    ));
  }

  static Future<void> showTestNotification() async {
    await _plugin.show(
      100000, // id fijo para test
      'Notificaciones activas',
      'Recibirás avisos cuando cambie el estado de tus tickets.',
      NotificationDetails(
        android: AndroidNotificationDetails(
          _androidChannelId,
          _androidChannelName,
          channelDescription: _androidChannelDesc,
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
        ),
        iOS: const DarwinNotificationDetails(),
      ),
    );
  }

  static Future<void> _showStatusChange({
    required int ticketId,
    required String newStatus,
  }) async {
    // Intentar convertir el código numérico de estado a su nombre
    String statusNombre = (() {
      final intCode = int.tryParse(newStatus.trim());
      if (intCode != null) {
        return _typeConv.getEstado(intCode);
      }
      return newStatus; // ya podría venir como texto
    })();

    final title = 'Ticket N°$ticketId recibió una actualización';
    final body = 'Su estado ha cambiado a $statusNombre';

    await _plugin.show(
      1000 + ticketId,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _androidChannelId,
          _androidChannelName,
          channelDescription: _androidChannelDesc,
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
        ),
        iOS: const DarwinNotificationDetails(),
      ),
    );
  }

  // Intenta resolver el userId desde distintas claves almacenadas en SharedPreferences
  static int? _parseInt(String? v) {
    if (v == null) return null;
    return int.tryParse(v.trim());
  }

  static Future<int?> _resolveUserId(SharedPreferences prefs) async {
    int? uid = prefs.getInt('userId');
    if (uid != null) return uid;

    // Claves alternativas que pudieron haberse guardado como String
    const candidates = [
      'userId',
      'id',
      'users_id',
      '_users_id_requester',
      'profile_user_id'
    ];
    for (final key in candidates) {
      final s = prefs.getString(key);
      final parsed = _parseInt(s);
      if (parsed != null) {
        await prefs.setInt('userId', parsed); // normalizar para el futuro
        return parsed;
      }
    }

    // Intentar extraer de un JSON guardado (por ejemplo user_profile)
    final profileJson = prefs.getString('user_profile');
    if (profileJson != null) {
      try {
        final data = jsonDecode(profileJson);
        if (data is Map) {
          for (final k in ['id', 'users_id', 'userId']) {
            final val = data[k];
            if (val != null) {
              final parsed = _parseInt(val.toString());
              if (parsed != null) {
                await prefs.setInt('userId', parsed);
                return parsed;
              }
            }
          }
        }
      } catch (_) {}
    }

    // Último recurso: usar UserService centralizado
    try {
      final fetched = await UserService().getCachedOrFetchUserId();
      if (fetched != null) return fetched;
    } catch (_) {}

    return null;
  }

  // Consulta los tickets y notifica cambios vs. la caché local
  static Future<void> checkAndNotify({bool manual = false}) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = await _resolveUserId(prefs);
    if (userId == null) {
      if (manual) {
        await _plugin.show(
          900000,
          'Verificación de tickets',
          'No hay usuario autenticado (userId no encontrado).',
          const NotificationDetails(
            android: AndroidNotificationDetails(
              _androidChannelId,
              _androidChannelName,
              channelDescription: _androidChannelDesc,
              importance: Importance.defaultImportance,
              priority: Priority.defaultPriority,
            ),
            iOS: DarwinNotificationDetails(),
          ),
        );
      }
      return;
    }

    final rawCache = prefs.getString('ticket_status_cache');
    final Map<String, String> cached =
        rawCache != null ? Map<String, String>.from(jsonDecode(rawCache)) : {};

    // usar repositorio (cache + servicio)
    final repo = TicketRepository.instance;
    List<Ticket> tickets = [];
    try {
      tickets = await repo.load(force: true);
    } catch (_) {
      if (manual) {
        await _plugin.show(
          900001,
          'Verificación de tickets',
          'Fallo de conexión al consultar.',
          const NotificationDetails(
            android: AndroidNotificationDetails(
              _androidChannelId,
              _androidChannelName,
              channelDescription: _androidChannelDesc,
              importance: Importance.defaultImportance,
              priority: Priority.defaultPriority,
            ),
            iOS: DarwinNotificationDetails(),
          ),
        );
      }
      return;
    }

    final Map<String, String> latest = {};
    bool anyChange = false;
    int changeCount = 0;
    final List<int> changedIds = [];

    for (final ticket in tickets) {
      final idStr = ticket.id.toString();
      final statusStr = ticket.estado.toString();
      latest[idStr] = statusStr;
      final prev = cached[idStr];
      if (prev != null && prev != statusStr) {
        anyChange = true;
        changeCount++;
        changedIds.add(ticket.id);
      }
    }

    await prefs.setString('ticket_status_cache', jsonEncode(latest));

    if (changeCount == 1 && changedIds.isNotEmpty) {
      final onlyId = changedIds.first;
      final newStatus = latest[onlyId.toString()]!;
      await _showStatusChange(ticketId: onlyId, newStatus: newStatus);
    } else if (changeCount > 1) {
      final title = 'Tickets actualizados ($changeCount)';
      final body =
          'Se detectaron cambios en ${changedIds.take(5).join(', ')}${changeCount > 5 ? '…' : ''}';
      await _plugin.show(
        910000,
        title,
        body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            _androidChannelId,
            _androidChannelName,
            channelDescription: _androidChannelDesc,
            importance: Importance.defaultImportance,
            priority: Priority.defaultPriority,
            styleInformation: const InboxStyleInformation([]),
          ),
          iOS: const DarwinNotificationDetails(),
        ),
      );
    }

    if (manual) {
      if (!anyChange) {
        await _plugin.show(
          900100,
          'Verificación de tickets',
          'No hay cambios de estado.',
          const NotificationDetails(
            android: AndroidNotificationDetails(
              _androidChannelId,
              _androidChannelName,
              channelDescription: _androidChannelDesc,
              importance: Importance.defaultImportance,
              priority: Priority.defaultPriority,
            ),
            iOS: DarwinNotificationDetails(),
          ),
        );
      } else {
        await _plugin.show(
          900101,
          'Verificación de tickets',
          'Cambios detectados en $changeCount ticket(s).',
          const NotificationDetails(
            android: AndroidNotificationDetails(
              _androidChannelId,
              _androidChannelName,
              channelDescription: _androidChannelDesc,
              importance: Importance.defaultImportance,
              priority: Priority.defaultPriority,
            ),
            iOS: DarwinNotificationDetails(),
          ),
        );
      }
    }
  }
}

// Callback top-level para Workmanager
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    WidgetsFlutterBinding.ensureInitialized();
    await TicketNotifications.backgroundInit();
    await TicketNotifications.checkAndNotify();
    return Future.value(true);
  });
}
