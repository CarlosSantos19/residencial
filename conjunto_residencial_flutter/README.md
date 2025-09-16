# 📱 Conjunto Aralia de Castilla - App Flutter

Una aplicación móvil moderna y profesional para la gestión del conjunto residencial, desarrollada con Flutter.

## ✨ Características

### 🔐 Autenticación
- Login y registro con validación
- Gestión de sesiones con SharedPreferences
- Usuario demo: `car-cbs@hotmail.com` / `password1`

### 🏠 Dashboard Inteligente
- Resumen de actividades y estadísticas
- Acciones rápidas
- Navegación fluida con animaciones

### 📅 Gestión de Reservas
- Reserva de espacios comunes
- Calendario visual
- Estados de reserva (confirmada, pendiente, completada)

### 💳 Control de Pagos
- Visualización de pagos pendientes y realizados
- Resumen financiero
- Botones de acción para pagos

### 💬 Chat Comunitario
- Chat general y administrativo
- Mensajes en tiempo real
- Interfaz tipo WhatsApp

### 🏪 Emprendimientos
- Directorio de negocios de residentes
- Contacto directo (llamadas y chat)
- Categorización por tipo de negocio

## 🚀 Tecnologías Utilizadas

- **Flutter 3.10+**: Framework multiplataforma
- **Provider**: Gestión de estado
- **Google Fonts**: Tipografía Poppins
- **HTTP**: Conexión con API backend
- **SharedPreferences**: Almacenamiento local
- **Material 3**: Sistema de diseño moderno

## 📋 Prerequisitos

1. **Flutter SDK 3.10+**
   ```bash
   flutter --version
   ```

2. **Dart SDK 3.0+**

3. **Android Studio / Xcode** (para desarrollo móvil)

4. **Backend en Node.js** ejecutándose en `http://localhost:3000`

## 🔧 Instalación

1. **Navegar al directorio Flutter**:
   ```bash
   cd conjunto_residencial_flutter
   ```

2. **Instalar dependencias**:
   ```bash
   flutter pub get
   ```

3. **Verificar configuración**:
   ```bash
   flutter doctor
   ```

4. **Ejecutar en dispositivo/emulador**:
   ```bash
   flutter run
   ```

## 📱 Configuración de Desarrollo

### Android
1. Habilitar **USB Debugging** en tu dispositivo Android
2. O usar un **emulador Android** desde Android Studio

### iOS (solo en macOS)
1. Usar **simulador iOS** desde Xcode
2. O dispositivo físico con certificado de desarrollo

### Backend
1. Asegúrate de que el servidor Node.js esté ejecutándose:
   ```bash
   cd ../
   npm start
   ```

2. El servidor debe estar en `http://localhost:3000`

## 📂 Estructura del Proyecto

```
lib/
├── main.dart                 # Punto de entrada
├── models/                   # Modelos de datos
│   ├── user.dart
│   ├── reserva.dart
│   └── pago.dart
├── services/                 # Servicios y API
│   ├── auth_service.dart
│   └── api_service.dart
├── screens/                  # Pantallas
│   ├── auth/
│   │   ├── login_screen.dart
│   │   └── register_screen.dart
│   ├── main/
│   │   ├── dashboard_screen.dart
│   │   └── main_navigation.dart
│   ├── reservas/
│   ├── pagos/
│   ├── chat/
│   └── emprendimientos/
├── widgets/                  # Widgets reutilizables
│   ├── custom_button.dart
│   └── custom_text_field.dart
└── utils/                    # Utilidades y temas
    └── app_theme.dart
```

## 🎨 Sistema de Diseño

### Paleta de Colores
- **Primario**: `#3B82F6` (Azul)
- **Secundario**: `#10B981` (Verde)
- **Acento**: `#6366F1` (Púrpura)
- **Advertencia**: `#F59E0B` (Amarillo)
- **Error**: `#EF4444` (Rojo)

### Tipografía
- **Fuente**: Poppins (Google Fonts)
- **Pesos**: Regular (400), Medium (500), SemiBold (600), Bold (700)

### Animaciones
- **Duración**: 200-800ms
- **Curvas**: easeInOut, easeOutCubic
- **Transiciones**: Fade, Slide, Scale

## 🔗 Conectividad con Backend

### Configuración de API
- **URL Base**: `http://localhost:3000/api`
- **Endpoints disponibles**:
  - `POST /auth/login` - Iniciar sesión
  - `POST /auth/register` - Registrar usuario
  - `GET /auth/verify` - Verificar token
  - `GET /reservas` - Obtener reservas
  - `POST /reservas` - Crear reserva
  - `GET /pagos` - Obtener pagos
  - `PUT /pagos/:id` - Marcar pago como realizado

### Autenticación
- **Método**: Bearer Token
- **Almacenamiento**: SharedPreferences
- **Expiración**: Gestionada por el backend

## 🧪 Testing

```bash
# Ejecutar tests unitarios
flutter test

# Ejecutar tests de integración
flutter test integration_test/
```

## 📦 Build para Producción

### Android APK
```bash
flutter build apk --release
```

### Android App Bundle
```bash
flutter build appbundle --release
```

### iOS (solo en macOS)
```bash
flutter build ios --release
```

## 🚀 Características Avanzadas

### 🔔 Notificaciones Push (Future)
- Firebase Cloud Messaging
- Notificaciones locales
- Badges de contador

### 📷 Funcionalidades de Cámara (Future)
- Escáner QR para permisos
- Captura de evidencias
- Reconocimiento de documentos

### 🗃️ Almacenamiento Offline (Future)
- Base de datos local Hive
- Sincronización automática
- Funcionamiento sin conexión

## 📞 Soporte

Para reportar problemas o solicitar nuevas características:

1. **Issues GitHub**: [Crear issue](https://github.com/tu-repo/issues)
2. **Email**: car-cbs@hotmail.com
3. **Chat**: Usar la funcionalidad de chat de la app

## 📄 Licencia

Este proyecto está bajo la Licencia MIT. Ver el archivo `LICENSE` para más detalles.

---

**Desarrollado con ❤️ para la comunidad de Aralia de Castilla**

### 🎯 Próximas Mejoras

- [ ] Integración con Firebase
- [ ] Notificaciones push
- [ ] Modo offline completo
- [ ] Escáner QR
- [ ] Pagos en línea
- [ ] Geolocalización
- [ ] Modo oscuro
- [ ] Múltiples idiomas
- [ ] Accesibilidad completa