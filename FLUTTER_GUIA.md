# 📱 Guía de Flutter - Conjunto Aralia de Castilla

## 🛠 Estado Actual

### ✅ Qué funciona:
- **Estructura completa**: Navegación, screens, servicios, modelos
- **Diseño moderno**: UI con Material Design 3 y animaciones
- **Autenticación**: Login/register con tokens y SharedPreferences
- **API Service**: Configurado para conectar con tu servidor Node.js
- **Estado**: Provider para gestión de estado
- **Pantallas**: Dashboard, Reservas, Pagos, Chat, Emprendimientos

### ⚠️ Problemas corregidos:
- **URL API**: Cambiada de `localhost:3000` → `localhost:8765` ✅
- **Puerto correcto**: Ahora apunta a tu servidor Express ✅

## 🚀 Cómo ejecutar Flutter

### 1. **Verificar Flutter** (desde terminal normal):
```bash
flutter doctor
```

### 2. **Ir a la carpeta Flutter**:
```bash
cd conjunto_residencial_flutter
```

### 3. **Instalar dependencias**:
```bash
flutter pub get
```

### 4. **Ejecutar en modo debug**:
```bash
flutter run
```

### 5. **O ejecutar en dispositivo específico**:
```bash
flutter devices  # Ver dispositivos disponibles
flutter run -d chrome  # Para web
flutter run -d windows  # Para Windows
```

## 📂 Estructura del proyecto Flutter

```
lib/
├── main.dart              # Punto de entrada
├── models/                # Modelos de datos
│   ├── user.dart
│   ├── reserva.dart
│   └── pago.dart
├── services/              # Servicios (API, Auth)
│   ├── api_service.dart   # ✅ URL corregida a :8765
│   └── auth_service.dart
├── screens/               # Pantallas de la app
│   ├── auth/              # Login/Register
│   ├── main/              # Dashboard/Navegación
│   ├── reservas/          # Sistema de reservas
│   ├── pagos/             # Gestión de pagos
│   ├── chat/              # Chat comunitario
│   └── emprendimientos/   # Negocios residentes
├── widgets/               # Componentes reutilizables
└── utils/                 # Temas y utilidades
```

## 🔗 Conexión con el servidor

### Para desarrollo local:

1. **Iniciar el servidor Node.js**:
```bash
# Desde la raíz del proyecto
npm run dev
```

2. **Verificar que el servidor esté en puerto 8765**:
```
http://localhost:8765
```

3. **Ejecutar Flutter**:
```bash
cd conjunto_residencial_flutter
flutter run
```

### Para dispositivo físico:

Debes cambiar la URL en `api_service.dart` por tu IP local:
```dart
// Cambiar localhost por tu IP
static const String baseUrl = 'http://192.168.1.100:8765/api';
```

## 📱 Pantallas implementadas

1. **🏠 Dashboard**: Vista principal con estadísticas
2. **📅 Reservas**: Sistema de reservas estilo calendario
3. **💳 Pagos**: Gestión de pagos y administración
4. **💬 Chat**: Chat comunitario en tiempo real
5. **🏪 Emprendimientos**: Directorio de negocios

## 🔧 Para desarrollo

### Comandos útiles:
```bash
# Hot reload (mientras corre)
r

# Hot restart
R

# Quit
q

# Ver logs
flutter logs

# Limpiar build
flutter clean

# Regenerar dependencias
flutter pub get
```

## 🐛 Problemas comunes

### Error de conexión:
- Verificar que el servidor Node.js esté corriendo en puerto 8765
- Verificar que la IP/URL sea correcta en `api_service.dart`

### Error de git en Flutter:
- Normal en algunos entornos de desarrollo
- No afecta el funcionamiento de la app

### Error de dependencias:
```bash
flutter clean
flutter pub get
flutter run
```

## 🎯 Próximos pasos

1. **Probar la conexión**: Verificar login/register funcione
2. **Completar funcionalidades**: PQR, Permisos
3. **Agregar WebSocket**: Para chat en tiempo real
4. **Optimizar UI**: Mejorar diseño según necesidades
5. **Testing**: Agregar pruebas unitarias

## 📊 Usuarios de prueba

Puedes probar con estos usuarios:
- **Email**: `car-cbs@hotmail.com`
- **Password**: `password1`

- **Admin**: `shayoja@hotmail.com` / `password2`
- **Vigilante**: `car02cbs@gmail.com` / `password3`

---

💡 **Tip**: Para probar rápidamente, inicia primero el servidor (`npm run dev`) y luego Flutter (`flutter run`).