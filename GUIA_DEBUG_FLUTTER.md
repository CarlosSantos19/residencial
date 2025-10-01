# 🔍 Guía completa de Debugging Flutter

## ✅ **Configuración completada**

He configurado VS Code completamente para debugging de Flutter:

- ✅ **launch.json** - 5 configuraciones de debug diferentes
- ✅ **tasks.json** - Tareas automáticas (analyze, clean, pub get, etc.)
- ✅ **settings.json** - Configuración específica de Flutter/Dart
- ✅ **PATH configurado** - Git visible para Flutter

## 🚀 **Pasos para usar el Debugger**

### **Paso 1: Abrir VS Code correctamente**
```bash
# Ir a la carpeta Flutter (importante!)
cd conjunto_residencial_flutter

# Abrir VS Code desde esa carpeta
code .
```

### **Paso 2: Verificar extensiones**
En VS Code, verifica que tienes instaladas:
- ✅ **Flutter** (Dart Code)
- ✅ **Dart** (Dart Code)

### **Paso 3: Ejecutar diagnóstico**
1. **Ctrl+Shift+P**
2. **Escribir**: `Tasks: Run Task`
3. **Seleccionar**: `flutter: Doctor`
4. **Ver output** en el panel de abajo

### **Paso 4: Instalar dependencias con debugging**
1. **Ctrl+Shift+P**
2. **Escribir**: `Tasks: Run Task`
3. **Seleccionar**: `flutter: Get Packages`
4. **Ver si hay errores** en el output

### **Paso 5: Analizar código**
1. **Ctrl+Shift+P**
2. **Escribir**: `Tasks: Run Task`
3. **Seleccionar**: `flutter: Analyze`
4. **Revisar problemas** que aparezcan

### **Paso 6: Ejecutar en modo Debug**
1. **Ir a Debug panel** (Ctrl+Shift+D)
2. **Seleccionar configuración**:
   - **Flutter Debug - Chrome** (para web)
   - **Flutter Debug - Windows** (para escritorio)
   - **Flutter Debug - Auto Device** (detecta automáticamente)
3. **Presionar F5** o hacer clic en ▶️
4. **Ver output detallado** en Debug Console

## 🔍 **Configuraciones de Debug disponibles**

### 1. **Flutter Debug - Chrome**
- Ejecuta en navegador Chrome
- Ideal para desarrollo web
- Permite hot reload

### 2. **Flutter Debug - Windows**
- Ejecuta como app de escritorio
- Nativa de Windows
- Mejor rendimiento

### 3. **Flutter Debug - Auto Device**
- Detecta automáticamente dispositivos
- Usa el primer dispositivo disponible

### 4. **Flutter Profile Mode**
- Para análisis de rendimiento
- Optimizaciones activadas

### 5. **Flutter Release Mode**
- Versión de producción
- Máxima optimización

### 6. **Debug App + Server**
- Inicia automáticamente el servidor Node.js
- Luego ejecuta Flutter
- Configuración completa

## 🛠 **Tareas disponibles (Ctrl+Shift+P → Tasks: Run Task)**

- **flutter: Analyze** - Analizar código en busca de errores
- **flutter: Clean** - Limpiar archivos de build
- **flutter: Get Packages** - Instalar dependencias
- **flutter: Doctor** - Diagnóstico completo
- **Start Node Server** - Iniciar servidor backend

## 📊 **Interpretando los resultados del Debug**

### ✅ **Si funciona correctamente:**
```
✓ Flutter (Channel stable, 3.24.1)
✓ Android toolchain
✓ Chrome - develop for the web
✓ Visual Studio Code
```

### ❌ **Si hay errores comunes:**

**Error: "Unable to find git"**
- ✅ **Solucionado** en nuestra configuración
- Git está en el PATH de todas las tareas

**Error: "No connected devices"**
- Ejecutar: `flutter devices`
- Chrome debe aparecer como dispositivo

**Error: "Packages not found"**
- Ejecutar tarea: `flutter: Get Packages`
- Verificar que se creó `pubspec.lock`

**Error: "Dart SDK not found"**
- ✅ **Configurado** en settings.json
- Path: `C:\dev\flutter_windows_3.24.1-stable\flutter\bin\cache\dart-sdk`

## 🔧 **Debugging paso a paso**

1. **Abrir VS Code** en la carpeta Flutter
2. **F5** para ejecutar debug
3. **Ver Debug Console** (abajo) para logs detallados
4. **Ver Terminal** para comandos ejecutados
5. **Ver Problems** (Ctrl+Shift+M) para errores de código

## 💡 **Tips de debugging**

- **Hot Reload**: `r` en el terminal mientras corre
- **Hot Restart**: `R` en el terminal
- **Breakpoints**: Clic en margen izquierdo del código
- **Variables**: Panel izquierdo durante debug
- **Call Stack**: Ver flujo de ejecución

## 🚨 **Si algo sigue fallando**

Ejecutar en este orden:
1. **flutter: Clean**
2. **flutter: Doctor**
3. **flutter: Get Packages**
4. **flutter: Analyze**
5. **Flutter Debug - Chrome**

---

**Todo está configurado para darte máxima información sobre qué está pasando con Flutter.**