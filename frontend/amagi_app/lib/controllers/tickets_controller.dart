import 'package:flutter/material.dart';
import 'package:startup_namer/views/solucion_screen.dart';
import '../services/ticket_service.dart';
import '../models/user.dart';
import '../views/tickets_screen.dart';
import '../models/ticket_factory.dart';
import '../models/ticket.dart';
import '../views/ticket_detail_screen.dart';
import '../services/user_service.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:html/parser.dart' show parse;
import '../views/loading_screen.dart';
import '../views/main_menu_screen.dart';
//import '../views/satisfaction_popup.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../views/common_pop_ups.dart';
import 'dart:async';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../config/environment.dart'; // Importar el archivo de configuración

/// Controlador para manejar las acciones relacionadas con los tickets.
class TicketsController {
  final TicketService _ticketService = TicketService();
  final UserService _userService = UserService();
  final Map<String, String> tickets = {};
  final usuario = User();
  final HtmlUnescape unescape = HtmlUnescape();
  static const _storage = FlutterSecureStorage();
  static const _sessionTokenKey = 'session_token';
  final String url = Environment.apiUrl; // Obtener la URL desde el archivo de configuración

  /// Obtiene el ID del usuario actual.
  int getUserId() {
    return usuario.idUsuario;
  }

  /// Cierra un ticket específico.
  ///
  /// Parámetros:
  /// - [context]: El contexto de la aplicación.
  /// - [ticket]: El ticket a cerrar.
  ///
  /// Verifica la conectividad antes de intentar cerrar el ticket. Si no hay conexión, muestra un mensaje de error.
  /// Si hay conexión, intenta cerrar el ticket y maneja las respuestas y errores adecuadamente.
  Future<void> closeTicket(BuildContext context, Ticket ticket) async {
    final connectivityResult = await (Connectivity().checkConnectivity());

    if (!context.mounted) return;

    if (connectivityResult == ConnectivityResult.none) {
      if (!context.mounted) return;
      showNoInternetMessage(context);
      return;
    }
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const LoadingScreen();
        },
      );
      Map<String, dynamic> updateData = {
        'status': '6',
      };
      await _ticketService.updateTicket(ticket.id, updateData);

      if (!context.mounted) return;
      Navigator.of(context).pop();

      

      // Este fragmento de código se comentó porque no se implementó la funcionalidad de calificar el ticket
      /*
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return SatisfactionPopup(
            onSubmit: (rating, comentarios) async {
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Calificación enviada exitosamente')),
              );
              navigateToTicketsScreen(context);
            },
            onCancel: () {
              navigateToTicketsScreen(context);
            },
          );
        },
      );
      */

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Solución aprobada exitosamente')),
      );
      navigateRechazarAprobarToTicketsScreen(context);
    } catch (e) {
      Navigator.of(context).pop();
      if (e is TimeoutException) {
        showTimeoutMessage(context);
      } else {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al aprobar la solución')),
        );
      }
    }
  }

  /// Obtiene la lista de tickets del usuario.
  ///
  /// Parámetros:
  /// - [context]: El contexto de la aplicación.
  /// - [primeraVez]: Indica si es la primera vez que se obtiene la lista de tickets.
  /// - [filters]: Filtros opcionales para la búsqueda de tickets.
  ///
  /// Retorna una lista de tickets.
  Future<List<Ticket>> getTicketsList(BuildContext context, bool primeraVez,
      {Map<String, dynamic>? filters}) async {
    try {
      final connectivityResult = await (Connectivity().checkConnectivity());

      if (connectivityResult == ConnectivityResult.none) {
        showNoInternetMessage(context);
        return [];
      }

      final userId = getUserId();

      List<dynamic> ticketsData = [];
      if (primeraVez) {
        ticketsData = await _ticketService.getUserTicketFilterDefault(userId);
      } else {
        ticketsData =
            await _ticketService.getUserTicketFiltered(userId, filters ?? {});
      }

      // Crear instancias de Ticket usando TicketFactory
      List<Ticket> tickets = ticketsData.map((ticketData) {
        return TicketFactory.createTicket(
          id: ticketData['2'],
          titulo: ticketData['1'],
          descripcion: _stripHtmlTags(unescape.convert(ticketData['21'])),
          fechaCreacion: DateTime.parse(ticketData['15']),
          fechaActualizacion: DateTime.parse(ticketData['19']),
          tipo: ticketData['14'],
          estado: ticketData['12'],
          entidadAsociada: ticketData['80'],
          prioridad: ticketData['3'],
        );
      }).toList();

      return tickets;
    } catch (e) {
      return [];
    }
  }

  /// Obtiene la lista de soluciones de un ticket.
  /// 
  /// Parámetros:
  /// - [ticketId]: El ID del ticket.
  /// 
  /// Retorna una lista de soluciones.
  Future<List<Map<String, dynamic>>> getTicketSolutions(int ticketId) async {
    final sessionToken = await _storage.read(key: _sessionTokenKey);
    if (sessionToken == null) {
      throw Exception("No session token found");
    }

    final soluciones = await _ticketService.getTicketSolution(ticketId, sessionToken);

    return Future.wait(soluciones.map((solucion) async {
      final nombreUsuario = await _userService.getUserName(solucion['users_id']);
      return {
        'id': solucion['id'],
        'users_id': solucion['users_id'],
        'date_creation': solucion['date_creation'] ?? solucion['date'] ?? '',
        'content': _stripHtmlTags(unescape.convert(solucion['content'])),
        'nombre_usuario': nombreUsuario,
      };
    }).toList());
  }

  /// Actualiza la lista de tickets haciendo otra consulta.
  /// 
  /// Parámetros:
  /// - [context]: El contexto de la aplicación.
  /// 
  /// Retorna una lista de tickets actualizada.
  Future<List<Ticket>> updateTickets(BuildContext context) async {
    try {
      final connectivityResult = await (Connectivity().checkConnectivity());

      if (connectivityResult == ConnectivityResult.none) {
        showNoInternetMessage(context);
        return [];
      }

      final userId = getUserId();
      List<dynamic> ticketsData = await _ticketService.getUserTicketFilterDefault(userId);

      // Crear instancias de Ticket usando TicketFactory
      List<Ticket> tickets = ticketsData.map((ticketData) {
        return TicketFactory.createTicket(
          id: ticketData['2'],
          titulo: ticketData['1'],
          descripcion: _stripHtmlTags(unescape.convert(ticketData['21'])),
          fechaCreacion: DateTime.parse(ticketData['15']),
          fechaActualizacion: DateTime.parse(ticketData['19']),
          tipo: ticketData['14'],
          estado: ticketData['12'],
          entidadAsociada: ticketData['80'],
          prioridad: ticketData['3'],
        );
      }).toList();

      return tickets;
    } catch (e) {
      return [];
    }
  }

  /// Navega a la pantalla de tickets.
  ///
  /// Parámetros:
  /// - [context]: El contexto de la aplicación.
  /// - [filters]: Filtros opcionales para la búsqueda de tickets.
  void navigateToTicketsScreen(BuildContext context,
      {Map<String, dynamic>? filters}) async {
    final connectivityResult = await (Connectivity().checkConnectivity());

    if (connectivityResult == ConnectivityResult.none) {
      showNoInternetMessage(context);
      return;
    }
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const LoadingScreen();
        },
      );

      List<Ticket> tickets = [];
      if (filters != null) {
        tickets = await getTicketsList(context, false, filters: filters);
      } else {
        tickets = await getTicketsList(context, true);
      }

      Navigator.of(context).pop();

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TicketsScreen(tickets: tickets),
        ),
      );
    } catch (e) {
      Navigator.of(context).pop();
      if (e is TimeoutException) {
        showTimeoutMessage(context);
      } else {
        Navigator.of(context).pop();
      }
    }
  }

  /// Navega a la pantalla de detalles del ticket.
  ///
  /// Parámetros:
  /// - [context]: El contexto de la aplicación.
  /// - [ticket]: El ticket cuyos detalles se mostrarán.
  Future<void> navigateToTicketDetailScreen(
      BuildContext context, Ticket ticket) async {
    final connectivityResult = await (Connectivity().checkConnectivity());

    if (connectivityResult == ConnectivityResult.none) {
      showNoInternetMessage(context);
      return;
    }
    try {
      // Mostrar la pantalla de carga
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const LoadingScreen();
        },
      );

      // Obtiene los históricos del ticket.
      List<dynamic> historicos =
          await _ticketService.getTicketFollowup(ticket.id);

      // Procesa cada histórico y obtiene detalles adicionales.
      ticket.historicos = await Future.wait(historicos.map((historico) async {
        // Obtiene el nombre del usuario que hizo el seguimiento.
        final nombreUsuario =
            await _userService.getUserName(historico['users_id']);

        // Obtiene los detalles del comentario del seguimiento.
        final detalleComentario =
            await _ticketService.getFollowupDetail(historico['id']);

        // Procesa cada detalle del comentario para obtener los documentos asociados.
        List<Map<String, dynamic>> documentos =
            await Future.wait(detalleComentario.map((detalle) async {
          // Obtiene la información del documento.
          final documento =
              await _ticketService.getDocFollowup(detalle['documents_id']);

          // Obtiene la ruta del archivo del documento.
          final String filePath =
              await _ticketService.getRawDoc(detalle['documents_id']);

          // Retorna un mapa con los detalles del documento.
          return {
            'filename': documento['filename'] ?? '',
            'filepath': filePath,
            'mime': documento['mime'] ?? '',
          };
        }).toList());

        // Retorna un mapa con los detalles del histórico procesado.
        return {
          'id': historico['id'] ?? '',
          'users_id': historico['users_id'] ?? '',
          'date': historico['date'] ?? '',
          'content': _stripHtmlTags(unescape.convert(historico['content'] ?? '')),
          'nombre_usuario': nombreUsuario,
          'documentos': documentos.isNotEmpty ? documentos : null,
        };
      }).toList());

      // Obtiene las soluciones del ticket.
      final sessionToken = await _storage.read(key: _sessionTokenKey);
      if (sessionToken == null) {
        throw Exception("No session token found");
      }
      List<dynamic> soluciones = await _ticketService.getTicketSolution(ticket.id, sessionToken);

      // Procesa cada solución y obtiene detalles adicionales.
      ticket.soluciones = await Future.wait(soluciones.map((solucion) async {
        // Obtiene el nombre del usuario que hizo la solución.
        final nombreUsuario =
            await _userService.getUserName(solucion['users_id']);

        // Retorna un mapa con los detalles de la solución procesada.
        return {
          'id': solucion['id'] ?? '',
          'users_id': solucion['users_id'] ?? '',
          'date_creation': solucion['date_creation'] ?? solucion['date'] ?? '',
          'content': _stripHtmlTags(unescape.convert(solucion['content'] ?? '')),
          'nombre_usuario': nombreUsuario,
        };
      }).toList());

      // Ocultar la pantalla de carga
      Navigator.of(context).pop();

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TicketDetailScreen(ticket: ticket),
        ),
      );

    } catch (e) {
      Navigator.of(context).pop();
      if (e is TimeoutException) {
        showTimeoutMessage(context);
      } else {
        Navigator.of(context).pop();
      }
    }
  }

  /// Navega a la pantalla de detalles del ticket una vez enviado el histórico.
  ///
  /// Parámetros:
  /// - [context]: El contexto de la aplicación.
  /// - [ticket]: El ticket cuyos detalles se mostrarán.

  Future<void> navigateEnviadoToTicketDetailScreen(
      BuildContext context, Ticket ticket) async {
    final connectivityResult = await (Connectivity().checkConnectivity());

    if (connectivityResult == ConnectivityResult.none) {
      showNoInternetMessage(context);
      return;
    }
    try {
      // Mostrar la pantalla de carga
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const LoadingScreen();
        },
      );

      // Obtiene los históricos del ticket.
      List<dynamic> historicos =
          await _ticketService.getTicketFollowup(ticket.id);

      // Procesa cada histórico y obtiene detalles adicionales.
      ticket.historicos = await Future.wait(historicos.map((historico) async {
        // Obtiene el nombre del usuario que hizo el seguimiento.
        final nombreUsuario =
            await _userService.getUserName(historico['users_id']);

        // Obtiene los detalles del comentario del seguimiento.
        final detalleComentario =
            await _ticketService.getFollowupDetail(historico['id']);

        // Procesa cada detalle del comentario para obtener los documentos asociados.
        List<Map<String, dynamic>> documentos =
            await Future.wait(detalleComentario.map((detalle) async {
          // Obtiene la información del documento.
          final documento =
              await _ticketService.getDocFollowup(detalle['documents_id']);

          // Obtiene la ruta del archivo del documento.
          final String filePath =
              await _ticketService.getRawDoc(detalle['documents_id']);

          // Retorna un mapa con los detalles del documento.
          return {
            'filename': documento['filename'] ?? '',
            'filepath': filePath,
            'mime': documento['mime'] ?? '',
          };
        }).toList());

        // Retorna un mapa con los detalles del histórico procesado.
        return {
          'id': historico['id'] ?? '',
          'users_id': historico['users_id'] ?? '',
          'date': historico['date'] ?? '',
          'content': _stripHtmlTags(unescape.convert(historico['content'] ?? '')),
          'nombre_usuario': nombreUsuario,
          'documentos': documentos.isNotEmpty ? documentos : null,
        };
      }).toList());

      // Obtiene las soluciones del ticket.
      final sessionToken = await _storage.read(key: _sessionTokenKey);
      if (sessionToken == null) {
        throw Exception("No session token found");
      }
      List<dynamic> soluciones = await _ticketService.getTicketSolution(ticket.id, sessionToken);

      // Procesa cada solución y obtiene detalles adicionales.
      ticket.soluciones = await Future.wait(soluciones.map((solucion) async {
        // Obtiene el nombre del usuario que hizo la solución.
        final nombreUsuario =
            await _userService.getUserName(solucion['users_id']);

        // Retorna un mapa con los detalles de la solución procesada.
        return {
          'id': solucion['id'] ?? '',
          'users_id': solucion['users_id'] ?? '',
          'date_creation': solucion['date_creation'] ?? solucion['date'] ?? '',
          'content': _stripHtmlTags(unescape.convert(solucion['content'] ?? '')),
          'nombre_usuario': nombreUsuario,
        };
      }).toList());

      // Ocultar la pantalla de carga
      Navigator.of(context).pop();

      // Eliminar la pantalla anterior (TicketDetailScreen)
      Navigator.of(context).pop();

      // Navegar a la nueva pantalla (historicalscreen) y luego a TicketDetailScreen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => TicketDetailScreen(ticket: ticket),
        ),
      );

    } catch (e) {
      Navigator.of(context).pop();
      if (e is TimeoutException) {
        showTimeoutMessage(context);
      } else {
        Navigator.of(context).pop();
      }
    }
  }

  /// Navega al menú principal.
  ///
  /// Parámetros:
  /// - [context]: El contexto de la aplicación.
  void navigateBackToMainMenu(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const MainMenuScreen()),
    );

  }

  /// Elimina las etiquetas HTML de una cadena.
  ///
  /// Parámetros:
  /// - [htmlString]: La cadena que contiene etiquetas HTML.
  ///
  /// Retorna la cadena sin etiquetas HTML.
  String _stripHtmlTags(String htmlString) {
    final document = parse(htmlString);
    return document.body?.text ?? '';
  }

  /// Navega a la pantalla de solución del ticket.
  /// 
  /// Parámetros:
  /// - [context]: El contexto de la aplicación.
  /// - [ticket]: El ticket cuya solución se mostrará.
  Future<void> navigateToSolucionScreen(BuildContext context, Ticket ticket) async {
    final connectivityResult = await (Connectivity().checkConnectivity());

    if (connectivityResult == ConnectivityResult.none) {
      showNoInternetMessage(context);
      return;
    }
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const LoadingScreen();
        },
      );

      List<Map<String, dynamic>> soluciones = await getTicketSolutions(ticket.id);

      // Obtener la solución más reciente
      Map<String, dynamic> solucionReciente = soluciones.reduce((a, b) {
        DateTime fechaA = DateTime.parse(a['date_creation']);
        DateTime fechaB = DateTime.parse(b['date_creation']);
        return fechaA.isAfter(fechaB) ? a : b;
      });

      Navigator.of(context).pop();

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SolucionScreen(ticket: ticket, solucion: solucionReciente),
        ),
      );
    } catch (e) {
      Navigator.of(context).pop();
      if (e is TimeoutException) {
        showTimeoutMessage(context);
      } else {
        Navigator.of(context).pop();
      }
    }
  }

  /// Reabre un ticket específico.
  /// 
  /// Parámetros:
  /// - [context]: El contexto de la aplicación.
  /// - [ticket]: El ticket a reabrir.
  Future<void> reopenTicket(BuildContext context, Ticket ticket) async {
    final connectivityResult = await (Connectivity().checkConnectivity());

    if (connectivityResult == ConnectivityResult.none) {
      showNoInternetMessage(context);
      return;
    }
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const LoadingScreen();
        },
      );

      Map<String, dynamic> updateData = {
        'status': '4', // Estado para reabrir el ticket
      };
      await _ticketService.updateTicket(ticket.id, updateData);

      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ticket reabierto exitosamente')),
      );
      navigateRechazarAprobarToTicketsScreen(context);
    } catch (e) {
      Navigator.of(context).pop();
      if (e is TimeoutException) {
        showTimeoutMessage(context);
      } else {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al reabrir el ticket')),
        );
      }
    }
  }


  /// Navega a la pantalla de consulta de ticket una vez rechazada o aprobada la solución.
  ///
  /// Parámetros:
  /// - [context]: El contexto de la aplicación.
  /// - [ticket]: El ticket cuyos detalles se mostrarán.

  void navigateRechazarAprobarToTicketsScreen(BuildContext context,
      {Map<String, dynamic>? filters}) async {
    final connectivityResult = await (Connectivity().checkConnectivity());

    if (connectivityResult == ConnectivityResult.none) {
      showNoInternetMessage(context);
      return;
    }
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const LoadingScreen();
        },
      );

      List<Ticket> tickets = [];
      if (filters != null) {
        tickets = await getTicketsList(context, false, filters: filters);
      } else {
        tickets = await getTicketsList(context, true);
      }

      Navigator.of(context).pop();

      // Eliminar la pantalla anterior
      Navigator.of(context).pop();

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => TicketsScreen(tickets: tickets),
        ),
      );
    } catch (e) {
      Navigator.of(context).pop();
      if (e is TimeoutException) {
        showTimeoutMessage(context);
      } else {
        Navigator.of(context).pop();
      }
    }
  }


}