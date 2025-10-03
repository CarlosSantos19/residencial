# 🚀 Guía Rápida: Configurar Firebase (5 minutos)

## ✅ Lo que ya está hecho

He configurado automáticamente:
- ✅ `android/build.gradle` con plugin de Google Services
- ✅ `android/app/build.gradle` con applicationId correcto
- ✅ `AndroidManifest.xml` con permisos de notificaciones
- ✅ `MainActivity.kt` en Kotlin

## 📝 Lo que TÚ debes hacer (3 pasos)

### PASO 1: Crear Proyecto Firebase (2 min)

1. Abre: https://console.firebase.google.com
2. Click **"Agregar proyecto"**
3. Nombre: `conjunto-aralia-castilla`
4. Habilitar Analytics: **Sí** (recomendado)
5. Click **"Crear proyecto"**
6. Espera ~1 minuto
7. Click **"Continuar"**

---

### PASO 2: Registrar App Android (1 min)

1. Click en el ícono de **Android** (🤖)
2. Nombre del paquete de Android:
   ```
   com.araliadecastilla.conjunto_residencial_app
   ```
3. Alias (opcional): `Aralia de Castilla`
4. SHA-1: **Dejar en blanco**
5. Click **"Registrar app"**

---

### PASO 3: Descargar google-services.json (1 min)

1. Click **"Descargar google-services.json"**
2. Mueve el archivo a:
   ```
   c:\Users\Administrador\Documents\residencial\conjunto_residencial_flutter\android\app\google-services.json
   ```
3. ⚠️ **MUY IMPORTANTE:** Debe estar en `android/app/`, NO en `android/`

4. En Firebase Console, click **"Siguiente"** 2 veces hasta llegar a **"Continuar a la consola"**

---

## 🎉 ¡Listo! Ahora vamos a probar

### Verificar que funciona

Ejecuta estos comandos en tu terminal:

```bash
cd c:\Users\Administrador\Documents\residencial\conjunto_residencial_flutter

# Limpiar build anterior
flutter clean

# Obtener dependencias
flutter pub get

# Ejecutar la app
flutter run
```

**Busca en la consola:**
```
✅ Firebase inicializado correctamente
✅ NotificationService inicializado
📱 FCM Token: eyJhbGc...
```

Si ves eso, **¡Firebase está funcionando!** 🎊

---

## 📲 Probar Notificación

### Método 1: Desde Firebase Console (Más Fácil)

1. Ve a **"Messaging"** o **"Cloud Messaging"** en Firebase
2. Click **"Enviar tu primer mensaje"**
3. Título: `Hola desde Firebase`
4. Texto: `¡Funciona!`
5. Click **"Enviar mensaje de prueba"**
6. Pega el **FCM Token** que viste en la consola de Flutter
7. Click **"Probar"**

**Deberías ver la notificación en tu dispositivo** 📱

---

## 🐛 Solución de Problemas

### Error: "google-services.json missing"
**Solución:** Verifica que el archivo esté en `android/app/google-services.json`

### Error: "Default FirebaseApp is not initialized"
**Solución:** Asegúrate de tener esto en `main.dart`:
```dart
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();  // ← Esto ANTES de runApp()
  runApp(MyApp());
}
```

### No llegan notificaciones
**Verifica:**
1. App está en **foreground** (abierta)
2. FCM Token es correcto
3. Permisos de notificación aceptados

---

## 📚 Documentación Completa

Para configuración avanzada (iOS, backend, etc.), ver:
- [CONFIGURACION_FIREBASE.md](CONFIGURACION_FIREBASE.md) - Guía completa paso a paso

---

**¡Eso es todo!** En 5 minutos deberías tener Firebase funcionando. 🚀
