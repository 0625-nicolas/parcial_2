import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:parcial_2/services/api_service.dart';
import 'package:parcial_2/models/establecimiento_model.dart';

class EstablecimientosListView extends StatefulWidget {
  const EstablecimientosListView({super.key});

  @override
  State<EstablecimientosListView> createState() => _EstablecimientosListViewState();
}

class _EstablecimientosListViewState extends State<EstablecimientosListView> {
  final ApiService _apiService = ApiService();
  late Future<List<EstablecimientoModel>> _futureEstablecimientos;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  void _cargarDatos() {
    setState(() {
      _futureEstablecimientos = _apiService.getEstablecimientos();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(title: const Text('Establecimientos'), centerTitle: true),
      body: FutureBuilder<List<EstablecimientoModel>>(
        future: _futureEstablecimientos,
        builder: (context, snapshot) {
          final bool isLoading = snapshot.connectionState == ConnectionState.waiting;
          final items = isLoading ? [] : (snapshot.data ?? []);

          return Skeletonizer(
            enabled: isLoading,
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: isLoading ? 5 : items.length,
              itemBuilder: (context, index) {
                if (isLoading) return const Card(child: ListTile(title: Text('Cargando...')));
                
                final est = items[index];

                return FutureBuilder<Map<String, dynamic>?>(
                  future: _apiService.getLocalData(est.id),
                  builder: (context, dataSnap) {
                    final nombre = dataSnap.data?['nombre'] ?? est.nombre;
                    final direccion = dataSnap.data?['direccion'] ?? est.direccion;

                    return FutureBuilder<String?>(
                      future: _apiService.getLocalLogo(est.id),
                      builder: (context, logoSnap) {
                        return Card(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundImage: logoSnap.data != null ? FileImage(File(logoSnap.data!)) : null,
                              child: logoSnap.data == null ? const Icon(Icons.business) : null,
                            ),
                            title: Text(nombre, style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text(direccion),
                            trailing: const Icon(Icons.edit, size: 18),
                            onTap: () => context.push('/establecimientos/editar', extra: est).then((v) {
                              if (v == true) _cargarDatos();
                            }),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/establecimientos/crear').then((v) {
          if (v == true) _cargarDatos();
        }),
        label: const Text('Nuevo Local'),
        icon: const Icon(Icons.add),
      ),
    );
  }
}