# 🐛 Cómo ejecutar Debug en Flutter (VS Code)

## ❌ NO ejecutar en terminal
- ❌ **No** abrir PowerShell/CMD
- ❌ **No** escribir comandos
- ❌ **No** usar `flutter run` manualmente

## ✅ Ejecutar DENTRO de VS Code

### **Método 1: Panel de Debug (Más fácil)**

1. **Abrir VS Code** con la carpeta `conjunto_residencial_flutter`
2. **Panel izquierdo** → Hacer clic en el ícono **🐛** (Run and Debug)
3. **Arriba verás un dropdown** que dice: `Flutter Debug - Chrome`
4. **Hacer clic en el botón verde ▶️** al lado

### **Método 2: Atajo F5**

1. **Estar en VS Code** (ventana activa)
2. **Presionar F5** en el teclado
3. **Si pregunta qué debugger usar**, seleccionar **"Dart & Flutter"**

### **Método 3: Desde el menú**

1. **Run** → **Start Debugging** (en la barra de menú)

## 🎯 **Configuraciones disponibles**

Cuando hagas clic en el dropdown verás:

- **Flutter Debug - Chrome** ← Para ejecutar en navegador
- **Flutter Debug - Windows** ← Para ejecutar como app de escritorio
- **Flutter Debug - Auto Device** ← Detecta automáticamente
- **Debug App + Server** ← Inicia servidor Node.js también

## 📊 **Qué esperar cuando ejecutes**

### ✅ **Si funciona correctamente:**
```
Launching lib/main.dart on Chrome in debug mode...
✓ Built build/web.
✓ Web server started at http://localhost:xxxxx
Debug service listening on ws://127.0.0.1:xxxxx
```

### ❌ **Si hay errores:**
- Se mostrará el error exacto en el **Debug Console**
- Podrás ver qué comando falló
- Información detallada sobre el problema

## 🖥️ **Paneles que se abrirán**

Cuando ejecutes debug, VS Code mostrará:

1. **Debug Console** (abajo) - Logs en tiempo real
2. **Terminal** (abajo) - Comandos ejecutados
3. **Variables** (izquierda) - Estado de la app
4. **Call Stack** (izquierda) - Flujo de ejecución

## 🔧 **Controles durante debug**

Una vez que esté ejecutando:

- **⏸️ Pause** - Pausar ejecución
- **▶️ Continue** - Continuar
- **🔄 Hot Reload** - Recargar cambios (o presiona `r` en terminal)
- **🔁 Hot Restart** - Reiniciar app (o presiona `R` en terminal)
- **🛑 Stop** - Detener debug

## 🚨 **Si F5 no funciona**

1. **Verificar que VS Code esté en la carpeta correcta**:
   - Debe mostrar `CONJUNTO_RESIDENCIAL_FLUTTER` arriba
   - Debe ver `lib/`, `pubspec.yaml`, etc.

2. **Verificar extensiones instaladas**:
   - Flutter (Dart Code)
   - Dart (Dart Code)

3. **Reiniciar Dart Analysis Server**:
   - Ctrl+Shift+P → `Dart: Restart Analysis Server`

4. **Si sigue sin funcionar**:
   - Ctrl+Shift+P → `Flutter: Get Packages`
   - Reiniciar VS Code

## 💡 **Tip importante**

**NUNCA** ejecutar Flutter desde terminal mientras está corriendo desde VS Code, puede causar conflictos.

---

**Una vez que presiones ▶️ o F5, el debugger te mostrará exactamente qué está pasando!**