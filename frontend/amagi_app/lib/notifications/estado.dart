import 'dart:async';
import 'dart:convert';
import 'dart:io';

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

  // Consulta los tickets y notifica cambios vs. la caché local
  static Future<void> checkAndNotify() async {
    final prefs = await SharedPreferences.getInstance();

    // Se espera que el userId esté persistido en SharedPreferences.
    final userId = prefs.getInt('userId');
    if (userId == null) {
      // No hay usuario -> no se puede consultar
      return;
    }

    // Caché previa de estados
    final rawCache = prefs.getString('ticket_status_cache');
    final Map<String, String> cached =
        rawCache != null ? Map<String, String>.from(jsonDecode(rawCache)) : {};

    final service = TicketService();
    List<dynamic> data = [];
    try {
      // Context nulo: ejecución en background sin UI
      data = await service.getUserTicketFilterDefault(userId, context: null);
    } catch (_) {
      // Fallo de red u otro: ignorar silenciosamente en background
      return;
    }

    final Map<String, String> latest = {};
    for (final item in data) {
      // Intentar obtener id y estado de diferentes formas
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

      // Notificar solo si cambia respecto a la caché previa (evitar spam)
      final prev = cached[idStr];
      final int? ticketId = int.tryParse(idStr);
      if (ticketId != null && prev != null && prev != statusStr) {
        await _showStatusChange(
            ticketId: ticketId, oldStatus: prev, newStatus: statusStr);
      }
    }

    // Guardar nuevo snapshot
    await prefs.setString('ticket_status_cache', jsonEncode(latest));
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
