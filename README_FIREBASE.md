# 🏢 Conjunto Residencial Aralia - Firebase Setup

Sistema completo de gestión residencial con aplicación web y móvil, base de datos en Firebase Firestore.

## 🚀 Inicio Rápido

### Requisitos
- Node.js 16+
- Flutter 3.0+
- Cuenta de Google (para Firebase)

### Instalación Rápida

1. **Clonar repositorio**
   ```bash
   git clone https://github.com/CarlosSantos19/residencial.git
   cd residencial
   ```

2. **Seguir la guía paso a paso**
   ```bash
   # Leer y seguir:
   cat PASOS_FIREBASE.md
   ```

## 📁 Estructura del Proyecto

```
residencial/
├── public/                          # Aplicación Web
│   └── conjunto-aralia-completo.html
├── conjunto_residencial_flutter/    # Aplicación Móvil Flutter
├── firebase.json                    # Config Firebase Hosting
├── firestore.rules                  # Reglas de seguridad
├── firestore.indexes.json          # Índices Firestore
├── migrate-to-firestore.js         # Script migración datos
└── PASOS_FIREBASE.md               # ⭐ GUÍA COMPLETA
```

## 🔥 Configuración Firebase

### Archivos ya listos:
- ✅ `firebase.json` - Configuración hosting
- ✅ `firestore.rules` - Reglas de seguridad
- ✅ `firestore.indexes.json` - Índices
- ✅ `migrate-to-firestore.js` - Migración de datos

### Lo que debes hacer:

1. **Crear proyecto Firebase**
   - Ir a [console.firebase.google.com](https://console.firebase.google.com)
   - Crear proyecto: `conjunto-residencial-aralia`

2. **Habilitar servicios**
   - Firestore Database (modo producción)
   - Authentication (Email/Password)
   - Hosting
   - Cloud Messaging

3. **Instalar Firebase CLI**
   ```bash
   npm install -g firebase-tools
   firebase login
   ```

4. **Configurar proyecto**
   ```bash
   firebase use --add
   # Selecciona: conjunto-residencial-aralia
   ```

5. **Migrar datos**
   ```bash
   # Descargar serviceAccountKey.json desde Firebase Console
   npm install firebase-admin
   node migrate-to-firestore.js
   ```

6. **Desplegar web**
   ```bash
   firebase deploy --only hosting
   ```

## 📱 Configurar App Móvil

1. **Configurar FlutterFire**
   ```bash
   dart pub global activate flutterfire_cli
   cd conjunto_residencial_flutter
   flutterfire configure
   ```

2. **Habilitar Firebase**
   - Editar `pubspec.yaml`: descomentar firebase_core y firebase_messaging
   - Editar `lib/services/notification_service.dart`: descomentar Firebase

3. **Generar APK**
   ```bash
   flutter build apk --release
   # APK en: build/app/outputs/flutter-apk/
   ```

4. **Instalar en celular**
   - Transferir APK al celular
   - Habilitar "Instalar desde fuentes desconocidas"
   - Instalar

## 👥 Usuarios Demo

| Email | Password | Rol |
|-------|----------|-----|
| car-cbs@hotmail.com | password1 | Residente |
| shayoja@hotmail.com | password2 | Admin |
| car02cbs@gmail.com | password3 | Vigilante |
| alcaldia@conjunto.com | alcaldia123 | Alcaldía |

## 📚 Documentación Completa

- **[PASOS_FIREBASE.md](PASOS_FIREBASE.md)** - Guía paso a paso detallada
- **[INSTRUCCIONES_FIREBASE.md](INSTRUCCIONES_FIREBASE.md)** - Documentación técnica completa
- **[CLAUDE.md](CLAUDE.md)** - Arquitectura del proyecto

## 🌐 URLs del Proyecto

- **App Web**: https://conjunto-residencial-aralia.web.app
- **Firebase Console**: https://console.firebase.google.com
- **GitHub**: https://github.com/CarlosSantos19/residencial

## 🛠️ Comandos Útiles

```bash
# Desplegar todo
firebase deploy

# Solo hosting
firebase deploy --only hosting

# Solo reglas
firebase deploy --only firestore:rules

# Ver logs
firebase functions:log

# Emuladores locales
firebase emulators:start
```

## ✨ Características

### Aplicación Web
- 🏠 Dashboard personalizado por rol
- 📰 Gestión de noticias y comunicados
- 📅 Reservas de espacios comunes
- 💳 Pagos y extractos
- 💬 Chat multicanal (general, admin, vigilantes, privado)
- 🏪 Marketplace de emprendimientos
- 📋 Sistema PQRS
- 🎲 Sorteo de parqueaderos
- 📊 Encuestas y votaciones

### Aplicación Móvil (Flutter)
- 📱 Todas las funcionalidades de la web
- 🔔 Notificaciones push
- 📷 Escaneo QR para visitantes
- 🚗 Control de vehículos visitantes
- 🔐 Generación de permisos
- 📸 Cámara para evidencias
- 🎨 UI nativa Android/iOS

### Roles del Sistema
- **Residente**: Acceso a servicios, reservas, pagos, PQRS
- **Admin**: Gestión completa del conjunto
- **Vigilante**: Control de acceso y seguridad
- **Alcaldía**: Recepción de incidentes vecinales

## 📞 Soporte

Para problemas o preguntas:
1. Revisar [PASOS_FIREBASE.md](PASOS_FIREBASE.md)
2. Verificar [Issues en GitHub](https://github.com/CarlosSantos19/residencial/issues)
3. Consultar documentación de [Firebase](https://firebase.google.com/docs)

## 📄 Licencia

Este proyecto es privado para uso interno del Conjunto Aralia de Castilla.

---

**¿Listo para comenzar?** Sigue [PASOS_FIREBASE.md](PASOS_FIREBASE.md) paso a paso 🚀
