# 🚀 Pasos para Configurar Firebase

## ✅ Archivos ya creados:
- `firebase.json` - Configuración de hosting
- `firestore.rules` - Reglas de seguridad
- `firestore.indexes.json` - Índices de base de datos
- `migrate-to-firestore.js` - Script de migración
- `.firebaserc` - Proyecto Firebase

## 📋 PASOS A SEGUIR:

### 1️⃣ Crear Proyecto en Firebase Console

1. Abre [Firebase Console](https://console.firebase.google.com/)
2. Clic en **"Agregar proyecto"**
3. Nombre: `conjunto-residencial-aralia`
4. Deshabilita Google Analytics
5. Clic en **"Crear proyecto"**

### 2️⃣ Habilitar Servicios

En tu proyecto Firebase, habilita:

**A) Firestore Database:**
- Menú lateral → **Firestore Database** → **Crear base de datos**
- Modo: **Producción**
- Región: **us-central1**

**B) Authentication:**
- Menú lateral → **Authentication** → **Comenzar**
- Habilitar: **Correo electrónico/contraseña**

**C) Hosting:**
- Menú lateral → **Hosting** → **Comenzar**

**D) Cloud Messaging:**
- Menú lateral → **Cloud Messaging**
- Copiar **Clave del servidor** (la necesitarás después)

### 3️⃣ Instalar Firebase CLI

Abre PowerShell como administrador:

```powershell
npm install -g firebase-tools
```

### 4️⃣ Iniciar Sesión en Firebase

```powershell
firebase login
```

Se abrirá tu navegador para autenticarte con Google.

### 5️⃣ Conectar Proyecto

En la carpeta del proyecto:

```powershell
cd C:\Users\Administrador\Documents\residencial
firebase use --add
```

Selecciona el proyecto `conjunto-residencial-aralia` que creaste.

### 6️⃣ Descargar Clave Privada

Para el script de migración:

1. Firebase Console → **⚙️ Configuración del proyecto**
2. Pestaña **Cuentas de servicio**
3. Clic en **Generar nueva clave privada**
4. Guardar el archivo como `serviceAccountKey.json` en la carpeta del proyecto

### 7️⃣ Migrar Datos a Firestore

```powershell
npm install firebase-admin
node migrate-to-firestore.js
```

Esto migrará todos los datos de `data.json` a Firestore.

### 8️⃣ Configurar Aplicación Web

1. Firebase Console → **⚙️ Configuración del proyecto**
2. En "Tus apps" → Clic en ícono **Web** (</>)
3. Nombre: `Conjunto Residencial Web`
4. Copiar el objeto `firebaseConfig`

Editar `public/conjunto-aralia-completo.html` y buscar (aproximadamente línea 50):

```javascript
// REEMPLAZAR ESTA CONFIGURACIÓN
const firebaseConfig = {
  apiKey: "TU_API_KEY_AQUI",
  authDomain: "conjunto-residencial-aralia.firebaseapp.com",
  projectId: "conjunto-residencial-aralia",
  storageBucket: "conjunto-residencial-aralia.appspot.com",
  messagingSenderId: "TU_SENDER_ID",
  appId: "TU_APP_ID"
};
```

### 9️⃣ Desplegar Aplicación Web

```powershell
firebase deploy --only hosting
```

Tu app estará en: `https://conjunto-residencial-aralia.web.app`

### 🔟 Configurar Flutter para Firebase

**A) Instalar FlutterFire CLI:**
```powershell
dart pub global activate flutterfire_cli
```

**B) Configurar Firebase automáticamente:**
```powershell
cd conjunto_residencial_flutter
flutterfire configure
```

Selecciona el proyecto `conjunto-residencial-aralia` y las plataformas: **Android, iOS, Web**

**C) Habilitar Firebase en pubspec.yaml:**

Editar `conjunto_residencial_flutter/pubspec.yaml` y descomentar:

```yaml
# Cambiar de:
  # firebase_core: ^3.6.0
  # firebase_messaging: ^15.1.3

# A:
  firebase_core: ^3.6.0
  firebase_messaging: ^15.1.3
```

**D) Actualizar dependencias:**
```powershell
flutter pub get
```

**E) Descomentar Firebase en notification_service.dart:**

Editar `lib/services/notification_service.dart` y descomentar las líneas de Firebase.

### 1️⃣1️⃣ Crear Usuarios de Prueba

En Firebase Console:

1. **Authentication** → **Usuarios** → **Agregar usuario**

Crear estos usuarios:

| Email | Contraseña | Rol |
|-------|-----------|-----|
| car-cbs@hotmail.com | password1 | residente |
| shayoja@hotmail.com | password2 | admin |
| car02cbs@gmail.com | password3 | vigilante |
| alcaldia@conjunto.com | alcaldia123 | alcaldia |

2. **Firestore Database** → **usuarios** → Crear documentos

Para cada usuario, usa su **UID** de Authentication como ID del documento:

```javascript
// Ejemplo para residente (usar UID real)
{
  id: 1,
  nombre: "Carlos Santos",
  email: "car-cbs@hotmail.com",
  rol: "residente",
  torre: "A",
  apartamento: "101",
  telefono: "3001234567",
  activo: true
}
```

### 1️⃣2️⃣ Generar APK para Android

**A) Para pruebas (Debug):**
```powershell
cd conjunto_residencial_flutter
flutter build apk
```

**B) Para publicar (Release):**
```powershell
flutter build apk --release
```

El APK estará en: `build/app/outputs/flutter-apk/app-release.apk`

### 1️⃣3️⃣ Instalar en Celular

**Opción A: Por USB**
```powershell
# Conecta tu celular con depuración USB habilitada
flutter install
```

**Opción B: Transferir APK**
1. Copia `build/app/outputs/flutter-apk/app-release.apk`
2. Pásalo a tu celular (WhatsApp, email, cable USB)
3. En el celular: Habilita "Instalar desde fuentes desconocidas"
4. Abre el APK e instala

### 1️⃣4️⃣ Desplegar Reglas de Seguridad

```powershell
firebase deploy --only firestore:rules
firebase deploy --only firestore:indexes
```

## ✅ Verificación Final

1. **Web App**: Abre `https://conjunto-residencial-aralia.web.app`
2. **Login**: Usa `car-cbs@hotmail.com` / `password1`
3. **App Móvil**: Abre la app instalada en tu celular
4. **Sincronización**: Ambas apps deben ver los mismos datos de Firestore

## 🆘 Solución de Problemas

**Error: Firebase no inicializado**
```powershell
firebase login
firebase use conjunto-residencial-aralia
```

**Error: Permisos denegados en Firestore**
```powershell
firebase deploy --only firestore:rules
```

**Error: Flutter no encuentra Firebase**
```powershell
flutterfire configure
flutter clean
flutter pub get
```

## 📱 Comandos Útiles

```powershell
# Ver logs en tiempo real
firebase functions:log

# Ejecutar emuladores locales
firebase emulators:start

# Desplegar todo
firebase deploy

# Solo hosting
firebase deploy --only hosting

# Ver apps configuradas
firebase apps:list
```

## 🎯 Resumen de URLs

- **Firebase Console**: https://console.firebase.google.com/
- **App Web**: https://conjunto-residencial-aralia.web.app
- **Documentación**: https://firebase.google.com/docs

---

**¡Listo!** Con estos pasos tendrás:
- ✅ App web en Firebase Hosting
- ✅ App móvil en tu celular
- ✅ Base de datos compartida en Firestore
- ✅ Autenticación centralizada
- ✅ Sincronización en tiempo real
