# 🔥 Guía de Configuración Firebase

## 📋 Prerequisitos

- ✅ Cuenta de Google
- ✅ Proyecto Flutter funcionando
- ✅ Android Studio o Xcode instalado

---

## 🚀 Paso 1: Crear Proyecto Firebase

1. Ve a [console.firebase.google.com](https://console.firebase.google.com)
2. Click en **"Agregar proyecto"**
3. Nombre del proyecto: `conjunto-aralia-castilla`
4. Habilitar Google Analytics: **Opcional** (recomendado: Sí)
5. Seleccionar cuenta de Analytics o crear nueva
6. Click en **"Crear proyecto"** (toma ~1 minuto)

---

## 📱 Paso 2: Configurar Android

### 2.1 Agregar App Android

1. En la consola Firebase, click en el ícono de **Android**
2. Completar el formulario:
   - **Nombre del paquete Android:** `com.araliadecastilla.conjunto_residencial_app`
   - **Alias de la app (opcional):** `Aralia App`
   - **Certificado SHA-1 (opcional):** Dejar en blanco por ahora
3. Click en **"Registrar app"**

### 2.2 Descargar google-services.json

1. Descargar el archivo `google-services.json`
2. Copiarlo a:
   ```
   conjunto_residencial_flutter/android/app/google-services.json
   ```

### 2.3 Configurar build.gradle (Nivel Proyecto)

**Archivo:** `android/build.gradle`

```gradle
buildscript {
    dependencies {
        // ... otras dependencias
        classpath 'com.google.gms:google-services:4.4.0' // Agregar esta línea
    }
}
```

### 2.4 Configurar build.gradle (Nivel App)

**Archivo:** `android/app/build.gradle`

**Al final del archivo, agregar:**
```gradle
apply plugin: 'com.google.gms.google-services'
```

**Verificar que la sección `defaultConfig` tenga:**
```gradle
android {
    defaultConfig {
        applicationId "com.araliadecastilla.conjunto_residencial_app"
        minSdkVersion 21  // Mínimo para Firebase
        targetSdkVersion 33
        // ...
    }
}
```

---

## 🍎 Paso 3: Configurar iOS (Opcional)

### 3.1 Agregar App iOS

1. En la consola Firebase, click en el ícono de **iOS**
2. Completar:
   - **ID del paquete de iOS:** `com.araliadecastilla.conjuntoResidencialApp`
   - **Alias de la app:** `Aralia iOS`
3. Click en **"Registrar app"**

### 3.2 Descargar GoogleService-Info.plist

1. Descargar el archivo `GoogleService-Info.plist`
2. Abrir el proyecto iOS en Xcode:
   ```bash
   open ios/Runner.xcworkspace
   ```
3. Arrastrar `GoogleService-Info.plist` a la carpeta `Runner` en Xcode
   - ✅ Marcar "Copy items if needed"
   - ✅ Seleccionar Target: **Runner**

### 3.3 Configurar AppDelegate

**Archivo:** `ios/Runner/AppDelegate.swift`

```swift
import UIKit
import Flutter
import Firebase  // Agregar

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    FirebaseApp.configure()  // Agregar esta línea
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
```

---

## 🔔 Paso 4: Habilitar Cloud Messaging

### 4.1 En la Consola Firebase

1. En el menú lateral, ir a **"Build" → "Cloud Messaging"**
2. Click en **"Get started"** o **"Comenzar"**
3. Para Android: Todo automático ✅
4. Para iOS: Necesitas:
   - Certificado APNs (Apple Push Notification service)
   - Archivo .p8 de tu cuenta de desarrollador Apple

### 4.2 Configurar Permisos Android

**Archivo:** `android/app/src/main/AndroidManifest.xml`

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <!-- Agregar estos permisos -->
    <uses-permission android:name="android.permission.INTERNET"/>
    <uses-permission android:name="android.permission.VIBRATE" />
    <uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>

    <application
        android:label="Aralia de Castilla"
        android:icon="@mipmap/ic_launcher">

        <!-- ... activity, etc. ... -->

        <!-- Agregar esto dentro de <application> -->
        <meta-data
            android:name="com.google.firebase.messaging.default_notification_channel_id"
            android:value="general_channel" />
    </application>
</manifest>
```

---

## ✅ Paso 5: Verificar Instalación

### 5.1 Probar Conexión

**Archivo:** `lib/main.dart`

```dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Inicializar Firebase
    await Firebase.initializeApp();
    print('✅ Firebase inicializado correctamente');

    // Inicializar NotificationService
    final notificationService = NotificationService();
    await notificationService.initialize();
    print('✅ NotificationService inicializado');
    print('📱 FCM Token: ${notificationService.fcmToken}');

  } catch (e) {
    print('❌ Error inicializando Firebase: $e');
  }

  runApp(MyApp());
}
```

### 5.2 Ejecutar la App

```bash
cd conjunto_residencial_flutter

# Limpiar build anterior
flutter clean

# Obtener dependencias
flutter pub get

# Ejecutar en Android
flutter run
```

**Buscar en la consola:**
```
✅ Firebase inicializado correctamente
✅ NotificationService inicializado
📱 FCM Token: e7xK3... (token largo)
```

---

## 🧪 Paso 6: Probar Notificaciones

### 6.1 Método 1: Firebase Console (Más Fácil)

1. Ve a **"Cloud Messaging"** en Firebase Console
2. Click en **"Enviar tu primer mensaje"**
3. Completar:
   - **Título:** "Prueba de Notificación"
   - **Texto:** "¡Hola desde Firebase!"
4. Click en **"Enviar mensaje de prueba"**
5. Pegar el **FCM Token** de la consola de Flutter
6. Click en **"Probar"**

✅ **Deberías ver la notificación** en tu dispositivo/emulador

### 6.2 Método 2: Desde el Backend

**Archivo:** `server.js`

**Instalar Firebase Admin SDK:**
```bash
npm install firebase-admin
```

**Configurar en server.js:**
```javascript
const admin = require('firebase-admin');

// Inicializar Firebase Admin
const serviceAccount = require('./firebase-service-account.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

// Endpoint para enviar notificación
app.post('/api/test/notificacion', async (req, res) => {
  const { token, titulo, mensaje } = req.body;

  const message = {
    notification: {
      title: titulo || 'Notificación de Prueba',
      body: mensaje || 'Esto es una prueba desde el backend',
    },
    data: {
      tipo: 'prueba',
      fecha: new Date().toISOString(),
    },
    token: token, // FCM token del usuario
  };

  try {
    const response = await admin.messaging().send(message);
    console.log('✅ Notificación enviada:', response);
    res.json({ success: true, messageId: response });
  } catch (error) {
    console.error('❌ Error enviando notificación:', error);
    res.status(500).json({ error: error.message });
  }
});
```

**Probar con cURL:**
```bash
curl -X POST http://localhost:8081/api/test/notificacion \
  -H "Content-Type: application/json" \
  -d '{
    "token": "TU_FCM_TOKEN_AQUI",
    "titulo": "Hola desde Backend",
    "mensaje": "Esta notificación viene del servidor Express"
  }'
```

---

## 🔐 Paso 7: Obtener Service Account Key (Backend)

Para enviar notificaciones desde el backend:

1. En Firebase Console, ir a **⚙️ Configuración del Proyecto**
2. Pestaña **"Cuentas de servicio"**
3. Click en **"Generar nueva clave privada"**
4. Se descargará un archivo JSON
5. Renombrarlo a `firebase-service-account.json`
6. Guardarlo en la raíz del proyecto Node.js
7. **⚠️ IMPORTANTE:** Agregar a `.gitignore`:
   ```
   firebase-service-account.json
   ```

---

## 📊 Paso 8: Guardar FCM Tokens en el Backend

**Modificar login en server.js:**

```javascript
app.post('/api/auth/login', async (req, res) => {
  const { email, password, fcmToken } = req.body; // Recibir FCM token

  const usuario = data.usuarios.find(u => u.email === email);

  if (!usuario || usuario.password !== password) {
    return res.status(401).json({ error: 'Credenciales inválidas' });
  }

  // Guardar FCM token
  if (fcmToken) {
    usuario.fcmToken = fcmToken;
    guardarDatos();
  }

  const token = Buffer.from(`${usuario.id}:${Date.now()}`).toString('base64');

  res.json({
    success: true,
    token,
    usuario: { ...usuario, password: undefined },
  });
});
```

**En Flutter, enviar token al hacer login:**

```dart
// lib/services/auth_service.dart

Future<void> login(String email, String password) async {
  // ... código existente ...

  // Obtener FCM token
  final notificationService = NotificationService();
  final fcmToken = notificationService.fcmToken;

  final response = await http.post(
    Uri.parse('$baseUrl/auth/login'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'email': email,
      'password': password,
      'fcmToken': fcmToken, // Enviar token
    }),
  );

  // ... resto del código ...
}
```

---

## 🎯 Paso 9: Enviar Notificaciones Contextuales

### Ejemplo 1: Notificación cuando llega un paquete

```javascript
// server.js - Endpoint de registrar paquete (vigilante)
app.post('/api/admin/paquetes', async (req, res) => {
  const { apartamento, descripcion, torre } = req.body;

  const nuevoPaquete = {
    id: data.paquetes.length + 1,
    apartamento,
    torre,
    descripcion,
    fechaLlegada: new Date().toISOString(),
    recogido: false,
  };

  data.paquetes.push(nuevoPaquete);
  guardarDatos();

  // ✅ ENVIAR NOTIFICACIÓN al residente
  const residente = data.usuarios.find(u =>
    u.apartamento === apartamento && u.torre === torre && u.rol === 'residente'
  );

  if (residente && residente.fcmToken) {
    const message = {
      notification: {
        title: '📦 Paquete Recibido',
        body: `Llegó ${descripcion} para ${apartamento}`,
      },
      data: {
        tipo: 'paquete',
        paqueteId: nuevoPaquete.id.toString(),
      },
      token: residente.fcmToken,
    };

    await admin.messaging().send(message);
  }

  res.json({ success: true, paquete: nuevoPaquete });
});
```

### Ejemplo 2: Notificación cuando se actualiza PQRS

```javascript
// server.js - Actualizar estado de PQRS
app.put('/api/pqrs/:id/estado', verificarAdmin, async (req, res) => {
  const { id } = req.params;
  const { estado, respuesta } = req.body;

  const pqrs = data.pqrs.find(p => p.id === parseInt(id));
  if (!pqrs) {
    return res.status(404).json({ error: 'PQRS no encontrada' });
  }

  pqrs.estado = estado;
  pqrs.respuesta = respuesta;
  pqrs.fechaRespuesta = new Date().toISOString();

  guardarDatos();

  // ✅ ENVIAR NOTIFICACIÓN al residente que creó la PQRS
  const residente = data.usuarios.find(u => u.id === pqrs.usuarioId);

  if (residente && residente.fcmToken) {
    const emojis = {
      'en proceso': '⏳',
      'resuelto': '✅',
      'rechazado': '❌',
    };

    const message = {
      notification: {
        title: `${emojis[estado] || '📝'} PQRS ${estado}`,
        body: pqrs.asunto,
      },
      data: {
        tipo: 'pqrs',
        pqrsId: pqrs.id.toString(),
        estado,
      },
      token: residente.fcmToken,
    };

    await admin.messaging().send(message);
  }

  res.json({ success: true, pqrs });
});
```

---

## 🐛 Solución de Problemas

### Error: "Default FirebaseApp is not initialized"

**Solución:**
```dart
// En main.dart, ANTES de runApp()
await Firebase.initializeApp();
```

### Error: "MissingPluginException"

**Solución:**
```bash
flutter clean
flutter pub get
flutter run
```

### No llegan notificaciones en Android

**Verificar:**
1. ✅ `google-services.json` en `android/app/`
2. ✅ Permisos en `AndroidManifest.xml`
3. ✅ Plugin `com.google.gms.google-services` en `build.gradle`
4. ✅ App en **foreground** (para testing inicial)

### Token FCM es null

**Verificar:**
```dart
// Esperar a que Firebase esté listo
await Firebase.initializeApp();
await Future.delayed(Duration(seconds: 2)); // Dar tiempo
final token = await FirebaseMessaging.instance.getToken();
print('Token: $token');
```

---

## 📚 Recursos Adicionales

- [Documentación Firebase Flutter](https://firebase.flutter.dev/)
- [FlutterFire GitHub](https://github.com/firebase/flutterfire)
- [Firebase Console](https://console.firebase.google.com)
- [Cloud Messaging Docs](https://firebase.google.com/docs/cloud-messaging)

---

## ✅ Checklist Final

- [ ] Proyecto Firebase creado
- [ ] App Android registrada
- [ ] `google-services.json` descargado y ubicado
- [ ] `build.gradle` configurados (proyecto y app)
- [ ] Dependencias de Firebase agregadas
- [ ] `Firebase.initializeApp()` en `main.dart`
- [ ] `NotificationService.initialize()` llamado
- [ ] FCM Token obtenido (verificar en consola)
- [ ] Notificación de prueba enviada y recibida
- [ ] Service Account Key descargado (backend)
- [ ] FCM Tokens guardados en base de datos
- [ ] Notificaciones contextuales implementadas

---

**¡Listo!** 🎉 Tu app Flutter ahora tiene notificaciones push completamente funcionales.

**Última actualización:** 3 de Octubre de 2025
