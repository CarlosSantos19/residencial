class Paquete {
  final int id;
  final String destinatario;
  final String apartamento;
  final String descripcion;
  final String? empresa;
  final String? guia;
  final DateTime fechaLlegada;
  final DateTime? fechaEntrega;
  final String estado; // 'en_porteria', 'entregado'
  final String vigilanteRecibe;
  final String? residenteRecibe;
  final bool notificado;

  Paquete({
    required this.id,
    required this.destinatario,
    required this.apartamento,
    required this.descripcion,
    this.empresa,
    this.guia,
    required this.fechaLlegada,
    this.fechaEntrega,
    this.estado = 'en_porteria',
    required this.vigilanteRecibe,
    this.residenteRecibe,
    this.notificado = false,
  });

  factory Paquete.fromJson(Map<String, dynamic> json) {
    return Paquete(
      id: json['id'],
      destinatario: json['destinatario'] ?? '',
      apartamento: json['apartamento'] ?? '',
      descripcion: json['descripcion'] ?? '',
      empresa: json['empresa'],
      guia: json['guia'],
      fechaLlegada: json['fechaLlegada'] != null
          ? DateTime.parse(json['fechaLlegada'])
          : DateTime.now(),
      fechaEntrega: json['fechaEntrega'] != null
          ? DateTime.parse(json['fechaEntrega'])
          : null,
      estado: json['estado'] ?? 'en_porteria',
      vigilanteRecibe: json['vigilanteRecibe'] ?? '',
      residenteRecibe: json['residenteRecibe'],
      notificado: json['notificado'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'destinatario': destinatario,
      'apartamento': apartamento,
      'descripcion': descripcion,
      'empresa': empresa,
      'guia': guia,
      'fechaLlegada': fechaLlegada.toIso8601String(),
      'fechaEntrega': fechaEntrega?.toIso8601String(),
      'estado': estado,
      'vigilanteRecibe': vigilanteRecibe,
      'residenteRecibe': residenteRecibe,
      'notificado': notificado,
    };
  }

  // Getters para compatibilidad con pantallas
  bool get retirado => estado == 'entregado';
  DateTime get fechaRecepcion => fechaLlegada;
}
