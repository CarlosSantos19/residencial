class Arriendo {
  final int id;
  final String tipo; // 'apartamento', 'parqueadero'
  final String numero; // Número de apartamento o parqueadero
  final int propietarioId;
  final String propietarioNombre;
  final String? propietarioContacto;
  final double precio;
  final String descripcion;
  final bool disponible;
  final DateTime fechaPublicacion;
  final List<String>? fotos;
  final Map<String, dynamic>? caracteristicas;

  Arriendo({
    required this.id,
    required this.tipo,
    required this.numero,
    required this.propietarioId,
    required this.propietarioNombre,
    this.propietarioContacto,
    required this.precio,
    required this.descripcion,
    this.disponible = true,
    required this.fechaPublicacion,
    this.fotos,
    this.caracteristicas,
  });

  factory Arriendo.fromJson(Map<String, dynamic> json) {
    return Arriendo(
      id: json['id'],
      tipo: json['tipo'] ?? 'apartamento',
      numero: json['numero'] ?? json['numeroParqueadero'] ?? '',
      propietarioId: json['propietarioId'] ?? 0,
      propietarioNombre: json['propietarioNombre'] ?? json['propietario'] ?? '',
      propietarioContacto: json['propietarioContacto'] ?? json['contacto'],
      precio: (json['precio'] ?? 0.0).toDouble(),
      descripcion: json['descripcion'] ?? '',
      disponible: json['disponible'] ?? true,
      fechaPublicacion: json['fechaPublicacion'] != null
          ? DateTime.parse(json['fechaPublicacion'])
          : DateTime.now(),
      fotos: json['fotos'] != null ? List<String>.from(json['fotos']) : null,
      caracteristicas: json['caracteristicas'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tipo': tipo,
      'numero': numero,
      'propietarioId': propietarioId,
      'propietarioNombre': propietarioNombre,
      'propietarioContacto': propietarioContacto,
      'precio': precio,
      'descripcion': descripcion,
      'disponible': disponible,
      'fechaPublicacion': fechaPublicacion.toIso8601String(),
      'fotos': fotos,
      'caracteristicas': caracteristicas,
    };
  }

  String get tipoDisplay {
    return tipo == 'apartamento' ? 'Apartamento' : 'Parqueadero';
  }

  // Getters para compatibilidad con pantallas
  String get apartamento => numero;
  int? get habitaciones => caracteristicas?['habitaciones'];
  int? get banos => caracteristicas?['banos'];
  bool? get parqueadero => caracteristicas?['parqueadero'];
  String get propietario => propietarioNombre;
  String? get contacto => propietarioContacto;
}
