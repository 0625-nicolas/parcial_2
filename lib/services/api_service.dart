import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:parcial_2/models/establecimiento_model.dart';

class ApiService {
  final Dio _dio = Dio();

  String get _parqueaderoUrl => dotenv.env['API_PARQUEADERO_URL'] ?? '';
  String get _accidentesUrl => dotenv.env['API_ACCIDENTES_URL'] ?? '';

  // --- ACCIDENTES ---
  Future<List<dynamic>> getAccidentesMasivos() async {
    try {
      final response = await _dio.get('$_accidentesUrl?\$limit=100000');
      return response.data is List ? response.data as List<dynamic> : [];
    } catch (e) {
      return [];
    }
  }

  // --- LISTA HÍBRIDA (ELIMINA DUPLICADOS POR NIT) ---
  Future<List<EstablecimientoModel>> getEstablecimientos() async {
    List<EstablecimientoModel> listaFinal = [];
    
    // 1. Intentar traer datos del servidor
    try {
      final response = await _dio.get('$_parqueaderoUrl/establecimientos');
      List<dynamic> jsonList = response.data is List ? response.data : response.data['data'] ?? [];
      listaFinal = jsonList.map((item) => EstablecimientoModel.fromJson(item)).toList();
    } catch (e) {
      print("Servidor en mantenimiento o error de red.");
    }

    // 2. Cargar registros locales y fusionar
    final prefs = await SharedPreferences.getInstance();
    List<String> localIds = prefs.getStringList('mis_creaciones_locales') ?? [];

    for (String idStr in localIds) {
      int idLocal = int.parse(idStr);
      final dataStr = prefs.getString('data_$idLocal');
      
      if (dataStr != null) {
        final map = jsonDecode(dataStr);
        String nitLocal = map['nit'] ?? '';

        // Buscamos si ya existe ese NIT en la lista que trajo el servidor
        var indexServer = listaFinal.indexWhere((est) => est.nit == nitLocal);
        
        if (indexServer != -1) {
          // SI EXISTE DUPLICADO: Le pasamos el logo del ID local al ID del servidor
          String? logoPath = prefs.getString('logo_$idLocal');
          if (logoPath != null) {
            await saveLocalLogo(listaFinal[indexServer].id, logoPath);
          }
          // También guardamos los datos bajo el ID del servidor por si acaso
          await saveLocalData(listaFinal[indexServer].id, map);
        } else {
          // NO EXISTE EN SERVER: Lo agregamos como registro puramente local
          listaFinal.add(EstablecimientoModel(
            id: idLocal,
            nombre: map['nombre'] ?? '',
            nit: nitLocal,
            direccion: map['direccion'] ?? '',
            telefono: map['telefono'] ?? '',
          ));
        }
      }
    }
    return listaFinal;
  }

  // --- PERSISTENCIA LOCAL ---
  Future<void> registrarIdLocal(int id) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> ids = prefs.getStringList('mis_creaciones_locales') ?? [];
    if (!ids.contains(id.toString())) {
      ids.add(id.toString());
      await prefs.setStringList('mis_creaciones_locales', ids);
    }
  }

  Future<void> saveLocalData(int id, Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('data_$id', jsonEncode(data));
  }

  Future<Map<String, dynamic>?> getLocalData(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final String? raw = prefs.getString('data_$id');
    return raw != null ? jsonDecode(raw) : null;
  }

  Future<void> saveLocalLogo(int id, String path) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('logo_$id', path);
  }

  Future<String?> getLocalLogo(int id) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('logo_$id');
  }

  // --- MÉTODOS DE RED ---
  Future<void> crearEstablecimiento(Map<String, dynamic> data) async {
    await _dio.post('$_parqueaderoUrl/establecimientos', data: FormData.fromMap(data));
  }

  Future<void> actualizarEstablecimiento(int id, Map<String, dynamic> data) async {
    data['_method'] = 'PUT';
    await _dio.post('$_parqueaderoUrl/establecimiento-update/$id', data: FormData.fromMap(data));
  }
}