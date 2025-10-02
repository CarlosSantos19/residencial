class Encuesta {
  final int id;
  final String pregunta;
  final List<OpcionEncuesta> opciones;
  final DateTime fechaCreacion;
  final DateTime? fechaCierre;
  final bool activa;
  final int creadoPor;
  final String creadoPorNombre;
  final int totalVotos;
  final List<int> usuariosVotaron;

  Encuesta({
    required this.id,
    required this.pregunta,
    required this.opciones,
    required this.fechaCreacion,
    this.fechaCierre,
    this.activa = true,
    required this.creadoPor,
    required this.creadoPorNombre,
    this.totalVotos = 0,
    this.usuariosVotaron = const [],
  });

  factory Encuesta.fromJson(Map<String, dynamic> json) {
    return Encuesta(
      id: json['id'],
      pregunta: json['pregunta'] ?? '',
      opciones: json['opciones'] != null
          ? (json['opciones'] as List)
              .map((o) => OpcionEncuesta.fromJson(o))
              .toList()
          : [],
      fechaCreacion: json['fechaCreacion'] != null
          ? DateTime.parse(json['fechaCreacion'])
          : DateTime.now(),
      fechaCierre: json['fechaCierre'] != null
          ? DateTime.parse(json['fechaCierre'])
          : null,
      activa: json['activa'] ?? true,
      creadoPor: json['creadoPor'] ?? 0,
      creadoPorNombre: json['creadoPorNombre'] ?? '',
      totalVotos: json['totalVotos'] ?? 0,
      usuariosVotaron: json['usuariosVotaron'] != null
          ? List<int>.from(json['usuariosVotaron'])
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'pregunta': pregunta,
      'opciones': opciones.map((o) => o.toJson()).toList(),
      'fechaCreacion': fechaCreacion.toIso8601String(),
      'fechaCierre': fechaCierre?.toIso8601String(),
      'activa': activa,
      'creadoPor': creadoPor,
      'creadoPorNombre': creadoPorNombre,
      'totalVotos': totalVotos,
      'usuariosVotaron': usuariosVotaron,
    };
  }

  bool haVotado(int usuarioId) {
    return usuariosVotaron.contains(usuarioId);
  }

  // Getters para compatibilidad con pantallas
  List<int> get votos => opciones.map((o) => o.votos).toList();
  bool get cerrada => !activa;
  List<int> get votantes => usuariosVotaron;
}

class OpcionEncuesta {
  final String texto;
  final int votos;

  OpcionEncuesta({
    required this.texto,
    this.votos = 0,
  });

  factory OpcionEncuesta.fromJson(Map<String, dynamic> json) {
    return OpcionEncuesta(
      texto: json['texto'] ?? json['opcion'] ?? '',
      votos: json['votos'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'texto': texto,
      'votos': votos,
    };
  }

  double porcentaje(int totalVotos) {
    if (totalVotos == 0) return 0.0;
    return (votos / totalVotos) * 100;
  }
}
