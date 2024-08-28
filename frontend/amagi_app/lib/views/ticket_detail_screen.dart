import 'package:flutter/material.dart';
import '../controllers/ticket_detail_controller.dart';
import '../controllers/tickets_controller.dart'; // Importar TicketsController

class TicketDetailScreen extends StatelessWidget {
  final dynamic ticket;
  final TicketDetailController _ticketDetailController = TicketDetailController();
  final TicketsController _ticketsController = TicketsController(); // Instancia de TicketsController

  TicketDetailScreen({required this.ticket});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            _ticketDetailController.navigateBack(context);
          },
        ),
        title: Text(
          '${ticket.titulo}',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Color(0xFF747678),
        elevation: 0,
        centerTitle: true,
      ),
      body: Container(
        color: Colors.white,
      ),
    );
  }
}