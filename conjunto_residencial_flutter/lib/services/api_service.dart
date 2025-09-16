import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user.dart';
import '../models/reserva.dart';
import '../models/pago.dart';

class ApiService {
  // En desarrollo, usar IP local de tu máquina
  static const String baseUrl = 'http://localhost:3000/api';

  String? _token;

  void setToken(String token) {
    _token = token;
  }

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    if (_token != null) 'Authorization': 'Bearer $_token',
  };

  // Autenticación
  Future<AuthResponse> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: _headers,
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      final data = jsonDecode(response.body);
      return AuthResponse.fromJson(data);
    } catch (e) {
      return AuthResponse(
        success: false,
        mensaje: 'Error de conexión: $e',
      );
    }
  }

  Future<AuthResponse> register(
    String nombre,
    String email,
    String apartamento,
    String password,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: _headers,
        body: jsonEncode({
          'nombre': nombre,
          'email': email,
          'apartamento': apartamento,
          'password': password,
        }),
      );

      final data = jsonDecode(response.body);
      return AuthResponse.fromJson(data);
    } catch (e) {
      return AuthResponse(
        success: false,
        mensaje: 'Error de conexión: $e',
      );
    }
  }

  Future<AuthResponse> verifyToken() async {
    if (_token == null) {
      return AuthResponse(success: false, mensaje: 'No hay token');
    }

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/auth/verify'),
        headers: _headers,
      );

      final data = jsonDecode(response.body);
      return AuthResponse.fromJson(data);
    } catch (e) {
      return AuthResponse(
        success: false,
        mensaje: 'Error verificando token: $e',
      );
    }
  }

  // Reservas
  Future<List<Reserva>> getReservas() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/reservas'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Reserva.fromJson(json)).toList();
      }
      throw Exception('Error cargando reservas');
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<Reserva> createReserva(
    String espacio,
    String fecha,
    String hora,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/reservas'),
        headers: _headers,
        body: jsonEncode({
          'espacio': espacio,
          'fecha': fecha,
          'hora': hora,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Reserva.fromJson(data);
      }
      throw Exception('Error creando reserva');
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // Pagos
  Future<List<Pago>> getPagos() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/pagos'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Pago.fromJson(json)).toList();
      }
      throw Exception('Error cargando pagos');
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<Pago> marcarComoPagado(int pagoId) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/pagos/$pagoId'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Pago.fromJson(data);
      }
      throw Exception('Error marcando pago');
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // Mensajes
  Future<List<dynamic>> getMensajes() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/mensajes'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      throw Exception('Error cargando mensajes');
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<dynamic> sendMensaje(String mensaje) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/mensajes'),
        headers: _headers,
        body: jsonEncode({
          'mensaje': mensaje,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      throw Exception('Error enviando mensaje');
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // Emprendimientos
  Future<List<dynamic>> getEmprendimientos() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/emprendimientos'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      throw Exception('Error cargando emprendimientos');
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // PQRs
  Future<List<dynamic>> getPQRs() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/pqrs'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      throw Exception('Error cargando PQRs');
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<dynamic> createPQR(
    String tipo,
    String asunto,
    String descripcion,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/pqrs'),
        headers: _headers,
        body: jsonEncode({
          'tipo': tipo,
          'asunto': asunto,
          'descripcion': descripcion,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      throw Exception('Error creando PQR');
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // Permisos
  Future<List<dynamic>> getPermisos() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/permisos'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      throw Exception('Error cargando permisos');
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<dynamic> createPermiso({
    required String tipo,
    String? nombre,
    String? cedula,
    String? objeto,
    required String vigencia,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/permisos'),
        headers: _headers,
        body: jsonEncode({
          'tipo': tipo,
          'nombre': nombre,
          'cedula': cedula,
          'objeto': objeto,
          'vigencia': vigencia,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      throw Exception('Error creando permiso');
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }
}