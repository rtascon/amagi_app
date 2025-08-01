import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../controllers/create_historical_controller.dart';
import '../models/ticket.dart';
import '../theme/app_theme.dart';

/// Esta vista permite a los usuarios agregar un histórico a un ticket existente,
/// incluyendo la descripción y la posibilidad de adjuntar archivos.

class CreateHistoricalScreen extends StatefulWidget {
  final int ticketId;
  final Ticket ticket;

  const CreateHistoricalScreen(
      {super.key, required this.ticketId, required this.ticket});

  @override
  CreateHistoricalScreenState createState() => CreateHistoricalScreenState();
}

class CreateHistoricalScreenState extends State<CreateHistoricalScreen> {
  final _formKey = GlobalKey<FormState>();
  final CreateHistoricalController _createHistoricalController =
      CreateHistoricalController();
  String? _descripcion;
  final List<PlatformFile> _selectedFiles = [];
  final TextEditingController _descripcionController = TextEditingController();
  bool _isLoading = false;

  Future<void> _pickFiles() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'png', 'jpg', 'jpeg'],
        allowMultiple: true,
      );

      if (result != null) {
        setState(() {
          _selectedFiles.addAll(
            result.files
                .where((file) => file.size <= 10 * 1024 * 1024)
                .toList(),
          );
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'No se pudo acceder a los archivos. Verifica los permisos de almacenamiento.')),
      );
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

  bool _hasChanges() {
    return _descripcionController.text.isNotEmpty || _selectedFiles.isNotEmpty;
  }

  Future<bool> _onWillPop() async {
    if (!_hasChanges()) {
      return true;
    }
    return (await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Center(
              child: Icon(
                Icons.warning,
                color: Colors.orange,
                size: 50,
              ),
            ),
            content: const Text(
                'Si abandona el formulario, perderá los cambios realizados. ¿Desea continuar?'),
            actions: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('Cancelar',
                        style: TextStyle(color: Colors.black)),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: const Text('Aceptar',
                        style: TextStyle(color: Colors.black)),
                  ),
                ],
              ),
            ],
          ),
        )) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.of(context);
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: colors.backgroundColor),
            onPressed: () async {
              if (await _onWillPop()) {
                Navigator.pop(context);
              }
            },
          ),
          title: Text(
            'Agregar Histórico',
            style: TextStyle(
              color: colors.backgroundColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: colors.primaryDarkColor,
          elevation: 0,
          centerTitle: true,
        ),
        body: Container(
          padding: const EdgeInsets.all(16.0),
          color: colors.backgroundColor,
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
                      Icon(Icons.edit_note, color: colors.iconColor),
                      const SizedBox(width: 4.0),
                      Text(
                        'Descripción',
                        style: TextStyle(color: colors.iconColor),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                      vertical: 16.0, horizontal: 16.0),
                  decoration: BoxDecoration(
                    color: colors.secondaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height * 0.3,
                    ),
                    child: TextFormField(
                      controller: _descripcionController,
                      decoration: InputDecoration(
                        hintText: 'Ingrese una descripción',
                        hintStyle:
                            TextStyle(color: colors.iconColor, fontSize: 17),
                        filled: true,
                        fillColor: colors.secondaryColor.withOpacity(0),
                        border: InputBorder.none,
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 10.0),
                      ),
                      maxLines: 5,
                      maxLength: 2000,
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
                ),
                const SizedBox(height: 16.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _pickFiles,
                        icon: Icon(Icons.folder, color: colors.backgroundColor),
                        label: const Text('Subir Archivo'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colors.primaryDarkColor,
                          foregroundColor: colors.backgroundColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16.0),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _pickImageFromCamera,
                        icon: Icon(Icons.camera_alt,
                            color: colors.backgroundColor),
                        label: const Text('Tomar Foto'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colors.primaryDarkColor,
                          foregroundColor: colors.backgroundColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16.0),
                Container(
                  width: double.infinity,
                  height: MediaQuery.of(context).size.height * 0.2,
                  padding: const EdgeInsets.symmetric(
                      vertical: 8.0, horizontal: 16.0),
                  decoration: BoxDecoration(
                    color: colors.secondaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  child: Stack(
                    children: [
                      SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _selectedFiles.isEmpty
                                ? SizedBox(
                                    height: 60,
                                    child: Center(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.attach_file,
                                              size: 24,
                                              color: colors.iconColor),
                                          const SizedBox(width: 4.0),
                                          Text(
                                            'No se ha cargado ningún archivo',
                                            style: TextStyle(
                                                color: colors.iconColor,
                                                fontSize: 12),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                : Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: _selectedFiles.map((file) {
                                      String fileName = file.name;
                                      IconData icon;
                                      if (file.extension == 'pdf') {
                                        icon = Icons.description;
                                      } else if (file.extension == 'jpg' ||
                                          file.extension == 'jpeg' ||
                                          file.extension == 'png') {
                                        icon = Icons.image;
                                      } else {
                                        icon = Icons.insert_drive_file;
                                      }
                                      return Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Row(
                                              children: [
                                                Icon(icon,
                                                    size: 25,
                                                    color: colors.iconColor),
                                                const SizedBox(width: 4.0),
                                                Expanded(
                                                  child: Text(
                                                    fileName,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    maxLines: 2,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          IconButton(
                                            icon: const Icon(
                                                Icons.close_rounded,
                                                size: 25,
                                                color: Colors.red),
                                            onPressed: () {
                                              setState(() {
                                                _selectedFiles.remove(file);
                                              });
                                            },
                                          ),
                                        ],
                                      );
                                    }).toList(),
                                  ),
                            const SizedBox(height: 8.0),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10.0, vertical: 5.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      _selectedFiles.fold<int>(
                                  0, (sum, file) => sum + file.size) >
                              10 * 1024 * 1024
                          ? 'Límite de 10 MB, por favor edite su selección'
                          : 'Tamaño total: ${(_selectedFiles.fold<int>(0, (sum, file) => sum + file.size) / (1024 * 1024)).toStringAsFixed(2)} MB',
                      style: TextStyle(
                        color: _selectedFiles.fold<int>(
                                    0, (sum, file) => sum + file.size) >
                                10 * 1024 * 1024
                            ? colors.errorColor
                            : colors.iconColor,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 5.0),
                Align(
                  alignment: Alignment.center,
                  child: SizedBox(
                    width: 150,
                    child: ElevatedButton(
                      onPressed: _isLoading ||
                              _selectedFiles.fold<int>(
                                      0, (sum, file) => sum + file.size) >
                                  10 * 1024 * 1024
                          ? null
                          : () async {
                              if (_formKey.currentState!.validate()) {
                                bool hasLargeFile = _selectedFiles.any(
                                    (file) => file.size > 10 * 1024 * 1024);
                                if (hasLargeFile) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text(
                                            'El archivo supera el tamaño máximo de 10MB')),
                                  );
                                  return;
                                }

                                setState(() {
                                  _isLoading = true;
                                });

                                _formKey.currentState!.save();
                                await _createHistoricalController
                                    .submitHistorical(
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
                        backgroundColor: colors.primaryDarkColor,
                        foregroundColor: colors.backgroundColor,
                      ),
                      child: _isLoading
                          ? CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  colors.backgroundColor),
                            )
                          : const Text('Enviar'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
