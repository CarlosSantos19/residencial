# 📱 Plan de Mejoras - App Flutter Conjunto Aralia

## 📊 Estado Actual del Proyecto

### ✅ Ya Implementado

#### Sistema Base
- ✅ Arquitectura modular por roles (Residente/Admin/Vigilante/Alcaldía)
- ✅ Sistema de colores diferenciado por rol
- ✅ Navegación con TabController dinámico
- ✅ Gradientes personalizados en AppBar y Drawer
- ✅ Autenticación con token JWT
- ✅ API Service centralizado
- ✅ Modelos de datos completos

#### Pantallas Implementadas
**Residente:** 15 pantallas ✅
**Admin:** 13 pantallas ✅
**Vigilante:** 6 pantallas ✅
**Alcaldía:** 2 pantallas ✅

---

## 🎯 Funcionalidades a Implementar/Mejorar

### 🟦 MÓDULO RESIDENTE

#### 1. Dashboard (Mejorar)
**Ubicación:** `lib/screens/residente/dashboard_residente_screen.dart`

**Pendiente:**
- [ ] Mostrar últimas 3-5 noticias publicadas por admin
- [ ] Widget de próximas reservas (Timeline)
- [ ] Widget de pagos pendientes con alerta visual
- [ ] Notificaciones push cuando se publiquen noticias
- [ ] Pull-to-refresh para actualizar datos

**Implementación:**
```dart
// Agregar sección de noticias recientes
Widget _buildUltimasNoticias() {
  return FutureBuilder<List<Noticia>>(
    future: _apiService.getNoticiasRecientes(limit: 5),
    builder: (context, snapshot) {
      // Mostrar últimas noticias con título, fecha y extracto
    }
  );
}

// Widget de próximas reservas
Widget _buildProximasReservas() {
  return StreamBuilder<List<Reserva>>(
    stream: _apiService.getReservasProximas(),
    builder: (context, snapshot) {
      // Timeline con las próximas 3 reservas
    }
  );
}
```

---

#### 2. Mis Reservas (Mejorar)
**Ubicación:** `lib/screens/residente/mis_reservas_screen.dart`

**Pendiente:**
- [ ] Agregar imágenes representativas a cada espacio (Asset images)
- [ ] Mostrar en calendario los días/horas ocupados (marcar en rojo)
- [ ] Historial de reservas con filtros (Vigente/Cancelada/Expirada)
- [ ] Opción para cancelar reserva con confirmación

**Implementación:**
```dart
// Agregar assets de imágenes
final Map<String, String> espacioImages = {
  'Salón Social': 'assets/images/salon_social.jpg',
  'Piscina': 'assets/images/piscina.jpg',
  'BBQ': 'assets/images/bbq.jpg',
  'Gimnasio': 'assets/images/gimnasio.jpg',
  'Cancha': 'assets/images/cancha.jpg',
};

// En el calendario, marcar fechas ocupadas
TableCalendar(
  eventLoader: (day) {
    return _reservasOcupadas.where((r) =>
      isSameDay(r.fecha, day)
    ).toList();
  },
  calendarBuilders: CalendarBuilders(
    markerBuilder: (context, date, events) {
      if (events.isNotEmpty) {
        return Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.red.withOpacity(0.7),
          ),
          width: 7,
          height: 7,
        );
      }
    },
  ),
)
```

**Assets necesarios:**
- Crear carpeta `assets/images/espacios/`
- Agregar imágenes en `pubspec.yaml`

---

#### 3. Emprendimientos (Mejorar)
**Ubicación:** `lib/screens/residente/emprendimientos_screen.dart`

**Pendiente:**
- [x] Ya implementa `url_launcher` (línea 3)
- [ ] Mejorar botón "Contactar" con ícono de teléfono más visible
- [ ] Sistema de reseñas y calificaciones (estrellas)
- [ ] Agregar imágenes de productos/servicios
- [ ] Filtros por categoría (Comida, Servicios, Productos, etc.)

**Implementación:**
```dart
// Botón contactar mejorado
ElevatedButton.icon(
  onPressed: () => _llamarDirecto(emprendimiento.telefono),
  icon: const Icon(Icons.phone),
  label: const Text('Llamar Ahora'),
  style: ElevatedButton.styleFrom(
    backgroundColor: Colors.green,
    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
  ),
)

// Sistema de calificación
Future<void> _llamarDirecto(String telefono) async {
  final Uri uri = Uri.parse('tel:$telefono');
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri);
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('No se puede llamar a $telefono')),
    );
  }
}

// Widget de estrellas de calificación
Widget _buildRating(double rating) {
  return Row(
    children: List.generate(5, (index) {
      return Icon(
        index < rating ? Icons.star : Icons.star_border,
        color: Colors.amber,
        size: 20,
      );
    }),
  );
}
```

**Modelo actualizado:**
```dart
// Agregar a lib/models/emprendimiento.dart
class Emprendimiento {
  final int id;
  final String nombre;
  final String descripcion;
  final String categoria;
  final String telefono;
  final String? imagenUrl;
  final double calificacion;
  final int numResenas;
  final List<Resena> resenas;
}

class Resena {
  final int id;
  final int usuarioId;
  final String nombreUsuario;
  final int calificacion;
  final String comentario;
  final DateTime fecha;
}
```

---

#### 4. Ver Arriendos (Mejorar)
**Ubicación:** `lib/screens/residente/ver_arriendos_screen.dart`

**Pendiente:**
- [ ] Subpestañas: "Apartamentos" y "Parqueaderos"
- [ ] Formulario de publicar arriendo con validaciones
- [ ] Selector de Torre (1 a 10) con Dropdown
- [ ] Campo opcional para número de parqueadero
- [ ] Botón "Contactar propietario" con llamada directa

**Implementación:**
```dart
class VerArriendosScreen extends StatefulWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          bottom: TabBar(
            tabs: [
              Tab(icon: Icon(Icons.apartment), text: 'Apartamentos'),
              Tab(icon: Icon(Icons.local_parking), text: 'Parqueaderos'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _ApartamentosTab(),
            _ParqueaderosTab(),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _mostrarFormularioArriendo,
          label: Text('Publicar Arriendo'),
          icon: Icon(Icons.add),
        ),
      ),
    );
  }
}

// Formulario de arriendo
void _mostrarFormularioArriendo() {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (context) => Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        padding: EdgeInsets.all(24),
        child: Column(
          children: [
            DropdownButtonFormField<int>(
              decoration: InputDecoration(labelText: 'Torre'),
              items: List.generate(10, (i) => i + 1)
                .map((torre) => DropdownMenuItem(
                  value: torre,
                  child: Text('Torre $torre'),
                ))
                .toList(),
              onChanged: (value) => setState(() => _torre = value),
            ),
            TextFormField(
              decoration: InputDecoration(labelText: 'Apartamento'),
              keyboardType: TextInputType.number,
            ),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Parqueadero (Opcional)',
                hintText: 'Ej: P-42',
              ),
            ),
            TextFormField(
              decoration: InputDecoration(labelText: 'Precio Mensual'),
              keyboardType: TextInputType.number,
              prefix: Text('\$'),
            ),
            TextFormField(
              decoration: InputDecoration(labelText: 'Teléfono Contacto'),
              keyboardType: TextInputType.phone,
            ),
          ],
        ),
      ),
    ),
  );
}
```

---

#### 5. Mi Parqueadero (Mejorar)
**Ubicación:** `lib/screens/residente/mi_parqueadero_screen.dart`

**Pendiente:**
- [ ] Mostrar SOLO el parqueadero asignado al residente en el sorteo
- [ ] Diseño visual del parqueadero (plano/mapa)
- [ ] Estado: Asignado/No asignado/En sorteo
- [ ] Historial de sorteos anteriores

**Implementación:**
```dart
Widget _buildParqueaderoAsignado(ParqueaderoAsignacion asignacion) {
  return Column(
    children: [
      Container(
        width: 200,
        height: 120,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade700, Colors.blue.shade500],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.withOpacity(0.3),
              blurRadius: 15,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.local_parking, size: 48, color: Colors.white),
              SizedBox(height: 8),
              Text(
                'P-${asignacion.numeroParqueadero}',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                'Piso ${asignacion.piso}',
                style: TextStyle(color: Colors.white70),
              ),
            ],
          ),
        ),
      ),
      SizedBox(height: 24),
      Card(
        child: ListTile(
          leading: Icon(Icons.casino, color: Colors.green),
          title: Text('Sorteo: ${asignacion.fechaSorteo}'),
          subtitle: Text('Asignado desde ${asignacion.fechaAsignacion}'),
        ),
      ),
    ],
  );
}
```

---

#### 6. Control de Vehículos Residente (Mejorar)
**Ubicación:** `lib/screens/residente/control_vehiculos_residente_screen.dart`

**Pendiente:**
- [ ] Mostrar SOLO vehículos visitando SU apartamento
- [ ] Timer en vivo mostrando tiempo acumulado
- [ ] Valor actual acumulado en tiempo real
- [ ] Cuando vigilante presiona STOP → Generar recibo
- [ ] Opciones de pago: Efectivo, Nequi, PSE
- [ ] Reglas de cobro:
  - ✅ 2 primeras horas: GRATIS
  - ✅ Hora 3-10: $1,000/hora
  - ✅ Después 10 horas: $12,000/día

**Implementación:**
```dart
class VehiculoVisitante {
  final String placa;
  final DateTime horaEntrada;
  final String apartamentoDestino;
  final bool activo;
  final DateTime? horaSalida;

  Duration get tiempoTranscurrido {
    final ahora = activo ? DateTime.now() : horaSalida!;
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
}

// Timer en vivo
Widget _buildVehiculoCard(VehiculoVisitante vehiculo) {
  return StreamBuilder(
    stream: Stream.periodic(Duration(seconds: 1)),
    builder: (context, snapshot) {
      return Card(
        child: ListTile(
          leading: Icon(Icons.directions_car, size: 40),
          title: Text(vehiculo.placa,
            style: TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Entrada: ${_formatTime(vehiculo.horaEntrada)}'),
              Text('Tiempo: ${_formatDuration(vehiculo.tiempoTranscurrido)}'),
              Text(
                'Valor: \$${_formatMoney(vehiculo.valorAPagar)}',
                style: TextStyle(
                  color: vehiculo.valorAPagar > 0 ? Colors.red : Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          trailing: vehiculo.activo
            ? Chip(label: Text('En visita'), backgroundColor: Colors.green)
            : ElevatedButton(
                onPressed: () => _generarRecibo(vehiculo),
                child: Text('Ver Recibo'),
              ),
        ),
      );
    },
  );
}
```

---

#### 7. Paquetes (Mejorar)
**Ubicación:** `lib/screens/residente/paquetes_residente_screen.dart`

**Pendiente:**
- [ ] Notificación push cuando llegue paquete
- [ ] Marcar como "Recogido" con firma digital
- [ ] Historial de paquetes recibidos
- [ ] Filtros por estado (Pendiente/Recogido)
- [ ] Foto del paquete (tomada por vigilante)

**Implementación:**
```dart
class Paquete {
  final int id;
  final String tipo; // 'Paquete', 'Pedido', 'Servicio Público'
  final String descripcion;
  final DateTime fechaLlegada;
  final String apartamentoDestino;
  final bool recogido;
  final DateTime? fechaRecogido;
  final String? fotoUrl;
  final String? firmaBeneficiario;
}

// Marcar como recogido con firma
Future<void> _marcarRecogido(Paquete paquete) async {
  final firma = await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => SignatureScreen(),
    ),
  );

  if (firma != null) {
    await _apiService.marcarPaqueteRecogido(
      paquete.id,
      firmaBase64: firma,
    );
    _loadPaquetes();
  }
}
```

---

#### 8. Chat (Mejorar)
**Ubicación:** `lib/screens/chat/chat_screen.dart`

**Pendiente:**
- [ ] 4 canales separados con TabBar:
  1. **General** (todos los usuarios)
  2. **Administrador** (solo admin ve)
  3. **Vigilantes** (solo vigilantes ven)
  4. **Residentes** (chat privado peer-to-peer)
- [ ] Sistema de solicitud/aceptación para chats privados
- [ ] Notificaciones de nuevos mensajes
- [ ] Estado online/offline de usuarios

**Implementación:**
```dart
class ChatScreen extends StatefulWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Chat Comunitario'),
          bottom: TabBar(
            isScrollable: true,
            tabs: [
              Tab(icon: Icon(Icons.public), text: 'General'),
              Tab(icon: Icon(Icons.admin_panel_settings), text: 'Admin'),
              Tab(icon: Icon(Icons.security), text: 'Vigilantes'),
              Tab(icon: Icon(Icons.people), text: 'Privados'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            ChatGeneralTab(),
            ChatAdminTab(),
            ChatVigilantesTab(),
            ChatPrivadosTab(),
          ],
        ),
      ),
    );
  }
}

// Chat privado con sistema de solicitud
class ChatPrivadosTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Lista de residentes activos
        Expanded(
          child: ListView.builder(
            itemBuilder: (context, index) {
              return ListTile(
                leading: CircleAvatar(child: Icon(Icons.person)),
                title: Text(residente.nombre),
                subtitle: Text(residente.apartamento),
                trailing: ElevatedButton(
                  onPressed: () => _solicitarChat(residente),
                  child: Text('Solicitar Chat'),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Future<void> _solicitarChat(User residente) async {
    await _apiService.solicitarChatPrivado(residente.id);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Solicitud enviada a ${residente.nombre}')),
    );
  }
}
```

---

#### 9. Cámaras (Implementar)
**Ubicación:** `lib/screens/residente/camaras_residente_screen.dart`

**Pendiente:**
- [ ] Lista de cámaras de zonas comunes
- [ ] Integración con streaming (WebRTC o HLS)
- [ ] Solo mostrar cámaras autorizadas para residentes
- [ ] Pantalla completa con doble tap

**Implementación:**
```dart
// Requerirá agregar dependencia: video_player, webview_flutter

class CamarasResidenteScreen extends StatelessWidget {
  final List<Camara> camaras = [
    Camara(id: 1, nombre: 'Entrada Principal', url: 'rtsp://...', activa: true),
    Camara(id: 2, nombre: 'Piscina', url: 'rtsp://...', activa: true),
    Camara(id: 3, nombre: 'Parqueadero', url: 'rtsp://...', activa: true),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GridView.builder(
        padding: EdgeInsets.all(16),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.3,
        ),
        itemCount: camaras.length,
        itemBuilder: (context, index) {
          final camara = camaras[index];
          return GestureDetector(
            onTap: () => _abrirCamaraCompleta(camara),
            child: Card(
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  Expanded(
                    child: camara.activa
                      ? WebView(initialUrl: camara.url) // Placeholder
                      : Icon(Icons.videocam_off, size: 48),
                  ),
                  Container(
                    padding: EdgeInsets.all(8),
                    color: Colors.black87,
                    width: double.infinity,
                    child: Text(
                      camara.nombre,
                      style: TextStyle(color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
```

---

#### 10. Juegos Comunitarios 🎮 (Implementar)
**Ubicación:** `lib/screens/residente/juegos_screen.dart`

**Pendiente:**
- [ ] Trivia comunitaria con preguntas del conjunto
- [ ] Bingo virtual con premios
- [ ] Rompecabezas simple
- [ ] Ranking por torre y apartamento
- [ ] Eventos organizados por admin

**Implementación:**
```dart
class JuegosScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GridView.count(
        crossAxisCount: 2,
        children: [
          _GameCard(
            titulo: 'Trivia',
            icono: Icons.quiz,
            color: Colors.purple,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => TriviaGameScreen()),
            ),
          ),
          _GameCard(
            titulo: 'Bingo',
            icono: Icons.grid_on,
            color: Colors.orange,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => BingoGameScreen()),
            ),
          ),
          _GameCard(
            titulo: 'Ranking',
            icono: Icons.leaderboard,
            color: Colors.green,
            onTap: () => _showRanking(context),
          ),
        ],
      ),
    );
  }
}

// Ejemplo: Trivia simple
class TriviaGameScreen extends StatefulWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Trivia Comunitaria')),
      body: Column(
        children: [
          // Pregunta
          Text('¿En qué año se fundó el conjunto?'),
          // Opciones
          ...['2015', '2018', '2020', '2022'].map((opcion) =>
            ElevatedButton(
              onPressed: () => _verificarRespuesta(opcion),
              child: Text(opcion),
            ),
          ),
        ],
      ),
    );
  }
}
```

---

#### 11. PQRS (Mejorar)
**Ubicación:** `lib/screens/residente/pqrs_screen.dart`

**Pendiente:**
- [ ] Estados: Pendiente, En proceso, Resuelto, Rechazado
- [ ] Adjuntar fotos/archivos
- [ ] Sistema de comentarios/seguimiento
- [ ] Notificación cuando cambien estado

---

#### 12. Encuestas (Mejorar)
**Ubicación:** `lib/screens/residente/encuestas_residente_screen.dart`

**Pendiente:**
- [ ] Responder encuestas creadas por admin
- [ ] Resultados en tiempo real con gráficos (fl_chart)
- [ ] Tipos: Opción múltiple, Si/No, Escala 1-5
- [ ] Marcar como "Ya votaste"

---

### 🟩 MÓDULO ADMINISTRADOR

#### 1. Panel Admin (Mejorar)
**Ubicación:** `lib/screens/admin/panel_admin_screen.dart`

**Pendiente:**
- [ ] Dashboard con estadísticas generales
- [ ] Gráficos de pagos mensuales
- [ ] Ocupación de zonas comunes
- [ ] Alertas de pagos vencidos
- [ ] Cada modal debe estar contenido en su pestaña

---

#### 2. Sorteo Parqueaderos (Mejorar)
**Ubicación:** `lib/screens/admin/sorteo_parqueaderos_screen.dart`

**Pendiente:**
- [ ] Realizar sorteo entre 100 parqueaderos
- [ ] Algoritmo de asignación aleatoria
- [ ] Mostrar resultados con animación
- [ ] Guardar historial de sorteos
- [ ] Exportar resultados (PDF/Excel)

**Implementación:**
```dart
Future<void> _realizarSorteo() async {
  // Obtener residentes activos
  final residentes = await _apiService.getResidentesActivos();

  // 100 parqueaderos disponibles
  final parqueaderos = List.generate(100, (i) => i + 1);
  parqueaderos.shuffle(); // Aleatorizar

  final asignaciones = <ParqueaderoAsignacion>[];

  for (int i = 0; i < residentes.length && i < parqueaderos.length; i++) {
    asignaciones.add(ParqueaderoAsignacion(
      residenteId: residentes[i].id,
      numeroParqueadero: parqueaderos[i],
      fechaSorteo: DateTime.now(),
    ));
  }

  // Guardar en backend
  await _apiService.guardarSorteoParqueaderos(asignaciones);

  // Mostrar resultados con animación
  _mostrarResultados(asignaciones);
}
```

---

#### 3. Control Vehículos Admin (Mejorar)
**Ubicación:** `lib/screens/admin/control_vehiculos_admin_screen.dart`

**Pendiente:**
- [ ] Ver TODOS los vehículos visitantes
- [ ] Botón STOP para calcular pago
- [ ] Total recaudado por día
- [ ] Si múltiples días → calcular por día ($12,000/día)
- [ ] Reportes exportables

---

#### 4. Noticias (Mejorar)
**Ubicación:** `lib/screens/admin/noticias_admin_screen.dart`

**Pendiente:**
- [ ] CRUD completo (Crear, Editar, Eliminar)
- [ ] Categorías: Evento, Asamblea, Recibo, Mantenimiento
- [ ] Enviar notificación push al publicar
- [ ] Adjuntar imágenes
- [ ] Programar publicación futura

---

#### 5. Pagos Admin (Mejorar)
**Ubicación:** `lib/screens/admin/pagos_admin_screen.dart`

**Pendiente:**
- [ ] Subir valores por torre/apartamento
- [ ] Carga masiva por archivo CSV/Excel
- [ ] Conceptos: Administración, Parqueadero
- [ ] Generar reporte de pagos pendientes
- [ ] Dashboard de morosidad

**Implementación:**
```dart
// Carga masiva desde CSV
Future<void> _cargarPagosMasivos() async {
  final result = await FilePicker.platform.pickFiles(
    type: FileType.custom,
    allowedExtensions: ['csv', 'xlsx'],
  );

  if (result != null) {
    final file = result.files.first;
    final pagos = await _parsearArchivoPagos(file);

    for (var pago in pagos) {
      await _apiService.crearPago(pago);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${pagos.length} pagos cargados')),
    );
  }
}

// Formato CSV esperado:
// Torre,Apartamento,ValorAdministracion,ValorParqueadero,Mes,Año
// 1,101,250000,50000,12,2024
```

---

#### 6. Usuarios (Mejorar)
**Ubicación:** `lib/screens/admin/usuarios_screen.dart`

**Pendiente:**
- [ ] Crear usuarios con roles
- [ ] Activar/Desactivar usuarios
- [ ] Asignar parqueadero manualmente
- [ ] Habilitar chat privado
- [ ] Editar información

---

#### 7. Permisos Admin (Mejorar)
**Ubicación:** `lib/screens/admin/permisos_admin_screen.dart`

**Pendiente:**
- [ ] Aprobar/Rechazar solicitudes
- [ ] Tipos: Visitantes, Objetos, Salidas, Trasteos
- [ ] Historial de permisos
- [ ] Notificar al residente cuando se apruebe

---

#### 8. Cámaras Admin (Implementar)
**Pendiente:**
- [ ] Acceso completo a todas las cámaras
- [ ] Control PTZ (Pan, Tilt, Zoom) si las cámaras lo permiten
- [ ] Grabaciones históricas
- [ ] Gestionar permisos de visualización

---

#### 9. PQRS Admin (Mejorar)
**Pendiente:**
- [ ] Recibir y responder PQRS
- [ ] Cambiar estados
- [ ] Asignar a responsable
- [ ] Estadísticas de resolución

---

#### 10. Encuestas Admin (Mejorar)
**Pendiente:**
- [ ] Crear encuestas/votaciones
- [ ] Tipos de pregunta: Múltiple, Abierta, Escala
- [ ] Ver resultados en tiempo real
- [ ] Exportar resultados (PDF/Excel)

---

### 🟧 MÓDULO VIGILANTE

#### 1. Panel Seguridad (Mejorar)
**Ubicación:** `lib/screens/vigilante/panel_seguridad_screen.dart`

**Pendiente:**
- [ ] Dashboard con estadísticas de seguridad
- [ ] Vehículos activos en tiempo real
- [ ] Permisos pendientes de confirmación
- [ ] Paquetes registrados hoy
- [ ] Botón SOS visible

---

#### 2. Control Vehículos Vigilante (Mejorar)
**Pendiente:**
- [ ] Registrar entrada de vehículo
- [ ] Botón STOP para calcular pago
- [ ] Generar recibo automático
- [ ] Lista de vehículos activos

---

#### 3. Gestión Permisos Vigilante (Mejorar)
**Pendiente:**
- [ ] Confirmar permisos autorizados
- [ ] Escanear QR de visitantes (futuro)
- [ ] Registro de entradas/salidas

---

#### 4. Paquetes Vigilante (Mejorar)
**Pendiente:**
- [ ] Registrar llegada de paquete
- [ ] Tomar foto del paquete
- [ ] Notificar al residente
- [ ] Marcar como entregado

---

### 🚨 FUNCIONALIDADES AVANZADAS

#### 1. Sistema de Alarmas SOS
**Ubicación:** Crear `lib/screens/shared/alarma_sos_screen.dart`

**Implementación:**
```dart
// Botón SOS en todas las pantallas principales
FloatingActionButton(
  backgroundColor: Colors.red,
  onPressed: () => _mostrarAlarmaSOS(),
  child: Icon(Icons.warning_amber),
)

// Modal de tipos de alarma
void _mostrarAlarmaSOS() {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('⚠️ ALARMA DE EMERGENCIA'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ElevatedButton.icon(
            onPressed: () => _activarAlarma('robo'),
            icon: Icon(Icons.dangerous),
            label: Text('ROBO'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          ),
          ElevatedButton.icon(
            onPressed: () => _activarAlarma('incendio'),
            icon: Icon(Icons.local_fire_department),
            label: Text('INCENDIO'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
          ),
          ElevatedButton.icon(
            onPressed: () => _activarAlarma('medica'),
            icon: Icon(Icons.medical_services),
            label: Text('EMERGENCIA MÉDICA'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
          ),
        ],
      ),
    ),
  );
}

Future<void> _activarAlarma(String tipo) async {
  await _apiService.activarAlarmaSOS(
    tipo: tipo,
    ubicacion: user.apartamento,
  );
  // Enviar notificación push a vigilantes y admin
  await _notificationService.enviarAlarmaSOS(tipo);
}
```

---

#### 2. Modo Visita con QR 🛎️
**Ubicación:** Crear `lib/screens/residente/generar_qr_visitante.dart`

**Dependencias:**
```yaml
dependencies:
  qr_flutter: ^4.1.0
  qr_code_scanner: ^1.0.1
```

**Implementación:**
```dart
// Residente genera QR
class GenerarQRVisitanteScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final qrData = {
      'residenteId': user.id,
      'apartamento': user.apartamento,
      'fechaGeneracion': DateTime.now().toIso8601String(),
      'validoHasta': DateTime.now().add(Duration(hours: 24)).toIso8601String(),
    };

    return Scaffold(
      appBar: AppBar(title: Text('Generar QR Visitante')),
      body: Center(
        child: QrImageView(
          data: jsonEncode(qrData),
          version: QrVersions.auto,
          size: 300,
        ),
      ),
    );
  }
}

// Vigilante escanea QR
class EscanearQRScreen extends StatefulWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Escanear QR Visitante')),
      body: QRView(
        key: qrKey,
        onQRViewCreated: _onQRViewCreated,
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    controller.scannedDataStream.listen((scanData) {
      final data = jsonDecode(scanData.code!);
      // Validar y autorizar entrada
      _autorizarEntrada(data);
    });
  }
}
```

---

#### 3. Integración de Pagos 💳
**Ubicación:** Crear `lib/services/payment_service.dart`

**Dependencias:**
```yaml
dependencies:
  flutter_stripe: ^9.4.0  # Para tarjetas
  # Wompi o PSE para Colombia
```

**Implementación:**
```dart
class PaymentService {
  Future<PaymentResult> procesarPago({
    required double monto,
    required String concepto,
    required MetodoPago metodo,
  }) async {
    switch (metodo) {
      case MetodoPago.nequi:
        return _pagarConNequi(monto);
      case MetodoPago.pse:
        return _pagarConPSE(monto);
      case MetodoPago.tarjeta:
        return _pagarConTarjeta(monto);
      default:
        return PaymentResult(success: false, mensaje: 'Método no soportado');
    }
  }
}

enum MetodoPago {
  efectivo,
  nequi,
  daviplata,
  pse,
  tarjeta,
}
```

---

#### 4. Tema Claro/Oscuro
**Ubicación:** Actualizar `lib/utils/app_theme.dart`

**Implementación:**
```dart
class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }

  ThemeData get currentTheme {
    return _isDarkMode ? AppTheme.darkTheme : AppTheme.lightTheme;
  }
}

// Agregar en AppTheme
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
    // ... resto de la configuración
  );
}
```

---

## 📦 Dependencias Adicionales Necesarias

Agregar en `pubspec.yaml`:

```yaml
dependencies:
  # Notificaciones Push
  firebase_core: ^2.24.0
  firebase_messaging: ^14.7.6
  flutter_local_notifications: ^16.3.0

  # QR
  qr_flutter: ^4.1.0
  qr_code_scanner: ^1.0.1

  # Pagos
  flutter_stripe: ^9.4.0

  # Firma digital
  signature: ^5.4.0

  # Video/Cámaras
  video_player: ^2.8.1
  webview_flutter: ^4.4.2

  # Archivos
  path_provider: ^2.1.1
  open_file: ^3.3.2
  pdf: ^3.10.7
  excel: ^4.0.2

  # Estado global
  get_it: ^7.6.4

  # Assets en pubspec
  assets:
    - assets/images/espacios/
    - assets/images/logos/
    - assets/images/icons/
```

---

## 🗂️ Estructura de Carpetas Recomendada

```
lib/
├── config/
│   ├── tab_config.dart ✅
│   ├── routes.dart
│   └── constants.dart
├── models/ ✅
├── screens/
│   ├── residente/ ✅
│   ├── admin/ ✅
│   ├── vigilante/ ✅
│   ├── alcaldia/ ✅
│   └── shared/
│       ├── alarma_sos_screen.dart (NUEVO)
│       ├── generar_qr_screen.dart (NUEVO)
│       └── payment_screen.dart (NUEVO)
├── services/
│   ├── api_service.dart ✅
│   ├── auth_service.dart ✅
│   ├── notification_service.dart (NUEVO)
│   ├── payment_service.dart (NUEVO)
│   └── camera_service.dart (NUEVO)
├── widgets/ ✅
├── utils/
│   ├── app_theme.dart ✅
│   ├── validators.dart (NUEVO)
│   └── formatters.dart (NUEVO)
└── main.dart ✅
```

---

## ✅ Checklist de Implementación

### Prioridad ALTA 🔴
- [ ] Sistema de notificaciones push (Firebase)
- [ ] Control de vehículos con timer en vivo
- [ ] Generar recibos de pago (PDF)
- [ ] Chat con 4 canales separados
- [ ] Sorteo de parqueaderos funcional
- [ ] Carga masiva de pagos (CSV)
- [ ] Imágenes en espacios de reserva

### Prioridad MEDIA 🟡
- [ ] Sistema de reseñas en emprendimientos
- [ ] Llamada directa desde botón Contactar
- [ ] PQRS con seguimiento completo
- [ ] Encuestas con gráficos en tiempo real
- [ ] Alarma SOS
- [ ] Tema claro/oscuro

### Prioridad BAJA 🟢
- [ ] Juegos comunitarios
- [ ] QR para visitantes
- [ ] Integración de pagos externos
- [ ] Cámaras en vivo (WebRTC)
- [ ] Reconocimiento facial
- [ ] Mapa interactivo del conjunto

---

## 🚀 Próximos Pasos

1. **Configurar Firebase** para notificaciones push
2. **Implementar timer en vivo** para control de vehículos
3. **Mejorar sistema de chat** con canales separados
4. **Agregar imágenes** a espacios de reserva
5. **Crear servicio de notificaciones**
6. **Implementar generación de PDF** para recibos

---

## 📞 Soporte Técnico

- Email: soporte@araliadecastilla.com
- Teléfono: +57 300 123 4567
- Documentación: [docs.araliadecastilla.com](https://docs.araliadecastilla.com)

---

**Última actualización:** 2 de octubre de 2025
**Versión del documento:** 1.0
