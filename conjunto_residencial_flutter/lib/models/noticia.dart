class Noticia {
  final int id;
  final String titulo;
  final String contenido;
  final String categoria;
  final String? fechaEvento;
  final String? horaEvento;
  final String? lugar;
  final String prioridad;
  final String fechaPublicacion;
  final String publicadoPor;
  final bool destacada;

  Noticia({
    required this.id,
    required this.titulo,
    required this.contenido,
    required this.categoria,
    this.fechaEvento,
    this.horaEvento,
    this.lugar,
    required this.prioridad,
    required this.fechaPublicacion,
    required this.publicadoPor,
    this.destacada = false,
  });

  factory Noticia.fromJson(Map<String, dynamic> json) {
    return Noticia(
      id: json['id'],
      titulo: json['titulo'],
      contenido: json['contenido'],
      categoria: json['categoria'],
      fechaEvento: json['fechaEvento'],
      horaEvento: json['horaEvento'],
      lugar: json['lugar'],
      prioridad: json['prioridad'] ?? 'media',
      fechaPublicacion: json['fechaPublicacion'],
      publicadoPor: json['publicadoPor'],
      destacada: json['destacada'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titulo': titulo,
      'contenido': contenido,
      'categoria': categoria,
      'fechaEvento': fechaEvento,
      'horaEvento': horaEvento,
      'lugar': lugar,
      'prioridad': prioridad,
      'fechaPublicacion': fechaPublicacion,
      'publicadoPor': publicadoPor,
      'destacada': destacada,
    };
  }

  DateTime get fecha {
    return DateTime.parse(fechaPublicacion);
  }
}
