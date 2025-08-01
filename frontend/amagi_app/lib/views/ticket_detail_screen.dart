import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:photo_view/photo_view.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import '../controllers/ticket_detail_controller.dart';
import '../models/user.dart';
import 'dart:io';
import 'create_historical_screen.dart';
import 'dart:ui' as ui;
import '../theme/app_theme.dart';

/// Esta vista muestra los detalles de un ticket específico, incluyendo su descripción,
/// históricos y documentos adjuntos. Permite a los usuarios ver y gestionar la información del ticket.

class TicketDetailScreen extends StatefulWidget {
  final dynamic ticket;

  const TicketDetailScreen({super.key, required this.ticket});

  @override
  _TicketDetailScreenState createState() => _TicketDetailScreenState();
}

class _TicketDetailScreenState extends State<TicketDetailScreen> {
  final TicketDetailController _ticketDetailController =
      TicketDetailController();
  final User usuario = User();
  final ScrollController _controller = ScrollController();
  bool _showScrollButton = false;
  final Map<int, bool> _showFullTextMap = {};

  @override
  void initState() {
    super.initState();
    _controller.addListener(_scrollListener);
  }

  void _scrollListener() {
    if (_controller.position.maxScrollExtent >
        _controller.position.pixels + 100) {
      setState(() {
        _showScrollButton = true;
      });
    } else {
      setState(() {
        _showScrollButton = false;
      });
    }
  }

  void _scrollDown() {
    _controller.animateTo(
      _controller.position.maxScrollExtent,
      duration: const Duration(seconds: 2),
      curve: Curves.fastOutSlowIn,
    );
  }

  @override
  Widget build(BuildContext context) {
    Color defaultTextButtonColor =
        TextButton.styleFrom().foregroundColor?.resolve({}) ??
            Theme.of(context).primaryColor;
    bool historicoInicialPresente = widget.ticket.historicos
        .any((historico) => historico['isInitial'] == true);

    if (!historicoInicialPresente) {
      final historicoInicial = {
        'date': widget.ticket.fechaCreacion.toString(),
        'nombre_usuario': usuario.nombreCompleto,
        'content': widget.ticket.descripcion,
        'documentos': [],
        'isInitial': true,
      };
      widget.ticket.historicos.insert(0, historicoInicial);
    }

    final combinedList = [
      ...widget.ticket.historicos,
      ...widget.ticket.soluciones
    ];
    combinedList.sort((a, b) {
      DateTime fechaA =
          DateTime.tryParse(a['date'] ?? a['date_creation'] ?? '') ??
              DateTime(1970);
      DateTime fechaB =
          DateTime.tryParse(b['date'] ?? b['date_creation'] ?? '') ??
              DateTime(1970);
      return fechaB.compareTo(fechaA);
    });

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'Ticket ${widget.ticket.id}',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        elevation: 0,
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Container(
            color: Colors.white,
            child: ListView.builder(
              controller: _controller,
              itemCount: combinedList.length,
              itemBuilder: (context, index) {
                final item = combinedList[index];
                final fecha = item['date'] ?? item['date_creation'] ?? '';
                final usuarioNombre = item['nombre_usuario'] ?? 'Desconocido';
                final documentos = item['documentos'] ?? [];
                final esUsuarioLogueado =
                    usuarioNombre == usuario.nombreCompleto;
                final esHistoricoInicial = item['isInitial'] == true;
                final esSolucion = widget.ticket.soluciones.contains(item);

                final formattedFecha = DateFormat('dd-MM-yy HH:mm')
                    .format(DateTime.tryParse(fecha) ?? DateTime(1970));

                return MessageBubble(
                  message: Message(
                    owner: esUsuarioLogueado
                        ? MessageOwner.myself
                        : MessageOwner.other,
                    text: item['content'] ?? '',
                  ),
                  isSolution: esSolucion,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(1),
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(0, 224, 224, 224),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  esSolucion ? "Solución: " : "Creado: ",
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                                const Icon(Icons.access_time,
                                    size: 16, color: Colors.white),
                                const SizedBox(width: 5),
                                Text(formattedFecha),
                              ],
                            ),
                            const SizedBox(height: 5),
                            Row(
                              children: [
                                const Text(
                                  "Por: ",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                const Icon(Icons.person,
                                    size: 20, color: Colors.white),
                                const SizedBox(width: 5),
                                Flexible(
                                  child: Text(
                                    usuarioNombre,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const Divider(
                              color: Color.fromARGB(171, 255, 255, 255),
                              thickness: 1,
                              indent: 1,
                              endIndent: 1,
                            ),
                          ],
                        ),
                      ),
                      if (esHistoricoInicial) ...[
                        const SizedBox(height: 10),
                        Text(
                          '${widget.ticket.titulo}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                      const SizedBox(height: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ...item.entries.where((entry) {
                            return entry.key != 'id' &&
                                entry.key != 'users_id' &&
                                entry.key != 'date_creation' &&
                                entry.key != 'nombre_usuario' &&
                                entry.key != 'documentos' &&
                                entry.key != 'isInitial' &&
                                entry.key != 'date' &&
                                entry.key != 'content';
                          }).map<Widget>((entry) {
                            return Text(
                              '${entry.value}',
                              overflow: TextOverflow.visible,
                            );
                          }).toList(),
                          Text(
                            _showFullTextMap[index] == true
                                ? item['content']
                                : (item['content'].length > 300
                                    ? '${item['content'].substring(0, 300)}...'
                                    : item['content']),
                          ),
                          if (item['content'].length > 300 &&
                              _showFullTextMap[index] != true)
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _showFullTextMap[index] = true;
                                });
                              },
                              child: const Text(
                                'Leer más',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 10),
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
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: [
                                            TextButton(
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                              child: const Text('Cerrar',
                                                  style: TextStyle(
                                                      color: Colors.black)),
                                            ),
                                            IconButton(
                                              onPressed: () async {
                                                await _ticketDetailController
                                                    .downloadFile(
                                                        context,
                                                        filePath,
                                                        documento['filename']);
                                              },
                                              icon: const Icon(
                                                  Icons.file_open_outlined,
                                                  color: Colors.black),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                              child: Container(
                                margin: const EdgeInsets.symmetric(vertical: 5),
                                decoration: const BoxDecoration(
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black12,
                                      blurRadius: 5,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8.0),
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
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: [
                                            TextButton(
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                              child: Text('Cerrar',
                                                  style: TextStyle(
                                                      color:
                                                          defaultTextButtonColor)),
                                            ),
                                            IconButton(
                                              onPressed: () async {
                                                await _ticketDetailController
                                                    .downloadFile(
                                                        context,
                                                        filePath,
                                                        documento['filename']);
                                                OpenFile.open(filePath);
                                              },
                                              icon: const Icon(
                                                  Icons.file_open_outlined,
                                                  color: Colors.black),
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
                                  const Icon(Icons.picture_as_pdf,
                                      size: 40, color: Colors.red),
                                  const SizedBox(width: 10),
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
          if (widget.ticket.estado != 5 && widget.ticket.estado != 6)
            Positioned(
              bottom: 18,
              right: MediaQuery.of(context).size.width * 0.08,
              child: FloatingActionButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => CreateHistoricalScreen(
                            ticketId: widget.ticket.id, ticket: widget.ticket)),
                  );
                },
                backgroundColor: Colors.orange,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.add, color: Colors.white),
              ),
            ),
          if (_showScrollButton)
            Positioned(
              bottom: widget.ticket.estado == 5 || widget.ticket.estado == 6
                  ? 18
                  : 80,
              right: MediaQuery.of(context).size.width * 0.08,
              child: FloatingActionButton.small(
                onPressed: _scrollDown,
                backgroundColor: const Color(0xFF005586),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.arrow_downward, color: Colors.white),
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

    final themeColors = AppTheme.of(context);

    final List<Color> solutionGradient = [
      const Color(0xFF388E3C),
      const Color(0xFF66BB6A),
    ];

    final List<Color> myMessageGradient = [
      themeColors.primaryColor,
      themeColors.primaryDarkColor,
    ];

    final List<Color> otherMessageGradient = [
      themeColors.primaryDarkColor,
      const Color.fromARGB(255, 0, 40, 92),
    ];

    return FractionallySizedBox(
      alignment: messageAlignment,
      widthFactor: 0.9,
      child: Align(
        alignment: messageAlignment,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 20.0),
          child: ClipRRect(
            borderRadius: const BorderRadius.all(Radius.circular(16.0)),
            child: Container(
              decoration: const BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black38,
                    blurRadius: 6.0,
                    offset: Offset(3, 3),
                  ),
                ],
              ),
              child: BubbleBackground(
                colors: isSolution
                    ? solutionGradient
                    : message.isMine
                        ? myMessageGradient
                        : otherMessageGradient,
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
