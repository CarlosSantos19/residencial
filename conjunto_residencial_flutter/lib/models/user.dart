class User {
  final int id;
  final String email;
  final String nombre;
  final String apartamento;
  final bool activo;

  User({
    required this.id,
    required this.email,
    required this.nombre,
    required this.apartamento,
    required this.activo,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      nombre: json['nombre'],
      apartamento: json['apartamento'],
      activo: json['activo'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'nombre': nombre,
      'apartamento': apartamento,
      'activo': activo,
    };
  }

  @override
  String toString() {
    return 'User{id: $id, email: $email, nombre: $nombre, apartamento: $apartamento}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is User && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class AuthResponse {
  final bool success;
  final String? token;
  final User? usuario;
  final String? mensaje;

  AuthResponse({
    required this.success,
    this.token,
    this.usuario,
    this.mensaje,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      success: json['success'],
      token: json['token'],
      usuario: json['usuario'] != null ? User.fromJson(json['usuario']) : null,
      mensaje: json['mensaje'],
    );
  }
}