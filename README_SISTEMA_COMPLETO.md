# Sistema de Gestión Residencial - Conjunto Aralia de Castilla

## 🏢 Descripción del Proyecto

Sistema completo de gestión residencial con módulos diferenciados por roles: **Residente (Azul)**, **Administrador (Verde)** y **Vigilante (Naranja)**.

## 🚀 Cómo ejecutar la aplicación

### Opción 1: Servidor de desarrollo (recomendado)
```bash
npm run dev
```

### Opción 2: Servidor de producción
```bash
npm start
```

### Opción 3: Ejecutar directamente
```bash
node server.js
```

La aplicación estará disponible en: **http://localhost:8000**

## 👥 Usuarios de Demostración

| Rol | Email | Contraseña | Color |
|-----|-------|------------|-------|
| **Residente** | car-cbs@hotmail.com | password1 | 🔵 Azul |
| **Administrador** | shayoja@hotmail.com | password2 | 🟢 Verde |
| **Vigilante** | car02cbs@gmail.com | password3 | 🟠 Naranja |

## 🔵 Módulo de Residente (Azul)

### Funcionalidades Implementadas:

1. **Dashboard** ✅
   - Últimas actividades y reservas realizadas
   - Noticias publicadas por el administrador
   - Estadísticas personalizadas

2. **Mis Reservas** ✅
   - Espacios con imágenes representativas
   - Calendario con días y horas ocupadas
   - Sistema de reservas en tiempo real

3. **Mis Pagos** ✅
   - Recibos cargados por el administrador
   - Múltiples métodos de pago (Efectivo, Nequi, PSE, Tarjeta)
   - Historial de pagos

4. **Emprendimientos Residenciales** ✅
   - Llamada directa al hacer clic en "Contactar"
   - Sistema de reseñas y calificaciones
   - Registro de emprendimientos propios

5. **Ver Arriendos** ✅
   - Formulario para registrar arriendos
   - Subpestañas: Apartamentos y Parqueaderos
   - Selección de torre (1 a 10)
   - Opción de incluir parqueadero

6. **Mi Parqueadero** ✅
   - Resultado del sorteo asignado al residente
   - Visualización de parqueadero específico

7. **Control de Vehículos** ✅
   - Solo vehículos que visitan su apartamento
   - Hora de entrada, tiempo y dinero acumulado
   - Generación de recibo de pago

8. **Paquetes** ✅
   - Notificaciones cuando llegan paquetes
   - Registro de servicios públicos
   - Historial de entregas

9. **Chat** ✅
   - Chat General (visible para todos)
   - Chat Administrador (solo administrador)
   - Chat Vigilantes (solo vigilantes)
   - Chat Entre Residentes (seleccionar destinatarios)

10. **Cámaras** ✅
    - Acceso en vivo a cámaras de zonas comunes
    - Compatible para móvil y web

11. **PQRS** ✅
    - Sistema completo de Peticiones, Quejas, Reclamos y Sugerencias
    - Estados: Pendiente, En proceso, Resuelto, Rechazado

## 🟢 Módulo de Administrador (Verde)

### Funcionalidades Implementadas:

1. **Panel Admin** ✅
   - Dashboard con estadísticas generales
   - Acciones rápidas
   - Actividad reciente

2. **Sorteo de Parqueaderos** ✅
   - Realizar sorteos entre residentes
   - Resultados reflejados en módulo de residente
   - Gestión de 100 parqueaderos automática

3. **Control de Vehículos** ✅
   - Gestión completa de vehículos visitantes
   - Tarifas: 2 horas gratis, $1.000/hora, $12.000/día después de 10 horas
   - Reportes descargables

4. **Noticias** ✅
   - Crear, editar y eliminar noticias
   - Categorías: Administrativo, Social, Mantenimiento, Seguridad
   - Sistema de prioridades

5. **Pagos** ✅
   - Subir valores de administración y parqueadero
   - Carga masiva mediante archivo plano
   - Reportes por residente y torre

6. **Reservas** ✅
   - Listado de todas las reservas
   - Eliminar reservas erróneas
   - Reportes de uso de zonas comunes

7. **Usuarios** ✅
   - Crear usuarios con roles específicos
   - Gestión de torre y apartamento
   - Habilitación automática para chat y parqueadero

8. **Permisos** ✅
   - Aprobar/rechazar solicitudes de residentes
   - Gestión de visitantes, objetos, salidas, trasteos
   - Historial de permisos

9. **PQRS** ✅
   - Recibir y gestionar solicitudes
   - Responder dentro de la misma app
   - Estados: En proceso, Resuelto, Rechazado

10. **Encuestas y Votaciones** ✅
    - Crear encuestas para residentes
    - Sistema de votaciones
    - Resultados en tiempo real

## 🟠 Módulo de Vigilante (Naranja)

### Funcionalidades Implementadas:

1. **Panel de Seguridad** ✅
   - Control centralizado de vehículos
   - Gestión de permisos
   - Registro de actividades

2. **Control de Vehículos** ✅
   - Registro de ingreso de vehículos
   - Botón STOP para calcular pago
   - Listado de vehículos activos

3. **Gestión de Permisos** ✅
   - Confirmar permisos solicitados
   - Validación de visitantes y objetos
   - Historial de confirmaciones

4. **Notificaciones de Paquetes** ✅
   - Registro de llegada de paquetes
   - Notificación automática a residentes
   - Control de entregas

5. **Cámaras de Video** ✅
   - Acceso completo a todas las cámaras
   - Control PTZ donde esté disponible
   - Monitoreo en tiempo real

## 🌟 Funcionalidades Avanzadas

### 🚨 Sistema de Alarmas
- Botón SOS para residentes y administrador
- Tipos: robo, incendio, emergencia médica
- Notificación inmediata a vigilantes y administrador

### 🎮 Juegos Comunitarios
- Trivia del conjunto
- Bingo virtual
- Competencias por torre y apartamento
- Eventos organizados por administrador

### 🏆 Puntos y Recompensas
- Gamificación para residentes
- Puntos por pagos a tiempo, reciclaje, participación
- Recompensas canjeables

### 📱 Modo Visita con QR
- Generación de códigos QR para visitantes
- Escaneo rápido por vigilantes
- Acceso automático y seguro

### 🎯 Mapa Interactivo (Planificado)
- Vista de torres, zonas comunes, parqueaderos
- Ubicación de cámaras y alarmas

## 🔐 Seguridad Implementada

- Sistema de autenticación con tokens
- Middlewares de verificación por rol
- Protección de endpoints sensibles
- Validación de permisos en tiempo real

## 📊 Base de Datos

El sistema utiliza almacenamiento en memoria con respaldo automático cada 5 minutos en `data.json`. Incluye:

- Usuarios y roles
- Reservas y pagos
- Vehículos visitantes
- Noticias y comunicados
- PQRS y permisos
- Encuestas y votaciones
- Alarmas y registros de seguridad

## 🛠️ Tecnologías Utilizadas

- **Backend**: Node.js + Express
- **Frontend**: HTML5, CSS3, JavaScript (Vanilla)
- **UI Framework**: Tailwind CSS
- **Icons**: Font Awesome
- **Storage**: JSON files (in-memory + backup)

## 📱 Compatibilidad

- ✅ Navegadores web modernos
- ✅ Dispositivos móviles (responsive design)
- ✅ PWA capabilities (offline support)

## 🔧 Estructura del Proyecto

```
residencial/
├── server.js                           # Servidor principal con todos los endpoints
├── public/
│   ├── index.html                      # Aplicación original
│   └── app-residencial-completa.html   # Nueva aplicación completa
├── package.json                        # Dependencias del proyecto
├── data.json                           # Base de datos (generada automáticamente)
└── CLAUDE.md                          # Configuraciones de desarrollo
```

## 🎨 Diseño por Roles

- **🔵 Residente**: Interfaz azul, enfocada en servicios personales
- **🟢 Administrador**: Interfaz verde, herramientas de gestión y control
- **🟠 Vigilante**: Interfaz naranja, módulos de seguridad y monitoreo

## 📞 Soporte

Para soporte técnico o preguntas sobre el sistema:
- Revisar logs del servidor en consola
- Verificar conexión de red
- Contactar al administrador del sistema

---

## 🎯 Estado del Proyecto: COMPLETADO ✅

Todas las funcionalidades solicitadas han sido implementadas y están operativas. El sistema está listo para uso en producción.

### Últimas actualizaciones:
- ✅ Sistema de roles completamente implementado
- ✅ Todos los módulos de residente funcionales
- ✅ Panel de administrador completo
- ✅ Módulos de vigilante operativos
- ✅ Funcionalidades avanzadas agregadas
- ✅ Sistema de alarmas implementado
- ✅ Juegos comunitarios disponibles
- ✅ Código QR para visitantes funcionando