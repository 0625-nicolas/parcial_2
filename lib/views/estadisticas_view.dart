import 'package:flutter/foundation.dart'; // <-- Agrega esta línea
import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:parcial_2/services/api_service.dart';
import 'package:parcial_2/isolates/accidentes_isolate.dart';

class EstadisticasView extends StatefulWidget {
  const EstadisticasView({super.key});

  @override
  State<EstadisticasView> createState() => _EstadisticasViewState();
}

class _EstadisticasViewState extends State<EstadisticasView> {
  final ApiService _apiService = ApiService();
  
  bool _isLoading = true;
  String _error = '';
  Map<String, dynamic>? _estadisticas;

  @override
  void initState() {
    super.initState();
    _procesarDatos();
  }

  Future<void> _procesarDatos() async {
    try {
      // 1. Descargamos el JSON masivo en el hilo principal
      final jsonList = await _apiService.getAccidentesMasivos();
      
      // 2. MAGIA: Mandamos la lista a un Isolate (segundo plano) para que no se trabe la app
      // Esto imprimirá en consola lo que pide el profesor: "[Isolate] Iniciado..."
      final stats = await compute(AccidentesIsolate.procesarEstadisticas, jsonList);

      setState(() {
        _estadisticas = stats;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Estadísticas Tuluá')),
      body: _error.isNotEmpty
          ? Center(child: Text(_error, style: const TextStyle(color: Colors.red)))
          : Skeletonizer(
              enabled: _isLoading,
              child: _isLoading 
                  ? _buildSkeletonFake() // Muestra cuadros grises mientras procesa
                  : _buildGraficasReales(),
            ),
    );
  }

  // Interfaz falsa para el Skeletonizer
  Widget _buildSkeletonFake() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: List.generate(4, (index) => Card(
        margin: const EdgeInsets.only(bottom: 16),
        child: Container(height: 250, padding: const EdgeInsets.all(16), child: const Text('Cargando gráfica...')),
      )),
    );
  }

  // Interfaz real con los datos del Isolate
  Widget _buildGraficasReales() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildPieChartCard('Clase de Accidente', _estadisticas!['clase'] as Map<String, int>),
        _buildPieChartCard('Gravedad del Accidente', _estadisticas!['gravedad'] as Map<String, int>),
        _buildBarChartCard('Top 5 Barrios', _estadisticas!['top5Barrios'] as Map<String, int>),
        _buildBarChartCard('Día de la Semana', _estadisticas!['dias'] as Map<String, int>),
      ],
    );
  }

  // --- WIDGETS DE GRÁFICAS (fl_chart) ---

  Widget _buildPieChartCard(String titulo, Map<String, int> datos) {
    final List<Color> colores = [Colors.blue, Colors.red, Colors.green, Colors.orange, Colors.purple, Colors.teal];
    int colorIndex = 0;
    
    final pieSections = datos.entries.map((e) {
      final color = colores[colorIndex % colores.length];
      colorIndex++;
      return PieChartSectionData(
        value: e.value.toDouble(),
        title: '${e.value}', // Muestra el número dentro de la torta
        color: color,
        radius: 60,
        titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
      );
    }).toList();

    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 24),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(titulo, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: PieChart(PieChartData(sections: pieSections, centerSpaceRadius: 40)),
            ),
            // Leyendas
            Wrap(
              spacing: 8,
              children: datos.entries.map((e) {
                final color = colores[datos.keys.toList().indexOf(e.key) % colores.length];
                return Chip(
                  avatar: CircleAvatar(backgroundColor: color, radius: 8),
                  label: Text(e.key, style: const TextStyle(fontSize: 10)),
                );
              }).toList(),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildBarChartCard(String titulo, Map<String, int> datos) {
    final maxVal = datos.values.isEmpty ? 1 : datos.values.reduce((a, b) => a > b ? a : b).toDouble();
    
    final barGroups = datos.entries.toList().asMap().entries.map((entry) {
      return BarChartGroupData(
        x: entry.key,
        barRods: [
          BarChartRodData(
            toY: entry.value.value.toDouble(),
            color: Colors.deepPurple,
            width: 16,
            borderRadius: BorderRadius.circular(4),
          )
        ],
      );
    }).toList();

    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 24),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(titulo, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: maxVal * 1.2, // Darle un poco de aire arriba
                  barGroups: barGroups,
                  titlesData: FlTitlesData(
                    show: true,
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() >= datos.length) return const Text('');
                          // Solo muestra las primeras 3 letras del barrio/día para que no se amontone
                          final label = datos.keys.elementAt(value.toInt());
                          final shortLabel = label.length > 5 ? label.substring(0, 5) : label;
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(shortLabel, style: const TextStyle(fontSize: 10)),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}