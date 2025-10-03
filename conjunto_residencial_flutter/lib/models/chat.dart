enum TipoChat {
  general,
  admin,
  vigilantes,
  privado;

  String get displayName {
    switch (this) {
      case TipoChat.general:
        return 'Chat General';
      case TipoChat.admin:
        return 'Chat Administradores';
      case TipoChat.vigilantes:
        return 'Chat Vigilantes';
      case TipoChat.privado:
        return 'Chat Privado';
    }
  }
}

class Mensaje {
  final int id;
  final int usuarioId;
  final String usuarioNombre;
  final String? usuarioRol;
  final String mensaje;
  final DateTime fecha;
  final String? tipo; // Para saber a qué chat pertenece
  final int? destinatarioId; // Para chats privados

  Mensaje({
    required this.id,
    required this.usuarioId,
    required this.usuarioNombre,
    this.usuarioRol,
    required this.mensaje,
    required this.fecha,
    this.tipo,
    this.destinatarioId,
  });

  factory Mensaje.fromJson(Map<String, dynamic> json) {
    return Mensaje(
      id: json['id'],
      usuarioId: json['usuarioId'] ?? json['autor'] ?? 0,
      usuarioNombre: json['usuarioNombre'] ?? json['nombreAutor'] ?? '',
      usuarioRol: json['usuarioRol'] ?? json['rol'],
      mensaje: json['mensaje'] ?? json['texto'] ?? '',
      fecha: json['fecha'] != null
          ? DateTime.parse(json['fecha'])
          : DateTime.now(),
      tipo: json['tipo'],
      destinatarioId: json['destinatarioId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'usuarioId': usuarioId,
      'usuarioNombre': usuarioNombre,
      'usuarioRol': usuarioRol,
      'mensaje': mensaje,
      'fecha': fecha.toIso8601String(),
      'tipo': tipo,
      'destinatarioId': destinatarioId,
    };
  }

  // Alias para compatibilidad
  String get nombreUsuario => usuarioNombre;
}

class ChatPrivado {
  final int usuarioId;
  final String usuarioNombre;
  final String? apartamento;
  final int mensajesNoLeidos;
  final Mensaje? ultimoMensaje;

  ChatPrivado({
    required this.usuarioId,
    required this.usuarioNombre,
    this.apartamento,
    this.mensajesNoLeidos = 0,
    this.ultimoMensaje,
  });

  factory ChatPrivado.fromJson(Map<String, dynamic> json) {
    return ChatPrivado(
      usuarioId: json['usuarioId'] ?? json['id'] ?? 0,
      usuarioNombre: json['usuarioNombre'] ?? json['nombre'] ?? '',
      apartamento: json['apartamento'],
      mensajesNoLeidos: json['mensajesNoLeidos'] ?? 0,
      ultimoMensaje: json['ultimoMensaje'] != null
          ? Mensaje.fromJson(json['ultimoMensaje'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'usuarioId': usuarioId,
      'usuarioNombre': usuarioNombre,
      'apartamento': apartamento,
      'mensajesNoLeidos': mensajesNoLeidos,
      'ultimoMensaje': ultimoMensaje?.toJson(),
    };
  }

  // Getters para compatibilidad con código existente
  int get id => usuarioId;
  int get otroUsuarioId => usuarioId;
  String get nombreOtroUsuario => usuarioNombre;
  String? get ultimoMensajeTexto => ultimoMensaje?.mensaje;
}

// Alias para compatibilidad con diferentes pantallas
typedef ChatMessage = Mensaje;

class SolicitudChat {
  final int id;
  final int solicitanteId;
  final String solicitanteNombre;
  final String? solicitanteApartamento;
  final int destinatarioId;
  final String destinatarioNombre;
  final String? destinatarioApartamento;
  final String estado; // 'pendiente', 'aceptada', 'rechazada'
  final DateTime fechaSolicitud;
  final DateTime? fechaRespuesta;

  SolicitudChat({
    required this.id,
    required this.solicitanteId,
    required this.solicitanteNombre,
    this.solicitanteApartamento,
    required this.destinatarioId,
    required this.destinatarioNombre,
    this.destinatarioApartamento,
    this.estado = 'pendiente',
    required this.fechaSolicitud,
    this.fechaRespuesta,
  });

  factory SolicitudChat.fromJson(Map<String, dynamic> json) {
    return SolicitudChat(
      id: json['id'],
      solicitanteId: json['solicitanteId'] ?? json['remitenteId'] ?? 0,
      solicitanteNombre: json['solicitanteNombre'] ?? json['nombreRemitente'] ?? '',
      solicitanteApartamento: json['solicitanteApartamento'],
      destinatarioId: json['destinatarioId'] ?? 0,
      destinatarioNombre: json['destinatarioNombre'] ?? '',
      destinatarioApartamento: json['destinatarioApartamento'],
      estado: json['estado'] ?? 'pendiente',
      fechaSolicitud: json['fechaSolicitud'] != null
          ? DateTime.parse(json['fechaSolicitud'])
          : (json['fecha'] != null ? DateTime.parse(json['fecha']) : DateTime.now()),
      fechaRespuesta: json['fechaRespuesta'] != null
          ? DateTime.parse(json['fechaRespuesta'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'solicitanteId': solicitanteId,
      'solicitanteNombre': solicitanteNombre,
      'solicitanteApartamento': solicitanteApartamento,
      'destinatarioId': destinatarioId,
      'destinatarioNombre': destinatarioNombre,
      'destinatarioApartamento': destinatarioApartamento,
      'estado': estado,
      'fechaSolicitud': fechaSolicitud.toIso8601String(),
      'fechaRespuesta': fechaRespuesta?.toIso8601String(),
    };
  }

  // Propiedades de compatibilidad con el código existente
  int get remitenteId => solicitanteId;
  String get nombreRemitente => solicitanteNombre;
  DateTime get fecha => fechaSolicitud;
}
