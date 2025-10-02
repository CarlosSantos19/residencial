class IncidenteAlcaldia {
  final int id;
  final String tipo; // 'ruido', 'basura', 'seguridad', 'construccion', 'otro'
  final String descripcion;
  final String? ubicacion;
  final int reportadoPor;
  final String reportadoPorNombre;
  final DateTime fechaReporte;
  final String estado; // 'pendiente', 'en_revision', 'resuelto', 'rechazado'
  final String? respuesta;
  final DateTime? fechaRespuesta;
  final int? respondidoPor;
  final String? respondidoPorNombre;
  final String prioridad; // 'baja', 'media', 'alta', 'urgente'
  final List<String>? fotos;

  IncidenteAlcaldia({
    required this.id,
    required this.tipo,
    required this.descripcion,
    this.ubicacion,
    required this.reportadoPor,
    required this.reportadoPorNombre,
    required this.fechaReporte,
    this.estado = 'pendiente',
    this.respuesta,
    this.fechaRespuesta,
    this.respondidoPor,
    this.respondidoPorNombre,
    this.prioridad = 'media',
    this.fotos,
  });

  factory IncidenteAlcaldia.fromJson(Map<String, dynamic> json) {
    return IncidenteAlcaldia(
      id: json['id'],
      tipo: json['tipo'] ?? 'otro',
      descripcion: json['descripcion'] ?? '',
      ubicacion: json['ubicacion'],
      reportadoPor: json['reportadoPor'] ?? 0,
      reportadoPorNombre: json['reportadoPorNombre'] ?? '',
      fechaReporte: json['fechaReporte'] != null
          ? DateTime.parse(json['fechaReporte'])
          : DateTime.now(),
      estado: json['estado'] ?? 'pendiente',
      respuesta: json['respuesta'],
      fechaRespuesta: json['fechaRespuesta'] != null
          ? DateTime.parse(json['fechaRespuesta'])
          : null,
      respondidoPor: json['respondidoPor'],
      respondidoPorNombre: json['respondidoPorNombre'],
      prioridad: json['prioridad'] ?? 'media',
      fotos: json['fotos'] != null ? List<String>.from(json['fotos']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tipo': tipo,
      'descripcion': descripcion,
      'ubicacion': ubicacion,
      'reportadoPor': reportadoPor,
      'reportadoPorNombre': reportadoPorNombre,
      'fechaReporte': fechaReporte.toIso8601String(),
      'estado': estado,
      'respuesta': respuesta,
      'fechaRespuesta': fechaRespuesta?.toIso8601String(),
      'respondidoPor': respondidoPor,
      'respondidoPorNombre': respondidoPorNombre,
      'prioridad': prioridad,
      'fotos': fotos,
    };
  }

  String get tipoDisplay {
    switch (tipo) {
      case 'ruido':
        return 'Ruido Excesivo';
      case 'basura':
        return 'Manejo de Basuras';
      case 'seguridad':
        return 'Seguridad';
      case 'construccion':
        return 'Construcción';
      default:
        return 'Otro';
    }
  }

  String get estadoDisplay {
    switch (estado) {
      case 'pendiente':
        return 'Pendiente';
      case 'en_revision':
        return 'En Revisión';
      case 'resuelto':
        return 'Resuelto';
      case 'rechazado':
        return 'Rechazado';
      default:
        return estado;
    }
  }
}
