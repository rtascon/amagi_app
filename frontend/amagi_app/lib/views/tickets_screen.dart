import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../controllers/tickets_controller.dart';
import '../controllers/side_menu_controller.dart';
import '../views/side_menu.dart';

class TicketsScreen extends StatelessWidget {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final List<dynamic> tickets;
  final TicketsController _ticketsController = TicketsController();
  final SideMenuController _sideMenuController = SideMenuController();
  late final Future<Map<String, String>> _userNameFuture;

  TicketsScreen({required this.tickets}) {
    _userNameFuture = _sideMenuController.getUserName();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.menu, color: Colors.white),
          onPressed: () {
            _scaffoldKey.currentState?.openDrawer();
          },
        ),
        title: Text(
          'Servicio GIA',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Color(0xFF747678),
        elevation: 0,
        centerTitle: true,
      ),
      drawer: SideMenu(
        sideMenuController: _sideMenuController,
        ticketsController: _ticketsController,
        userNameFuture: _userNameFuture,
      ),
      body: Container(
        color: Colors.white,
        child: ListView.builder(
          padding: EdgeInsets.all(16.0),
          itemCount: tickets.length,
          itemBuilder: (context, index) {
            final ticket = tickets[index];
            final fechaCreacion = ticket.fechaCreacion is String
                ? DateTime.parse(ticket.fechaCreacion)
                : ticket.fechaCreacion;
            final formattedDate = DateFormat('yyyy-MM-dd HH:mm').format(fechaCreacion);
            return Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: GestureDetector(
                onTap: () {
                  _ticketsController.navigateToTicketDetailScreen(context, ticket);
                },
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                                decoration: BoxDecoration(
                                  color: Colors.grey[300],
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                child: Row(
                                  children: [
                                    if (_ticketsController.getEstado(ticket.estado) == 'Nuevo')
                                      Container(
                                        width: 10,
                                        height: 10,
                                        decoration: BoxDecoration(
                                          color: Colors.green,
                                          shape: BoxShape.circle,
                                        ),
                                        margin: EdgeInsets.only(right: 8.0),
                                      ),
                                    Text(
                                      _ticketsController.getEstado(ticket.estado),
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                                decoration: BoxDecoration(
                                  color: _ticketsController.getTipo(ticket.tipo) == 'Requerimiento'
                                      ? Colors.blue[100]
                                      : Colors.orange[100],
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 20, // Aumenta el tamaño del contenedor
                                      height: 20, // Aumenta el tamaño del contenedor
                                      decoration: BoxDecoration(
                                        color: _ticketsController.getTipo(ticket.tipo) == 'Requerimiento'
                                            ? Colors.blue
                                            : Colors.orange,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Center(
                                        child: Text(
                                          _ticketsController.getTipo(ticket.tipo) == 'Requerimiento'
                                              ? '?'
                                              : '!',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16, // Aumenta el tamaño de la fuente
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      margin: EdgeInsets.only(right: 8.0),
                                    ),
                                    Text(
                                      _ticketsController.getTipo(ticket.tipo),
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(width: 8.0),
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
                        ],
                      ),
                      SizedBox(height: 8.0),
                      Text(
                        ticket.titulo,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4.0),
                      Text(
                        formattedDate,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}