import 'package:parcial_2/models/accidente_model.dart';

class AccidentesIsolate {
  // Esta es la función que correrá en el hilo secundario
  static Map<String, dynamic> procesarEstadisticas(List<dynamic> jsonList) {
    final startTime = DateTime.now();
    print("[Isolate] Iniciado — ${jsonList.length} registros recibidos");

    // 1. Convertir JSON a Modelos
    final accidentes = jsonList.map((e) => AccidenteModel.fromJson(e)).toList();

    // Contadores para las estadísticas
    final Map<String, int> claseCount = {};
    final Map<String, int> gravedadCount = {};
    final Map<String, int> barrioCount = {};
    final Map<String, int> diaCount = {};

    // 2. Procesamiento masivo
    for (var acc in accidentes) {
      // Clase
      claseCount[acc.claseAccidente] = (claseCount[acc.claseAccidente] ?? 0) + 1;
      // Gravedad
      gravedadCount[acc.gravedad] = (gravedadCount[acc.gravedad] ?? 0) + 1;
      // Barrio
      if (acc.barrio.isNotEmpty && acc.barrio != 'Desconocido') {
        barrioCount[acc.barrio] = (barrioCount[acc.barrio] ?? 0) + 1;
      }
      // Día
      diaCount[acc.dia] = (diaCount[acc.dia] ?? 0) + 1;
    }

    // 3. Ordenar el Top 5 de barrios
    var barriosOrdenados = barrioCount.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final top5Barrios = Map.fromEntries(barriosOrdenados.take(5));

    final endTime = DateTime.now();
    print("[Isolate] Completado en ${endTime.difference(startTime).inMilliseconds} ms");

    // 4. Retornar el mapa consolidado
    return {
      'total': accidentes.length,
      'clase': claseCount,
      'gravedad': gravedadCount,
      'top5Barrios': top5Barrios,
      'dias': diaCount,
    };
  }
}