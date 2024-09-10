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
import '../views/loading_screen.dart';
import '../views/main_menu_screen.dart'; 

class TicketsController {
  final TicketService _ticketService = TicketService();
  final UserService _userService = UserService();
  final Map<String, String> tickets = {};
  final usuario = User();
  final HtmlUnescape unescape = HtmlUnescape();

  int getUserId() {
    return usuario.idUsuario;
  }

  Future<List<Ticket>> obtenerListaTickets(BuildContext context, bool primeraVez,{Map<String, dynamic>? filters}) async {
    try {
      // Obtener el ID del usuario
      final userId = getUserId();
      List<dynamic> ticketsData = [];
      if(primeraVez){
      // Obtener los tickets del usuario
        ticketsData = await _ticketService.obtenerTicketsUsuarioFiltroPorDefecto(userId);
      }
      else{
        ticketsData = await _ticketService.obtenerTicketsUsuarioFiltrado(userId,filters ?? {});
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

      List<Ticket> tickets = await obtenerListaTickets(context, true);

      
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

  void navigateBackToMainMenu(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => MainMenuScreen()),
      (Route<dynamic> route) => false,
    );
  }


  String _stripHtmlTags(String htmlString) {
    final document = parse(htmlString);
    return document.body?.text ?? '';
  }
}