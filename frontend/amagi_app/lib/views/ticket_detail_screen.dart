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
        child: ListView.builder(
          itemCount: ticket.historicos.length,
          itemBuilder: (context, index) {
            final historico = ticket.historicos[index];
            final fecha = historico['date'];
            //final usuario = historico['usuario'];
            return Align(
              alignment: Alignment.centerLeft,
              child: Container(
                margin: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.lightBlue[50], // Azul más claro
                  border: Border.all(color: Colors.black), // Borde negro
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(15),
                    topRight: Radius.circular(15),
                    bottomRight: Radius.circular(15),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Text(
                                "Creado: ",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Icon(Icons.access_time, size: 16, color: Colors.black),
                              SizedBox(width: 5),
                              Text(fecha),
                            ],
                          ),
                          Row(
                            children: [
                              Text(
                                "Por: ",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Icon(Icons.person, size: 16, color: Colors.black),
                              SizedBox(width: 5),
                              Text(''), // Cambiar por el nombre del usuario
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: historico.entries.where((entry) {
                        return entry.key != 'id' && entry.key != 'users_id' && entry.key != 'date';
                      }).map<Widget>((entry) {
                        return Text('${entry.value}');
                      }).toList(),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}