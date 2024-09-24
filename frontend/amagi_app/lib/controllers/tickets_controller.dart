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
//import '../views/satisfaction_popup.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../views/common_pop_ups.dart'; 
import 'dart:async';

class TicketsController {
  final TicketService _ticketService = TicketService();
  final UserService _userService = UserService();
  final Map<String, String> tickets = {};
  final usuario = User();
  final HtmlUnescape unescape = HtmlUnescape();

  int getUserId() {
    return usuario.idUsuario;
  }

  Future<void> closeTicket(BuildContext context, Ticket ticket) async {
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
          return LoadingScreen();
        },
      );
      Map<String, dynamic> updateData = {
        'status': '6',
      };
      await _ticketService.updateTicket(ticket.id, updateData);

      Navigator.of(context).pop();
/*
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return SatisfactionPopup(
            onSubmit: (rating, comentarios) async {
              await _ticketService.sendRatings(ticket.id, rating, comentarios);
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
        SnackBar(content: Text('Ticket cerrado exitosamente')),
      );
      navigateToTicketsScreen(context);

    } catch (e) {
      Navigator.of(context).pop(); 
      if (e is TimeoutException) {
        showTimeoutMessage(context); 
      } else {
        print("Error al cerrar el ticket: $e");
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cerrar el ticket')),
        );
      }
    }
  }

  Future<List<Ticket>> getTicketsList(BuildContext context, bool primeraVez,{Map<String, dynamic>? filters}) async {
    try {
     
      final userId = getUserId();
      List<dynamic> ticketsData = [];
      if(primeraVez){
        ticketsData = await _ticketService.getUserTicketFilterDefault(userId);
      }
      else{
        ticketsData = await _ticketService.getUserTicketFiltered(userId,filters ?? {});
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

  void navigateToTicketsScreen(BuildContext context,{Map<String, dynamic>? filters}) async {
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
          return LoadingScreen();
        },
      );
      List<Ticket> tickets = [];
      if (filters != null) {
        tickets = await getTicketsList(context, false,filters: filters);
      }
      else{
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
      print("Error al obtener la lista de tickets: $e");
      Navigator.of(context).pop();
      }
    }
  }

  Future<void> navigateToTicketDetailScreen(BuildContext context, Ticket ticket) async {
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
          return LoadingScreen();
        },
      );

      List<dynamic> historicos = await _ticketService.getTicketFollowup(ticket.id);
      ticket.historicos = await Future.wait(historicos.map((historico) async {
        final nombreUsuario = await _userService.getUserName(historico['users_id']);
        final detalleComentario = await _ticketService.getFollowupDetail(historico['id']);
        
        List<Map<String, dynamic>> documentos = await Future.wait(detalleComentario.map((detalle) async {
          final documento = await _ticketService.getDocFollowup(detalle['documents_id']);
          final String filePath = await _ticketService.getRawDoc(detalle['documents_id']);
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
      Navigator.of(context).pop(); 
      if (e is TimeoutException) {
        showTimeoutMessage(context); 
      } else {
      print("Error al obtener históricos del ticket: $e"); 
      Navigator.of(context).pop();
      }
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