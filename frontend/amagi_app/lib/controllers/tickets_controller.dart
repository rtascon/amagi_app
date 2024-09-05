import 'package:flutter/material.dart';
import '../services/ticket_service.dart';
import '../models/user.dart'; 
import '../views/tickets_screen.dart';
import '../models/ticket_factory.dart'; 
import '../models/ticket.dart'; 
import '../views/ticket_detail_screen.dart';
import '../services/user_service.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:html/parser.dart' show parse;
import '../views/loading_screen.dart'; // Importar la pantalla de carga

class TicketsController {
  final TicketService _ticketService = TicketService();
  final UserService _userService = UserService();
  final Map<String, String> tickets = {};
  final usuario = User();
  final HtmlUnescape unescape = HtmlUnescape();

  int getUserId() {
    return usuario.idUsuario;
  }

  Future<List<Ticket>> obtenerListaTickets(BuildContext context) async {
    try {
      // Obtener el ID del usuario
      final userId = getUserId();

      // Obtener los tickets del usuario
      List<dynamic> ticketsData = await _ticketService.obtenerTicketsUsuario(userId);

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
      // Manejar error
      return [];
    }
  }

  void navigateToTicketsScreen(BuildContext context) async {
    try {
      
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return LoadingScreen();
        },
      );

      List<Ticket> tickets = await obtenerListaTickets(context);

      
      Navigator.of(context).pop();

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TicketsScreen(tickets: tickets),
        ),
      );
    } catch (e) {
      
      print("Error al obtener la lista de tickets: $e");
      
      Navigator.of(context).pop();
    }
  }

  Future<void> navigateToTicketDetailScreen(BuildContext context, Ticket ticket) async {
    try {
      // Mostrar la pantalla de carga
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return LoadingScreen();
        },
      );

      List<dynamic> historicos = await _ticketService.obtenerHistoricosTicket(ticket.id);
      ticket.historicos = await Future.wait(historicos.map((historico) async {
        final nombreUsuario = await _userService.obtenerNombreUsuario(historico['users_id']);
        final detalleComentario = await _ticketService.obtenerDetalleComentario(historico['id']);
        
        List<Map<String, dynamic>> documentos = await Future.wait(detalleComentario.map((detalle) async {
          final documento = await _ticketService.obtenerDocumentoHistorico(detalle['documents_id']);
          final String filePath = await _ticketService.obtenerDocumentoCrudo(detalle['documents_id']);
          return {
            'filename': documento['filename'],
            'filepath': filePath,
            'mime': documento['mime'],
            
          };
        }).toList());
        
        return {
          'id': historico['id'],
          'users_id': historico['users_id'],
          'date': historico['date'],
          'content': _stripHtmlTags(unescape.convert(historico['content'])),
          'nombre_usuario': nombreUsuario,
          'documentos': documentos.isNotEmpty ? documentos : null,
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
      // Manejar error
      print("Error al obtener históricos del ticket: $e");
      // Ocultar la pantalla de carga en caso de error
      Navigator.of(context).pop();
    }
  }

  String getPrioridad(int prioridad) {
    switch (prioridad) {
      case 2:
        return 'Baja';
      case 3:
        return 'Media';
      case 4:
        return 'Alta';
      case 5:
        return 'Muy Alta';
      case 6:
        return 'Mayor';
      default:
        return 'Desconocida';
    }
  }

  String getTipo(int tipo) {
    switch (tipo) {
      case 1:
        return 'Incidente';
      case 2:
        return 'Requerimiento';
      default:
        return 'Desconocido';
    }
  }

  String getEstado(int estado) {
    switch (estado) {
      case 1:
        return 'Nuevo';
      case 2:
        return 'En curso (asignado)';
      case 3:
        return 'En curso (Planificado)';
      case 4:
        return 'En espera';
      case 5:
        return 'Resuelto';
      case 6:
        return 'Cerrado';
      default:
        return 'Desconocido';
    }
  }

  String _stripHtmlTags(String htmlString) {
    final document = parse(htmlString);
    return document.body?.text ?? '';
  }
}