import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:parcial_2/models/establecimiento_model.dart';

class ApiService {
  final Dio _dio = Dio();

  String get _parqueaderoUrl => dotenv.env['API_PARQUEADERO_URL'] ?? '';
  String get _accidentesUrl => dotenv.env['API_ACCIDENTES_URL'] ?? '';

  Future<List<dynamic>> getAccidentesMasivos() async {
    try {
      final response = await _dio.get('$_accidentesUrl?\$limit=100000');
      return response.data is List ? response.data as List<dynamic> : [];
    } catch (e) { return []; }
  }

  Future<List<EstablecimientoModel>> getEstablecimientos() async {
    List<EstablecimientoModel> listaFinal = [];
    try {
      final response = await _dio.get('$_parqueaderoUrl/establecimientos');
      List<dynamic> jsonList = response.data is List ? response.data : response.data['data'] ?? [];
      listaFinal = jsonList.map((item) => EstablecimientoModel.fromJson(item)).toList();
    } catch (e) { debugPrint("Error de red en lista."); }

    final prefs = await SharedPreferences.getInstance();
    List<String> localIds = prefs.getStringList('mis_creaciones_locales') ?? [];

    for (String idStr in localIds) {
      int idLocal = int.parse(idStr);
      final dataStr = prefs.getString('data_$idLocal');
      if (dataStr != null) {
        final map = jsonDecode(dataStr);
        String nitLocal = map['nit'] ?? '';
        var indexServer = listaFinal.indexWhere((est) => est.nit == nitLocal);
        
        if (indexServer != -1) {
          String? logoPath = prefs.getString('logo_$idLocal');
          if (logoPath != null) await saveLocalLogo(listaFinal[indexServer].id, logoPath);
          await saveLocalData(listaFinal[indexServer].id, map);
        } else {
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

  Future<void> registrarIdLocal(int id) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> ids = prefs.getStringList('mis_creaciones_locales') ?? [];
    if (!ids.contains(id.toString())) {
      ids.add(id.toString());
      await prefs.setStringList('mis_creaciones_locales', ids);
    }
  }

  Future<void> saveLocalData(int id, Map<String, dynamic> data) async => (await SharedPreferences.getInstance()).setString('data_$id', jsonEncode(data));
  Future<Map<String, dynamic>?> getLocalData(int id) async {
    final raw = (await SharedPreferences.getInstance()).getString('data_$id');
    return raw != null ? jsonDecode(raw) : null;
  }
  Future<void> saveLocalLogo(int id, String path) async => (await SharedPreferences.getInstance()).setString('logo_$id', path);
  Future<String?> getLocalLogo(int id) async => (await SharedPreferences.getInstance()).getString('logo_$id');

  Future<void> crearEstablecimiento(Map<String, dynamic> data) async => await _dio.post('$_parqueaderoUrl/establecimientos', data: FormData.fromMap(data));
  Future<void> actualizarEstablecimiento(int id, Map<String, dynamic> data) async {
    data['_method'] = 'PUT';
    await _dio.post('$_parqueaderoUrl/establecimiento-update/$id', data: FormData.fromMap(data));
  }

  // ELIMINACIÓN BLINDADA
  Future<void> eliminarEstablecimiento(int id) async {
    try {
      // Timeout corto para que no se quede cargando si el server no responde
      await _dio.delete('$_parqueaderoUrl/establecimientos/$id').timeout(const Duration(seconds: 5));
    } catch (e) {
      debugPrint("Eliminación en server falló o tomó mucho tiempo, procediendo local.");
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('data_$id');
    await prefs.remove('logo_$id');
    List<String> localIds = prefs.getStringList('mis_creaciones_locales') ?? [];
    localIds.remove(id.toString());
    await prefs.setStringList('mis_creaciones_locales', localIds);
  }
}