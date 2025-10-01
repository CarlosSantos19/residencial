# 🔧 Solución para errores en Flutter

## ❌ Problema: "Todo me sale en rojo"

Los errores en rojo en Flutter suelen indicar que:
1. **Las dependencias no están instaladas**
2. **Flutter no puede resolver las imports**
3. **El proyecto no está inicializado correctamente**

## ✅ Soluciones paso a paso:

### 🛠 Opción 1: Solución desde VS Code (Recomendado)

1. **Abrir VS Code**
2. **Abrir la carpeta Flutter**: `conjunto_residencial_flutter`
3. **Abrir Command Palette** (Ctrl+Shift+P)
4. **Ejecutar**: `Flutter: Clean`
5. **Ejecutar**: `Flutter: Get Packages`
6. **Reiniciar VS Code**

### 🛠 Opción 2: Solución manual

1. **Instalar Git** (necesario para Flutter):
   - Descargar de: https://git-scm.com/download/win
   - Añadir al PATH del sistema

2. **Ejecutar comandos** (desde terminal):
```bash
cd conjunto_residencial_flutter
flutter clean
flutter pub get
```

3. **Si persisten errores**:
```bash
flutter doctor
flutter pub deps
flutter analyze
```

### 🛠 Opción 3: Recrear proyecto (Última opción)

Si nada funciona, puedes recrear el proyecto:

```bash
# Desde la raíz del proyecto
flutter create conjunto_residencial_flutter_nuevo
# Luego copiar solo la carpeta lib/ al nuevo proyecto
```

## 🔍 Verificar que todo funciona:

### Archivos que DEBEN existir:
- ✅ `pubspec.yaml` - Configuración del proyecto
- ⚠️ `pubspec.lock` - Este se genera automáticamente
- ✅ `lib/main.dart` - Punto de entrada
- ✅ `lib/` - Todo el código fuente

### Dependencias verificadas:
```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.6      # ✅
  google_fonts: ^6.1.0         # ✅
  provider: ^6.1.1             # ✅
  http: ^1.1.2                 # ✅
  shared_preferences: ^2.2.2   # ✅
  intl: ^0.19.0               # ✅
```

## 🚀 Para probar que funciona:

1. **Ejecutar el servidor Node.js**:
```bash
# Desde la raíz
npm run dev
```

2. **Ejecutar Flutter**:
```bash
cd conjunto_residencial_flutter
flutter run -d chrome  # Para web
flutter run -d windows # Para Windows
```

## 🐛 Errores comunes y soluciones:

### Error: "Unable to find git"
**Solución**: Instalar Git y añadirlo al PATH

### Error: "Target of URI doesn't exist"
**Solución**: Ejecutar `flutter pub get`

### Error: "The method 'X' isn't defined"
**Solución**: Verificar imports y dependencias

### Error: "No named parameter"
**Solución**: Verificar versión de Flutter y dependencias

## 📋 Comandos útiles para debug:

```bash
# Verificar estado de Flutter
flutter doctor -v

# Ver todos los dispositivos disponibles
flutter devices

# Limpiar completamente el proyecto
flutter clean
flutter pub get

# Analizar código en busca de errores
flutter analyze

# Ver dependencias instaladas
flutter pub deps
```

## 💡 Tip final:

Si tienes **VS Code con la extensión de Flutter**, el método más fácil es:
1. Abrir VS Code
2. Ir a Command Palette (Ctrl+Shift+P)
3. Escribir "Flutter: Doctor" y ejecutarlo
4. Seguir las recomendaciones que aparezcan

**El código Flutter está correcto**, solo necesita que las dependencias se instalen correctamente.