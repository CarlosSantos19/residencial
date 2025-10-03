class PQRS {
  final int id;
  final String tipo; // 'Petición', 'Queja', 'Reclamo', 'Sugerencia'
  final String asunto;
  final String descripcion;
  final String estado; // 'Pendiente', 'En proceso', 'Resuelto', 'Rechazado'
  final String fecha;
  final String usuarioId;
  final String? respuesta;
  final String? fechaRespuesta;
  final List<String>? adjuntos; // URLs de imágenes/archivos adjuntos
  final List<ComentarioPQRS>? comentarios; // Seguimiento y actualizaciones

  PQRS({
    required this.id,
    required this.tipo,
    required this.asunto,
    required this.descripcion,
    required this.estado,
    required this.fecha,
    required this.usuarioId,
    this.respuesta,
    this.fechaRespuesta,
    this.adjuntos,
    this.comentarios,
  });

  factory PQRS.fromJson(Map<String, dynamic> json) {
    return PQRS(
      id: json['id'],
      tipo: json['tipo'],
      asunto: json['asunto'],
      descripcion: json['descripcion'],
      estado: json['estado'],
      fecha: json['fecha'],
      usuarioId: json['usuarioId'].toString(),
      respuesta: json['respuesta'],
      fechaRespuesta: json['fechaRespuesta'],
      adjuntos: json['adjuntos'] != null
          ? List<String>.from(json['adjuntos'])
          : null,
      comentarios: json['comentarios'] != null
          ? (json['comentarios'] as List)
              .map((c) => ComentarioPQRS.fromJson(c))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tipo': tipo,
      'asunto': asunto,
      'descripcion': descripcion,
      'estado': estado,
      'fecha': fecha,
      'usuarioId': usuarioId,
      'respuesta': respuesta,
      'fechaRespuesta': fechaRespuesta,
      'adjuntos': adjuntos,
      'comentarios': comentarios?.map((c) => c.toJson()).toList(),
    };
  }
}

/// Comentario de seguimiento para PQRS
class ComentarioPQRS {
  final int id;
  final int pqrsId;
  final String autorNombre;
  final String autorRol; // 'residente', 'admin'
  final String comentario;
  final DateTime fecha;
  final bool esRespuestaOficial; // true si es respuesta del admin

  ComentarioPQRS({
    required this.id,
    required this.pqrsId,
    required this.autorNombre,
    required this.autorRol,
    required this.comentario,
    required this.fecha,
    this.esRespuestaOficial = false,
  });

  factory ComentarioPQRS.fromJson(Map<String, dynamic> json) {
    return ComentarioPQRS(
      id: json['id'],
      pqrsId: json['pqrsId'],
      autorNombre: json['autorNombre'],
      autorRol: json['autorRol'],
      comentario: json['comentario'],
      fecha: DateTime.parse(json['fecha']),
      esRespuestaOficial: json['esRespuestaOficial'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'pqrsId': pqrsId,
      'autorNombre': autorNombre,
      'autorRol': autorRol,
      'comentario': comentario,
      'fecha': fecha.toIso8601String(),
      'esRespuestaOficial': esRespuestaOficial,
    };
  }
}
