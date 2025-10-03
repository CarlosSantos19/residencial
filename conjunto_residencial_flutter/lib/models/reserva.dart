class Reserva {
  final int id;
  final String espacio;
  final String fecha;
  final String hora;
  final String usuario;
  final String estado;
  final int? usuarioId; // ID del usuario que reservó
  final String? imagenEspacio; // URL de imagen del espacio
  final String? descripcionEspacio; // Descripción del espacio
  final int? capacidadMaxima; // Capacidad máxima de personas
  final bool? cancelable; // Si se puede cancelar

  Reserva({
    required this.id,
    required this.espacio,
    required this.fecha,
    required this.hora,
    required this.usuario,
    this.estado = 'confirmada',
    this.usuarioId,
    this.imagenEspacio,
    this.descripcionEspacio,
    this.capacidadMaxima,
    this.cancelable = true,
  });

  factory Reserva.fromJson(Map<String, dynamic> json) {
    return Reserva(
      id: json['id'],
      espacio: json['espacio'],
      fecha: json['fecha'],
      hora: json['hora'],
      usuario: json['usuario'],
      estado: json['estado'] ?? 'confirmada',
      usuarioId: json['usuarioId'],
      imagenEspacio: json['imagenEspacio'],
      descripcionEspacio: json['descripcionEspacio'],
      capacidadMaxima: json['capacidadMaxima'],
      cancelable: json['cancelable'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'espacio': espacio,
      'fecha': fecha,
      'hora': hora,
      'usuario': usuario,
      'estado': estado,
      'usuarioId': usuarioId,
      'imagenEspacio': imagenEspacio,
      'descripcionEspacio': descripcionEspacio,
      'capacidadMaxima': capacidadMaxima,
      'cancelable': cancelable,
    };
  }

  DateTime get fechaDateTime {
    return DateTime.parse(fecha);
  }

  // Alias para compatibilidad
  DateTime get fechaDate => fechaDateTime;

  bool get isToday {
    final now = DateTime.now();
    final reservaDate = fechaDateTime;
    return now.year == reservaDate.year &&
        now.month == reservaDate.month &&
        now.day == reservaDate.day;
  }

  bool get isPast {
    return fechaDateTime.isBefore(DateTime.now());
  }
}

enum EspacioType {
  salonComunal('Salón Comunal', '🏛️'),
  gimnasio('Gimnasio', '💪'),
  bbq('Zona BBQ', '🔥'),
  piscina('Piscina', '🏊'),
  cancha('Cancha Múltiple', '⚽');

  const EspacioType(this.nombre, this.emoji);
  final String nombre;
  final String emoji;
}