import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../controllers/tickets_controller.dart';
import '../controllers/side_menu_controller.dart';
import '../views/side_menu.dart';
import '../views/filter_ticket_menu.dart';
import '../models/ticket.dart';
import '../models/type_conversion.dart';

/// Esta vista muestra una lista de tickets del usuario, permitiendo filtrar y ordenar
/// los tickets según diferentes criterios. También proporciona acceso a los detalles de cada ticket.

class TicketsScreen extends StatefulWidget {
  final List<dynamic> tickets;
  final Map<String, dynamic>? initialFilters;

  const TicketsScreen({super.key, required this.tickets, this.initialFilters});

  @override
  TicketsScreenState createState() => TicketsScreenState();
}

class TicketsScreenState extends State<TicketsScreen> {
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
      DateTime fechaA = a.fechaActualizacion is String
          ? DateTime.parse(a.fechaActualizacion)
          : a.fechaActualizacion;
      DateTime fechaB = b.fechaActualizacion is String
          ? DateTime.parse(b.fechaActualizacion)
          : b.fechaActualizacion;
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
      filteredTickets = await _ticketsController.getTicketsList(context, false,
          filters: filters);
    }

    setState(() {
      _filteredTickets = filteredTickets;
      _sortTicketsByDate();
      _isLoading = false;
    });
  }

  String truncateTitle(String title) {
    if (title.length > 30) {
      return '${title.substring(0, 30)}...';
    }
    return title;
  }

  @override
  Widget build(BuildContext context) {
    Color defaultTextButtonColor =
        TextButton.styleFrom().foregroundColor?.resolve({}) ??
            Theme.of(context).primaryColor;
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: () {
            _scaffoldKey.currentState?.openDrawer();
          },
        ),
        title: const Text(
          'Servicio GIA',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list, color: Colors.white),
            onPressed: () {
              _scaffoldKey.currentState?.openEndDrawer();
            },
          ),
        ],
        backgroundColor: const Color(0xFF005586),
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
            child: RefreshIndicator(
              color: const Color(0xFF005586), // Cambiar el color del icono
              backgroundColor: Colors.white, // Cambiar el color del círculo a blanco
              onRefresh: _refreshTickets,
              child: _filteredTickets.isEmpty
                  ? const Center(
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
                      padding: const EdgeInsets.all(16.0),
                      itemCount: _filteredTickets
                          .length, // Usar _filteredTickets en lugar de tickets
                      itemBuilder: (context, index) {
                        final ticket = _filteredTickets[
                            index]; // Usar _filteredTickets en lugar de tickets
                        final fechaCreacion = ticket.fechaCreacion is String
                            ? DateTime.parse(ticket.fechaCreacion)
                            : ticket.fechaCreacion;
                        final formattedDate =
                            DateFormat('dd-MM-yyyy HH:mm').format(fechaCreacion);
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: GestureDetector(
                            onTap: () {
                              _ticketsController.navigateToTicketDetailScreen(
                                  context, ticket);
                            },
                            child: Stack(
                              children: [
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(16.0),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    borderRadius: BorderRadius.circular(15.0),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 8.0,
                                                        vertical: 4.0),
                                                decoration: BoxDecoration(
                                                  color: Colors.grey[300],
                                                  borderRadius:
                                                      BorderRadius.circular(8.0),
                                                ),
                                                child: Row(
                                                  children: [
                                                    if (_typeConversion.getEstado(
                                                            ticket.estado) ==
                                                        'Nuevo')
                                                      Container(
                                                        width: 10,
                                                        height: 10,
                                                        decoration:
                                                            const BoxDecoration(
                                                          color: Colors.green,
                                                          shape: BoxShape.circle,
                                                        ),
                                                        margin:
                                                            const EdgeInsets.only(
                                                                right: 8.0),
                                                      ),
                                                    if (_typeConversion.getEstado(
                                                            ticket.estado) ==
                                                        'En curso (asignado)')
                                                      Container(
                                                        width: 10,
                                                        height: 10,
                                                        decoration: BoxDecoration(
                                                          border: Border.all(
                                                              color:
                                                                  Colors.green),
                                                          shape: BoxShape.circle,
                                                        ),
                                                        margin:
                                                            const EdgeInsets.only(
                                                                right: 8.0),
                                                      ),
                                                    if (_typeConversion.getEstado(
                                                            ticket.estado) ==
                                                        'En curso (Planificado)')
                                                      Container(
                                                        margin:
                                                            const EdgeInsets.only(
                                                                right: 8.0),
                                                        child: const Icon(
                                                          Icons.calendar_today,
                                                          color: Colors.black,
                                                          size: 16,
                                                        ),
                                                      ),
                                                    if (_typeConversion.getEstado(
                                                            ticket.estado) ==
                                                        'En espera')
                                                      Container(
                                                        width: 10,
                                                        height: 10,
                                                        decoration:
                                                            const BoxDecoration(
                                                          color:
                                                              Color(0xFFE98300),
                                                          shape: BoxShape.circle,
                                                        ),
                                                        margin:
                                                            const EdgeInsets.only(
                                                                right: 8.0),
                                                      ),
                                                    if (_typeConversion.getEstado(
                                                            ticket.estado) ==
                                                        'Resuelto')
                                                      Container(
                                                        margin:
                                                            const EdgeInsets.only(
                                                                right: 8.0),
                                                        child: const Icon(
                                                          Icons
                                                              .check_circle_outline,
                                                          color: Colors.green,
                                                          size: 16,
                                                        ),
                                                      ),
                                                    if (_typeConversion.getEstado(
                                                            ticket.estado) ==
                                                        'Cerrado')
                                                      Container(
                                                        width: 10,
                                                        height: 10,
                                                        decoration:
                                                            const BoxDecoration(
                                                          color: Colors.black,
                                                          shape: BoxShape.circle,
                                                        ),
                                                        margin:
                                                            const EdgeInsets.only(
                                                                right: 8.0),
                                                      ),
                                                    Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          _typeConversion
                                                              .getEstado(
                                                                  ticket.estado)
                                                              .split(' (')[0],
                                                          style: const TextStyle(
                                                            fontSize: 16,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                        if (_typeConversion
                                                            .getEstado(
                                                                ticket.estado)
                                                            .contains(' ('))
                                                          Text(
                                                            '(${_typeConversion.getEstado(ticket.estado).split(' (')[1]}',
                                                            style:
                                                                const TextStyle(
                                                              fontSize: 14,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .normal,
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
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 10.0,
                                                        vertical: 4.0),
                                                decoration: BoxDecoration(
                                                  color: _typeConversion.getTipo(
                                                              ticket.tipo) ==
                                                          'Requerimiento'
                                                      ? Colors.blue[100]
                                                      : Colors.orange[100],
                                                  borderRadius:
                                                      BorderRadius.circular(8.0),
                                                ),
                                                child: Row(
                                                  children: [
                                                    Container(
                                                      width: 20,
                                                      height: 20,
                                                      child: Center(
                                                        child: Icon(
                                                          _typeConversion.getTipo(
                                                                      ticket
                                                                          .tipo) ==
                                                                  'Requerimiento'
                                                              ? Icons.help
                                                              : Icons.error,
                                                          color: _typeConversion.getTipo(ticket.tipo) == 'Requerimiento'
                                                              ? const Color(0xFF009FDA)
                                                              : const Color(0xFFE98300),
                                                          size: 20,
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(width: 8.0),
                                                    Text(
                                                      _typeConversion
                                                          .getTipo(ticket.tipo),
                                                      style: TextStyle(
                                                        color: _typeConversion
                                                                    .getTipo(ticket
                                                                        .tipo) ==
                                                                'Requerimiento'
                                                            ? const Color(
                                                                0xFF009FDA)
                                                            : const Color(
                                                                0xFFE98300), fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              const SizedBox(width: 8.0),
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 10.0,
                                                        vertical: 4.0),
                                                decoration: BoxDecoration(
                                                  color: Colors.grey[300],
                                                  borderRadius:
                                                      BorderRadius.circular(8.0),
                                                ),
                                                child: Row(
                                                  children: [
                                                    const Text(
                                                      '#',
                                                      style: TextStyle(
                                                        color: Colors.black,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 4.0),
                                                    Text(
                                                      ticket.id.toString(),
                                                      style: const TextStyle(
                                                        color: Colors.black, fontSize: 10,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8.0),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Container(
                                              child: Text(
                                                ticket.titulo,
                                                style: const TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4.0),
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
                                if (_typeConversion.getEstado(ticket.estado) ==
                                    'Resuelto')
                                  Positioned(
                                    right: -10,
                                    bottom: 0,
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFF005586),
                                        foregroundColor: Colors.white,
                                        minimumSize: const Size(50, 30),
                                      ),
                                      onPressed: () {
                                        _ticketsController.navigateToSolucionScreen(context, ticket);
                                      },
                                      child: const Text('Cerrar Ticket'),
                                    ),
                                  ),
                                Positioned(
                                  //top: 40,
                                  bottom: 32,
                                  //left: 0,
                                  right: 1,
                                  child: Center(
                                    child: IconButton(
                                      icon: Icon(
                                        Icons.info_outline,
                                        color: Colors.grey[500],
                                        size: 25,
                                      ),
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            final String fechaCreacion = DateFormat('dd-MM-yyyy HH:mm').format(ticket.fechaCreacion);
                                            final String fechaModificacion = DateFormat('dd-MM-yyyy HH:mm').format(ticket.fechaActualizacion);
                                            final String prioridad = _typeConversion.getPrioridad(ticket.prioridad);
                                            return AlertDialog(
                                              title: const Text(
                                                'Más detalles',
                                                style: TextStyle(fontWeight: FontWeight.bold),
                                              ),
                                              content: SingleChildScrollView(
                                                child: ListBody(
                                                  children: <Widget>[
                                                    ListTile(
                                                      leading: const Icon(Icons.date_range),
                                                      title: const Text('Fecha de Creación'),
                                                      subtitle: Text(fechaCreacion),
                                                    ),
                                                    ListTile(
                                                      leading: const Icon(Icons.update),
                                                      title: const Text('Fecha de Modificación'),
                                                      subtitle: Text(fechaModificacion),
                                                    ),
                                                    ListTile(
                                                      leading: const Icon(Icons.priority_high),
                                                      title: const Text('Prioridad'),
                                                      subtitle: Text(prioridad),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              actions: <Widget>[
                                                TextButton(
                                                  child: Text(
                                                    'Cerrar',
                                                    style: TextStyle(color: defaultTextButtonColor),
                                                  ),
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
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _refreshTickets() async {
    setState(() {
      _isLoading = true;
    });

    List<Ticket> updatedTickets = await _ticketsController.updateTickets(context);

    setState(() {
      _filteredTickets = updatedTickets;
      _sortTicketsByDate();
      _isLoading = false;
    });
  }
}
