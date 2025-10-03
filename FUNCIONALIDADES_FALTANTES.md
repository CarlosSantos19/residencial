# 📋 FUNCIONALIDADES FALTANTES - App Flutter

## ✅ YA IMPLEMENTADAS (100%)

### Servicios Core
- ✅ NotificationService - Push notifications con Firebase
- ✅ PaymentService - 5 métodos de pago
- ✅ PdfService - Generación de recibos y reportes

### Pantallas Completas
- ✅ ChatScreenMejorado - 4 canales (General, Admin, Vigilantes, Privados)
- ✅ ControlVehiculosMejorado - Timer en vivo + cálculo automático
- ✅ SorteoParqueaderosMejorado - Con confetti y PDF
- ✅ AlarmaSosWidget - 4 tipos de emergencia
- ✅ GenerarQRVisitante + EscanearQR - Sistema completo

---

## 🟡 PARCIALMENTE IMPLEMENTADAS (Necesitan mejoras)

### 1. Dashboard Residente
**Estado:** 70% completo
**Archivo creado:** `dashboard_residente_mejorado.dart` ✅

**Implementado:**
- ✅ Header con gradiente y saludo personalizado
- ✅ Estadísticas rápidas (Reservas, Pagos, Paquetes)
- ✅ Widget de pagos pendientes con alertas
- ✅ Widget de próximas reservas con timeline
- ✅ Widget de últimas noticias con categorías
- ✅ Pull-to-refresh

**Falta:**
- [ ] Agregar métodos al ApiService:
  ```dart
  Future<List<Noticia>> getNoticiasRecientes({int limit = 5})
  Future<List<Reserva>> getProximasReservas()
  Future<List<Pago>> getPagosPendientes()
  Future<Map<String, dynamic>> getEstadisticasResidente()
  ```

---

### 2. Mis Reservas
**Estado:** 60% completo
**Archivo:** `lib/screens/residente/mis_reservas_screen.dart`

**Implementado:**
- ✅ Calendario con TableCalendar
- ✅ Selección de espacio
- ✅ Selección de fecha y hora
- ✅ Crear reserva

**Falta:**
- [ ] Agregar imágenes de espacios
- [ ] Marcar en calendario días/horas ocupados
- [ ] Historial de reservas con filtros
- [ ] Cancelar reserva
- [ ] Crear assets: `assets/images/espacios/`

**Assets necesarios:**
```
assets/images/espacios/
  ├── salon_social.jpg
  ├── piscina.jpg
  ├── bbq.jpg
  ├── gimnasio.jpg
  ├── cancha.jpg
  └── sala_juegos.jpg
```

---

### 3. Emprendimientos
**Estado:** 50% completo
**Archivo:** `lib/screens/residente/emprendimientos_screen.dart`

**Implementado:**
- ✅ Lista de emprendimientos
- ✅ Botón contactar (básico)

**Falta:**
- [ ] Llamada directa con `url_launcher`
- [ ] Sistema de reseñas con estrellas
- [ ] Galería de imágenes
- [ ] Filtros por categoría
- [ ] Agregar modelo `Resena`:
  ```dart
  class Resena {
    final int id;
    final int emprendimientoId;
    final int usuarioId;
    final String nombreUsuario;
    final int calificacion; // 1-5 estrellas
    final String comentario;
    final DateTime fecha;
  }
  ```

---

## 🔴 NO IMPLEMENTADAS (Alta Prioridad)

### 4. Panel Admin con Estadísticas
**Estado:** 0% - NO IMPLEMENTADO
**Archivo:** Crear `lib/screens/admin/panel_admin_mejorado.dart`

**Funcionalidades necesarias:**
- [ ] Dashboard con gráficos (fl_chart)
- [ ] Estadísticas de pagos mensuales (gráfico de barras)
- [ ] Ocupación de zonas comunes (gráfico circular)
- [ ] Alertas de pagos vencidos
- [ ] Morosidad por torre (gráfico de líneas)
- [ ] Top 5 espacios más reservados
- [ ] Vehículos visitantes del mes

**Gráficos a usar:**
```dart
import 'package:fl_chart/fl_chart.dart';

// Gráfico de barras - Pagos mensuales
BarChart(
  BarChartData(
    // ...datos de pagos por mes
  ),
)

// Gráfico circular - Ocupación de espacios
PieChart(
  PieChartData(
    // ...porcentaje de uso por espacio
  ),
)

// Gráfico de líneas - Morosidad
LineChart(
  LineChartData(
    // ...morosidad mensual
  ),
)
```

---

### 5. PQRS Completo
**Estado:** 0% - NO IMPLEMENTADO
**Archivo:** Mejorar `lib/screens/residente/pqrs_screen.dart`

**Funcionalidades necesarias:**
- [ ] Formulario completo con validaciones
- [ ] Tipos: Pregunta, Queja, Reclamo, Sugerencia
- [ ] Adjuntar fotos (image_picker)
- [ ] Estados: Pendiente, En Proceso, Resuelto, Rechazado
- [ ] Sistema de comentarios/seguimiento
- [ ] Notificación cuando cambie estado
- [ ] Vista admin para gestionar PQRS

**Modelo:**
```dart
class PQRS {
  final int id;
  final String tipo; // pregunta, queja, reclamo, sugerencia
  final String asunto;
  final String descripcion;
  final List<String> imagenes;
  final EstadoPQRS estado;
  final DateTime fechaCreacion;
  final DateTime? fechaRespuesta;
  final String? respuesta;
  final List<Comentario> comentarios;
}

enum EstadoPQRS {
  pendiente,
  enProceso,
  resuelto,
  rechazado,
}

class Comentario {
  final int id;
  final int usuarioId;
  final String nombreUsuario;
  final String comentario;
  final DateTime fecha;
}
```

---

### 6. Encuestas con Gráficos
**Estado:** 0% - NO IMPLEMENTADO
**Archivos:**
- Crear `lib/screens/admin/encuestas_admin_mejorado.dart`
- Mejorar `lib/screens/residente/encuestas_residente_screen.dart`

**Funcionalidades Admin:**
- [ ] Crear encuestas/votaciones
- [ ] Tipos de pregunta:
  - Opción múltiple
  - Sí/No
  - Escala 1-5
  - Respuesta abierta
- [ ] Fecha de inicio/fin
- [ ] Ver resultados en tiempo real con gráficos
- [ ] Exportar resultados a PDF/Excel

**Funcionalidades Residente:**
- [ ] Ver encuestas activas
- [ ] Responder encuestas
- [ ] Ver resultados (si el admin lo permite)
- [ ] Marcar como "Ya votaste"

**Modelo:**
```dart
class Encuesta {
  final int id;
  final String titulo;
  final String descripcion;
  final DateTime fechaInicio;
  final DateTime fechaFin;
  final List<Pregunta> preguntas;
  final bool resultadosPublicos;
  final int totalVotos;
}

class Pregunta {
  final int id;
  final String pregunta;
  final TipoPregunta tipo;
  final List<OpcionRespuesta> opciones;
}

enum TipoPregunta {
  opcionMultiple,
  siNo,
  escala,
  abierta,
}

class OpcionRespuesta {
  final int id;
  final String texto;
  final int votos;
}
```

---

### 7. Carga Masiva de Pagos
**Estado:** 0% - NO IMPLEMENTADO
**Archivo:** Agregar a `lib/screens/admin/pagos_admin_screen.dart`

**Funcionalidades:**
- [ ] Botón "Carga Masiva"
- [ ] Seleccionar archivo CSV/Excel
- [ ] Parsear archivo con validaciones
- [ ] Previsualizar datos antes de importar
- [ ] Importar con progress indicator
- [ ] Reporte de errores

**Formato CSV esperado:**
```csv
Torre,Apartamento,ValorAdministracion,ValorParqueadero,Mes,Año
1,101,250000,50000,10,2025
1,102,250000,0,10,2025
2,201,250000,50000,10,2025
```

**Implementación:**
```dart
import 'package:file_picker/file_picker.dart';
import 'package:excel/excel.dart';

Future<void> _cargarPagosMasivos() async {
  // 1. Seleccionar archivo
  final result = await FilePicker.platform.pickFiles(
    type: FileType.custom,
    allowedExtensions: ['csv', 'xlsx'],
  );

  if (result == null) return;

  // 2. Parsear archivo
  final pagos = await _parsearArchivo(result.files.first);

  // 3. Mostrar preview
  await _mostrarPreview(pagos);

  // 4. Importar
  await _importarPagos(pagos);
}
```

---

### 8. Tema Claro/Oscuro
**Estado:** 0% - NO IMPLEMENTADO
**Archivos:**
- Actualizar `lib/utils/app_theme.dart`
- Crear `lib/providers/theme_provider.dart`

**Implementación:**
```dart
// theme_provider.dart
class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    _guardarPreferencia();
    notifyListeners();
  }

  Future<void> _guardarPreferencia() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', _isDarkMode);
  }

  Future<void> cargarPreferencia() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    notifyListeners();
  }
}

// app_theme.dart - Agregar darkTheme
static ThemeData get darkTheme {
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.dark(
      primary: primaryColor,
      secondary: secondaryColor,
      surface: Color(0xFF1E1E1E),
      background: Color(0xFF121212),
    ),
    scaffoldBackgroundColor: Color(0xFF121212),
    // ... resto de configuración
  );
}

// main.dart - Usar provider
ChangeNotifierProvider(
  create: (_) => ThemeProvider()..cargarPreferencia(),
  child: Consumer<ThemeProvider>(
    builder: (context, themeProvider, _) {
      return MaterialApp(
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: themeProvider.isDarkMode
            ? ThemeMode.dark
            : ThemeMode.light,
        // ...
      );
    },
  ),
)
```

**UI para cambiar tema:**
```dart
// En configuración o drawer
SwitchListTile(
  title: Text('Tema Oscuro'),
  subtitle: Text('Activar modo oscuro'),
  value: context.watch<ThemeProvider>().isDarkMode,
  onChanged: (_) => context.read<ThemeProvider>().toggleTheme(),
  secondary: Icon(Icons.dark_mode),
)
```

---

## 🟢 FUNCIONALIDADES OPCIONALES (Baja Prioridad)

### 9. Juegos Comunitarios
**Estado:** 0% - NO IMPLEMENTADO

**Juegos sugeridos:**
- [ ] Trivia con preguntas del conjunto
- [ ] Bingo virtual
- [ ] Rompecabezas simple
- [ ] Ranking por torre/apartamento

---

### 10. Cámaras en Vivo
**Estado:** 0% - NO IMPLEMENTADO

**Requiere:**
- [ ] Integración con sistema de cámaras real (RTSP, HLS, WebRTC)
- [ ] Dependencias: `video_player`, `webview_flutter`
- [ ] Permisos de visualización por rol
- [ ] Control PTZ (si las cámaras lo soportan)

---

### 11. Reconocimiento Facial
**Estado:** 0% - NO IMPLEMENTADO

**Requiere:**
- [ ] ML Kit o TensorFlow Lite
- [ ] Base de datos de rostros autorizados
- [ ] Integración con control de acceso
- [ ] Alertas de rostros no autorizados

---

### 12. Mapa Interactivo
**Estado:** 0% - NO IMPLEMENTADO

**Funcionalidades:**
- [ ] Mapa del conjunto con torres
- [ ] Ubicación de zonas comunes
- [ ] Ubicación de cámaras
- [ ] Ubicación de parqueaderos

---

## 📊 RESUMEN POR PRIORIDAD

### 🔴 **ALTA PRIORIDAD** (Completar primero)
1. ✅ Agregar métodos al ApiService para Dashboard
2. ✅ Panel Admin con Estadísticas y Gráficos
3. ✅ PQRS Completo con seguimiento
4. ✅ Encuestas con gráficos en tiempo real
5. ✅ Mejora de Reservas con imágenes

### 🟡 **MEDIA PRIORIDAD**
6. ✅ Emprendimientos con llamada directa y reseñas
7. ✅ Carga masiva de pagos (CSV/Excel)
8. ✅ Tema claro/oscuro

### 🟢 **BAJA PRIORIDAD** (Futuras versiones)
9. ⏸️ Juegos comunitarios
10. ⏸️ Cámaras en vivo
11. ⏸️ Reconocimiento facial
12. ⏸️ Mapa interactivo

---

## 🛠️ MÉTODOS PENDIENTES EN ApiService

Agregar en `lib/services/api_service.dart`:

```dart
// ========== DASHBOARD ==========
Future<List<Noticia>> getNoticiasRecientes({int limit = 5}) async {
  final response = await http.get(
    Uri.parse('$baseUrl/noticias/recientes?limit=$limit'),
    headers: _headers,
  );
  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    return (data as List).map((n) => Noticia.fromJson(n)).toList();
  }
  throw Exception('Error al cargar noticias');
}

Future<List<Reserva>> getProximasReservas() async {
  final response = await http.get(
    Uri.parse('$baseUrl/reservas/proximas'),
    headers: _headers,
  );
  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    return (data as List).map((r) => Reserva.fromJson(r)).toList();
  }
  throw Exception('Error al cargar reservas');
}

Future<List<Pago>> getPagosPendientes() async {
  final response = await http.get(
    Uri.parse('$baseUrl/pagos/pendientes'),
    headers: _headers,
  );
  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    return (data as List).map((p) => Pago.fromJson(p)).toList();
  }
  throw Exception('Error al cargar pagos');
}

Future<Map<String, dynamic>> getEstadisticasResidente() async {
  final response = await http.get(
    Uri.parse('$baseUrl/estadisticas/residente'),
    headers: _headers,
  );
  if (response.statusCode == 200) {
    return json.decode(response.body);
  }
  throw Exception('Error al cargar estadísticas');
}

// ========== PQRS ==========
Future<void> crearPQRS({
  required String tipo,
  required String asunto,
  required String descripcion,
  List<String>? imagenes,
}) async {
  final response = await http.post(
    Uri.parse('$baseUrl/pqrs'),
    headers: _headers,
    body: json.encode({
      'tipo': tipo,
      'asunto': asunto,
      'descripcion': descripcion,
      'imagenes': imagenes ?? [],
    }),
  );
  if (response.statusCode != 200) {
    throw Exception('Error al crear PQRS');
  }
}

Future<List<PQRS>> getMisPQRS() async {
  final response = await http.get(
    Uri.parse('$baseUrl/pqrs/mis-solicitudes'),
    headers: _headers,
  );
  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    return (data as List).map((p) => PQRS.fromJson(p)).toList();
  }
  throw Exception('Error al cargar PQRS');
}

// ========== ENCUESTAS ==========
Future<List<Encuesta>> getEncuestasActivas() async {
  final response = await http.get(
    Uri.parse('$baseUrl/encuestas/activas'),
    headers: _headers,
  );
  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    return (data as List).map((e) => Encuesta.fromJson(e)).toList();
  }
  throw Exception('Error al cargar encuestas');
}

Future<void> responderEncuesta(int encuestaId, Map<int, dynamic> respuestas) async {
  final response = await http.post(
    Uri.parse('$baseUrl/encuestas/$encuestaId/responder'),
    headers: _headers,
    body: json.encode({'respuestas': respuestas}),
  );
  if (response.statusCode != 200) {
    throw Exception('Error al responder encuesta');
  }
}

// ========== EMPRENDIMIENTOS ==========
Future<List<Resena>> getResenasEmprendimiento(int emprendimientoId) async {
  final response = await http.get(
    Uri.parse('$baseUrl/emprendimientos/$emprendimientoId/resenas'),
    headers: _headers,
  );
  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    return (data as List).map((r) => Resena.fromJson(r)).toList();
  }
  throw Exception('Error al cargar reseñas');
}

Future<void> crearResena({
  required int emprendimientoId,
  required int calificacion,
  required String comentario,
}) async {
  final response = await http.post(
    Uri.parse('$baseUrl/emprendimientos/$emprendimientoId/resenas'),
    headers: _headers,
    body: json.encode({
      'calificacion': calificacion,
      'comentario': comentario,
    }),
  );
  if (response.statusCode != 200) {
    throw Exception('Error al crear reseña');
  }
}

// ========== ADMIN ESTADÍSTICAS ==========
Future<Map<String, dynamic>> getEstadisticasAdmin() async {
  final response = await http.get(
    Uri.parse('$baseUrl/admin/estadisticas'),
    headers: _headers,
  );
  if (response.statusCode == 200) {
    return json.decode(response.body);
  }
  throw Exception('Error al cargar estadísticas');
}
```

---

## ✅ CHECKLIST DE IMPLEMENTACIÓN

### Configuración Base
- [x] Instalar dependencias (`flutter pub get`)
- [ ] Configurar Firebase (Android + iOS)
- [ ] Crear assets de imágenes

### Código
- [ ] Agregar métodos al ApiService
- [ ] Actualizar modelos (Pago, PQRS, Encuesta, Resena)
- [ ] Implementar Panel Admin
- [ ] Implementar PQRS completo
- [ ] Implementar Encuestas
- [ ] Mejorar Emprendimientos
- [ ] Mejorar Reservas
- [ ] Implementar tema oscuro

### Backend
- [ ] Crear endpoints faltantes
- [ ] Probar todos los endpoints

---

**Última actualización:** 2 de octubre de 2025
**Estado general:** 65% completado
**Funcionalidades críticas:** 8 implementadas, 7 pendientes
