class AccidenteModel {
  final String claseAccidente;
  final String gravedad;
  final String barrio;
  final String dia;

  AccidenteModel({
    required this.claseAccidente,
    required this.gravedad,
    required this.barrio,
    required this.dia,
  });

  factory AccidenteModel.fromJson(Map<String, dynamic> json) {
    return AccidenteModel(
      claseAccidente: json['clase_de_accidente']?.toString().trim() ?? 'Desconocido',
      gravedad: json['gravedad_del_accidente']?.toString().trim() ?? 'Desconocida',
      barrio: json['barrio_hecho']?.toString().trim() ?? 'Desconocido',
      dia: json['dia']?.toString().trim() ?? 'Desconocido',
    );
  }
}