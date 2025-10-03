class Resena {
  final int id;
  final int emprendimientoId;
  final int usuarioId;
  final String nombreUsuario;
  final int calificacion; // 1-5 estrellas
  final String comentario;
  final DateTime fecha;

  Resena({
    required this.id,
    required this.emprendimientoId,
    required this.usuarioId,
    required this.nombreUsuario,
    required this.calificacion,
    required this.comentario,
    required this.fecha,
  });

  factory Resena.fromJson(Map<String, dynamic> json) {
    return Resena(
      id: json['id'],
      emprendimientoId: json['emprendimientoId'],
      usuarioId: json['usuarioId'],
      nombreUsuario: json['nombreUsuario'],
      calificacion: json['calificacion'],
      comentario: json['comentario'],
      fecha: DateTime.parse(json['fecha']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'emprendimientoId': emprendimientoId,
      'usuarioId': usuarioId,
      'nombreUsuario': nombreUsuario,
      'calificacion': calificacion,
      'comentario': comentario,
      'fecha': fecha.toIso8601String(),
    };
  }
}
