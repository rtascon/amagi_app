import 'package:flutter/material.dart';
import '../controllers/create_ticket_controller.dart';
import '../views/main_menu_screen.dart';
import '../theme/app_theme.dart';

/// Este archivo contiene la pantalla de creación de tickets, donde los usuarios pueden ingresar
/// información sobre un nuevo ticket, incluyendo el título, tipo y descripción.

class CreateTicketScreen extends StatefulWidget {
  const CreateTicketScreen({super.key});

  @override
  CreateTicketScreenState createState() => CreateTicketScreenState();
}

class CreateTicketScreenState extends State<CreateTicketScreen> {
  final _formKey = GlobalKey<FormState>();
  final createTicketController = CreateTicketController();

  final TextEditingController _tituloController = TextEditingController();
  final TextEditingController _descripcionController = TextEditingController();
  final TextEditingController _tipoController = TextEditingController();
  bool _isLoading = false;

  final List<Map<String, dynamic>> tipoItems = [
    {
      'value': '2',
      'label': 'Requerimiento',
      'icon': Icons.help,
      'color': AppColors.blue
    },
    {
      'value': '1',
      'label': 'Incidente',
      'icon': Icons.error,
      'color': AppColors.orange
    },
  ];

  String? selectedTipo;

  bool _hasChanges() {
    return _tituloController.text.isNotEmpty ||
        _descripcionController.text.isNotEmpty ||
        selectedTipo != null;
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
  void dispose() {
    _tituloController.dispose();
    _descripcionController.dispose();
    _tipoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (await _onWillPop()) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const MainMenuScreen()),
            (route) => false,
          );
        }
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.white),
            onPressed: () async {
              if (await _onWillPop()) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const MainMenuScreen()),
                  (route) => false,
                );
              }
            },
          ),
          title: const Text(
            'Crear Ticket',
            style: TextStyle(
              color: AppColors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: AppColors.darkBlue,
          elevation: 0,
          centerTitle: true,
        ),
        body: Container(
          color: AppColors.white,
          height: MediaQuery.of(context).size.height,
          child: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Icon(Icons.edit_note, color: Colors.grey[600]),
                              const SizedBox(width: 4.0),
                              Text(
                                'Título',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                              vertical: 4.0, horizontal: 16.0),
                          decoration: BoxDecoration(
                            color: AppColors.blueGrey.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          child: TextFormField(
                            controller: _tituloController,
                            decoration: InputDecoration(
                              hintText: 'Ingrese un título',
                              hintStyle: const TextStyle(
                                  color: AppColors.blueGrey, fontSize: 17),
                              filled: true,
                              fillColor: AppColors.blueGrey.withOpacity(0),
                              border: InputBorder.none,
                              contentPadding:
                                  const EdgeInsets.symmetric(vertical: 10.0),
                            ),
                            maxLength: 50,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Por favor ingrese un título';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(height: 16.0),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Icon(Icons.playlist_add_check,
                                  color: Colors.grey[600]),
                              const SizedBox(width: 4.0),
                              Text(
                                'Tipo',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                              vertical: 4.0, horizontal: 16.0),
                          decoration: BoxDecoration(
                            color: AppColors.blueGrey.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          child: DropdownButtonFormField<String>(
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: AppColors.blueGrey.withOpacity(0),
                              border: InputBorder.none,
                              contentPadding:
                                  const EdgeInsets.symmetric(vertical: 10.0),
                            ),
                            dropdownColor: AppColors.white,
                            hint: const Text(
                              'Seleccione una opción',
                              style: TextStyle(fontSize: 17),
                            ),
                            items: tipoItems.map((item) {
                              return DropdownMenuItem<String>(
                                value: item['value'],
                                child: Row(
                                  children: [
                                    Icon(item['icon'], color: item['color']),
                                    const SizedBox(width: 8),
                                    Text(
                                      item['label'],
                                      style: TextStyle(
                                          fontSize: 16, color: item['color']),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                            validator: (value) {
                              if (value == null) {
                                return 'Por favor seleccione un tipo.';
                              }
                              return null;
                            },
                            onChanged: (value) {
                              setState(() {
                                _tipoController.text = value ?? '';
                              });
                            },
                            onSaved: (value) {
                              selectedTipo = value;
                            },
                          ),
                        ),
                        const SizedBox(height: 16.0),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Icon(Icons.edit_note, color: Colors.grey[600]),
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
                          padding: const EdgeInsets.symmetric(
                              vertical: 16.0, horizontal: 16.0),
                          decoration: BoxDecoration(
                            color: AppColors.blueGrey.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              maxHeight:
                                  MediaQuery.of(context).size.height * 0.3,
                            ),
                            child: TextFormField(
                              controller: _descripcionController,
                              decoration: InputDecoration(
                                hintText: 'Ingrese una descripción',
                                hintStyle: const TextStyle(
                                    color: AppColors.blueGrey, fontSize: 17),
                                filled: true,
                                fillColor: AppColors.blueGrey.withOpacity(0),
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
                            ),
                          ),
                        ),
                        const SizedBox(height: 10.0),
                        Align(
                          alignment: Alignment.center,
                          child: SizedBox(
                            width: 150,
                            child: ElevatedButton(
                              onPressed: _isLoading
                                  ? null
                                  : () async {
                                      if (_formKey.currentState?.validate() ??
                                          false) {
                                        if (mounted) {
                                          setState(() {
                                            _isLoading = true;
                                          });
                                        }

                                        await createTicketController
                                            .submitCrearticketController(
                                          context,
                                          _tituloController.text.trim(),
                                          _descripcionController.text.trim(),
                                          int.parse(
                                              _tipoController.text.trim()),
                                        );

                                        if (mounted) {
                                          setState(() {
                                            _isLoading = false;
                                            _tituloController.clear();
                                            _descripcionController.clear();
                                            _tipoController.clear();
                                            selectedTipo = null;
                                          });
                                        }
                                      }
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.darkBlue,
                                foregroundColor: AppColors.white,
                              ),
                              child: _isLoading
                                  ? const CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          AppColors.darkBlue),
                                    )
                                  : const Text('Enviar'),
                            ),
                          ),
                        ),
                      ],
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
