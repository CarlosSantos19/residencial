class Documento {
  final int id;
  final String titulo;
  final String descripcion;
  final String tipo; // 'manual', 'acta', 'balance', 'reglamento', 'otro'
  final String? url;
  final String? archivo;
  final DateTime fechaPublicacion;
  final int publicadoPor;
  final String publicadoPorNombre;
  final int descargas;

  Documento({
    required this.id,
    required this.titulo,
    required this.descripcion,
    required this.tipo,
    this.url,
    this.archivo,
    required this.fechaPublicacion,
    required this.publicadoPor,
    required this.publicadoPorNombre,
    this.descargas = 0,
  });

  factory Documento.fromJson(Map<String, dynamic> json) {
    return Documento(
      id: json['id'],
      titulo: json['titulo'] ?? '',
      descripcion: json['descripcion'] ?? '',
      tipo: json['tipo'] ?? 'otro',
      url: json['url'],
      archivo: json['archivo'],
      fechaPublicacion: json['fechaPublicacion'] != null
          ? DateTime.parse(json['fechaPublicacion'])
          : DateTime.now(),
      publicadoPor: json['publicadoPor'] ?? 0,
      publicadoPorNombre: json['publicadoPorNombre'] ?? '',
      descargas: json['descargas'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titulo': titulo,
      'descripcion': descripcion,
      'tipo': tipo,
      'url': url,
      'archivo': archivo,
      'fechaPublicacion': fechaPublicacion.toIso8601String(),
      'publicadoPor': publicadoPor,
      'publicadoPorNombre': publicadoPorNombre,
      'descargas': descargas,
    };
  }

  String get tipoDisplay {
    switch (tipo) {
      case 'manual':
        return 'Manual de Convivencia';
      case 'acta':
        return 'Acta de Asamblea';
      case 'balance':
        return 'Balance Financiero';
      case 'reglamento':
        return 'Reglamento';
      default:
        return 'Otro Documento';
    }
  }

  // Getters para compatibilidad con pantallas
  String get nombre => titulo;
}
