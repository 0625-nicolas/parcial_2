import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:parcial_2/services/api_service.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  final ApiService _apiService = ApiService();
  int _totalAccidentes = 0;
  int _totalEstablecimientos = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _cargarTotales();
  }

  Future<void> _cargarTotales() async {
    try {
      // LLAMADA CORRECTA CON PARÉNTESIS ()
      final resultados = await Future.wait([
        _apiService.getAccidentesMasivos(),
        _apiService.getEstablecimientos(),
      ]);

      if (mounted) {
        setState(() {
          _totalAccidentes = (resultados[0] as List).length;
          _totalEstablecimientos = (resultados[1] as List).length;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard Parcial')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Card(
              child: ListTile(
                leading: const Icon(Icons.warning, color: Colors.orange),
                title: const Text('Accidentes Tuluá'),
                subtitle: Text(_isLoading ? 'Cargando...' : '$_totalAccidentes registros'),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => context.push('/estadisticas'),
              child: const Text('Ver Estadísticas (Isolate)'),
            ),
            ElevatedButton(
              onPressed: () => context.push('/establecimientos'),
              child: const Text('Gestión Establecimientos'),
            ),
          ],
        ),
      ),
    );
  }
}