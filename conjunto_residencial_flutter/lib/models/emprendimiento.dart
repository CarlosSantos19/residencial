class Emprendimiento {
  final int id;
  final String nombreNegocio;
  final String descripcion;
  final String categoria;
  final String contacto;
  final String? telefono;
  final String? whatsapp;
  final String? instagram;
  final String? correo;
  final int residenteId;
  final String residenteNombre;
  final String apartamento;
  final DateTime fechaRegistro;
  final List<Resena> resenas;
  final double calificacionPromedio;
  final int totalResenas;

  Emprendimiento({
    required this.id,
    required this.nombreNegocio,
    required this.descripcion,
    required this.categoria,
    required this.contacto,
    this.telefono,
    this.whatsapp,
    this.instagram,
    this.correo,
    required this.residenteId,
    required this.residenteNombre,
    required this.apartamento,
    required this.fechaRegistro,
    this.resenas = const [],
    this.calificacionPromedio = 0.0,
    this.totalResenas = 0,
  });

  factory Emprendimiento.fromJson(Map<String, dynamic> json) {
    return Emprendimiento(
      id: json['id'],
      nombreNegocio: json['nombreNegocio'] ?? json['nombre'] ?? '',
      descripcion: json['descripcion'] ?? '',
      categoria: json['categoria'] ?? '',
      contacto: json['contacto'] ?? '',
      telefono: json['telefono'],
      whatsapp: json['whatsapp'],
      instagram: json['instagram'],
      correo: json['correo'],
      residenteId: json['residenteId'] ?? 0,
      residenteNombre: json['residenteNombre'] ?? '',
      apartamento: json['apartamento'] ?? '',
      fechaRegistro: json['fechaRegistro'] != null
          ? DateTime.parse(json['fechaRegistro'])
          : DateTime.now(),
      resenas: json['resenas'] != null
          ? (json['resenas'] as List).map((r) => Resena.fromJson(r)).toList()
          : [],
      calificacionPromedio: (json['calificacionPromedio'] ?? 0.0).toDouble(),
      totalResenas: json['totalResenas'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombreNegocio': nombreNegocio,
      'descripcion': descripcion,
      'categoria': categoria,
      'contacto': contacto,
      'telefono': telefono,
      'whatsapp': whatsapp,
      'instagram': instagram,
      'correo': correo,
      'residenteId': residenteId,
      'residenteNombre': residenteNombre,
      'apartamento': apartamento,
      'fechaRegistro': fechaRegistro.toIso8601String(),
      'resenas': resenas.map((r) => r.toJson()).toList(),
      'calificacionPromedio': calificacionPromedio,
      'totalResenas': totalResenas,
    };
  }

  // Getters para compatibilidad con pantallas
  String get nombre => nombreNegocio;
  String get propietario => residenteNombre;
}

class Resena {
  final int id;
  final int emprendimientoId;
  final int usuarioId;
  final String usuarioNombre;
  final int calificacion;
  final String? comentario;
  final DateTime fecha;

  Resena({
    required this.id,
    required this.emprendimientoId,
    required this.usuarioId,
    required this.usuarioNombre,
    required this.calificacion,
    this.comentario,
    required this.fecha,
  });

  factory Resena.fromJson(Map<String, dynamic> json) {
    return Resena(
      id: json['id'],
      emprendimientoId: json['emprendimientoId'] ?? 0,
      usuarioId: json['usuarioId'] ?? 0,
      usuarioNombre: json['usuarioNombre'] ?? '',
      calificacion: json['calificacion'] ?? 0,
      comentario: json['comentario'],
      fecha: json['fecha'] != null
          ? DateTime.parse(json['fecha'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'emprendimientoId': emprendimientoId,
      'usuarioId': usuarioId,
      'usuarioNombre': usuarioNombre,
      'calificacion': calificacion,
      'comentario': comentario,
      'fecha': fecha.toIso8601String(),
    };
  }
}
