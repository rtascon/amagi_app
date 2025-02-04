import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:photo_view/photo_view.dart';
import 'package:intl/intl.dart'; 
import '../controllers/ticket_detail_controller.dart';
import '../controllers/tickets_controller.dart';
import '../models/user.dart'; 
import 'dart:io';
import 'create_historical_screen.dart';
import 'dart:math';
import 'dart:ui' as ui;

/// Esta vista muestra los detalles de un ticket específico, incluyendo su descripción,
/// históricos y documentos adjuntos. Permite a los usuarios ver y gestionar la información del ticket.

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

    // Combinar históricos y soluciones en una sola lista y ordenar por fecha
    final combinedList = [...ticket.historicos, ...ticket.soluciones];
    combinedList.sort((a, b) {
      DateTime fechaA = DateTime.tryParse(a['date'] ?? a['date_creation'] ?? '') ?? DateTime(1970);
      DateTime fechaB = DateTime.tryParse(b['date'] ?? b['date_creation'] ?? '') ?? DateTime(1970);
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
              itemCount: combinedList.length,
              itemBuilder: (context, index) {
                final item = combinedList[index];
                final fecha = item['date'] ?? item['date_creation'] ?? '';
                final usuarioNombre = item['nombre_usuario'] ?? '';
                final documentos = item['documentos'] ?? [];
                final esUsuarioLogueado = usuarioNombre == usuario.nombreCompleto;
                final esHistoricoInicial = item['isInitial'] == true;
                final esSolucion = ticket.soluciones.contains(item);

                // Formatear la fecha para no mostrar milisegundos
                final formattedFecha = DateFormat('dd-MM-yyyy HH:mm').format(DateTime.tryParse(fecha) ?? DateTime(1970));

                return MessageBubble(
                  message: Message(
                    owner: esUsuarioLogueado ? MessageOwner.myself : MessageOwner.other,
                    text: item['content'] ?? '',
                  ),
                  isSolution: esSolucion,
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
                                  esSolucion ? "Solución creada: " : "Creado: ",
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
                        children: item.entries.where((entry) {
                          return entry.key != 'id' && entry.key != 'users_id' && entry.key != 'date_creation' && entry.key != 'nombre_usuario' && entry.key != 'documentos' && entry.key != 'isInitial';
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
                );
              },
            ),
          ),
          if (ticket.estado != 5 && ticket.estado != 6)
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

@immutable
class MessageBubble extends StatelessWidget {
  const MessageBubble({
    super.key,
    required this.message,
    required this.child,
    this.isSolution = false,
  });

  final Message message;
  final Widget child;
  final bool isSolution;

  @override
  Widget build(BuildContext context) {
    final messageAlignment =
        message.isMine ? Alignment.topRight : Alignment.topLeft;

    return FractionallySizedBox(
      alignment: messageAlignment,
      widthFactor: 0.8,
      child: Align(
        alignment: messageAlignment,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 20.0),
          child: ClipRRect(
            borderRadius: const BorderRadius.all(Radius.circular(16.0)),
            child: BubbleBackground(
              colors: isSolution
                  ? [Color(0xFF00FF00), Color(0xFF008000)]
                  : message.isMine
                      ? [Color.fromARGB(255, 0, 145, 230), Color(0xFF005586)]
                      : [Color.fromARGB(255, 120, 164, 189), Color.fromARGB(255, 0, 48, 77)],
              child: DefaultTextStyle.merge(
                style: const TextStyle(
                  fontSize: 18.0,
                  color: Colors.white,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: child,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

@immutable
class BubbleBackground extends StatelessWidget {
  const BubbleBackground({
    super.key,
    required this.colors,
    this.child,
  });

  final List<Color> colors;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: BubblePainter(
        scrollable: Scrollable.of(context),
        bubbleContext: context,
        colors: colors,
      ),
      child: child,
    );
  }
}

class BubblePainter extends CustomPainter {
  BubblePainter({
    required ScrollableState scrollable,
    required BuildContext bubbleContext,
    required List<Color> colors,
  })  : _scrollable = scrollable,
        _bubbleContext = bubbleContext,
        _colors = colors,
        super(repaint: scrollable.position);

  final ScrollableState _scrollable;
  final BuildContext _bubbleContext;
  final List<Color> _colors;

  @override
  void paint(Canvas canvas, Size size) {
    final scrollableBox = _scrollable.context.findRenderObject() as RenderBox;
    final scrollableRect = Offset.zero & scrollableBox.size;
    final bubbleBox = _bubbleContext.findRenderObject() as RenderBox;

    final origin =
        bubbleBox.localToGlobal(Offset.zero, ancestor: scrollableBox);
    final paint = Paint()
      ..shader = ui.Gradient.linear(
        scrollableRect.topCenter,
        scrollableRect.bottomCenter,
        _colors,
        [0.0, 1.0],
        TileMode.clamp,
        Matrix4.translationValues(-origin.dx, -origin.dy, 0.0).storage,
      );
    canvas.drawRect(Offset.zero & size, paint);
  }

  @override
  bool shouldRepaint(BubblePainter oldDelegate) {
    return oldDelegate._scrollable != _scrollable ||
        oldDelegate._bubbleContext != _bubbleContext ||
        oldDelegate._colors != _colors;
  }
}

enum MessageOwner { myself, other }

@immutable
class Message {
  const Message({
    required this.owner,
    required this.text,
  });

  final MessageOwner owner;
  final String text;

  bool get isMine => owner == MessageOwner.myself;
}