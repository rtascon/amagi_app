import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../controllers/create_historical_controller.dart';
import '../models/ticket.dart';

/// Esta vista permite a los usuarios agregar un histórico a un ticket existente,
/// incluyendo la descripción y la posibilidad de adjuntar archivos.

class CreateHistoricalScreen extends StatefulWidget {
  final int ticketId;
  final Ticket ticket;

  const CreateHistoricalScreen(
      {super.key, required this.ticketId, required this.ticket});

  @override
  _CreateHistoricalScreenState createState() => _CreateHistoricalScreenState();
}

class _CreateHistoricalScreenState extends State<CreateHistoricalScreen> {
  final _formKey = GlobalKey<FormState>();
  final CreateHistoricalController _createHistoricalController =
      CreateHistoricalController();
  String? _descripcion;
  List<PlatformFile> _selectedFiles = [];
  final TextEditingController _descripcionController = TextEditingController(); // Añadir controlador para el campo de descripción
  bool _isLoading = false; // Añadir variable de estado para el loading

  Future<void> _pickFiles() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'png', 'jpg', 'jpeg'],
      allowMultiple: true,
    );

    if (result != null) {
      setState(() {
        _selectedFiles = result.files
            .where((file) => file.size <= 10 * 1024 * 1024)
            .toList();
      });
    }
  }

  Future<void> _pickImageFromCamera() async {
    PlatformFile? image =
        await _createHistoricalController.pickImageFromCamera();
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
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Agregar Histórico',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF005586),
        elevation: 0,
        centerTitle: true,
      ),
      body: Container(
        padding: const EdgeInsets.all(16.0),
        color: Colors.white,
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Icon(Icons.edit_square, color: Colors.grey[600]), // Ajustar ícono
                    const SizedBox(width: 4.0),
                    Text(
                      'Descripción',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0), // Margen del campo de texto
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(15.0),
                ),
                child: TextFormField(
                  controller: _descripcionController,
                  decoration: InputDecoration(
                    hintText: 'Ingrese una descripción', // Texto de marcador de posición
                    hintStyle: TextStyle(color: Colors.grey[600], fontSize: 17), // Tamaño de letra igual al de título
                    filled: true,
                    fillColor: Colors.grey[200], // Ajustar el fondo del texto
                    border: InputBorder.none, // Eliminar el borde del campo de texto
                    contentPadding: const EdgeInsets.symmetric(vertical: 10.0), // Ajustar el padding vertical
                  ),
                  maxLines: 10,
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
              ),
              const SizedBox(height: 16.0),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: Column(
                      children: [
                        ElevatedButton.icon(
                          onPressed: _pickFiles,
                          icon: const Icon(Icons.attach_file,
                              color: Colors.white),
                          label: const Text('Adjuntar Archivo'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF005586),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16.0),
                        ElevatedButton.icon(
                          onPressed: _pickImageFromCamera,
                          icon:
                              const Icon(Icons.camera_alt, color: Colors.white),
                          label: const Text('Tomar Foto'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF005586),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16.0),
                  Expanded(
                    flex: 3,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0), // Margen del contenedor
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      child: _selectedFiles.isEmpty
                          ? SizedBox(
                              height:
                                  100, // Ajusta la altura según sea necesario
                              child: Center(
                                child: Text(
                                  'No se ha cargado archivo',
                                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                                ),
                              ),
                            )
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: _selectedFiles
                                  .map((file) => Text(file.name))
                                  .toList(),
                            ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16.0),
              Align(
                alignment: Alignment.center,
                child: SizedBox(
                  width: 150,
                  child: ElevatedButton(
                    onPressed: _isLoading
                        ? null
                        : () async {
                            if (_formKey.currentState!.validate()) {
                              // Verificar si algún archivo es mayor de 15MB
                              bool hasLargeFile = _selectedFiles.any((file) => file.size > 15 * 1024 * 1024);
                              if (hasLargeFile) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('El archivo supera el tamaño máximo de 15MB')),
                                );
                                return;
                              }

                              setState(() {
                                _isLoading = true;
                              });

                              _formKey.currentState!.save();
                              await _createHistoricalController.submitHistorical(
                                context,
                                widget.ticketId,
                                _descripcion!,
                                _selectedFiles,
                                widget.ticket,
                              );

                              setState(() {
                                _isLoading = false;
                              });
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF005586),
                      foregroundColor: Colors.white,
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          )
                        : const Text('Enviar'),
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