import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user.dart';
import '../models/reserva.dart';
import '../models/pago.dart';
import '../models/noticia.dart';
import '../models/pqrs.dart';
import '../models/emprendimiento.dart';
import '../models/vehiculo.dart';
import '../models/paquete.dart';
import '../models/documento.dart';
import '../models/encuesta.dart';
import '../models/chat.dart';
import '../models/arriendo.dart';
import '../models/permiso.dart';
import '../models/incidente_alcaldia.dart';

class ApiService {
  // IMPORTANTE: Usar localhost:8081 según el CLAUDE.md
  static const String baseUrl = 'http://localhost:8081/api';

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

  // ========== NOTICIAS ==========
  Future<List<Noticia>> getNoticias() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/noticias'),
        headers: _headers,
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Noticia.fromJson(json)).toList();
      }
      throw Exception('Error cargando noticias');
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<Noticia> getNoticiaById(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/noticias/$id'),
        headers: _headers,
      );
      if (response.statusCode == 200) {
        return Noticia.fromJson(jsonDecode(response.body));
      }
      throw Exception('Error cargando noticia');
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<Noticia> crearNoticia(String titulo, String contenido, String tipo) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/admin/noticias'),
        headers: _headers,
        body: jsonEncode({
          'titulo': titulo,
          'contenido': contenido,
          'tipo': tipo,
        }),
      );
      if (response.statusCode == 200) {
        return Noticia.fromJson(jsonDecode(response.body));
      }
      throw Exception('Error creando noticia');
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<void> eliminarNoticia(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/admin/noticias/$id'),
        headers: _headers,
      );
      if (response.statusCode != 200) {
        throw Exception('Error eliminando noticia');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // ========== PQRS ==========
  Future<List<PQRS>> getPQRSList() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/pqrs'),
        headers: _headers,
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => PQRS.fromJson(json)).toList();
      }
      throw Exception('Error cargando PQRS');
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<PQRS> crearPQRS(String tipo, String asunto, String descripcion) async {
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
        return PQRS.fromJson(jsonDecode(response.body));
      }
      throw Exception('Error creando PQRS');
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<void> responderPQRS(int id, String respuesta) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/pqrs/$id/responder'),
        headers: _headers,
        body: jsonEncode({'respuesta': respuesta}),
      );
      if (response.statusCode != 200) {
        throw Exception('Error respondiendo PQRS');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<void> cambiarEstadoPQRS(int id, String estado) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/pqrs/$id/estado'),
        headers: _headers,
        body: jsonEncode({'estado': estado}),
      );
      if (response.statusCode != 200) {
        throw Exception('Error cambiando estado PQRS');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // ========== EMPRENDIMIENTOS ==========
  Future<List<Emprendimiento>> getEmprendimientosList() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/emprendimientos'),
        headers: _headers,
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Emprendimiento.fromJson(json)).toList();
      }
      throw Exception('Error cargando emprendimientos');
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<List<Emprendimiento>> getMisEmprendimientos() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/residente/emprendimientos'),
        headers: _headers,
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Emprendimiento.fromJson(json)).toList();
      }
      throw Exception('Error cargando emprendimientos');
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // ========== ARRIENDOS ==========
  Future<List<Arriendo>> getArriendos() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/arriendos'),
        headers: _headers,
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Arriendo.fromJson(json)).toList();
      }
      throw Exception('Error cargando arriendos');
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<List<Arriendo>> getMisArriendos() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/residente/arriendos'),
        headers: _headers,
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Arriendo.fromJson(json)).toList();
      }
      throw Exception('Error cargando mis arriendos');
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<Arriendo> publicarArriendo(Map<String, dynamic> datos) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/residente/publicar-arriendo'),
        headers: _headers,
        body: jsonEncode(datos),
      );
      if (response.statusCode == 200) {
        return Arriendo.fromJson(jsonDecode(response.body));
      }
      throw Exception('Error publicando arriendo');
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // ========== PERMISOS ==========
  Future<List<Permiso>> getPermisosList() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/permisos'),
        headers: _headers,
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Permiso.fromJson(json)).toList();
      }
      throw Exception('Error cargando permisos');
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<List<Permiso>> getMisPermisos() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/residente/mis-permisos'),
        headers: _headers,
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Permiso.fromJson(json)).toList();
      }
      throw Exception('Error cargando mis permisos');
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<Permiso> solicitarPermiso(Map<String, dynamic> datos) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/residente/solicitar-permiso'),
        headers: _headers,
        body: jsonEncode(datos),
      );
      if (response.statusCode == 200) {
        return Permiso.fromJson(jsonDecode(response.body));
      }
      throw Exception('Error solicitando permiso');
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<void> registrarIngresoPermiso(int id) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/permisos/$id/ingresar'),
        headers: _headers,
      );
      if (response.statusCode != 200) {
        throw Exception('Error registrando ingreso');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<void> registrarSalidaPermiso(int id) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/permisos/$id/salir'),
        headers: _headers,
      );
      if (response.statusCode != 200) {
        throw Exception('Error registrando salida');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // ========== PAQUETES ==========
  Future<List<Paquete>> getPaquetes() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/paquetes'),
        headers: _headers,
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Paquete.fromJson(json)).toList();
      }
      throw Exception('Error cargando paquetes');
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<List<Paquete>> getMisPaquetes() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/residente/mis-paquetes'),
        headers: _headers,
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Paquete.fromJson(json)).toList();
      }
      throw Exception('Error cargando mis paquetes');
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<Paquete> registrarPaquete(Map<String, dynamic> datos) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/paquetes/registrar'),
        headers: _headers,
        body: jsonEncode(datos),
      );
      if (response.statusCode == 200) {
        return Paquete.fromJson(jsonDecode(response.body));
      }
      throw Exception('Error registrando paquete');
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<void> retirarPaquete(int id) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/paquetes/$id/retirar'),
        headers: _headers,
      );
      if (response.statusCode != 200) {
        throw Exception('Error retirando paquete');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // ========== CHAT ==========
  Future<List<Mensaje>> getChatMensajes(String canal) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/chat/$canal'),
        headers: _headers,
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Mensaje.fromJson(json)).toList();
      }
      throw Exception('Error cargando mensajes');
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<Mensaje> enviarMensajeChat(String canal, String mensaje) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/chat/$canal'),
        headers: _headers,
        body: jsonEncode({'mensaje': mensaje}),
      );
      if (response.statusCode == 200) {
        return Mensaje.fromJson(jsonDecode(response.body));
      }
      throw Exception('Error enviando mensaje');
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<List<ChatPrivado>> getChatsPrivados() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/chat/privados/lista'),
        headers: _headers,
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => ChatPrivado.fromJson(json)).toList();
      }
      throw Exception('Error cargando chats privados');
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<List<Mensaje>> getChatPrivado(int otroUsuarioId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/chat/privado/$otroUsuarioId'),
        headers: _headers,
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Mensaje.fromJson(json)).toList();
      }
      throw Exception('Error cargando chat privado');
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<Mensaje> enviarMensajePrivado(int otroUsuarioId, String mensaje) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/chat/privado/$otroUsuarioId'),
        headers: _headers,
        body: jsonEncode({'mensaje': mensaje}),
      );
      if (response.statusCode == 200) {
        return Mensaje.fromJson(jsonDecode(response.body));
      }
      throw Exception('Error enviando mensaje privado');
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<SolicitudChat> solicitarChatPrivado(int destinatarioId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/chat/solicitar'),
        headers: _headers,
        body: jsonEncode({'destinatarioId': destinatarioId}),
      );
      if (response.statusCode == 200) {
        return SolicitudChat.fromJson(jsonDecode(response.body));
      }
      throw Exception('Error solicitando chat');
    } catch (e) {
      throw Exception('Error de conexión: $e');
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
        return data.map((json) => SolicitudChat.fromJson(json)).toList();
      }
      throw Exception('Error cargando solicitudes');
    } catch (e) {
      throw Exception('Error de conexión: $e');
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
      throw Exception('Error de conexión: $e');
    }
  }

  // ========== RESIDENTES ==========
  Future<List<User>> getResidentes() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/residentes/lista'),
        headers: _headers,
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => User.fromJson(json)).toList();
      }
      throw Exception('Error cargando residentes');
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // ========== INCIDENTES ALCALDÍA ==========
  Future<List<IncidenteAlcaldia>> getIncidentes() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/incidentes'),
        headers: _headers,
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => IncidenteAlcaldia.fromJson(json)).toList();
      }
      throw Exception('Error cargando incidentes');
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<IncidenteAlcaldia> crearIncidente(Map<String, dynamic> datos) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/incidentes'),
        headers: _headers,
        body: jsonEncode(datos),
      );
      if (response.statusCode == 200) {
        return IncidenteAlcaldia.fromJson(jsonDecode(response.body));
      }
      throw Exception('Error creando incidente');
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<void> responderIncidente(int id, String respuesta) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/incidentes/$id/responder'),
        headers: _headers,
        body: jsonEncode({'respuesta': respuesta}),
      );
      if (response.statusCode != 200) {
        throw Exception('Error respondiendo incidente');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<void> cambiarEstadoIncidente(int id, String estado) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/incidentes/$id/estado'),
        headers: _headers,
        body: jsonEncode({'estado': estado}),
      );
      if (response.statusCode != 200) {
        throw Exception('Error cambiando estado');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // ========== ENCUESTAS ==========
  Future<List<Encuesta>> getEncuestas() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/encuestas'),
        headers: _headers,
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Encuesta.fromJson(json)).toList();
      }
      throw Exception('Error cargando encuestas');
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<Encuesta> crearEncuesta(String pregunta, List<String> opciones) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/encuestas'),
        headers: _headers,
        body: jsonEncode({
          'pregunta': pregunta,
          'opciones': opciones,
        }),
      );
      if (response.statusCode == 200) {
        return Encuesta.fromJson(jsonDecode(response.body));
      }
      throw Exception('Error creando encuesta');
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<void> votarEncuesta(int encuestaId, int opcionIndex) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/encuestas/$encuestaId/votar'),
        headers: _headers,
        body: jsonEncode({'opcion': opcionIndex}),
      );
      if (response.statusCode != 200) {
        throw Exception('Error votando');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<void> cerrarEncuesta(int id) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/encuestas/$id/cerrar'),
        headers: _headers,
      );
      if (response.statusCode != 200) {
        throw Exception('Error cerrando encuesta');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<void> eliminarEncuesta(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/encuestas/$id'),
        headers: _headers,
      );
      if (response.statusCode != 200) {
        throw Exception('Error eliminando encuesta');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // ========== DOCUMENTOS ==========
  Future<List<Documento>> getDocumentos() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/documentos'),
        headers: _headers,
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Documento.fromJson(json)).toList();
      }
      throw Exception('Error cargando documentos');
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<Documento> crearDocumento(Map<String, dynamic> datos) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/admin/documentos'),
        headers: _headers,
        body: jsonEncode(datos),
      );
      if (response.statusCode == 200) {
        return Documento.fromJson(jsonDecode(response.body));
      }
      throw Exception('Error creando documento');
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<void> eliminarDocumento(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/admin/documentos/$id'),
        headers: _headers,
      );
      if (response.statusCode != 200) {
        throw Exception('Error eliminando documento');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // ========== VEHÍCULOS VISITANTES ==========
  Future<List<VehiculoVisitante>> getVehiculosVisitantes() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/vehiculos-visitantes'),
        headers: _headers,
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => VehiculoVisitante.fromJson(json)).toList();
      }
      throw Exception('Error cargando vehículos');
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<List<VehiculoVisitante>> getVehiculosHoy() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/vehiculos-visitantes/hoy'),
        headers: _headers,
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => VehiculoVisitante.fromJson(json)).toList();
      }
      throw Exception('Error cargando vehículos de hoy');
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<VehiculoVisitante> registrarIngresoVehiculo(Map<String, dynamic> datos) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/vehiculos-visitantes/ingreso'),
        headers: _headers,
        body: jsonEncode(datos),
      );
      if (response.statusCode == 200) {
        return VehiculoVisitante.fromJson(jsonDecode(response.body));
      }
      throw Exception('Error registrando ingreso');
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<ReciboParqueadero> registrarSalidaVehiculo(String placa) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/vehiculos-visitantes/salida'),
        headers: _headers,
        body: jsonEncode({'placa': placa}),
      );
      if (response.statusCode == 200) {
        return ReciboParqueadero.fromJson(jsonDecode(response.body));
      }
      throw Exception('Error registrando salida');
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<List<ReciboParqueadero>> getRecibosParqueadero() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/recibos-parqueadero'),
        headers: _headers,
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => ReciboParqueadero.fromJson(json)).toList();
      }
      throw Exception('Error cargando recibos');
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // ========== PARQUEADEROS ==========
  Future<List<Parqueadero>> getParqueaderos() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/parqueaderos'),
        headers: _headers,
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Parqueadero.fromJson(json)).toList();
      }
      throw Exception('Error cargando parqueaderos');
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<Parqueadero?> getMiParqueadero() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/residente/mi-parqueadero'),
        headers: _headers,
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data != null ? Parqueadero.fromJson(data) : null;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<void> sortearParqueaderos() async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/admin/sorteo-parqueaderos'),
        headers: _headers,
      );
      if (response.statusCode != 200) {
        throw Exception('Error sorteando parqueaderos');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // ========== ADMIN ENDPOINTS ==========
  Future<List<User>> getUsuarios() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/usuarios'),
        headers: _headers,
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => User.fromJson(json)).toList();
      }
      throw Exception('Error cargando usuarios');
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<User> crearUsuario(Map<String, dynamic> datos) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/admin/usuarios'),
        headers: _headers,
        body: jsonEncode(datos),
      );
      if (response.statusCode == 200) {
        return User.fromJson(jsonDecode(response.body));
      }
      throw Exception('Error creando usuario');
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<void> eliminarResidente(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/admin/residentes/$id'),
        headers: _headers,
      );
      if (response.statusCode != 200) {
        throw Exception('Error eliminando residente');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<Map<String, dynamic>> getEstadisticas() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/admin/estadisticas'),
        headers: _headers,
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      throw Exception('Error cargando estadísticas');
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<Map<String, dynamic>> getReportePagos() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/admin/pagos/reporte'),
        headers: _headers,
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      throw Exception('Error cargando reporte');
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<void> cargarPagosMasivo(List<Map<String, dynamic>> pagos) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/admin/pagos/cargar-masivo'),
        headers: _headers,
        body: jsonEncode({'pagos': pagos}),
      );
      if (response.statusCode != 200) {
        throw Exception('Error cargando pagos');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
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
      throw Exception('Error de conexión: $e');
    }
  }

  Future<void> eliminarReserva(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/admin/reservas/$id'),
        headers: _headers,
      );
      if (response.statusCode != 200) {
        throw Exception('Error eliminando reserva');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }
}