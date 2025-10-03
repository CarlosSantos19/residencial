// Script para migrar datos de data.json a Firebase Firestore
// Uso: node migrate-to-firestore.js

const admin = require('firebase-admin');
const fs = require('fs');

// Inicializar Firebase Admin SDK
// IMPORTANTE: Descarga la clave privada desde Firebase Console:
// Configuración del proyecto → Cuentas de servicio → Generar nueva clave privada
// Guarda el archivo como serviceAccountKey.json en la raíz del proyecto

const serviceAccount = require('./serviceAccountKey.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();

// Cargar datos actuales
const data = JSON.parse(fs.readFileSync('./data.json', 'utf8'));

async function migrateData() {
  console.log('🚀 Iniciando migración de datos a Firestore...\n');

  try {
    // 1. Migrar usuarios
    console.log('📝 Migrando usuarios...');
    const batch1 = db.batch();
    for (const usuario of data.usuarios) {
      const docRef = db.collection('usuarios').doc(usuario.id.toString());
      batch1.set(docRef, usuario);
    }
    await batch1.commit();
    console.log(`✅ ${data.usuarios.length} usuarios migrados\n`);

    // 2. Migrar noticias
    console.log('📰 Migrando noticias...');
    const batch2 = db.batch();
    for (const noticia of data.noticias) {
      const docRef = db.collection('noticias').doc(noticia.id.toString());
      batch2.set(docRef, noticia);
    }
    await batch2.commit();
    console.log(`✅ ${data.noticias.length} noticias migradas\n`);

    // 3. Migrar reservas
    console.log('📅 Migrando reservas...');
    const batch3 = db.batch();
    for (const reserva of data.reservas) {
      const docRef = db.collection('reservas').doc(reserva.id.toString());
      batch3.set(docRef, reserva);
    }
    await batch3.commit();
    console.log(`✅ ${data.reservas.length} reservas migradas\n`);

    // 4. Migrar PQRS
    console.log('📋 Migrando PQRS...');
    const batch4 = db.batch();
    for (const pqrs of data.pqrs) {
      const docRef = db.collection('pqrs').doc(pqrs.id.toString());
      batch4.set(docRef, pqrs);
    }
    await batch4.commit();
    console.log(`✅ ${data.pqrs.length} PQRS migrados\n`);

    // 5. Migrar pagos
    console.log('💳 Migrando pagos...');
    const batch5 = db.batch();
    for (const pago of data.pagos) {
      const docRef = db.collection('pagos').doc(pago.id.toString());
      batch5.set(docRef, pago);
    }
    await batch5.commit();
    console.log(`✅ ${data.pagos.length} pagos migrados\n`);

    // 6. Migrar emprendimientos
    console.log('🏪 Migrando emprendimientos...');
    const batch6 = db.batch();
    for (const emp of data.emprendimientos) {
      const docRef = db.collection('emprendimientos').doc(emp.id.toString());
      batch6.set(docRef, emp);
    }
    await batch6.commit();
    console.log(`✅ ${data.emprendimientos.length} emprendimientos migrados\n`);

    // 7. Migrar reseñas
    if (data.resenas && data.resenas.length > 0) {
      console.log('⭐ Migrando reseñas...');
      const batch7 = db.batch();
      for (const resena of data.resenas) {
        const docRef = db.collection('resenas').doc(resena.id.toString());
        batch7.set(docRef, resena);
      }
      await batch7.commit();
      console.log(`✅ ${data.resenas.length} reseñas migradas\n`);
    }

    // 8. Migrar chat general
    console.log('💬 Migrando chat general...');
    const chatGeneralRef = db.collection('chats').doc('general').collection('mensajes');
    const batch8 = db.batch();
    for (const mensaje of data.chats.general) {
      const docRef = chatGeneralRef.doc(mensaje.id.toString());
      batch8.set(docRef, mensaje);
    }
    await batch8.commit();
    console.log(`✅ ${data.chats.general.length} mensajes del chat general migrados\n`);

    // 9. Migrar chat admin
    console.log('💬 Migrando chat admin...');
    const chatAdminRef = db.collection('chats').doc('admin').collection('mensajes');
    const batch9 = db.batch();
    for (const mensaje of data.chats.admin) {
      const docRef = chatAdminRef.doc(mensaje.id.toString());
      batch9.set(docRef, mensaje);
    }
    await batch9.commit();
    console.log(`✅ ${data.chats.admin.length} mensajes del chat admin migrados\n`);

    // 10. Migrar chat vigilantes
    console.log('💬 Migrando chat vigilantes...');
    const chatVigilantesRef = db.collection('chats').doc('vigilantes').collection('mensajes');
    const batch10 = db.batch();
    for (const mensaje of data.chats.vigilantes) {
      const docRef = chatVigilantesRef.doc(mensaje.id.toString());
      batch10.set(docRef, mensaje);
    }
    await batch10.commit();
    console.log(`✅ ${data.chats.vigilantes.length} mensajes del chat vigilantes migrados\n`);

    // 11. Migrar chats privados
    console.log('💬 Migrando chats privados...');
    const chatsPrivadosCount = Object.keys(data.chats.privados).length;
    let mensajesPrivadosCount = 0;
    for (const [chatId, mensajes] of Object.entries(data.chats.privados)) {
      const chatPrivadoRef = db.collection('chats').doc('privados').collection(chatId);
      const batchPrivado = db.batch();
      for (const mensaje of mensajes) {
        const docRef = chatPrivadoRef.doc(mensaje.id.toString());
        batchPrivado.set(docRef, mensaje);
        mensajesPrivadosCount++;
      }
      await batchPrivado.commit();
    }
    console.log(`✅ ${chatsPrivadosCount} chats privados con ${mensajesPrivadosCount} mensajes migrados\n`);

    // 12. Migrar vehículos visitantes
    if (data.vehiculosVisitantes && data.vehiculosVisitantes.length > 0) {
      console.log('🚗 Migrando vehículos visitantes...');
      const batch12 = db.batch();
      for (const vehiculo of data.vehiculosVisitantes) {
        const docRef = db.collection('vehiculosVisitantes').doc(vehiculo.id.toString());
        batch12.set(docRef, vehiculo);
      }
      await batch12.commit();
      console.log(`✅ ${data.vehiculosVisitantes.length} vehículos visitantes migrados\n`);
    }

    // 13. Migrar permisos
    if (data.permisos && data.permisos.length > 0) {
      console.log('🔑 Migrando permisos...');
      const batch13 = db.batch();
      for (const permiso of data.permisos) {
        const docRef = db.collection('permisos').doc(permiso.id.toString());
        batch13.set(docRef, permiso);
      }
      await batch13.commit();
      console.log(`✅ ${data.permisos.length} permisos migrados\n`);
    }

    // 14. Migrar encuestas
    if (data.encuestas && data.encuestas.length > 0) {
      console.log('📊 Migrando encuestas...');
      const batch14 = db.batch();
      for (const encuesta of data.encuestas) {
        const docRef = db.collection('encuestas').doc(encuesta.id.toString());
        batch14.set(docRef, encuesta);
      }
      await batch14.commit();
      console.log(`✅ ${data.encuestas.length} encuestas migradas\n`);
    }

    // 15. Migrar paquetes
    if (data.paquetes && data.paquetes.length > 0) {
      console.log('📦 Migrando paquetes...');
      const batch15 = db.batch();
      for (const paquete of data.paquetes) {
        const docRef = db.collection('paquetes').doc(paquete.id.toString());
        batch15.set(docRef, paquete);
      }
      await batch15.commit();
      console.log(`✅ ${data.paquetes.length} paquetes migrados\n`);
    }

    // 16. Migrar parqueaderos
    if (data.parqueaderos && data.parqueaderos.length > 0) {
      console.log('🅿️ Migrando parqueaderos...');
      const batch16 = db.batch();
      for (const parqueadero of data.parqueaderos) {
        const docRef = db.collection('parqueaderos').doc(parqueadero.numero.toString());
        batch16.set(docRef, parqueadero);
      }
      await batch16.commit();
      console.log(`✅ ${data.parqueaderos.length} parqueaderos migrados\n`);
    }

    // 17. Migrar sorteo parqueaderos
    if (data.sorteoParqueaderos && data.sorteoParqueaderos.length > 0) {
      console.log('🎲 Migrando sorteos de parqueaderos...');
      const batch17 = db.batch();
      for (const sorteo of data.sorteoParqueaderos) {
        const docRef = db.collection('sorteoParqueaderos').doc(sorteo.id.toString());
        batch17.set(docRef, sorteo);
      }
      await batch17.commit();
      console.log(`✅ ${data.sorteoParqueaderos.length} sorteos migrados\n`);
    }

    // 18. Migrar apartamentos en arriendo
    if (data.apartamentosArriendo && data.apartamentosArriendo.length > 0) {
      console.log('🏠 Migrando apartamentos en arriendo...');
      const batch18 = db.batch();
      for (const apt of data.apartamentosArriendo) {
        const docRef = db.collection('apartamentosArriendo').doc(apt.id.toString());
        batch18.set(docRef, apt);
      }
      await batch18.commit();
      console.log(`✅ ${data.apartamentosArriendo.length} apartamentos en arriendo migrados\n`);
    }

    // 19. Migrar incidentes
    if (data.incidentes && data.incidentes.length > 0) {
      console.log('🚨 Migrando incidentes...');
      const batch19 = db.batch();
      for (const incidente of data.incidentes) {
        const docRef = db.collection('incidentes').doc(incidente.id.toString());
        batch19.set(docRef, incidente);
      }
      await batch19.commit();
      console.log(`✅ ${data.incidentes.length} incidentes migrados\n`);
    }

    console.log('\n✨ ¡Migración completada exitosamente! ✨\n');
    console.log('Ahora puedes:');
    console.log('1. Verificar los datos en Firebase Console');
    console.log('2. Desplegar la aplicación web: firebase deploy --only hosting');
    console.log('3. Generar el APK de Flutter: cd conjunto_residencial_flutter && flutter build apk');

  } catch (error) {
    console.error('❌ Error en la migración:', error);
    process.exit(1);
  }

  process.exit(0);
}

// Ejecutar migración
migrateData();
