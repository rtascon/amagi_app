import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../controllers/tickets_controller.dart';
import '../controllers/side_menu_controller.dart';
import '../views/side_menu.dart';
import '../views/filter_ticket_menu.dart';
import '../models/ticket.dart'; 
import '../models/type_conversion.dart';

class TicketsScreen extends StatefulWidget {
  final List<dynamic> tickets;
  final Map<String, dynamic>? initialFilters;

  TicketsScreen({required this.tickets,this.initialFilters});

  @override
  _TicketsScreenState createState() => _TicketsScreenState();
}

class _TicketsScreenState extends State<TicketsScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TicketsController _ticketsController = TicketsController();
  final SideMenuController _sideMenuController = SideMenuController();
  late final Future<Map<String, String>> _userNameFuture;
  List<dynamic> _filteredTickets = [];
  bool _isLoading = false;
  final TypeConversion _typeConversion = TypeConversion();

  @override
  void initState() {
    super.initState();
    _filteredTickets = widget.tickets;
    _userNameFuture = _sideMenuController.getUserName();
    if (widget.initialFilters != null) {
      _applyFilters(widget.initialFilters!);
    } else {
      _sortTicketsByDate();
    }
  }

  void _sortTicketsByDate() {
    _filteredTickets.sort((a, b) {
      DateTime fechaA = a.fechaCreacion is String ? DateTime.parse(a.fechaCreacion) : a.fechaCreacion;
      DateTime fechaB = b.fechaCreacion is String ? DateTime.parse(b.fechaCreacion) : b.fechaCreacion;
      return fechaB.compareTo(fechaA);
    });
  }

  void _applyFilters(Map<String, dynamic> filters) async {
    setState(() {
      _isLoading = true;
    });
  
    List<Ticket> filteredTickets;
    if (filters.containsKey('tickets')) {
      filteredTickets = filters['tickets'];
    } else {
      filteredTickets = await _ticketsController.obtenerListaTickets(context, false, filters: filters);
    }
  
    setState(() {
      _filteredTickets = filteredTickets;
      _sortTicketsByDate();
      _isLoading = false;
    });
  }

  String truncateTitle(String title) {
    if (title.length > 30) {
      return title.substring(0, 30) + '...';
    }
    return title;
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
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list, color: Colors.white),
            onPressed: () {
              _scaffoldKey.currentState?.openEndDrawer();
            },
          ),
        ],
        backgroundColor: Color(0xFF005586),
        elevation: 0,
        centerTitle: true,
      ),
      drawer: SideMenu(
        sideMenuController: _sideMenuController,
        ticketsController: _ticketsController,
        userNameFuture: _userNameFuture,
      ),
      endDrawer: FilterTicketMenu(
        onFilterChanged: _applyFilters,
      ), // Pasar la función de filtro
      body: Stack(
        children: [
          Container(
            color: Colors.white,
            child: _filteredTickets.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.inbox,
                          size: 80,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Ups... parece que no hay nada que mostrar',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: EdgeInsets.all(16.0),
                    itemCount: _filteredTickets.length, // Usar _filteredTickets en lugar de tickets
                    itemBuilder: (context, index) {
                      final ticket = _filteredTickets[index]; // Usar _filteredTickets en lugar de tickets
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
                                                  if (_typeConversion.getEstado(ticket.estado) == 'Nuevo')
                                                    Container(
                                                      width: 10,
                                                      height: 10,
                                                      decoration: BoxDecoration(
                                                        color: Colors.green,
                                                        shape: BoxShape.circle,
                                                      ),
                                                      margin: EdgeInsets.only(right: 8.0),
                                                    ),
                                                  if (_typeConversion.getEstado(ticket.estado) == 'En curso (asignado)')
                                                    Container(
                                                      width: 10,
                                                      height: 10,
                                                      decoration: BoxDecoration(
                                                        border: Border.all(color: Colors.green),
                                                        shape: BoxShape.circle,
                                                      ),
                                                      margin: EdgeInsets.only(right: 8.0),
                                                    ),
                                                  if (_typeConversion.getEstado(ticket.estado) == 'En curso (Planificado)')
                                                    Container(
                                                      margin: EdgeInsets.only(right: 8.0),
                                                      child: Icon(
                                                        Icons.calendar_today,
                                                        color: Colors.black,
                                                        size: 16,
                                                      ),
                                                    ),
                                                  if (_typeConversion.getEstado(ticket.estado) == 'En espera')
                                                    Container(
                                                      width: 10,
                                                      height: 10,
                                                      decoration: BoxDecoration(
                                                        color: Color(0xFFE98300),
                                                        shape: BoxShape.circle,
                                                      ),
                                                      margin: EdgeInsets.only(right: 8.0),
                                                    ),
                                                  if (_typeConversion.getEstado(ticket.estado) == 'Resuelto')
                                                    Container(
                                                      margin: EdgeInsets.only(right: 8.0),
                                                      child: Icon(
                                                        Icons.check_circle_outline,
                                                        color: Colors.green,
                                                        size: 16,
                                                      ),
                                                    ),
                                                  if (_typeConversion.getEstado(ticket.estado) == 'Cerrado')
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
                                                        _typeConversion.getEstado(ticket.estado).split(' (')[0],
                                                        style: TextStyle(
                                                          fontSize: 16,
                                                          fontWeight: FontWeight.bold,
                                                        ),
                                                      ),
                                                      if (_typeConversion.getEstado(ticket.estado).contains(' ('))
                                                        Text(
                                                          '(${_typeConversion.getEstado(ticket.estado).split(' (')[1]}',
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
                                                color: _typeConversion.getTipo(ticket.tipo) == 'Requerimiento'
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
                                                      color: _typeConversion.getTipo(ticket.tipo) == 'Requerimiento'
                                                          ? Color(0xFF009FDA)
                                                          : Color(0xFFE98300),
                                                      shape: BoxShape.circle,
                                                    ),
                                                    child: Center(
                                                      child: Text(
                                                        _typeConversion.getTipo(ticket.tipo) == 'Requerimiento'
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
                                                    _typeConversion.getTipo(ticket.tipo),
                                                    style: TextStyle(
                                                      color: _typeConversion.getTipo(ticket.tipo) == 'Requerimiento'
                                                          ? Color(0xFF009FDA)
                                                          : Color(0xFFE98300),
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
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          truncateTitle(ticket.titulo),
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
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
                                if (_typeConversion.getEstado(ticket.estado) == 'Resuelto')
                                  Positioned(
                                    right: -10,
                                    bottom: -10,
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red,
                                        foregroundColor: Colors.white,
                                        minimumSize: Size(60, 20), 
                                      ),
                                      onPressed: () {
                                        _ticketsController.closeTicket(context, ticket);
                                      },
                                      child: Text('Cerrar Ticket'),
                                    ),
                                  ),
                                Positioned(
                                  bottom: 18,
                                  right: 8,
                                  child: IconButton(
                                    icon: Icon(Icons.info_outline),
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          final String fechaCreacion = DateFormat('yyyy-MM-dd HH:mm').format(ticket.fechaCreacion);
                                          final String fechaModificacion = DateFormat('yyyy-MM-dd HH:mm').format(ticket.fechaActualizacion);
                                          final String prioridad = _typeConversion.getPrioridad(ticket.prioridad);
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