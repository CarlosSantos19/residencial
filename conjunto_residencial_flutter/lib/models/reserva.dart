class Reserva {
  final int id;
  final String espacio;
  final String fecha;
  final String hora;
  final String usuario;

  Reserva({
    required this.id,
    required this.espacio,
    required this.fecha,
    required this.hora,
    required this.usuario,
  });

  factory Reserva.fromJson(Map<String, dynamic> json) {
    return Reserva(
      id: json['id'],
      espacio: json['espacio'],
      fecha: json['fecha'],
      hora: json['hora'],
      usuario: json['usuario'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'espacio': espacio,
      'fecha': fecha,
      'hora': hora,
      'usuario': usuario,
    };
  }

  DateTime get fechaDateTime {
    return DateTime.parse(fecha);
  }

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