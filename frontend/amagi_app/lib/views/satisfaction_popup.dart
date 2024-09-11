import 'package:flutter/material.dart';

class SatisfactionPopup extends StatefulWidget {
  final Function(int, String) onSubmit;
  final Function onCancel;

  SatisfactionPopup({required this.onSubmit, required this.onCancel});

  @override
  _SatisfaccionPopupState createState() => _SatisfaccionPopupState();
}

class _SatisfaccionPopupState extends State<SatisfactionPopup> {
  int _rating = 0;
  TextEditingController _comentariosController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Ticket cerrado exitosamente'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Por favor, califique su experiencia'),
          SizedBox(height: 16),
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
          SizedBox(height: 16),
          TextField(
            controller: _comentariosController,
            decoration: InputDecoration(
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
          child: Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () {
            widget.onSubmit(_rating, _comentariosController.text);
            Navigator.of(context).pop();
          },
          child: Text('Enviar'),
        ),
      ],
    );
  }
}