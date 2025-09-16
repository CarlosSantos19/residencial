# Sistema de Gestión Conjunto Aralia de Castilla

Sistema web completo para la gestión de un conjunto residencial con múltiples módulos integrados.

## 🏢 Características Principales

### 🔐 Autenticación
- Sistema de login/registro
- Usuario demo: `car-cbs@hotmail.com` / `password1`
- Autenticación basada en tokens

### 📊 Dashboard
- Vista general del conjunto residencial
- Estadísticas de reservas, pagos y actividades
- Interfaz intuitiva y responsive

### 📅 Sistema de Reservas
- Reservas estilo Outlook con calendario
- Espacios disponibles: Salón Social, Gimnasio, Piscina, Zona BBQ, Cancha
- Selección de fecha y hora
- Gestión de disponibilidad

### 💬 Chat Comunidad
- Chat general y de administración
- Chat privado entre residentes
- Sistema de solicitudes de chat privado
- Notificaciones en tiempo real

### 🏠 Gestión de Arriendos
- **Apartamentos**: Registro de propiedades en arriendo
- **Parqueaderos**: Gestión de espacios de parqueo en arriendo
- Filtros por torre, estado y precio
- Formularios dinámicos según tipo de propiedad

### 🎲 Sistema de Sorteo de Parqueaderos
- Sorteo para 100 parqueaderos (P-001 a P-100)
- Distribución por niveles (Sótano 1, 2, 3)
- Generación automática de participantes
- Descarga de resultados en CSV

### 🚗 Control de Vehículos Visitantes
- Registro de ingreso con datos completos
- Sistema de tarifas automático:
  - Primeras 2 horas: **GRATIS**
  - Hora 3+: **$1,000/hora**
  - Después de 15 horas: **$12,000 tarifa plana**
- Historial en tiempo real
- Último registro visible en modal
- Generación automática de recibos

### 📰 Sistema de Noticias
- Publicación de eventos del conjunto
- Filtros por categoría
- Modal de detalles de noticias

### 📝 Módulos Adicionales
- **PQR**: Peticiones, Quejas y Reclamos
- **Permisos**: Gestión de autorizaciones
- **Emprendimientos**: Promoción de negocios de residentes

## 🛠 Tecnologías

### Frontend
- **HTML5, CSS3, JavaScript** (Vanilla)
- **Tailwind CSS** para estilos
- **Font Awesome** para iconografía
- Diseño responsive y moderno

### Backend
- **Node.js** con Express
- **Almacenamiento en memoria** (sin base de datos)
- **API RESTful** completa
- Sistema de autenticación con tokens

### Flutter (Incluido)
- Aplicación móvil completa
- Misma funcionalidad que la web
- Material Design 3
- Provider para gestión de estado

## 🚀 Instalación y Uso

### Requisitos
- Node.js instalado
- Git instalado

### Pasos
1. **Clonar el repositorio**
   ```bash
   git clone <repository-url>
   cd residencial
   ```

2. **Instalar dependencias**
   ```bash
   npm install
   ```

3. **Iniciar el servidor**
   ```bash
   npm start
   # o
   node server.js
   ```

4. **Acceder a la aplicación**
   - Abrir navegador en: `http://localhost:8081`
   - Usuario demo: `car-cbs@hotmail.com`
   - Contraseña: `password1`

## 📱 Aplicación Flutter

### Estructura del proyecto Flutter
```
conjunto_residencial_flutter/
├── lib/
│   ├── main.dart
│   ├── screens/
│   ├── services/
│   ├── widgets/
│   └── utils/
├── pubspec.yaml
└── README.md
```

### Para ejecutar la app Flutter
```bash
cd conjunto_residencial_flutter
flutter pub get
flutter run
```

## 📊 Endpoints API

### Autenticación
- `POST /api/auth/login` - Iniciar sesión
- `POST /api/auth/register` - Registrar usuario

### Reservas
- `GET /api/reservas` - Obtener reservas
- `POST /api/reservas` - Crear reserva

### Vehículos
- `GET /api/vehiculos-visitantes` - Lista de vehículos
- `POST /api/vehiculos-visitantes/ingreso` - Registrar ingreso
- `POST /api/vehiculos-visitantes/salida` - Procesar salida
- `GET /api/vehiculos-visitantes/hoy` - Vehículos del día

### Arriendos
- `GET /api/apartamentos-arriendo` - Apartamentos en arriendo
- `GET /api/parqueaderos-arriendo` - Parqueaderos en arriendo
- `POST /api/arriendos` - Registrar nuevo arriendo

### Chat
- `GET /api/usuarios` - Lista de usuarios
- `POST /api/chat/solicitar` - Solicitar chat privado
- `GET /api/chat/solicitudes` - Obtener solicitudes
- `POST /api/chat/responder` - Responder solicitud

### Noticias
- `GET /api/noticias` - Obtener noticias
- `GET /api/noticias/:id` - Detalle de noticia

## 👨‍💻 Características de Desarrollo

- **Código limpio y documentado**
- **Arquitectura modular**
- **API RESTful bien estructurada**
- **Responsive design**
- **Manejo de errores**
- **Validaciones frontend y backend**

## 🎯 Usuarios Predefinidos

El sistema incluye 6 usuarios de prueba:
1. `car-cbs@hotmail.com` (Demo principal)
2. `maria.gonzalez@email.com`
3. `carlos.ruiz@email.com`
4. `ana.martinez@email.com`
5. `luis.rodriguez@email.com`
6. `sofia.lopez@email.com`

Contraseña para usuarios demo: `demo123` (excepto el principal)

## 📝 Notas de Desarrollo

- **Sin base de datos**: Los datos se almacenan en memoria
- **Autenticación simple**: Tokens Base64 para desarrollo
- **Datos de prueba**: Incluye datos simulados para testing
- **Escalable**: Preparado para migrar a base de datos real

## 🎨 Interfaz

- **Tema moderno** con gradientes y colores profesionales
- **Iconografía consistente** con Font Awesome
- **Animaciones suaves** para mejor UX
- **Feedback visual** en todas las interacciones
- **Modal systems** para workflows complejos

---

🏢 **Conjunto Aralia de Castilla** - Tu hogar, más conectado