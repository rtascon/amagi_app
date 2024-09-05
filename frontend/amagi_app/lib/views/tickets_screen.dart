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
    // Ordenar los tickets por fecha en orden ascendente
    tickets.sort((a, b) {
      DateTime fechaA = a.fechaCreacion is String ? DateTime.parse(a.fechaCreacion) : a.fechaCreacion;
      DateTime fechaB = b.fechaCreacion is String ? DateTime.parse(b.fechaCreacion) : b.fechaCreacion;
      return fechaB.compareTo(fechaA);
    });
  }

  @override
  Widget build(BuildContext context) {
    Color defaultTextButtonColor = TextButton.styleFrom().foregroundColor?.resolve({}) ?? Theme.of(context).primaryColor;
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
        backgroundColor: Color(0xFF005586),
        elevation: 0,
        centerTitle: true,
      ),
      drawer: SideMenu(
        sideMenuController: _sideMenuController,
        ticketsController: _ticketsController,
        userNameFuture: _userNameFuture,
      ),
      body: Stack(
        children: [
          Container(
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
                      child: Stack(
                        children: [
                          Column(
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
                                            if (_ticketsController.getEstado(ticket.estado) == 'En curso (asignado)')
                                              Container(
                                                width: 10,
                                                height: 10,
                                                decoration: BoxDecoration(
                                                  border: Border.all(color: Colors.green),
                                                  shape: BoxShape.circle,
                                                ),
                                                margin: EdgeInsets.only(right: 8.0),
                                              ),
                                            if (_ticketsController.getEstado(ticket.estado) == 'En curso (Planificado)')
                                              Container(
                                                margin: EdgeInsets.only(right: 8.0),
                                                child: Icon(
                                                  Icons.calendar_today,
                                                  color: Colors.black,
                                                  size: 16,
                                                ),
                                              ),
                                            if (_ticketsController.getEstado(ticket.estado) == 'En espera')
                                              Container(
                                                width: 10,
                                                height: 10,
                                                decoration: BoxDecoration(
                                                  color: Colors.orange,
                                                  shape: BoxShape.circle,
                                                ),
                                                margin: EdgeInsets.only(right: 8.0),
                                              ),
                                            if (_ticketsController.getEstado(ticket.estado) == 'Resuelto')
                                              Container(
                                                width: 10,
                                                height: 10,
                                                decoration: BoxDecoration(
                                                  border: Border.all(color: Colors.black),
                                                  shape: BoxShape.circle,
                                                ),
                                                margin: EdgeInsets.only(right: 8.0),
                                              ),
                                            if (_ticketsController.getEstado(ticket.estado) == 'Cerrado')
                                              Container(
                                                width: 10,
                                                height: 10,
                                                decoration: BoxDecoration(
                                                  color: Colors.black,
                                                  shape: BoxShape.circle,
                                                ),
                                                margin: EdgeInsets.only(right: 8.0),
                                              ),
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  _ticketsController.getEstado(ticket.estado).split(' (')[0],
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                if (_ticketsController.getEstado(ticket.estado).contains(' ('))
                                                  Text(
                                                    '(${_ticketsController.getEstado(ticket.estado).split(' (')[1]}',
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      fontWeight: FontWeight.normal,
                                                    ),
                                                  ),
                                              ],
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
                                              width: 20,
                                              height: 20,
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
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            SizedBox(width: 8.0),
                                            Text(
                                              _ticketsController.getTipo(ticket.tipo),
                                              style: TextStyle(
                                                color: _ticketsController.getTipo(ticket.tipo) == 'Requerimiento'
                                                    ? Colors.blue
                                                    : Colors.orange,
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
                                                color: Colors.black,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            SizedBox(width: 4.0),
                                            Text(
                                              ticket.id.toString(),
                                              style: TextStyle(
                                                color: Colors.black,
                                                fontWeight: FontWeight.bold,
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
                          Positioned(
                            bottom: 8,
                            right: 8,
                            child: IconButton(
                              icon: Icon(Icons.info_outline),
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    final String fechaCreacion = DateFormat('yyyy-MM-dd HH:mm').format(ticket.fechaCreacion);
                                    final String fechaModificacion = DateFormat('yyyy-MM-dd HH:mm').format(ticket.fechaActualizacion);
                                    final String prioridad = _ticketsController.getPrioridad(ticket.prioridad);
                                    return AlertDialog(
                                      title: Text(
                                        'Más detalles',
                                        style: TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                      content: SingleChildScrollView(
                                        child: ListBody(
                                          children: <Widget>[
                                            ListTile(
                                              leading: Icon(Icons.date_range),
                                              title: Text('Fecha de Creación'),
                                              subtitle: Text(fechaCreacion),
                                            ),
                                            ListTile(
                                              leading: Icon(Icons.update),
                                              title: Text('Fecha de Modificación'),
                                              subtitle: Text(fechaModificacion),
                                            ),
                                            ListTile(
                                              leading: Icon(Icons.priority_high),
                                              title: Text('Prioridad'),
                                              subtitle: Text(prioridad),
                                            ),
                                          ],
                                        ),
                                      ),
                                      actions: <Widget>[
                                        TextButton(
                                          child: Text('Cerrar', style: TextStyle(color: defaultTextButtonColor)),
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
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
        ],
      ),
    );
  }
}