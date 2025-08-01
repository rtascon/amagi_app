import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../controllers/tickets_controller.dart';
import '../controllers/side_menu_controller.dart';
import '../views/side_menu.dart';
import '../models/ticket.dart';
import '../models/type_conversion.dart';
import '../views/main_menu_screen.dart';
import '../theme/app_theme.dart';

/// Esta vista muestra una lista de tickets resueltos del usuario

class TicketsResolvedScreen extends StatefulWidget {
  final List<dynamic> tickets;
  final Map<String, dynamic>? initialFilters;

  const TicketsResolvedScreen(
      {super.key, required this.tickets, this.initialFilters});

  @override
  TicketsResolvedScreenState createState() => TicketsResolvedScreenState();
}

class TicketsResolvedScreenState extends State<TicketsResolvedScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TicketsController _ticketsController = TicketsController();
  final SideMenuController _sideMenuController = SideMenuController();
  late final Future<Map<String, String>> _userNameFuture;
  List<dynamic> _filteredTickets = [];
  final TypeConversion _typeConversion = TypeConversion();

  @override
  void initState() {
    super.initState();
    _filteredTickets = widget.tickets.where((ticket) {
      return _typeConversion.getEstado(ticket.estado) == 'Resuelto';
    }).toList();
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
    setState(() {});

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
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.menu, color: AppColors.white),
            onPressed: () {
              _scaffoldKey.currentState?.openDrawer();
            },
          ),
          title: const Text(
            'Servicio GIA',
            style: TextStyle(
              color: AppColors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: AppColors.darkBlue,
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
              color: AppColors.white,
              child: RefreshIndicator(
                color: AppColors.darkBlue,
                backgroundColor: AppColors.white,
                onRefresh: _refreshTickets,
                child: _filteredTickets.isEmpty
                    ? SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: SizedBox(
                          height: MediaQuery.of(context).size.height -
                              kToolbarHeight,
                          child: const Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.inbox,
                                  size: 80,
                                  color: AppColors.blueGrey,
                                ),
                                SizedBox(height: 16),
                                Text(
                                  'Ups... parece que no hay nada que mostrar',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: AppColors.blueGrey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16.0),
                        itemCount: _filteredTickets.length,
                        itemBuilder: (context, index) {
                          final ticket = _filteredTickets[index];
                          final fechaCreacion = ticket.fechaCreacion is String
                              ? DateTime.parse(ticket.fechaCreacion)
                              : ticket.fechaCreacion;
                          final formattedDate = DateFormat('dd-MM-yyyy HH:mm')
                              .format(fechaCreacion);
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
                                      color:
                                          AppColors.blueGrey.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(15.0),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              children: [
                                                Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 8.0,
                                                      vertical: 4.0),
                                                  decoration: BoxDecoration(
                                                    color: AppColors.blueGrey
                                                        .withOpacity(0.2),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8.0),
                                                  ),
                                                  child: Row(
                                                    children: [
                                                      if (_typeConversion
                                                              .getEstado(ticket
                                                                  .estado) ==
                                                          'Nuevo')
                                                        Container(
                                                          width: 10,
                                                          height: 10,
                                                          decoration:
                                                              const BoxDecoration(
                                                            color:
                                                                AppColors.green,
                                                            shape:
                                                                BoxShape.circle,
                                                          ),
                                                          margin:
                                                              const EdgeInsets
                                                                  .only(
                                                                  right: 8.0),
                                                        ),
                                                      if (_typeConversion
                                                              .getEstado(ticket
                                                                  .estado) ==
                                                          'En curso (asignado)')
                                                        Container(
                                                          width: 10,
                                                          height: 10,
                                                          decoration:
                                                              BoxDecoration(
                                                            border: Border.all(
                                                                color: AppColors
                                                                    .green),
                                                            shape:
                                                                BoxShape.circle,
                                                          ),
                                                          margin:
                                                              const EdgeInsets
                                                                  .only(
                                                                  right: 8.0),
                                                        ),
                                                      if (_typeConversion
                                                              .getEstado(ticket
                                                                  .estado) ==
                                                          'En curso (Planificado)')
                                                        Container(
                                                          margin:
                                                              const EdgeInsets
                                                                  .only(
                                                                  right: 8.0),
                                                          child: const Icon(
                                                            Icons
                                                                .calendar_today,
                                                            color:
                                                                AppColors.black,
                                                            size: 16,
                                                          ),
                                                        ),
                                                      if (_typeConversion
                                                              .getEstado(ticket
                                                                  .estado) ==
                                                          'En espera')
                                                        Container(
                                                          width: 10,
                                                          height: 10,
                                                          decoration:
                                                              const BoxDecoration(
                                                            color: AppColors
                                                                .orange,
                                                            shape:
                                                                BoxShape.circle,
                                                          ),
                                                          margin:
                                                              const EdgeInsets
                                                                  .only(
                                                                  right: 8.0),
                                                        ),
                                                      if (_typeConversion
                                                              .getEstado(ticket
                                                                  .estado) ==
                                                          'Resuelto')
                                                        Container(
                                                          margin:
                                                              const EdgeInsets
                                                                  .only(
                                                                  right: 8.0),
                                                          child: const Icon(
                                                            Icons
                                                                .check_circle_outline,
                                                            color:
                                                                AppColors.green,
                                                            size: 16,
                                                          ),
                                                        ),
                                                      if (_typeConversion
                                                              .getEstado(ticket
                                                                  .estado) ==
                                                          'Cerrado')
                                                        Container(
                                                          width: 10,
                                                          height: 10,
                                                          decoration:
                                                              const BoxDecoration(
                                                            color:
                                                                AppColors.black,
                                                            shape:
                                                                BoxShape.circle,
                                                          ),
                                                          margin:
                                                              const EdgeInsets
                                                                  .only(
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
                                                                    ticket
                                                                        .estado)
                                                                .split(' (')[0],
                                                            style:
                                                                const TextStyle(
                                                              fontSize: 16,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
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
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 10.0,
                                                      vertical: 4.0),
                                                  decoration: BoxDecoration(
                                                    color: _typeConversion
                                                                .getTipo(ticket
                                                                    .tipo) ==
                                                            'Requerimiento'
                                                        ? AppColors.blue
                                                            .withOpacity(0.1)
                                                        : AppColors.orangeLight
                                                            .withOpacity(0.3),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8.0),
                                                  ),
                                                  child: Row(
                                                    children: [
                                                      SizedBox(
                                                        width: 15,
                                                        height: 20,
                                                        child: Center(
                                                          child: Icon(
                                                            _typeConversion.getTipo(
                                                                        ticket
                                                                            .tipo) ==
                                                                    'Requerimiento'
                                                                ? Icons.help
                                                                : Icons.error,
                                                            color: _typeConversion
                                                                        .getTipo(ticket
                                                                            .tipo) ==
                                                                    'Requerimiento'
                                                                ? AppColors.blue
                                                                : AppColors
                                                                    .orange,
                                                            size: 20,
                                                          ),
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                          width: 8.0),
                                                      Text(
                                                        _typeConversion.getTipo(
                                                            ticket.tipo),
                                                        style: TextStyle(
                                                          color: _typeConversion
                                                                      .getTipo(
                                                                          ticket
                                                                              .tipo) ==
                                                                  'Requerimiento'
                                                              ? AppColors.blue
                                                              : AppColors
                                                                  .orange,
                                                          fontSize: 10,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                const SizedBox(width: 8.0),
                                                Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 10.0,
                                                      vertical: 4.0),
                                                  decoration: BoxDecoration(
                                                    color: AppColors.blueGrey
                                                        .withOpacity(0.2),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8.0),
                                                  ),
                                                  child: Row(
                                                    children: [
                                                      const Text(
                                                        '#',
                                                        style: TextStyle(
                                                          color:
                                                              AppColors.black,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                          width: 4.0),
                                                      Text(
                                                        ticket.id.toString(),
                                                        style: const TextStyle(
                                                          color:
                                                              AppColors.black,
                                                          fontSize: 10,
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
                                              child: Text(
                                                ticket.titulo,
                                                style: const TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 14.0),
                                          ],
                                        ),
                                        const SizedBox(height: 4.0),
                                        Text(
                                          formattedDate,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: AppColors.blueGrey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (_typeConversion
                                          .getEstado(ticket.estado) ==
                                      'Resuelto')
                                    Positioned(
                                      right: -10,
                                      bottom: 0,
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppColors.darkBlue,
                                          foregroundColor: AppColors.white,
                                          minimumSize: const Size(50, 30),
                                        ),
                                        onPressed: () {
                                          _ticketsController
                                              .navigateToSolucionScreen(
                                                  context, ticket);
                                        },
                                        child: const Text('Cerrar Ticket'),
                                      ),
                                    ),
                                  Positioned(
                                    bottom: 35,
                                    right: 1,
                                    child: Center(
                                      child: Container(
                                        width: 40,
                                        height: 40,
                                        decoration: const BoxDecoration(
                                          color: Colors.transparent,
                                          shape: BoxShape.rectangle,
                                        ),
                                        child: IconButton(
                                          icon: const Icon(
                                            Icons.info_outline,
                                            color: AppColors.blueGrey,
                                            size: 25,
                                          ),
                                          onPressed: () {
                                            showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                final String fechaCreacion =
                                                    DateFormat(
                                                            'dd-MM-yyyy HH:mm')
                                                        .format(ticket
                                                            .fechaCreacion);
                                                final String fechaModificacion =
                                                    DateFormat(
                                                            'dd-MM-yyyy HH:mm')
                                                        .format(ticket
                                                            .fechaActualizacion);
                                                final String prioridad =
                                                    _typeConversion
                                                        .getPrioridad(
                                                            ticket.prioridad);
                                                return AlertDialog(
                                                  title: const Text(
                                                    'Más detalles',
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                  content:
                                                      SingleChildScrollView(
                                                    child: ListBody(
                                                      children: <Widget>[
                                                        ListTile(
                                                          leading: const Icon(
                                                              Icons.date_range),
                                                          title: const Text(
                                                              'Fecha de Creación'),
                                                          subtitle: Text(
                                                              fechaCreacion),
                                                        ),
                                                        ListTile(
                                                          leading: const Icon(
                                                              Icons.update),
                                                          title: const Text(
                                                              'Fecha de Modificación'),
                                                          subtitle: Text(
                                                              fechaModificacion),
                                                        ),
                                                        ListTile(
                                                          leading: const Icon(
                                                              Icons
                                                                  .priority_high),
                                                          title: const Text(
                                                              'Prioridad'),
                                                          subtitle:
                                                              Text(prioridad),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  actions: <Widget>[
                                                    TextButton(
                                                      child: Text(
                                                        'Cerrar',
                                                        style: TextStyle(
                                                            color:
                                                                defaultTextButtonColor),
                                                      ),
                                                      onPressed: () {
                                                        Navigator.of(context)
                                                            .pop();
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
      ),
    );
  }

  Future<bool> _onWillPop() async {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const MainMenuScreen()),
      (route) => false,
    );
    return false;
  }

  Future<void> _refreshTickets() async {
    setState(() {});

    List<Ticket> updatedTicketsResolved = await _ticketsController
        .getTicketsList(context, false, filters: {'status': 5});

    setState(() {
      _filteredTickets = updatedTicketsResolved;
      _sortTicketsByDate();
    });
  }
}
