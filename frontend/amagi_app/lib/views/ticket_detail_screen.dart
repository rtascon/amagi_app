import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:photo_view/photo_view.dart';
import 'package:intl/intl.dart'; 
import '../controllers/ticket_detail_controller.dart';
import '../controllers/tickets_controller.dart';
import '../models/user.dart'; 
import 'dart:io';
import 'create_historical_screen.dart';

class TicketDetailScreen extends StatelessWidget {
  final dynamic ticket;
  final TicketDetailController _ticketDetailController = TicketDetailController();
  final TicketsController _ticketsController = TicketsController();
  final User usuario = User(); 

  TicketDetailScreen({required this.ticket});

  @override
  Widget build(BuildContext context) {
    Color defaultTextButtonColor = TextButton.styleFrom().foregroundColor?.resolve({}) ?? Theme.of(context).primaryColor;
    // Agregar el histórico creado por el usuario logueado
    final historicoInicial = {
      'date': ticket.fechaCreacion.toString(),
      'nombre_usuario': usuario.nombreCompleto,
      'content': ticket.descripcion,
      'documentos': [],
      'isInitial': true, // Marcar este histórico como inicial
    };
    ticket.historicos.insert(0, historicoInicial);

    // Ordenar los históricos por fecha en orden ascendente
    ticket.historicos.sort((a, b) {
      DateTime fechaA = DateTime.parse(a['date']);
      DateTime fechaB = DateTime.parse(b['date']);
      return fechaB.compareTo(fechaA); 
    });

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            _ticketsController.navigateToTicketsScreen(context);
          },
        ),
        title: Text(
          'Ticket ${ticket.id}',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Color(0xFF005586),
        elevation: 0,
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Container(
            color: Colors.white,
            child: ListView.builder(
              itemCount: ticket.historicos.length,
              itemBuilder: (context, index) {
                final historico = ticket.historicos[index];
                final fecha = historico['date'];
                final usuarioNombre = historico['nombre_usuario'];
                final documentos = historico['documentos'] ?? [];
                final esUsuarioLogueado = usuarioNombre == usuario.nombreCompleto;
                final esHistoricoInicial = historico['isInitial'] == true;

                // Formatear la fecha para no mostrar milisegundos
                final formattedFecha = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.parse(fecha));

                return Align(
                  alignment: esUsuarioLogueado ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: esHistoricoInicial ? Colors.yellow[100] : (esUsuarioLogueado ? Colors.lightGreen[50] : Colors.lightBlue[50]), // Amarillo claro para el histórico inicial
                      border: Border.all(color: Colors.black), // Borde negro
                      borderRadius: esUsuarioLogueado
                          ? BorderRadius.only(
                              topLeft: Radius.circular(15),
                              topRight: Radius.circular(15),
                              bottomLeft: Radius.circular(15),
                            )
                          : BorderRadius.only(
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
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    "Creado: ",
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  Icon(Icons.access_time, size: 16, color: Colors.black),
                                  SizedBox(width: 5),
                                  Text(formattedFecha), // Usar la fecha formateada
                                ],
                              ),
                              SizedBox(height: 5),
                              Row(
                                children: [
                                  Text(
                                    "Por: ",
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  Icon(Icons.person, size: 16, color: Colors.black),
                                  SizedBox(width: 5),
                                  Flexible(
                                    child: Text(
                                      usuarioNombre,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        if (esHistoricoInicial) ...[
                          SizedBox(height: 10),
                          Text(
                            '${ticket.titulo}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Divider(
                            color: Colors.black,
                            thickness: 1,
                            indent: 10,
                            endIndent: 10,
                          ),
                        ],
                        SizedBox(height: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: historico.entries.where((entry) {
                            return entry.key != 'id' && entry.key != 'users_id' && entry.key != 'date' && entry.key != 'nombre_usuario' && entry.key != 'documentos' && entry.key != 'isInitial';
                          }).map<Widget>((entry) {
                            return Text('${entry.value}');
                          }).toList(),
                        ),
                        SizedBox(height: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: documentos.map<Widget>((documento) {
                            final mime = documento['mime'];
                            final String filePath = documento['filepath'];
                            final file = File(filePath);
                            if (mime.startsWith('image/')) {
                              return GestureDetector(
                                onTap: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => Dialog(
                                      child: Column(
                                        children: [
                                          Expanded(
                                            child: PhotoView(
                                              imageProvider: FileImage(file),
                                            ),
                                          ),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                            children: [
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                },
                                                child: Text('Cerrar',style: TextStyle(color: defaultTextButtonColor)),
                                              ),
                                              TextButton(
                                                onPressed: () async {
                                                  await _ticketDetailController.downloadFile(filePath, documento['filename']);
                                                },
                                                child: Text('Descargar',style: TextStyle(color: defaultTextButtonColor)),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                                child: Container(
                                  margin: EdgeInsets.symmetric(vertical: 5),
                                  decoration: BoxDecoration(
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black12,
                                        blurRadius: 5,
                                        offset: Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8.0), // Optional: Add border radius if needed
                                    child: Image.file(
                                      file,
                                      width: 80,
                                      height: 80,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                              );
                            } else if (mime == 'application/pdf') {
                              return GestureDetector(
                                onTap: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => Dialog(
                                      child: Column(
                                        children: [
                                          Expanded(
                                            child: PDFView(
                                              filePath: file.path,
                                            ),
                                          ),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                            children: [
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                },
                                                child: Text('Cerrar',style: TextStyle(color: defaultTextButtonColor)),
                                              ),
                                              TextButton(
                                                onPressed: () async {
                                                 await _ticketDetailController.downloadFile(filePath, documento['filename']);
                                                },
                                                child: Text('Descargar',style: TextStyle(color: defaultTextButtonColor)),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                                child: Row(
                                  children: [
                                    Icon(Icons.picture_as_pdf, size: 40, color: Colors.red),
                                    SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        documento['filename'],
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            } else {
                              return Container();
                            }
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Positioned(
            bottom: 16,
            right: 16,
            child: FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CreateHistoricalScreen(ticketId: ticket.id,ticket: ticket)),
                );
              },
              backgroundColor: Colors.orange,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.add, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}