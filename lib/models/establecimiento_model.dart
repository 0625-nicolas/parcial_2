class EstablecimientoModel {
  final int id;
  final String nombre;
  final String nit;
  final String direccion;
  final String telefono;
  final String? logoUrl;

  EstablecimientoModel({
    required this.id,
    required this.nombre,
    required this.nit,
    required this.direccion,
    required this.telefono,
    this.logoUrl,
  });

  factory EstablecimientoModel.fromJson(Map<String, dynamic> json) {
    return EstablecimientoModel(
      id: json['id'] ?? 0,
      nombre: json['nombre'] ?? '',
      nit: json['nit'] ?? '',
      direccion: json['direccion'] ?? '',
      telefono: json['telefono'] ?? '',
      logoUrl: json['logo'], 
    );
  }
}