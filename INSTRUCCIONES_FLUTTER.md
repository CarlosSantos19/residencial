# 🔧 Instrucciones para Ejecutar la App Flutter

## ❌ Problema Actual
El error `Unable to find git in your PATH` indica que Git no está instalado o no está en el PATH del sistema.

## ✅ Solución Paso a Paso

### 1. **Instalar Git**
1. Ve a: https://git-scm.com/download/win
2. Descarga la versión más reciente para Windows
3. **Durante la instalación**:
   - ✅ Marca "Git from the command line and also from 3rd-party software"
   - ✅ Esto agregará Git al PATH automáticamente

### 2. **Verificar la Instalación**
```bash
# Reinicia el terminal/VS Code y verifica:
git --version
# Debería mostrar: git version 2.x.x.windows.x
```

### 3. **Instalar Flutter (si no lo tienes)**
1. Ve a: https://docs.flutter.dev/get-started/install/windows
2. Descarga Flutter SDK
3. Extrae a: `C:\flutter`
4. Agrega `C:\flutter\bin` al PATH del sistema

### 4. **Verificar Flutter**
```bash
flutter doctor
# Esto te dirá qué necesitas instalar
```

### 5. **Ejecutar la App**
```bash
# Navegar al proyecto
cd conjunto_residencial_flutter

# Instalar dependencias
flutter pub get

# Verificar dispositivos disponibles
flutter devices

# Ejecutar en emulador/dispositivo
flutter run
```

## 📱 Dispositivos para Probar

### **Android**
- **Emulador**: Crear desde Android Studio
- **Dispositivo físico**: Habilitar USB Debugging

### **Windows Desktop** (más fácil para pruebas)
```bash
# Habilitar soporte para Windows
flutter config --enable-windows-desktop

# Ejecutar en Windows
flutter run -d windows
```

### **Web** (navegador)
```bash
# Habilitar soporte web
flutter config --enable-web

# Ejecutar en navegador
flutter run -d chrome
```

## 🔍 Verificar Backend

Asegúrate de que el servidor Node.js esté ejecutándose:

```bash
# En otra terminal, en el directorio raíz
cd C:\Users\Administrador\Documents\residencial
npm start

# Debería mostrar:
# 🏢 Servidor del conjunto residencial corriendo en http://localhost:3000
```

## 📁 Estructura del Proyecto Flutter

```
conjunto_residencial_flutter/
├── lib/
│   ├── main.dart                 # Punto de entrada
│   ├── models/                   # Modelos de datos
│   ├── services/                 # Servicios y API
│   ├── screens/                  # Pantallas
│   ├── widgets/                  # Widgets reutilizables
│   └── utils/                    # Utilidades y temas
├── pubspec.yaml                  # Dependencias
└── README.md                     # Documentación
```

## 🎯 Datos de Prueba

**Usuario Demo:**
- Email: `car-cbs@hotmail.com`
- Contraseña: `password1`

## 🚨 Problemas Comunes

### Git no encontrado
```bash
# Verificar PATH
echo $PATH  # Linux/Mac
echo %PATH% # Windows

# Reinstalar Git si es necesario
```

### Flutter no encontrado
```bash
# Verificar instalación
flutter --version

# Si no funciona, agregar al PATH:
# Windows: C:\flutter\bin
```

### Emulador no funciona
- Instalar Android Studio
- Crear un AVD (Android Virtual Device)
- O usar un dispositivo físico con USB Debugging

### Dependencias no se instalan
```bash
# Limpiar cache
flutter clean
flutter pub get
```

## 🔄 Comandos Útiles

```bash
# Limpiar proyecto
flutter clean

# Instalar dependencias
flutter pub get

# Ver dispositivos disponibles
flutter devices

# Ejecutar en modo debug
flutter run

# Ejecutar en modo release
flutter run --release

# Hot reload (durante desarrollo)
# Presiona 'r' en la consola

# Hot restart
# Presiona 'R' en la consola
```

## ✨ Características de la App

Una vez que funcione, verás:

### 🔐 **Pantalla de Login**
- Diseño moderno con gradientes
- Animaciones fluidas
- Validación de formularios
- Usuario demo precargado

### 🏠 **Dashboard**
- Cards de estadísticas animadas
- Actividad reciente
- Acciones rápidas con FAB
- Navegación con bottom bar

### 📱 **5 Secciones Principales**
1. **Dashboard** - Resumen general
2. **Reservas** - Gestión de espacios
3. **Pagos** - Control financiero
4. **Chat** - Comunicación comunitaria
5. **Emprendimientos** - Directorio de negocios

### 🎨 **Diseño Profesional**
- Material 3 Design
- Animaciones nativas
- Paleta de colores consistente
- Responsive design

## 📞 Soporte

Si sigues teniendo problemas:

1. Verifica que Git esté instalado: `git --version`
2. Verifica que Flutter esté instalado: `flutter doctor`
3. Asegúrate de que el backend esté corriendo en puerto 3000
4. Prueba primero en Windows Desktop: `flutter run -d windows`

---

**¡La app Flutter está lista! Solo necesitas resolver el problema de Git para empezar a probarla.**