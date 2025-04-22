import 'package:flutter/material.dart';

/// pantalla de satisfacción no funcional
class SatisfactionPopup extends StatefulWidget {
  final Function(int, String) onSubmit;
  final Function onCancel;

  const SatisfactionPopup(
      {super.key, required this.onSubmit, required this.onCancel});

  @override
  SatisfaccionPopupState createState() => SatisfaccionPopupState();
}

class SatisfaccionPopupState extends State<SatisfactionPopup> {
  int _rating = 0;
  final TextEditingController _comentariosController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Ticket cerrado exitosamente'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Por favor, califique su experiencia'),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              return IconButton(
                icon: Icon(
                  index < _rating ? Icons.star : Icons.star_border,
                  color: index < _rating ? Colors.yellow : Colors.grey,
                ),
                onPressed: () {
                  setState(() {
                    _rating = index + 1;
                  });
                },
              );
            }),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _comentariosController,
            decoration: const InputDecoration(
              labelText: 'Comentarios (opcional)',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            widget.onCancel();
            Navigator.of(context).pop();
          },
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () {
            widget.onSubmit(_rating, _comentariosController.text);
            Navigator.of(context).pop();
          },
          child: const Text('Enviar'),
        ),
      ],
    );
  }
}
