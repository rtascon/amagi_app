import 'dart:async';
import 'dart:convert';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';

import '../services/ticket_service.dart';

class TicketNotifications {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const String _androidChannelId = 'gia_tickets';
  static const String _androidChannelName = 'Actualizaciones de tickets';
  static const String _androidChannelDesc =
      'Avisos de cambios de estado de tickets';

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

  static Future<void> _showStatusChange(
      {required int ticketId,
      String? oldStatus,
      required String newStatus}) async {
    final title = 'Ticket #$ticketId actualizado';
    final body = (oldStatus == null || oldStatus.isEmpty)
        ? 'Nuevo estado: $newStatus'
        : 'Estado: $oldStatus → $newStatus';
    await _plugin.show(
      1000 + ticketId, // id único por ticket
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

    // Último recurso: consultar a la API para obtener el userId y persistirlo
    try {
      final service = TicketService();
      final fetched = await service.fetchCurrentUserId();
      if (fetched != null) return fetched;
    } catch (_) {}

    return null;
  }

  // Consulta los tickets y notifica cambios vs. la caché local
  static Future<void> checkAndNotify({bool manual = false}) async {
    final prefs = await SharedPreferences.getInstance();

    // Resolver userId de forma robusta
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

    // Validar existencia de session_token en secure storage indirectamente (SharedPreferences copia)
    final sessionTokenShadow = prefs.getString('sessionToken');
    if (sessionTokenShadow == null || sessionTokenShadow.isEmpty) {
      if (manual) {
        await _plugin.show(
          900002,
          'Verificación de tickets',
          'Session token ausente. Reingrese a la aplicación.',
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
      // Continuamos igual; el TicketService leerá el seguro y fallará si realmente no está.
    }

    final rawCache = prefs.getString('ticket_status_cache');
    final Map<String, String> cached =
        rawCache != null ? Map<String, String>.from(jsonDecode(rawCache)) : {};

    final service = TicketService();
    List<dynamic> data = [];
    try {
      data = await service.getUserTicketFilterDefault(userId, context: null);
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

    for (final item in data) {
      final String? idStr = (() {
        if (item is Map) {
          return item['2']?.toString() ??
              item['id']?.toString() ??
              item['ID']?.toString();
        }
        return null;
      })();
      final String? statusStr = (() {
        if (item is Map) {
          return item['12']?.toString() ??
              item['status']?.toString() ??
              item['Estado']?.toString();
        }
        return null;
      })();

      if (idStr == null || statusStr == null) continue;

      latest[idStr] = statusStr;

      final prev = cached[idStr];
      final int? ticketId = int.tryParse(idStr);
      if (ticketId != null && prev != null && prev != statusStr) {
        anyChange = true;
        changeCount++;
        await _showStatusChange(
            ticketId: ticketId, oldStatus: prev, newStatus: statusStr);
      }
    }

    await prefs.setString('ticket_status_cache', jsonEncode(latest));

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
