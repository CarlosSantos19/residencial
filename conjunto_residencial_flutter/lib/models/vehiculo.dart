class VehiculoVisitante {
  final int id;
  final String placa;
  final String tipo;
  final String? modelo;
  final String? color;
  final String visitanteNombre;
  final String? visitanteCedula;
  final int apartamento;
  final DateTime fechaIngreso;
  final DateTime? fechaSalida;
  final int? costoParqueo;
  final String? reciboId;
  final String estado; // 'en_conjunto', 'retirado'
  final String vigilanteIngreso;
  final String? vigilanteSalida;

  VehiculoVisitante({
    required this.id,
    required this.placa,
    required this.tipo,
    this.modelo,
    this.color,
    required this.visitanteNombre,
    this.visitanteCedula,
    required this.apartamento,
    required this.fechaIngreso,
    this.fechaSalida,
    this.costoParqueo,
    this.reciboId,
    this.estado = 'en_conjunto',
    required this.vigilanteIngreso,
    this.vigilanteSalida,
  });

  factory VehiculoVisitante.fromJson(Map<String, dynamic> json) {
    return VehiculoVisitante(
      id: json['id'],
      placa: json['placa'] ?? '',
      tipo: json['tipo'] ?? 'automovil',
      modelo: json['modelo'],
      color: json['color'],
      visitanteNombre: json['visitanteNombre'] ?? json['visitante'] ?? '',
      visitanteCedula: json['visitanteCedula'] ?? json['cedula'],
      apartamento: json['apartamento'] is int
          ? json['apartamento']
          : int.tryParse(json['apartamento'].toString()) ?? 0,
      fechaIngreso: json['fechaIngreso'] != null
          ? DateTime.parse(json['fechaIngreso'])
          : DateTime.now(),
      fechaSalida: json['fechaSalida'] != null
          ? DateTime.parse(json['fechaSalida'])
          : null,
      costoParqueo: json['costoParqueo'],
      reciboId: json['reciboId'],
      estado: json['estado'] ?? 'en_conjunto',
      vigilanteIngreso: json['vigilanteIngreso'] ?? '',
      vigilanteSalida: json['vigilanteSalida'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'placa': placa,
      'tipo': tipo,
      'modelo': modelo,
      'color': color,
      'visitanteNombre': visitanteNombre,
      'visitanteCedula': visitanteCedula,
      'apartamento': apartamento,
      'fechaIngreso': fechaIngreso.toIso8601String(),
      'fechaSalida': fechaSalida?.toIso8601String(),
      'costoParqueo': costoParqueo,
      'reciboId': reciboId,
      'estado': estado,
      'vigilanteIngreso': vigilanteIngreso,
      'vigilanteSalida': vigilanteSalida,
    };
  }

  String get horasParqueado {
    final DateTime fin = fechaSalida ?? DateTime.now();
    final Duration diferencia = fin.difference(fechaIngreso);
    final int horas = diferencia.inHours;
    final int minutos = diferencia.inMinutes % 60;
    return '$horas h $minutos min';
  }

  // Getters para compatibilidad con pantallas
  String get horaIngreso => fechaIngreso.toIso8601String();
  String? get horaSalida => fechaSalida?.toIso8601String();
}

class ReciboParqueadero {
  final String id;
  final String placa;
  final DateTime fechaIngreso;
  final DateTime fechaSalida;
  final int horasTotal;
  final int minutosTotal;
  final int costo;
  final String detalleCalculo;
  final String vigilante;

  ReciboParqueadero({
    required this.id,
    required this.placa,
    required this.fechaIngreso,
    required this.fechaSalida,
    required this.horasTotal,
    required this.minutosTotal,
    required this.costo,
    required this.detalleCalculo,
    required this.vigilante,
  });

  factory ReciboParqueadero.fromJson(Map<String, dynamic> json) {
    return ReciboParqueadero(
      id: json['id'] ?? '',
      placa: json['placa'] ?? '',
      fechaIngreso: json['fechaIngreso'] != null
          ? DateTime.parse(json['fechaIngreso'])
          : DateTime.now(),
      fechaSalida: json['fechaSalida'] != null
          ? DateTime.parse(json['fechaSalida'])
          : DateTime.now(),
      horasTotal: json['horasTotal'] ?? 0,
      minutosTotal: json['minutosTotal'] ?? 0,
      costo: json['costo'] ?? 0,
      detalleCalculo: json['detalleCalculo'] ?? '',
      vigilante: json['vigilante'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'placa': placa,
      'fechaIngreso': fechaIngreso.toIso8601String(),
      'fechaSalida': fechaSalida.toIso8601String(),
      'horasTotal': horasTotal,
      'minutosTotal': minutosTotal,
      'costo': costo,
      'detalleCalculo': detalleCalculo,
      'vigilante': vigilante,
    };
  }

  // Getters para compatibilidad con pantallas
  double get monto => costo.toDouble();
  String get fecha => fechaSalida.toIso8601String();
  String get detalles => detalleCalculo;
}

class Parqueadero {
  final String numero;
  final int? residenteId;
  final String? residenteNombre;
  final String? apartamento;
  final bool asignado;
  final String? placa;
  final DateTime? fechaAsignacion;

  Parqueadero({
    required this.numero,
    this.residenteId,
    this.residenteNombre,
    this.apartamento,
    this.asignado = false,
    this.placa,
    this.fechaAsignacion,
  });

  factory Parqueadero.fromJson(Map<String, dynamic> json) {
    return Parqueadero(
      numero: json['numero'] ?? '',
      residenteId: json['residenteId'],
      residenteNombre: json['residenteNombre'],
      apartamento: json['apartamento'],
      asignado: json['asignado'] ?? false,
      placa: json['placa'],
      fechaAsignacion: json['fechaAsignacion'] != null
          ? DateTime.parse(json['fechaAsignacion'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'numero': numero,
      'residenteId': residenteId,
      'residenteNombre': residenteNombre,
      'apartamento': apartamento,
      'asignado': asignado,
      'placa': placa,
      'fechaAsignacion': fechaAsignacion?.toIso8601String(),
    };
  }

  // Getters para compatibilidad con pantallas
  String get ubicacion => numero;
  String get tipo => 'regular';
  bool get ocupado => asignado;
  String? get asignadoA => residenteNombre;
}
