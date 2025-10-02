import 'package:flutter/material.dart';

enum UserRole {
  residente,
  admin,
  vigilante,
  alcaldia;

  String get displayName {
    switch (this) {
      case UserRole.residente:
        return 'Residente';
      case UserRole.admin:
        return 'Administrador';
      case UserRole.vigilante:
        return 'Vigilante';
      case UserRole.alcaldia:
        return 'Alcaldía';
    }
  }

  Color get primaryColor {
    switch (this) {
      case UserRole.residente:
        return const Color(0xFF2563EB); // Blue
      case UserRole.admin:
        return const Color(0xFF16A34A); // Green
      case UserRole.vigilante:
        return const Color(0xFFEA580C); // Orange
      case UserRole.alcaldia:
        return const Color(0xFF7C3AED); // Purple
    }
  }

  Color get gradientStart {
    switch (this) {
      case UserRole.residente:
        return const Color(0xFF1E3A8A);
      case UserRole.admin:
        return const Color(0xFF166534);
      case UserRole.vigilante:
        return const Color(0xFFC2410C);
      case UserRole.alcaldia:
        return const Color(0xFF6D28D9);
    }
  }

  Color get gradientEnd {
    switch (this) {
      case UserRole.residente:
        return const Color(0xFF3B82F6);
      case UserRole.admin:
        return const Color(0xFF22C55E);
      case UserRole.vigilante:
        return const Color(0xFFFB923C);
      case UserRole.alcaldia:
        return const Color(0xFFA78BFA);
    }
  }

  static UserRole fromString(String? role) {
    switch (role?.toLowerCase()) {
      case 'admin':
        return UserRole.admin;
      case 'vigilante':
        return UserRole.vigilante;
      case 'alcaldia':
        return UserRole.alcaldia;
      default:
        return UserRole.residente;
    }
  }
}

class User {
  final int id;
  final String email;
  final String nombre;
  final String apartamento;
  final bool activo;
  final UserRole rol;

  User({
    required this.id,
    required this.email,
    required this.nombre,
    required this.apartamento,
    required this.activo,
    this.rol = UserRole.residente,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      nombre: json['nombre'],
      apartamento: json['apartamento'],
      activo: json['activo'] ?? true,
      rol: UserRole.fromString(json['rol']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'nombre': nombre,
      'apartamento': apartamento,
      'activo': activo,
      'rol': rol.name,
    };
  }

  @override
  String toString() {
    return 'User{id: $id, email: $email, nombre: $nombre, apartamento: $apartamento, rol: ${rol.name}}';
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