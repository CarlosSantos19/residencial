class PQRS {
  final int id;
  final String tipo;
  final String asunto;
  final String descripcion;
  final String estado;
  final String fecha;
  final String usuarioId;
  final String? respuesta;
  final String? fechaRespuesta;

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
    };
  }
}
