// EXTENSIÓN DE ApiService con todos los métodos faltantes
// Este archivo contiene los métodos que deben agregarse a api_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/noticia.dart';
import '../models/reserva.dart';
import '../models/pago.dart';
import '../models/pqrs.dart';
import '../models/encuesta.dart';
import '../models/emprendimiento.dart';
import '../models/user.dart';
import '../models/vehiculo.dart';
import '../models/chat.dart';
import '../services/pdf_service.dart';

// Copiar estos métodos dentro de la clase ApiService en api_service.dart

class ApiServiceExtension {
  static const String baseUrl = 'http://localhost:8081/api';
  String? _token;

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    if (_token != null) 'Authorization': 'Bearer $_token',
  };

  void setToken(String token) => _token = token;

  // ========== DASHBOARD Y NOTICIAS ==========

  Future<List<Noticia>> getNoticiasRecientes({int limit = 5}) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/noticias?limit=$limit'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Noticia.fromJson(json)).toList();
      }
      throw Exception('Error cargando noticias');
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<List<Reserva>> getProximasReservas() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/residente/reservas/proximas'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Reserva.fromJson(json)).toList();
      }
      throw Exception('Error cargando reservas');
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<List<Reserva>> getMisReservas() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/residente/mis-reservas'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Reserva.fromJson(json)).toList();
      }
      throw Exception('Error cargando mis reservas');
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<List<Pago>> getPagosPendientes() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/residente/pagos/pendientes'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Pago.fromJson(json)).toList();
      }
      throw Exception('Error cargando pagos pendientes');
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<Map<String, dynamic>> getEstadisticasResidente() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/residente/estadisticas'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
      throw Exception('Error cargando estadísticas');
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // ========== CHAT ==========

  Future<List<ChatMessage>> getChatGeneral() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/chat/general'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return (data['mensajes'] as List)
            .map((m) => ChatMessage.fromJson(m))
            .toList();
      }
      throw Exception('Error cargando mensajes');
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<void> enviarMensajeGeneral(String mensaje) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/chat/general'),
        headers: _headers,
        body: jsonEncode({'mensaje': mensaje}),
      );

      if (response.statusCode != 200) {
        throw Exception('Error enviando mensaje');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<List<User>> getResidentesActivos() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/residentes/activos'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((u) => User.fromJson(u)).toList();
      }
      throw Exception('Error cargando residentes');
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<List<SolicitudChat>> getSolicitudesChat() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/chat/solicitudes'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((s) => SolicitudChat.fromJson(s)).toList();
      }
      throw Exception('Error cargando solicitudes');
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<List<ChatPrivado>> getChatsPrivados() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/chat/privados'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((c) => ChatPrivado.fromJson(c)).toList();
      }
      throw Exception('Error cargando chats');
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<void> solicitarChatPrivado(int usuarioId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/chat/solicitar'),
        headers: _headers,
        body: jsonEncode({'destinatarioId': usuarioId}),
      );

      if (response.statusCode != 200) {
        throw Exception('Error solicitando chat');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<void> responderSolicitudChat(int solicitudId, bool aceptar) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/chat/responder'),
        headers: _headers,
        body: jsonEncode({
          'solicitudId': solicitudId,
          'aceptar': aceptar,
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Error respondiendo solicitud');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<List<ChatMessage>> getMensajesChatPrivado(int chatId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/chat/privado/$chatId'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return (data['mensajes'] as List)
            .map((m) => ChatMessage.fromJson(m))
            .toList();
      }
      throw Exception('Error cargando mensajes');
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<void> enviarMensajePrivado(int chatId, String mensaje) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/chat/privado/$chatId/mensaje'),
        headers: _headers,
        body: jsonEncode({'mensaje': mensaje}),
      );

      if (response.statusCode != 200) {
        throw Exception('Error enviando mensaje');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // ========== VEHÍCULOS ==========

  Future<List<VehiculoVisitante>> getVehiculosDeApartamento(String apartamento) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/vehiculos-visitantes/apartamento/$apartamento'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((v) => VehiculoVisitante.fromJson(v)).toList();
      }
      throw Exception('Error cargando vehículos');
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<List<VehiculoVisitante>> getTodosVehiculosActivos() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/vehiculos-visitantes/activos'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((v) => VehiculoVisitante.fromJson(v)).toList();
      }
      throw Exception('Error cargando vehículos');
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<void> registrarIngresoVehiculo({
    required String placa,
    required String apartamento,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/vehiculos-visitantes/ingreso'),
        headers: _headers,
        body: jsonEncode({
          'placa': placa,
          'apartamento': apartamento,
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Error registrando ingreso');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<void> registrarSalidaVehiculo(int vehiculoId, {String? metodoPago}) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/vehiculos-visitantes/salida'),
        headers: _headers,
        body: jsonEncode({
          'vehiculoId': vehiculoId,
          'metodoPago': metodoPago ?? 'efectivo',
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Error registrando salida');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // ========== SORTEO PARQUEADEROS ==========

  Future<Map<String, dynamic>> getUltimoSorteoParqueaderos() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/admin/sorteo-parqueaderos/ultimo'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
      throw Exception('Error cargando sorteo');
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<void> guardarSorteoParqueaderos(List<AsignacionParqueadero> asignaciones) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/admin/sorteo-parqueaderos'),
        headers: _headers,
        body: jsonEncode({
          'asignaciones': asignaciones.map((a) => {
            'torre': a.torre,
            'apartamento': a.apartamento,
            'nombreResidente': a.nombreResidente,
            'numeroParqueadero': a.numeroParqueadero,
          }).toList(),
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Error guardando sorteo');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // ========== QR VISITANTES ==========

  Future<void> crearQRVisitante(Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/qr/visitante'),
        headers: _headers,
        body: jsonEncode(data),
      );

      if (response.statusCode != 200) {
        throw Exception('Error creando QR');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<Map<String, dynamic>> validarQRVisitante(String codigo) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/qr/validar'),
        headers: _headers,
        body: jsonEncode({'codigo': codigo}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
      throw Exception('Error validando QR');
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // ========== ALARMA SOS ==========

  Future<void> activarAlarmaSOS({
    required String tipo,
    required String ubicacion,
    required String descripcion,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/alarma/sos'),
        headers: _headers,
        body: jsonEncode({
          'tipo': tipo,
          'ubicacion': ubicacion,
          'descripcion': descripcion,
          'fecha': DateTime.now().toIso8601String(),
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Error activando alarma');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // ========== PQRS ==========

  Future<List<PQRS>> getMisPQRS() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/pqrs/mis-solicitudes'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((p) => PQRS.fromJson(p)).toList();
      }
      throw Exception('Error cargando PQRS');
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<List<PQRS>> getAllPQRS() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/admin/pqrs'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((p) => PQRS.fromJson(p)).toList();
      }
      throw Exception('Error cargando PQRS');
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<void> crearPQRS({
    required String tipo,
    required String asunto,
    required String descripcion,
    List<String>? imagenes,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/pqrs'),
        headers: _headers,
        body: jsonEncode({
          'tipo': tipo,
          'asunto': asunto,
          'descripcion': descripcion,
          'imagenes': imagenes ?? [],
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Error creando PQRS');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<void> actualizarEstadoPQRS(int pqrsId, String nuevoEstado, {String? respuesta}) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/admin/pqrs/$pqrsId'),
        headers: _headers,
        body: jsonEncode({
          'estado': nuevoEstado,
          if (respuesta != null) 'respuesta': respuesta,
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Error actualizando PQRS');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<void> agregarComentarioPQRS(int pqrsId, String comentario) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/pqrs/$pqrsId/comentarios'),
        headers: _headers,
        body: jsonEncode({'comentario': comentario}),
      );

      if (response.statusCode != 200) {
        throw Exception('Error agregando comentario');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // ========== ENCUESTAS ==========

  Future<List<Encuesta>> getEncuestasActivas() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/encuestas/activas'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((e) => Encuesta.fromJson(e)).toList();
      }
      throw Exception('Error cargando encuestas');
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<List<Encuesta>> getAllEncuestas() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/admin/encuestas'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((e) => Encuesta.fromJson(e)).toList();
      }
      throw Exception('Error cargando encuestas');
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<void> crearEncuesta(Encuesta encuesta) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/admin/encuestas'),
        headers: _headers,
        body: jsonEncode(encuesta.toJson()),
      );

      if (response.statusCode != 200) {
        throw Exception('Error creando encuesta');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<void> responderEncuesta(int encuestaId, Map<int, dynamic> respuestas) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/encuestas/$encuestaId/responder'),
        headers: _headers,
        body: jsonEncode({'respuestas': respuestas}),
      );

      if (response.statusCode != 200) {
        throw Exception('Error respondiendo encuesta');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<Map<String, dynamic>> getResultadosEncuesta(int encuestaId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/encuestas/$encuestaId/resultados'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
      throw Exception('Error cargando resultados');
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // ========== EMPRENDIMIENTOS Y RESEÑAS ==========

  Future<List<Emprendimiento>> getEmprendimientosList() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/emprendimientos'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((e) => Emprendimiento.fromJson(e)).toList();
      }
      throw Exception('Error cargando emprendimientos');
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<List<Resena>> getResenasEmprendimiento(int emprendimientoId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/emprendimientos/$emprendimientoId/resenas'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((r) => Resena.fromJson(r)).toList();
      }
      throw Exception('Error cargando reseñas');
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<void> crearResena({
    required int emprendimientoId,
    required int calificacion,
    required String comentario,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/emprendimientos/$emprendimientoId/resenas'),
        headers: _headers,
        body: jsonEncode({
          'calificacion': calificacion,
          'comentario': comentario,
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Error creando reseña');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // ========== ADMIN ESTADÍSTICAS ==========

  Future<Map<String, dynamic>> getEstadisticasAdmin() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/admin/estadisticas'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
      throw Exception('Error cargando estadísticas');
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<Map<String, dynamic>> getEstadisticasPagos() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/admin/estadisticas/pagos'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
      throw Exception('Error cargando estadísticas de pagos');
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<Map<String, dynamic>> getEstadisticasReservas() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/admin/estadisticas/reservas'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
      throw Exception('Error cargando estadísticas de reservas');
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}

// Modelos auxiliares que deben estar en sus archivos correspondientes

class Resena {
  final int id;
  final int emprendimientoId;
  final int usuarioId;
  final String nombreUsuario;
  final int calificacion; // 1-5 estrellas
  final String comentario;
  final DateTime fecha;

  Resena({
    required this.id,
    required this.emprendimientoId,
    required this.usuarioId,
    required this.nombreUsuario,
    required this.calificacion,
    required this.comentario,
    required this.fecha,
  });

  factory Resena.fromJson(Map<String, dynamic> json) {
    return Resena(
      id: json['id'],
      emprendimientoId: json['emprendimientoId'],
      usuarioId: json['usuarioId'],
      nombreUsuario: json['nombreUsuario'],
      calificacion: json['calificacion'],
      comentario: json['comentario'],
      fecha: DateTime.parse(json['fecha']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'emprendimientoId': emprendimientoId,
      'usuarioId': usuarioId,
      'nombreUsuario': nombreUsuario,
      'calificacion': calificacion,
      'comentario': comentario,
      'fecha': fecha.toIso8601String(),
    };
  }
}

class AsignacionParqueadero {
  final String torre;
  final String apartamento;
  final String nombreResidente;
  final int numeroParqueadero;

  AsignacionParqueadero({
    required this.torre,
    required this.apartamento,
    required this.nombreResidente,
    required this.numeroParqueadero,
  });
}
