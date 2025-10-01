# 🔥 Instrucciones para Deploy en Firebase

## ⚠️ IMPORTANTE
Tu aplicación usa un backend Node.js/Express. Firebase Hosting solo sirve archivos estáticos.

## 🎯 Opciones de Deploy

### Opción A: Firebase Functions + Hosting (Recomendado)

1. **Instalar dependencias de Functions**:
```bash
npm install -g firebase-tools
firebase init functions
```

2. **Migrar server.js a Functions**:
- Crear `functions/index.js`
- Convertir rutas Express a Cloud Functions
- Mantener la lógica de autenticación y datos

3. **Deploy completo**:
```bash
firebase deploy
```

### Opción B: Solo Frontend + API Externa

1. **Modificar el frontend** para usar una API externa
2. **Deploy del backend** en otro servicio (Railway, Render, Vercel)
3. **Deploy solo frontend** en Firebase Hosting

## 🚀 Deploy Solo Frontend (Opción B)

Si quieres probar solo el frontend:

```bash
# 1. Hacer login
firebase login

# 2. Inicializar (si no lo has hecho)
firebase init hosting

# 3. Deploy
firebase deploy --only hosting
```

## 📝 Configuración Actual

- **firebase.json**: ✅ Configurado
- **public/**: ✅ Archivos listos
- **Backend**: ⚠️ Necesita migración

## 🔧 Para usar con tu backend actual

1. **Mantén tu servidor local**:
```bash
npm run dev
```

2. **Deploy solo frontend** a Firebase
3. **Configura CORS** en server.js para el dominio de Firebase
4. **Actualiza URLs** en el frontend para apuntar a tu servidor

## 📱 Flutter + Firebase

Para la app Flutter:

```bash
cd conjunto_residencial_flutter
flutter pub add firebase_core
flutter pub add firebase_auth
flutter pub add cloud_firestore

# Configurar Firebase en Flutter
firebase init
```