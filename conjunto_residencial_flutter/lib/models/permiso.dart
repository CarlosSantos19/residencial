class Permiso {
  final int id;
  final int residenteId;
  final String residenteNombre;
  final String apartamento;
  final String nombreVisitante;
  final String? cedulaVisitante;
  final String? placaVehiculo;
  final DateTime fechaInicio;
  final DateTime fechaFin;
  final String tipo; // 'visitante', 'trabajador', 'otro'
  final String? observaciones;
  final String estado; // 'pendiente', 'autorizado', 'ingresado', 'finalizado', 'rechazado'
  final DateTime? fechaIngreso;
  final DateTime? fechaSalida;
  final String? vigilanteAutoriza;
  final String? vigilanteIngreso;
  final String? vigilanteSalida;

  Permiso({
    required this.id,
    required this.residenteId,
    required this.residenteNombre,
    required this.apartamento,
    required this.nombreVisitante,
    this.cedulaVisitante,
    this.placaVehiculo,
    required this.fechaInicio,
    required this.fechaFin,
    this.tipo = 'visitante',
    this.observaciones,
    this.estado = 'pendiente',
    this.fechaIngreso,
    this.fechaSalida,
    this.vigilanteAutoriza,
    this.vigilanteIngreso,
    this.vigilanteSalida,
  });

  factory Permiso.fromJson(Map<String, dynamic> json) {
    return Permiso(
      id: json['id'],
      residenteId: json['residenteId'] ?? 0,
      residenteNombre: json['residenteNombre'] ?? '',
      apartamento: json['apartamento'] ?? '',
      nombreVisitante: json['nombreVisitante'] ?? json['visitante'] ?? '',
      cedulaVisitante: json['cedulaVisitante'] ?? json['cedula'],
      placaVehiculo: json['placaVehiculo'] ?? json['placa'],
      fechaInicio: json['fechaInicio'] != null
          ? DateTime.parse(json['fechaInicio'])
          : DateTime.now(),
      fechaFin: json['fechaFin'] != null
          ? DateTime.parse(json['fechaFin'])
          : DateTime.now(),
      tipo: json['tipo'] ?? 'visitante',
      observaciones: json['observaciones'],
      estado: json['estado'] ?? 'pendiente',
      fechaIngreso: json['fechaIngreso'] != null
          ? DateTime.parse(json['fechaIngreso'])
          : null,
      fechaSalida: json['fechaSalida'] != null
          ? DateTime.parse(json['fechaSalida'])
          : null,
      vigilanteAutoriza: json['vigilanteAutoriza'],
      vigilanteIngreso: json['vigilanteIngreso'],
      vigilanteSalida: json['vigilanteSalida'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'residenteId': residenteId,
      'residenteNombre': residenteNombre,
      'apartamento': apartamento,
      'nombreVisitante': nombreVisitante,
      'cedulaVisitante': cedulaVisitante,
      'placaVehiculo': placaVehiculo,
      'fechaInicio': fechaInicio.toIso8601String(),
      'fechaFin': fechaFin.toIso8601String(),
      'tipo': tipo,
      'observaciones': observaciones,
      'estado': estado,
      'fechaIngreso': fechaIngreso?.toIso8601String(),
      'fechaSalida': fechaSalida?.toIso8601String(),
      'vigilanteAutoriza': vigilanteAutoriza,
      'vigilanteIngreso': vigilanteIngreso,
      'vigilanteSalida': vigilanteSalida,
    };
  }

  bool get estaVigente {
    final ahora = DateTime.now();
    return ahora.isAfter(fechaInicio) && ahora.isBefore(fechaFin);
  }

  // Getters para compatibilidad con pantallas
  String? get horaIngreso => fechaIngreso?.toIso8601String();
  String? get horaSalida => fechaSalida?.toIso8601String();
}
