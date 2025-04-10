import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../controllers/tickets_controller.dart';
import '../models/ticket.dart';

class SolucionScreen extends StatefulWidget {
  final Ticket ticket;
  final Map<String, dynamic> solucion;
  final TicketsController ticketsController = TicketsController();

  SolucionScreen({super.key, required this.ticket, required this.solucion});

  @override
  SolucionScreenState createState() => SolucionScreenState();
}

class SolucionScreenState extends State<SolucionScreen> {
  bool _isLoadingAprobar = false;
  bool _isLoadingRechazar = false;

  @override
  Widget build(BuildContext context) {
    // Obtener la fecha y hora formateada
    final fecha = widget.solucion['date_creation'] ?? '';
    final formattedFecha = DateFormat('dd-MM-yy HH:mm').format(DateTime.tryParse(fecha) ?? DateTime(1970));
    final usuarioNombre = widget.solucion['nombre_usuario'] ?? '';

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Ticket: ${widget.ticket.id}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold,)),
        backgroundColor: const Color(0xFF005586),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  "Solución: ",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const Icon(Icons.access_time, size: 16, color: Colors.black),
                const SizedBox(width: 5),
                Text(formattedFecha), // Usar la fecha formateada
              ],
            ),
            const SizedBox(height: 5),
            Row(
              children: [
                const Text(
                  "Por: ",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const Icon(Icons.person, size: 20, color: Colors.black),
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
            const SizedBox(height: 8),
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0), 
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(15.0),
                ),
                child: Scrollbar(
                  thumbVisibility: true, // Mostrar la barra de desplazamiento
                  child: SingleChildScrollView(
                    child: Text(
                      widget.solucion['content'],
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16), // Espacio entre el texto y los botones
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: _isLoadingRechazar ? null : () async {
                    setState(() {
                      _isLoadingAprobar = true;
                    });
                    await widget.ticketsController.closeTicket(context, widget.ticket);
                    setState(() {
                      _isLoadingAprobar = false;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green, // Color verde para el botón de aprobar
                  ),
                  child: _isLoadingAprobar
                      ? const CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        )
                      : const Row(
                          children: [
                            Icon(Icons.check, color: Colors.white), // Icono de check
                            SizedBox(width: 5),
                            Text(
                              'Aprobar',
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold), // Letras blancas y en negrita
                            ),
                          ],
                        ),
                ),
                ElevatedButton(
                  onPressed: _isLoadingAprobar ? null : () async {
                    setState(() {
                      _isLoadingRechazar = true;
                    });
                    await widget.ticketsController.deniedTicket(context, widget.ticket);
                    setState(() {
                      _isLoadingRechazar = false;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red, // Color rojo para el botón de rechazar
                  ),
                  child: _isLoadingRechazar
                      ? const CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        )
                      : const Row(
                          children: [
                            Icon(Icons.close, color: Colors.white), // Icono acorde
                            SizedBox(width: 5),
                            Text(
                              'Rechazar',
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold), // Letras blancas y en negrita
                            ),
                          ],
                        ),
                ),
              ],
            ),
          ],
        ),
      ),
      backgroundColor: Colors.white,
    );
  }
}
