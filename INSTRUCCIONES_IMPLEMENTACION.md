# 🚀 Instrucciones de Implementación - App Flutter Conjunto Aralia

## ✅ Lo que ya está implementado

### 1. **Dependencias Agregadas** (`pubspec.yaml`)
```yaml
# Firebase & Notifications
firebase_core: ^2.24.0
firebase_messaging: ^14.7.6
flutter_local_notifications: ^16.3.0

# QR Code
qr_flutter: ^4.1.0
mobile_scanner: ^3.5.2

# PDF & Excel
pdf: ^3.10.7
printing: ^5.11.1
path_provider: ^2.1.1
open_file: ^3.3.2
excel: ^4.0.2

# Animations
lottie: ^2.7.0
confetti: ^0.7.0

# Video & Camera
video_player: ^2.8.1
camera: ^0.10.5+5

# Signature
signature: ^5.4.0

# Service Locator
get_it: ^7.6.4
```

### 2. **Servicios Creados**

#### `lib/services/notification_service.dart` ✅
- Sistema completo de notificaciones push con Firebase
- Notificaciones locales
- Métodos específicos para cada tipo:
  - `enviarNotificacionNoticia()`
  - `enviarNotificacionPaquete()`
  - `enviarNotificacionPago()`
  - `enviarNotificacionReserva()`
  - `enviarNotificacionPQRS()`
  - `enviarNotificacionPermiso()`
  - `enviarAlarmaSOS()`
  - `enviarNotificacionChat()`

#### `lib/services/payment_service.dart` ✅
- Métodos de pago: Efectivo, Nequi, Daviplata, PSE, Transferencia
- `procesarPago()` - Procesa según método seleccionado
- `generarRecibo()` - Genera recibo de pago
- Deep links para Nequi y Daviplata

#### `lib/services/pdf_service.dart` ✅
- `generarReciboPago()` - Recibos de pago completos
- `generarReciboVehiculo()` - Recibos para vehículos visitantes con cálculo detallado
- `generarReporteSorteo()` - Reporte de sorteo de parqueaderos
- Función `imprimirPdf()` para imprimir directamente

### 3. **Pantallas Mejoradas Creadas**

#### `lib/screens/chat/chat_screen_mejorado.dart` ✅
Sistema de chat con 4 canales separados:

1. **Chat General** - Todos los usuarios pueden ver y enviar mensajes
2. **Chat Administrador** - Solo admin ve (residentes envían, solo admin responde)
3. **Chat Vigilantes** - Solo vigilantes y admin ven
4. **Chats Privados** - Sistema peer-to-peer con:
   - Lista de residentes activos
   - Solicitud de chat (aceptar/rechazar)
   - Chats activos con contador de no leídos
   - Mensajes en tiempo real

**Características:**
- Burbujas de mensaje estilizadas
- Actualización automática cada 5 segundos
- Pull to refresh
- Indicador de "escrib iendo..." (futuro)
- Notificaciones de nuevos mensajes

#### `lib/screens/shared/control_vehiculos_mejorado.dart` ✅
Sistema completo de control de vehículos visitantes:

**Características:**
- ⏱️ **Timer en vivo** que se actualiza cada segundo
- 🚗 **Tres vistas según rol:**
  - Residente: Solo vehículos visitando SU apartamento
  - Vigilante: Todos los vehículos activos
  - Admin: Todos los vehículos activos
- 💰 **Cálculo automático de tarifas:**
  ```
  - Primeras 2 horas: GRATIS
  - Horas 3-10: $1,000 por hora
  - Más de 10 horas o varios días: $12,000 por día
  ```
- 📄 **Generación automática de recibo PDF** al registrar salida
- 💳 **Selección de método de pago** (Efectivo, Nequi, Daviplata, PSE, Transferencia)
- 📊 **Card visualmente atractiva** con:
  - Placa del vehículo destacada
  - Estado EN VISITA con indicador animado
  - Timer grande y legible
  - Valor acumulado en tiempo real
  - Botón STOP para vigilantes/admin

---

## 📋 PRÓXIMOS PASOS (EN ORDEN)

### PASO 1: Instalar Dependencias
```bash
cd conjunto_residencial_flutter
flutter pub get
```

**Nota:** Algunos errores de IDE desaparecerán después de ejecutar esto.

---

### PASO 2: Configurar Firebase (Para Notificaciones Push)

#### 2.1 Crear Proyecto en Firebase Console
1. Ir a [console.firebase.google.com](https://console.firebase.google.com)
2. Crear nuevo proyecto "ConjuntoAralia"
3. Agregar app Android:
   - Package name: `com.conjunto.aralia` (o tu package)
   - Descargar `google-services.json`
   - Colocar en `android/app/`

4. Agregar app iOS:
   - Bundle ID: `com.conjunto.aralia`
   - Descargar `GoogleService-Info.plist`
   - Colocar en `ios/Runner/`

#### 2.2 Configurar Android (`android/app/build.gradle`)
```gradle
plugins {
    id "com.android.application"
    id "kotlin-android"
    id "dev.flutter.flutter-gradle-plugin"
    id "com.google.gms.google-services"  // ← AGREGAR
}

dependencies {
    implementation platform('com.google.firebase:firebase-bom:32.7.0')  // ← AGREGAR
}
```

#### 2.3 Configurar Android (`android/build.gradle`)
```gradle
buildscript {
    dependencies {
        classpath 'com.google.gms:google-services:4.4.0'  // ← AGREGAR
    }
}
```

#### 2.4 Inicializar Firebase en `main.dart`
```dart
import 'package:firebase_core/firebase_core.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar Firebase
  await Firebase.initializeApp();

  // Inicializar servicio de notificaciones
  await NotificationService().initialize();

  runApp(const MyApp());
}
```

---

### PASO 3: Agregar Métodos Faltantes al API Service

Editar `lib/services/api_service.dart` y agregar:

```dart
// ========== CHAT ==========
Future<List<ChatMessage>> getChatGeneral() async {
  final response = await http.get(
    Uri.parse('$baseUrl/chat/general'),
    headers: _headers,
  );

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    return (data['mensajes'] as List)
        .map((m) => ChatMessage.fromJson(m))
        .toList();
  } else {
    throw Exception('Error al cargar mensajes');
  }
}

Future<void> enviarMensajeGeneral(String mensaje) async {
  final response = await http.post(
    Uri.parse('$baseUrl/chat/general'),
    headers: _headers,
    body: json.encode({'mensaje': mensaje}),
  );

  if (response.statusCode != 200) {
    throw Exception('Error al enviar mensaje');
  }
}

Future<List<User>> getResidentesActivos() async {
  final response = await http.get(
    Uri.parse('$baseUrl/residentes/activos'),
    headers: _headers,
  );

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    return (data as List).map((u) => User.fromJson(u)).toList();
  } else {
    throw Exception('Error al cargar residentes');
  }
}

Future<List<SolicitudChat>> getSolicitudesChat() async {
  final response = await http.get(
    Uri.parse('$baseUrl/chat/solicitudes'),
    headers: _headers,
  );

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    return (data as List).map((s) => SolicitudChat.fromJson(s)).toList();
  } else {
    throw Exception('Error al cargar solicitudes');
  }
}

Future<List<ChatPrivado>> getChatsPrivados() async {
  final response = await http.get(
    Uri.parse('$baseUrl/chat/privados'),
    headers: _headers,
  );

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    return (data as List).map((c) => ChatPrivado.fromJson(c)).toList();
  } else {
    throw Exception('Error al cargar chats');
  }
}

Future<void> solicitarChatPrivado(int usuarioId) async {
  final response = await http.post(
    Uri.parse('$baseUrl/chat/solicitar'),
    headers: _headers,
    body: json.encode({'destinatarioId': usuarioId}),
  );

  if (response.statusCode != 200) {
    throw Exception('Error al solicitar chat');
  }
}

Future<void> responderSolicitudChat(int solicitudId, bool aceptar) async {
  final response = await http.post(
    Uri.parse('$baseUrl/chat/responder'),
    headers: _headers,
    body: json.encode({
      'solicitudId': solicitudId,
      'aceptar': aceptar,
    }),
  );

  if (response.statusCode != 200) {
    throw Exception('Error al responder solicitud');
  }
}

Future<List<ChatMessage>> getMensajesChatPrivado(int chatId) async {
  final response = await http.get(
    Uri.parse('$baseUrl/chat/privado/$chatId'),
    headers: _headers,
  );

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    return (data['mensajes'] as List)
        .map((m) => ChatMessage.fromJson(m))
        .toList();
  } else {
    throw Exception('Error al cargar mensajes');
  }
}

Future<void> enviarMensajePrivado(int chatId, String mensaje) async {
  final response = await http.post(
    Uri.parse('$baseUrl/chat/privado/$chatId/mensaje'),
    headers: _headers,
    body: json.encode({'mensaje': mensaje}),
  );

  if (response.statusCode != 200) {
    throw Exception('Error al enviar mensaje');
  }
}

// ========== VEHÍCULOS ==========
Future<List<VehiculoVisitante>> getVehiculosDeApartamento(String apartamento) async {
  final response = await http.get(
    Uri.parse('$baseUrl/vehiculos-visitantes/apartamento/$apartamento'),
    headers: _headers,
  );

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    return (data as List).map((v) => VehiculoVisitante.fromJson(v)).toList();
  } else {
    throw Exception('Error al cargar vehículos');
  }
}

Future<List<VehiculoVisitante>> getTodosVehiculosActivos() async {
  final response = await http.get(
    Uri.parse('$baseUrl/vehiculos-visitantes/activos'),
    headers: _headers,
  );

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    return (data as List).map((v) => VehiculoVisitante.fromJson(v)).toList();
  } else {
    throw Exception('Error al cargar vehículos');
  }
}

Future<void> registrarIngresoVehiculo(VehiculoVisitante vehiculo) async {
  final response = await http.post(
    Uri.parse('$baseUrl/vehiculos-visitantes/ingreso'),
    headers: _headers,
    body: json.encode({
      'placa': vehiculo.placa,
      'apartamento': vehiculo.apartamentoDestino,
    }),
  );

  if (response.statusCode != 200) {
    throw Exception('Error al registrar ingreso');
  }
}

Future<void> registrarSalidaVehiculo(int vehiculoId, {String? metodoPago}) async {
  final response = await http.post(
    Uri.parse('$baseUrl/vehiculos-visitantes/salida'),
    headers: _headers,
    body: json.encode({
      'vehiculoId': vehiculoId,
      'metodoPago': metodoPago ?? 'efectivo',
    }),
  );

  if (response.statusCode != 200) {
    throw Exception('Error al registrar salida');
  }
}
```

---

### PASO 4: Actualizar Modelo de Vehículo

Editar `lib/models/vehiculo.dart` y agregar propiedades calculadas:

```dart
class VehiculoVisitante {
  final int id;
  final String placa;
  final String apartamentoDestino;
  final DateTime horaEntrada;
  final DateTime? horaSalida;
  final bool activo;

  VehiculoVisitante({
    required this.id,
    required this.placa,
    required this.apartamentoDestino,
    required this.horaEntrada,
    this.horaSalida,
    required this.activo,
  });

  // Getters calculados
  Duration get tiempoTranscurrido {
    final ahora = activo ? DateTime.now() : (horaSalida ?? DateTime.now());
    return ahora.difference(horaEntrada);
  }

  int get valorAPagar {
    final horas = tiempoTranscurrido.inHours;
    final dias = tiempoTranscurrido.inDays;

    if (dias >= 1) {
      return 12000 * (dias + 1);
    }

    if (horas <= 2) return 0;
    if (horas <= 10) return (horas - 2) * 1000;
    return 12000;
  }

  factory VehiculoVisitante.fromJson(Map<String, dynamic> json) {
    return VehiculoVisitante(
      id: json['id'],
      placa: json['placa'],
      apartamentoDestino: json['apartamentoDestino'],
      horaEntrada: DateTime.parse(json['horaEntrada']),
      horaSalida: json['horaSalida'] != null
          ? DateTime.parse(json['horaSalida'])
          : null,
      activo: json['activo'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'placa': placa,
      'apartamentoDestino': apartamentoDestino,
      'horaEntrada': horaEntrada.toIso8601String(),
      'horaSalida': horaSalida?.toIso8601String(),
      'activo': activo,
    };
  }
}
```

---

### PASO 5: Actualizar Modelo de Chat

Editar `lib/models/chat.dart` y agregar:

```dart
class ChatMessage {
  final int id;
  final int usuarioId;
  final String nombreUsuario;
  final String mensaje;
  final DateTime fecha;

  ChatMessage({
    required this.id,
    required this.usuarioId,
    required this.nombreUsuario,
    required this.mensaje,
    required this.fecha,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'],
      usuarioId: json['usuarioId'],
      nombreUsuario: json['nombreUsuario'],
      mensaje: json['mensaje'],
      fecha: DateTime.parse(json['fecha']),
    );
  }
}

class SolicitudChat {
  final int id;
  final int remitenteId;
  final String nombreRemitente;
  final DateTime fecha;

  SolicitudChat({
    required this.id,
    required this.remitenteId,
    required this.nombreRemitente,
    required this.fecha,
  });

  factory SolicitudChat.fromJson(Map<String, dynamic> json) {
    return SolicitudChat(
      id: json['id'],
      remitenteId: json['remitenteId'],
      nombreRemitente: json['nombreRemitente'],
      fecha: DateTime.parse(json['fecha']),
    );
  }
}

class ChatPrivado {
  final int id;
  final int otroUsuarioId;
  final String nombreOtroUsuario;
  final String? ultimoMensaje;
  final int mensajesNoLeidos;

  ChatPrivado({
    required this.id,
    required this.otroUsuarioId,
    required this.nombreOtroUsuario,
    this.ultimoMensaje,
    this.mensajesNoLeidos = 0,
  });

  factory ChatPrivado.fromJson(Map<String, dynamic> json) {
    return ChatPrivado(
      id: json['id'],
      otroUsuarioId: json['otroUsuarioId'],
      nombreOtroUsuario: json['nombreOtroUsuario'],
      ultimoMensaje: json['ultimoMensaje'],
      mensajesNoLeidos: json['mensajesNoLeidos'] ?? 0,
    );
  }
}
```

---

### PASO 6: Reemplazar Pantallas Antiguas con las Nuevas

#### Chat
Reemplazar `lib/screens/chat/chat_screen.dart` con el contenido de:
`lib/screens/chat/chat_screen_mejorado.dart`

#### Control de Vehículos
Usar `ControlVehiculosMejorado` en lugar del componente actual:

**Para Residente:**
```dart
ControlVehiculosMejorado(tipoUsuario: TipoUsuario.residente)
```

**Para Vigilante:**
```dart
ControlVehiculosMejorado(tipoUsuario: TipoUsuario.vigilante)
```

**Para Admin:**
```dart
ControlVehiculosMejorado(tipoUsuario: TipoUsuario.admin)
```

---

### PASO 7: Crear Carpetas de Assets

```bash
mkdir -p assets/images/espacios
mkdir -p assets/images/logos
mkdir -p assets/animations
```

Agregar imágenes de ejemplo para espacios:
- `assets/images/espacios/salon_social.jpg`
- `assets/images/espacios/piscina.jpg`
- `assets/images/espacios/bbq.jpg`
- `assets/images/espacios/gimnasio.jpg`
- `assets/images/espacios/cancha.jpg`

---

## 🎯 FUNCIONALIDADES PENDIENTES POR IMPLEMENTAR

### Alta Prioridad 🔴

1. **Sorteo de Parqueaderos** (`lib/screens/admin/sorteo_parqueaderos_mejorado.dart`)
   - Algoritmo de asignación aleatoria de 100 parqueaderos
   - Animación de sorteo con confetti
   - Generación de reporte PDF

2. **Mejora de Reservas con Imágenes** (`lib/screens/residente/mis_reservas_screen.dart`)
   - Agregar imágenes a cada espacio
   - Marcar en calendario días/horas ocupados
   - Historial de reservas

3. **Emprendimientos con Llamada Directa** (`lib/screens/residente/emprendimientos_screen.dart`)
   - Botón "Llamar Ahora" funcional
   - Sistema de reseñas con estrellas
   - Galería de imágenes

4. **Panel Admin con Estadísticas** (`lib/screens/admin/panel_admin_screen.dart`)
   - Dashboard con gráficos (fl_chart)
   - Estadísticas de pagos, ocupación, morosidad
   - Alertas importantes

### Prioridad Media 🟡

5. **PQRS Completo** (`lib/screens/residente/pqrs_screen.dart`)
   - Estados: Pendiente, En proceso, Resuelto, Rechazado
   - Adjuntar fotos
   - Sistema de comentarios

6. **Encuestas con Gráficos** (`lib/screens/admin/encuestas_admin_screen.dart`)
   - Crear encuestas/votaciones
   - Resultados en tiempo real con gráficos
   - Exportar a PDF/Excel

7. **Alarma SOS** (`lib/screens/shared/alarma_sos_screen.dart`)
   - Botón de pánico
   - 3 tipos: Robo, Incendio, Emergencia Médica
   - Notificación inmediata a vigilantes/admin

8. **Carga Masiva de Pagos** (`lib/screens/admin/pagos_admin_screen.dart`)
   - Importar CSV/Excel
   - Validar datos
   - Asignar masivamente

### Prioridad Baja 🟢

9. **QR para Visitantes** (`lib/screens/residente/generar_qr_visitante.dart`)
   - Generar QR temporal
   - Vigilante escanea con mobile_scanner
   - Validación automática

10. **Juegos Comunitarios** (`lib/screens/residente/juegos_screen.dart`)
    - Trivia
    - Bingo virtual
    - Ranking por torre

11. **Cámaras en Vivo** (Requiere integración con sistema de cámaras real)
    - WebRTC o HLS streaming
    - Control PTZ
    - Grabaciones

12. **Tema Claro/Oscuro**
    - ThemeProvider con Provider
    - Persistir preferencia con SharedPreferences

---

## 📞 Endpoints del Backend que Debes Crear

El backend (`server.js`) debe agregar estos endpoints:

```javascript
// Chat
app.get('/api/chat/general', verificarToken, (req, res) => {
  // Retornar mensajes del chat general
});

app.post('/api/chat/general', verificarToken, (req, res) => {
  // Crear mensaje en chat general
});

app.get('/api/residentes/activos', verificarToken, (req, res) => {
  // Retornar usuarios activos
});

app.get('/api/chat/solicitudes', verificarToken, (req, res) => {
  // Retornar solicitudes de chat privado pendientes
});

app.get('/api/chat/privados', verificarToken, (req, res) => {
  // Retornar chats privados activos del usuario
});

app.post('/api/chat/solicitar', verificarToken, (req, res) => {
  // Crear solicitud de chat privado
});

app.post('/api/chat/responder', verificarToken, (req, res) => {
  // Aceptar o rechazar solicitud
});

app.get('/api/chat/privado/:chatId', verificarToken, (req, res) => {
  // Retornar mensajes de un chat privado
});

app.post('/api/chat/privado/:chatId/mensaje', verificarToken, (req, res) => {
  // Enviar mensaje a chat privado
});

// Vehículos
app.get('/api/vehiculos-visitantes/apartamento/:apartamento', verificarToken, (req, res) => {
  // Retornar vehículos visitando un apartamento
});

app.get('/api/vehiculos-visitantes/activos', verificarVigilante, (req, res) => {
  // Retornar todos los vehículos activos
});

app.post('/api/vehiculos-visitantes/ingreso', verificarVigilante, (req, res) => {
  // Registrar ingreso de vehículo
});

app.post('/api/vehiculos-visitantes/salida', verificarVigilante, (req, res) => {
  // Registrar salida y calcular pago
});
```

---

## ✅ CHECKLIST FINAL

- [ ] Ejecutar `flutter pub get`
- [ ] Configurar Firebase (Android e iOS)
- [ ] Agregar métodos al ApiService
- [ ] Actualizar modelo VehiculoVisitante
- [ ] Actualizar modelo Chat
- [ ] Inicializar Firebase en main.dart
- [ ] Crear carpetas de assets
- [ ] Agregar imágenes de espacios
- [ ] Reemplazar ChatScreen
- [ ] Implementar ControlVehiculosMejorado
- [ ] Probar notificaciones push
- [ ] Probar chat en 4 canales
- [ ] Probar control de vehículos con timer
- [ ] Generar recibo PDF de vehículo
- [ ] Crear endpoints en backend

---

## 🎉 Resultado Final

Cuando completes estos pasos tendrás:

✅ Sistema de notificaciones push funcional
✅ Chat con 4 canales completamente operativo
✅ Control de vehículos con timer en vivo y recibos PDF
✅ Múltiples métodos de pago integrados
✅ Base sólida para las funcionalidades restantes

---

**Última actualización:** 2 de octubre de 2025
**Versión:** 1.0
