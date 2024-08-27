import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Importar para formatear fechas
import '../controllers/ticket_detail_controller.dart';
import '../controllers/tickets_controller.dart'; // Importar TicketsController

class TicketDetailScreen extends StatelessWidget {
  final dynamic ticket;
  final TicketDetailController _ticketDetailController = TicketDetailController();
  final TicketsController _ticketsController = TicketsController(); // Instancia de TicketsController

  TicketDetailScreen({required this.ticket});

  @override
  Widget build(BuildContext context) {
    // Formatear fechas
    final String fechaCreacion = DateFormat('yyyy-MM-dd HH:mm').format(ticket.fechaCreacion);
    final String fechaModificacion = DateFormat('yyyy-MM-dd HH:mm').format(ticket.fechaActualizacion);
    
    // Obtener color del icono de prioridad
    Color getPriorityColor(String prioridad) {
      switch (prioridad) {
        case 'Baja':
          return Colors.green;
        case 'Media':
          return Colors.yellow;
        case 'Alta':
          return Colors.red;
        default:
          return Colors.grey;
      }
    }

    // Obtener la prioridad del ticket
    final String prioridad = _ticketsController.getPrioridad(ticket.prioridad);

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
        child: Column(
          children: [
            Container(
              color: Colors.grey[200],
              width: double.infinity,
              padding: EdgeInsets.all(16.0),
              child: Row(
                children: [
                  if (ticket.estado == 'Nuevo')
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                      margin: EdgeInsets.only(right: 8.0),
                    ),
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: ticket.tipo == 'Requerimiento' ? Colors.blue : Colors.orange,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        ticket.tipo == 'Requerimiento' ? '?' : '!',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16, // Aumenta el tamaño de la fuente
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    margin: EdgeInsets.only(right: 8.0),
                  ),
                  Icon(
                    Icons.signal_cellular_alt,
                    color: getPriorityColor(prioridad),
                  ),
                  Spacer(),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Row(
                      children: [
                        Text(
                          '#',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(width: 4.0),
                        Text(
                          '${ticket.id}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 8.0),
                    Text(
                      'Detalles',
                      style: TextStyle(
                        fontSize: 20, // Tamaño mediano
                        fontWeight: FontWeight.bold, // En negrita
                      ),
                    ),
                    SizedBox(height: 8.0),
                    Text(
                      'Fecha de Creación: $fechaCreacion',
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      'Fecha de Modificación: $fechaModificacion',
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 8.0),
                    Text(
                      'Descripción: ${ticket.descripcion}',
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                    // Agrega más detalles del ticket aquí
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}