import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:parcial_2/models/establecimiento_model.dart';
import 'package:parcial_2/services/api_service.dart';

class EstablecimientoFormView extends StatefulWidget {
  final EstablecimientoModel? establecimiento;
  const EstablecimientoFormView({super.key, this.establecimiento});

  @override
  State<EstablecimientoFormView> createState() => _EstablecimientoFormViewState();
}

class _EstablecimientoFormViewState extends State<EstablecimientoFormView> {
  final _formKey = GlobalKey<FormState>();
  final ApiService _apiService = ApiService();
  
  final _nombreCtrl = TextEditingController();
  final _nitCtrl = TextEditingController();
  final _direccionCtrl = TextEditingController();
  final _telefonoCtrl = TextEditingController();
  
  XFile? _logoFile;
  String? _localPath;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.establecimiento != null) {
      _nombreCtrl.text = widget.establecimiento!.nombre;
      _nitCtrl.text = widget.establecimiento!.nit;
      _direccionCtrl.text = widget.establecimiento!.direccion;
      _telefonoCtrl.text = widget.establecimiento!.telefono;
      _cargarInfoLocal();
    }
  }

  Future<void> _cargarInfoLocal() async {
    final id = widget.establecimiento!.id;
    final path = await _apiService.getLocalLogo(id);
    final data = await _apiService.getLocalData(id);
    if (path != null) setState(() => _localPath = path);
    if (data != null) {
      setState(() {
        _nombreCtrl.text = data['nombre'] ?? _nombreCtrl.text;
        _nitCtrl.text = data['nit'] ?? _nitCtrl.text;
        _direccionCtrl.text = data['direccion'] ?? _direccionCtrl.text;
        _telefonoCtrl.text = data['telefono'] ?? _telefonoCtrl.text;
      });
    }
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    // ID de emergencia o ID real
    final int id = widget.establecimiento?.id ?? DateTime.now().millisecondsSinceEpoch;
    final data = {
      'nombre': _nombreCtrl.text,
      'nit': _nitCtrl.text,
      'direccion': _direccionCtrl.text,
      'telefono': _telefonoCtrl.text,
    };

    try {
      if (widget.establecimiento == null) {
        await _apiService.crearEstablecimiento(data);
      } else {
        await _apiService.actualizarEstablecimiento(id, data);
      }
    } catch (e) {
      debugPrint("Error de red: Persistiendo localmente...");
    } finally {
      // 1. Guardar Datos y Logo LOCALMENTE
      await _apiService.saveLocalData(id, data);
      if (_logoFile != null) {
        await _apiService.saveLocalLogo(id, _logoFile!.path);
      }
      
      // 2. Registrar ID para la lista híbrida si es nuevo
      if (widget.establecimiento == null) {
        await _apiService.registrarIdLocal(id);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Operación exitosa ✅'), backgroundColor: Colors.green)
        );
        context.pop(true); // Retornar true para refrescar
      }
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.establecimiento == null ? 'Nuevo Establecimiento' : 'Editar Detalles')),
      body: _isLoading ? const Center(child: CircularProgressIndicator()) : SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              GestureDetector(
                onTap: () async {
                  final img = await ImagePicker().pickImage(source: ImageSource.gallery);
                  if (img != null) setState(() => _logoFile = img);
                },
                child: CircleAvatar(
                  radius: 55,
                  backgroundColor: Colors.deepPurple.shade50,
                  backgroundImage: _logoFile != null 
                    ? FileImage(File(_logoFile!.path)) 
                    : (_localPath != null ? FileImage(File(_localPath!)) : null),
                  child: (_logoFile == null && _localPath == null) ? const Icon(Icons.add_a_photo, size: 30) : null,
                ),
              ),
              const SizedBox(height: 30),
              TextFormField(controller: _nombreCtrl, decoration: const InputDecoration(labelText: 'Nombre', border: OutlineInputBorder())),
              const SizedBox(height: 15),
              TextFormField(controller: _nitCtrl, decoration: const InputDecoration(labelText: 'NIT', border: OutlineInputBorder())),
              const SizedBox(height: 15),
              TextFormField(controller: _direccionCtrl, decoration: const InputDecoration(labelText: 'Dirección', border: OutlineInputBorder())),
              const SizedBox(height: 15),
              TextFormField(controller: _telefonoCtrl, decoration: const InputDecoration(labelText: 'Teléfono', border: OutlineInputBorder())),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity, height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple, foregroundColor: Colors.white),
                  onPressed: _guardar, 
                  child: const Text('GUARDAR ESTABLECIMIENTO', style: TextStyle(fontWeight: FontWeight.bold))
                )
              )
            ],
          ),
        ),
      ),
    );
  }
}