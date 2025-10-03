class AsignacionParqueadero {
  final String torre;
  final String apartamento;
  final String nombreResidente;
  final int numeroParqueadero;
  final int? usuarioId; // Opcional para la API

  AsignacionParqueadero({
    required this.torre,
    required this.apartamento,
    required this.nombreResidente,
    required this.numeroParqueadero,
    this.usuarioId,
  });

  factory AsignacionParqueadero.fromJson(Map<String, dynamic> json) {
    return AsignacionParqueadero(
      torre: json['torre'] as String,
      apartamento: json['apartamento'] as String,
      nombreResidente: json['nombreResidente'] as String,
      numeroParqueadero: json['numeroParqueadero'] as int,
      usuarioId: json['usuarioId'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'torre': torre,
      'apartamento': apartamento,
      'nombreResidente': nombreResidente,
      'numeroParqueadero': numeroParqueadero,
      if (usuarioId != null) 'usuarioId': usuarioId,
    };
  }
}
