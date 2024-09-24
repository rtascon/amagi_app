import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../controllers/create_historical_controller.dart';
import '../models/ticket.dart';

/// Esta vista permite a los usuarios agregar un histórico a un ticket existente,
/// incluyendo la descripción y la posibilidad de adjuntar archivos.

class CreateHistoricalScreen extends StatefulWidget {
  final int ticketId;
  final Ticket ticket;

  CreateHistoricalScreen({required this.ticketId, required this.ticket});

  @override
  _CreateHistoricalScreenState createState() => _CreateHistoricalScreenState();
}

class _CreateHistoricalScreenState extends State<CreateHistoricalScreen> {
  final _formKey = GlobalKey<FormState>();
  final CreateHistoricalController _createHistoricalController = CreateHistoricalController();
  String? _descripcion;
  List<PlatformFile> _selectedFiles = [];

  Future<void> _pickFiles() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'png', 'jpg', 'jpeg'],
      allowMultiple: true,
    );

    if (result != null) {
      setState(() {
        _selectedFiles = result.files.where((file) => file.size <= 10 * 1024 * 1024).toList();
      });
    }
  }

  Future<void> _pickImageFromCamera() async {
    PlatformFile? image = await _createHistoricalController.pickImageFromCamera();
    if (image != null) {
      setState(() {
        _selectedFiles.add(image);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'Agregar Histórico',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Color(0xFF005586),
        elevation: 0,
        centerTitle: true,
      ),
      body: Container(
        padding: EdgeInsets.all(16.0),
        color: Colors.white,
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Descripción',
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide(color: Colors.black),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide(color: Colors.black),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide(color: Colors.black),
                  ),
                ),
                maxLines: 5,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese una descripción';
                  }
                  return null;
                },
                onSaved: (value) {
                  _descripcion = value;
                },
              ),
              SizedBox(height: 16.0),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: Column(
                      children: [
                        ElevatedButton.icon(
                          onPressed: _pickFiles,
                          icon: Icon(Icons.attach_file, color: Colors.white),
                          label: Text('Seleccionar Archivos'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF005586),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                          ),
                        ),
                        SizedBox(height: 16.0),
                        ElevatedButton.icon(
                          onPressed: _pickImageFromCamera,
                          icon: Icon(Icons.camera_alt, color: Colors.white),
                          label: Text('Tomar Foto'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF005586),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 16.0),
                  Expanded(
                    flex: 3,
                    child: Container(
                      padding: EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        border: Border.all(color: Color(0xFF005586)),
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: _selectedFiles.isEmpty
                          ? Container(
                              height: 100, // Ajusta la altura según sea necesario
                              child: Center(
                                child: Text(
                                  'No se han cargado archivos',
                                  style: TextStyle(color: Color(0xFF005586)),
                                ),
                              ),
                            )
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: _selectedFiles.map((file) => Text(file.name)).toList(),
                            ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.0),
              Align(
                alignment: Alignment.center,
                child: SizedBox(
                  width: 150,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _formKey.currentState!.save();
                        _createHistoricalController.submitHistorical(
                          context,
                          widget.ticketId,
                          _descripcion!,
                          _selectedFiles,
                          widget.ticket,
                        );
                      }
                    },
                    child: Text('Enviar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF005586),
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}