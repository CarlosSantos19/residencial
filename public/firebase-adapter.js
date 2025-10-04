// Firebase Adapter - Convierte llamadas API a Firestore
import { initializeApp } from 'https://www.gstatic.com/firebasejs/10.7.1/firebase-app.js';
import { getAuth, signInWithEmailAndPassword, onAuthStateChanged, signOut } from 'https://www.gstatic.com/firebasejs/10.7.1/firebase-auth.js';
import { getFirestore, collection, getDocs, getDoc, doc, addDoc, updateDoc, deleteDoc, query, where, orderBy, limit } from 'https://www.gstatic.com/firebasejs/10.7.1/firebase-firestore.js';

// Configuración Firebase
const firebaseConfig = {
    apiKey: "AIzaSyCTglrnttR2NKUHIsS9ddj37Yuwvz6Lv7A",
    authDomain: "conjunto-residencial-2024.firebaseapp.com",
    projectId: "conjunto-residencial-2024",
    storageBucket: "conjunto-residencial-2024.firebasestorage.app",
    messagingSenderId: "26128855451",
    appId: "1:26128855451:web:d94aae5e71376e6808313e",
    measurementId: "G-1PRFW148P0"
};

// Inicializar Firebase
const app = initializeApp(firebaseConfig);
const auth = getAuth(app);
const db = getFirestore(app);

// Objeto global para compatibilidad
window.firebaseAdapter = {
    auth,
    db,
    currentUser: null
};

// Función de login compatible con la app actual
window.firebaseLogin = async (email, password) => {
    try {
        const userCredential = await signInWithEmailAndPassword(auth, email, password);
        const user = userCredential.user;

        // Obtener datos del usuario desde Firestore
        const userDoc = await getDoc(doc(db, 'usuarios', user.uid));

        if (userDoc.exists()) {
            const userData = userDoc.data();
            window.firebaseAdapter.currentUser = userData;

            // Retornar en formato compatible con la app
            return {
                success: true,
                token: await user.getIdToken(),
                usuario: userData
            };
        } else {
            return {
                success: false,
                mensaje: 'Usuario no encontrado en Firestore'
            };
        }
    } catch (error) {
        console.error('Error en login:', error);
        return {
            success: false,
            mensaje: error.message
        };
    }
};

// Función logout
window.firebaseLogout = async () => {
    await signOut(auth);
    window.firebaseAdapter.currentUser = null;
};

// Adaptador de fetch - convierte llamadas API a Firestore
window.fetchWithAuth = async (url, options = {}) => {
    const method = options.method || 'GET';
    const body = options.body ? JSON.parse(options.body) : null;

    // Extraer endpoint
    const endpoint = url.replace('/api/', '');
    const parts = endpoint.split('/');

    try {
        // RUTAS DE AUTENTICACIÓN
        if (endpoint === 'auth/login') {
            const result = await window.firebaseLogin(body.email, body.password);
            return { json: async () => result };
        }

        // RUTAS DE NOTICIAS
        if (endpoint === 'noticias' && method === 'GET') {
            const noticiasSnap = await getDocs(query(collection(db, 'noticias'), orderBy('fechaPublicacion', 'desc')));
            const noticias = noticiasSnap.docs.map(doc => ({ id: doc.id, ...doc.data() }));
            return { json: async () => noticias };
        }

        // RUTAS DE RESERVAS
        if (endpoint === 'reservas' && method === 'GET') {
            const reservasSnap = await getDocs(collection(db, 'reservas'));
            const reservas = reservasSnap.docs.map(doc => ({ id: doc.id, ...doc.data() }));
            return { json: async () => reservas };
        }

        if (endpoint === 'reservas' && method === 'POST') {
            const docRef = await addDoc(collection(db, 'reservas'), {
                ...body,
                usuarioId: window.firebaseAdapter.currentUser?.id,
                fechaCreacion: new Date().toISOString()
            });
            return { json: async () => ({ success: true, id: docRef.id }) };
        }

        // RUTAS DE PQRS
        if (endpoint === 'pqrs' && method === 'GET') {
            const pqrsSnap = await getDocs(collection(db, 'pqrs'));
            const pqrs = pqrsSnap.docs.map(doc => ({ id: doc.id, ...doc.data() }));
            return { json: async () => pqrs };
        }

        if (endpoint === 'pqrs' && method === 'POST') {
            const docRef = await addDoc(collection(db, 'pqrs'), {
                ...body,
                usuarioId: window.firebaseAdapter.currentUser?.id,
                estado: 'Pendiente',
                fechaCreacion: new Date().toISOString()
            });
            return { json: async () => ({ success: true, id: docRef.id }) };
        }

        // RUTAS DE PAGOS
        if (endpoint === 'pagos' && method === 'GET') {
            const pagosSnap = await getDocs(collection(db, 'pagos'));
            const pagos = pagosSnap.docs.map(doc => ({ id: doc.id, ...doc.data() }));
            return { json: async () => pagos };
        }

        // RUTAS DE EMPRENDIMIENTOS
        if (endpoint === 'emprendimientos' && method === 'GET') {
            const empSnap = await getDocs(collection(db, 'emprendimientos'));
            const emprendimientos = empSnap.docs.map(doc => ({ id: doc.id, ...doc.data() }));
            return { json: async () => emprendimientos };
        }

        // RUTAS DE CHAT
        if (endpoint.startsWith('chat/general') && method === 'GET') {
            const mensajesSnap = await getDocs(query(collection(db, 'chats', 'general', 'mensajes'), orderBy('fecha', 'asc')));
            const mensajes = mensajesSnap.docs.map(doc => ({ id: doc.id, ...doc.data() }));
            return { json: async () => ({ mensajes }) };
        }

        if (endpoint.startsWith('chat/general') && method === 'POST') {
            const docRef = await addDoc(collection(db, 'chats', 'general', 'mensajes'), {
                ...body,
                usuarioId: window.firebaseAdapter.currentUser?.id,
                usuarioNombre: window.firebaseAdapter.currentUser?.nombre,
                fecha: new Date().toISOString()
            });
            return { json: async () => ({ success: true, id: docRef.id }) };
        }

        // RUTAS DE USUARIOS
        if (endpoint === 'usuarios' && method === 'GET') {
            const usuariosSnap = await getDocs(collection(db, 'usuarios'));
            const usuarios = usuariosSnap.docs.map(doc => ({ id: doc.id, ...doc.data() }));
            return { json: async () => usuarios };
        }

        // RUTAS DE ENCUESTAS
        if (endpoint === 'encuestas' && method === 'GET') {
            const encuestasSnap = await getDocs(collection(db, 'encuestas'));
            const encuestas = encuestasSnap.docs.map(doc => ({ id: doc.id, ...doc.data() }));
            return { json: async () => encuestas };
        }

        // RUTAS DE VEHICULOS VISITANTES
        if (endpoint === 'vehiculos-visitantes' && method === 'GET') {
            const vehiculosSnap = await getDocs(collection(db, 'vehiculosVisitantes'));
            const vehiculos = vehiculosSnap.docs.map(doc => ({ id: doc.id, ...doc.data() }));
            return { json: async () => vehiculos };
        }

        // RUTAS DE PARQUEADEROS
        if (endpoint === 'parqueaderos' && method === 'GET') {
            const parqueaderosSnap = await getDocs(collection(db, 'parqueaderos'));
            const parqueaderos = parqueaderosSnap.docs.map(doc => ({ numero: doc.id, ...doc.data() }));
            return { json: async () => parqueaderos };
        }

        // RUTAS DE APARTAMENTOS EN ARRIENDO
        if (endpoint === 'apartamentos-arriendo' && method === 'GET') {
            const aptosSnap = await getDocs(collection(db, 'apartamentosArriendo'));
            const apartamentos = aptosSnap.docs.map(doc => ({ id: doc.id, ...doc.data() }));
            return { json: async () => apartamentos };
        }

        // ============= RUTAS DE ADMINISTRADOR =============

        // ADMIN - Estadísticas
        if (endpoint === 'admin/estadisticas' && method === 'GET') {
            const [usuarios, reservas, pagos, pqrs] = await Promise.all([
                getDocs(collection(db, 'usuarios')),
                getDocs(collection(db, 'reservas')),
                getDocs(collection(db, 'pagos')),
                getDocs(collection(db, 'pqrs'))
            ]);

            return { json: async () => ({
                totalUsuarios: usuarios.size,
                totalReservas: reservas.size,
                totalPagos: pagos.size,
                totalPQRS: pqrs.size,
                reservasActivas: reservas.docs.filter(d => d.data().estado === 'activa').length,
                pagosPendientes: pagos.docs.filter(d => d.data().estado === 'pendiente').length
            })};
        }

        // ADMIN - Noticias
        if (endpoint === 'admin/noticias' && method === 'POST') {
            const docRef = await addDoc(collection(db, 'noticias'), {
                ...body,
                fechaPublicacion: new Date().toISOString(),
                activa: true,
                autor: window.firebaseAdapter.currentUser?.nombre || 'Admin'
            });
            return { json: async () => ({ success: true, id: docRef.id }) };
        }

        if (endpoint.startsWith('admin/noticias/') && method === 'DELETE') {
            const noticiaId = parts[2];
            await deleteDoc(doc(db, 'noticias', noticiaId));
            return { json: async () => ({ success: true }) };
        }

        // ADMIN - Usuarios
        if (endpoint === 'admin/usuarios' && method === 'POST') {
            const docRef = await addDoc(collection(db, 'usuarios'), {
                ...body,
                fechaRegistro: new Date().toISOString(),
                activo: true
            });
            return { json: async () => ({ success: true, id: docRef.id }) };
        }

        if (endpoint === 'admin/usuarios/todos' && method === 'GET') {
            const usuariosSnap = await getDocs(collection(db, 'usuarios'));
            const usuarios = usuariosSnap.docs.map(doc => ({ id: doc.id, ...doc.data() }));
            return { json: async () => ({ success: true, usuarios }) };
        }

        // ADMIN - Reservas
        if (endpoint === 'admin/reservas/reporte' && method === 'GET') {
            const reservasSnap = await getDocs(collection(db, 'reservas'));
            const reservas = reservasSnap.docs.map(doc => ({ id: doc.id, ...doc.data() }));
            return { json: async () => reservas };
        }

        if (endpoint.startsWith('admin/reservas/') && method === 'DELETE') {
            const reservaId = parts[2];
            await deleteDoc(doc(db, 'reservas', reservaId));
            return { json: async () => ({ success: true }) };
        }

        if (endpoint.startsWith('admin/reservas/') && method === 'PUT') {
            const reservaId = parts[2];
            await updateDoc(doc(db, 'reservas', reservaId), body);
            return { json: async () => ({ success: true }) };
        }

        // ADMIN - Pagos
        if (endpoint === 'admin/pagos/reporte' && method === 'GET') {
            const pagosSnap = await getDocs(collection(db, 'pagos'));
            const pagos = pagosSnap.docs.map(doc => ({ id: doc.id, ...doc.data() }));
            return { json: async () => pagos };
        }

        if (endpoint === 'admin/pagos/cargar-masivo' && method === 'POST') {
            const { pagos } = body;
            const promises = pagos.map(pago =>
                addDoc(collection(db, 'pagos'), {
                    ...pago,
                    fechaCreacion: new Date().toISOString()
                })
            );
            await Promise.all(promises);
            return { json: async () => ({ success: true, cantidad: pagos.length }) };
        }

        if (endpoint === 'admin/estadisticas/pagos' && method === 'GET') {
            const pagosSnap = await getDocs(collection(db, 'pagos'));
            const pagos = pagosSnap.docs.map(doc => doc.data());

            const totalRecaudado = pagos.reduce((sum, p) => sum + (p.monto || 0), 0);
            const pagosPendientes = pagos.filter(p => p.estado === 'pendiente').length;
            const pagosPagados = pagos.filter(p => p.estado === 'pagado').length;

            return { json: async () => ({
                totalRecaudado,
                pagosPendientes,
                pagosPagados,
                totalPagos: pagos.length
            })};
        }

        if (endpoint === 'admin/estadisticas/reservas' && method === 'GET') {
            const reservasSnap = await getDocs(collection(db, 'reservas'));
            const reservas = reservasSnap.docs.map(doc => doc.data());

            return { json: async () => ({
                totalReservas: reservas.length,
                reservasActivas: reservas.filter(r => r.estado === 'activa').length,
                reservasCanceladas: reservas.filter(r => r.estado === 'cancelada').length
            })};
        }

        // ADMIN - PQRS
        if (endpoint === 'admin/pqrs/todas' && method === 'GET') {
            const pqrsSnap = await getDocs(collection(db, 'pqrs'));
            const pqrs = pqrsSnap.docs.map(doc => ({ id: doc.id, ...doc.data() }));
            return { json: async () => pqrs };
        }

        if (endpoint.startsWith('admin/pqrs/') && method === 'PUT') {
            const pqrsId = parts[2];
            await updateDoc(doc(db, 'pqrs', pqrsId), body);
            return { json: async () => ({ success: true }) };
        }

        // ADMIN - Encuestas
        if (endpoint === 'admin/encuestas' && method === 'POST') {
            const docRef = await addDoc(collection(db, 'encuestas'), {
                ...body,
                fechaCreacion: new Date().toISOString(),
                activa: true,
                votos: []
            });
            return { json: async () => ({ success: true, id: docRef.id }) };
        }

        if (endpoint.startsWith('admin/encuestas/') && endpoint.endsWith('/resultados') && method === 'GET') {
            const encuestaId = parts[2];
            const encuestaDoc = await getDoc(doc(db, 'encuestas', encuestaId));
            if (encuestaDoc.exists()) {
                return { json: async () => ({ success: true, encuesta: encuestaDoc.data() }) };
            }
            return { json: async () => ({ success: false, mensaje: 'Encuesta no encontrada' }) };
        }

        // ADMIN - Sorteo Parqueaderos
        if (endpoint === 'admin/sorteo-parqueaderos' && method === 'POST') {
            const { participantes } = body;
            const resultados = participantes.map((p, i) => ({
                ...p,
                parqueadero: `P-${String(i + 1).padStart(3, '0')}`,
                nivel: i < 33 ? 'Sótano 1' : i < 66 ? 'Sótano 2' : 'Sótano 3'
            }));

            const docRef = await addDoc(collection(db, 'sorteoParqueaderos'), {
                fecha: new Date().toISOString(),
                resultados,
                realizado: true
            });

            return { json: async () => ({ success: true, resultados, id: docRef.id }) };
        }

        if (endpoint === 'admin/sorteo-parqueaderos/ultimo' && method === 'GET') {
            const sorteosSnap = await getDocs(
                query(collection(db, 'sorteoParqueaderos'), orderBy('fecha', 'desc'), limit(1))
            );

            if (!sorteosSnap.empty) {
                return { json: async () => ({
                    success: true,
                    sorteo: { id: sorteosSnap.docs[0].id, ...sorteosSnap.docs[0].data() }
                })};
            }
            return { json: async () => ({ success: false, sorteo: null }) };
        }

        // ADMIN - Residentes
        if (endpoint === 'admin/residentes' && method === 'GET') {
            const residentesSnap = await getDocs(collection(db, 'residentes'));
            const residentes = residentesSnap.docs.map(doc => ({ id: doc.id, ...doc.data() }));
            return { json: async () => ({ success: true, residentes }) };
        }

        if (endpoint === 'admin/residentes/activos' && method === 'GET') {
            const residentesSnap = await getDocs(
                query(collection(db, 'residentes'), where('activo', '==', true))
            );
            const residentes = residentesSnap.docs.map(doc => ({ id: doc.id, ...doc.data() }));
            return { json: async () => residentes };
        }

        if (endpoint === 'admin/residentes' && method === 'POST') {
            const docRef = await addDoc(collection(db, 'residentes'), {
                ...body,
                fechaRegistro: new Date().toISOString(),
                activo: true
            });
            return { json: async () => ({ success: true, id: docRef.id }) };
        }

        if (endpoint.startsWith('admin/residentes/') && method === 'DELETE') {
            const residenteId = parts[2];
            await deleteDoc(doc(db, 'residentes', residenteId));
            return { json: async () => ({ success: true }) };
        }

        // ADMIN - Vehículos
        if (endpoint === 'admin/vehiculos/reporte' && method === 'GET') {
            const vehiculosSnap = await getDocs(collection(db, 'vehiculosVisitantes'));
            const vehiculos = vehiculosSnap.docs.map(doc => ({ id: doc.id, ...doc.data() }));
            return { json: async () => vehiculos };
        }

        // ADMIN - Cámaras
        if (endpoint === 'admin/camaras' && method === 'GET') {
            const camarasSnap = await getDocs(collection(db, 'camaras'));
            const camaras = camarasSnap.docs.map(doc => ({ id: doc.id, ...doc.data() }));
            return { json: async () => camaras };
        }

        if (endpoint === 'admin/camaras' && method === 'POST') {
            const docRef = await addDoc(collection(db, 'camaras'), body);
            return { json: async () => ({ success: true, id: docRef.id }) };
        }

        if (endpoint.startsWith('admin/camaras/') && method === 'PUT') {
            const camaraId = parts[2];
            await updateDoc(doc(db, 'camaras', camaraId), body);
            return { json: async () => ({ success: true }) };
        }

        // ADMIN - Documentos
        if (endpoint === 'admin/documentos' && method === 'POST') {
            const docRef = await addDoc(collection(db, 'documentos'), {
                ...body,
                fechaSubida: new Date().toISOString()
            });
            return { json: async () => ({ success: true, id: docRef.id }) };
        }

        if (endpoint.startsWith('admin/documentos/') && method === 'DELETE') {
            const documentoId = parts[2];
            await deleteDoc(doc(db, 'documentos', documentoId));
            return { json: async () => ({ success: true }) };
        }

        if (endpoint.startsWith('admin/documentos/') && method === 'PUT') {
            const documentoId = parts[2];
            await updateDoc(doc(db, 'documentos', documentoId), body);
            return { json: async () => ({ success: true }) };
        }

        // ADMIN - Solicitudes
        if (endpoint === 'admin/solicitudes' && method === 'GET') {
            const solicitudesSnap = await getDocs(collection(db, 'solicitudes'));
            const solicitudes = solicitudesSnap.docs.map(doc => ({ id: doc.id, ...doc.data() }));
            return { json: async () => solicitudes };
        }

        if (endpoint.startsWith('admin/solicitudes/') && method === 'PUT') {
            const solicitudId = parts[2];
            await updateDoc(doc(db, 'solicitudes', solicitudId), body);
            return { json: async () => ({ success: true }) };
        }

        // ============= RUTAS DE VIGILANTE =============

        // VIGILANTE - Solicitudes
        if (endpoint === 'vigilante/solicitudes' && method === 'GET') {
            const solicitudesSnap = await getDocs(collection(db, 'solicitudes'));
            const solicitudes = solicitudesSnap.docs.map(doc => ({ id: doc.id, ...doc.data() }));
            return { json: async () => solicitudes };
        }

        if (endpoint.startsWith('vigilante/solicitudes/') && method === 'PUT') {
            const solicitudId = parts[2];
            await updateDoc(doc(db, 'solicitudes', solicitudId), {
                ...body,
                procesadoPor: window.firebaseAdapter.currentUser?.nombre,
                fechaProceso: new Date().toISOString()
            });
            return { json: async () => ({ success: true }) };
        }

        // VIGILANTE - Vehículos
        if (endpoint === 'vehiculos-visitantes/ingreso' && method === 'POST') {
            const docRef = await addDoc(collection(db, 'vehiculosVisitantes'), {
                ...body,
                fechaIngreso: new Date().toISOString(),
                activo: true,
                registradoPor: window.firebaseAdapter.currentUser?.nombre || 'Vigilante'
            });
            return { json: async () => ({ success: true, vehiculo: { id: docRef.id, ...body } }) };
        }

        if (endpoint === 'vehiculos-visitantes/salida' && method === 'POST') {
            const { placa } = body;
            const vehiculosSnap = await getDocs(
                query(collection(db, 'vehiculosVisitantes'), where('placa', '==', placa), where('activo', '==', true))
            );

            if (!vehiculosSnap.empty) {
                const vehiculoDoc = vehiculosSnap.docs[0];
                await updateDoc(doc(db, 'vehiculosVisitantes', vehiculoDoc.id), {
                    activo: false,
                    fechaSalida: new Date().toISOString(),
                    procesadoPor: window.firebaseAdapter.currentUser?.nombre
                });
                return { json: async () => ({ success: true, vehiculo: vehiculoDoc.data() }) };
            }
            return { json: async () => ({ success: false, mensaje: 'Vehículo no encontrado' }) };
        }

        // VIGILANTE - Permisos
        if (endpoint === 'permisos' && method === 'GET') {
            const permisosSnap = await getDocs(collection(db, 'permisos'));
            const permisos = permisosSnap.docs.map(doc => ({ id: doc.id, ...doc.data() }));
            return { json: async () => permisos };
        }

        if (endpoint === 'permisos' && method === 'POST') {
            const docRef = await addDoc(collection(db, 'permisos'), {
                ...body,
                fechaSolicitud: new Date().toISOString(),
                estado: 'pendiente'
            });
            return { json: async () => ({ success: true, id: docRef.id }) };
        }

        if (endpoint.startsWith('permisos/') && endpoint.endsWith('/ingresar') && method === 'PUT') {
            const permisoId = parts[1];
            await updateDoc(doc(db, 'permisos', permisoId), {
                estado: 'ingresado',
                fechaIngreso: new Date().toISOString(),
                procesadoPor: window.firebaseAdapter.currentUser?.nombre
            });
            return { json: async () => ({ success: true }) };
        }

        if (endpoint.startsWith('permisos/') && endpoint.endsWith('/salir') && method === 'PUT') {
            const permisoId = parts[1];
            await updateDoc(doc(db, 'permisos', permisoId), {
                estado: 'salida',
                fechaSalida: new Date().toISOString()
            });
            return { json: async () => ({ success: true }) };
        }

        // VIGILANTE - Paquetes
        if (endpoint === 'paquetes' && method === 'GET') {
            const paquetesSnap = await getDocs(collection(db, 'paquetes'));
            const paquetes = paquetesSnap.docs.map(doc => ({ id: doc.id, ...doc.data() }));
            return { json: async () => paquetes };
        }

        if (endpoint === 'paquetes' && method === 'POST') {
            const docRef = await addDoc(collection(db, 'paquetes'), {
                ...body,
                fechaLlegada: new Date().toISOString(),
                estado: 'pendiente',
                registradoPor: window.firebaseAdapter.currentUser?.nombre || 'Vigilante'
            });
            return { json: async () => ({ success: true, id: docRef.id }) };
        }

        // ============= RUTAS DE ALCALDÍA =============

        // ALCALDÍA - Incidentes
        if (endpoint === 'incidentes' && method === 'GET') {
            const incidentesSnap = await getDocs(collection(db, 'incidentes'));
            const incidentes = incidentesSnap.docs.map(doc => ({ id: doc.id, ...doc.data() }));
            return { json: async () => incidentes };
        }

        if (endpoint === 'incidentes' && method === 'POST') {
            const docRef = await addDoc(collection(db, 'incidentes'), {
                ...body,
                fechaReporte: new Date().toISOString(),
                estado: 'Reportado',
                reportadoPor: window.firebaseAdapter.currentUser?.nombre || window.firebaseAdapter.currentUser?.email
            });
            return { json: async () => ({ success: true, id: docRef.id }) };
        }

        if (endpoint.startsWith('incidentes/') && endpoint.endsWith('/responder') && method === 'POST') {
            const incidenteId = parts[1];
            await updateDoc(doc(db, 'incidentes', incidenteId), {
                respuesta: body.respuesta,
                estado: 'Respondido',
                fechaRespuesta: new Date().toISOString(),
                respondidoPor: window.firebaseAdapter.currentUser?.nombre
            });
            return { json: async () => ({ success: true }) };
        }

        if (endpoint.startsWith('incidentes/') && endpoint.endsWith('/estado') && method === 'PUT') {
            const incidenteId = parts[1];
            await updateDoc(doc(db, 'incidentes', incidenteId), {
                estado: body.estado,
                fechaActualizacion: new Date().toISOString()
            });
            return { json: async () => ({ success: true }) };
        }

        // ============= RUTAS GENERALES CON POST =============

        // Encuestas - Votar
        if (endpoint.startsWith('encuestas/') && endpoint.endsWith('/votar') && method === 'POST') {
            const encuestaId = parts[1];
            const encuestaRef = doc(db, 'encuestas', encuestaId);
            const encuestaDoc = await getDoc(encuestaRef);

            if (encuestaDoc.exists()) {
                const votos = encuestaDoc.data().votos || [];
                votos.push({
                    usuarioId: window.firebaseAdapter.currentUser?.id,
                    opcion: body.opcion,
                    fecha: new Date().toISOString()
                });

                await updateDoc(encuestaRef, { votos });
                return { json: async () => ({ success: true }) };
            }
            return { json: async () => ({ success: false, mensaje: 'Encuesta no encontrada' }) };
        }

        // Documentos - GET
        if (endpoint === 'documentos' && method === 'GET') {
            const documentosSnap = await getDocs(collection(db, 'documentos'));
            const documentos = documentosSnap.docs.map(doc => ({ id: doc.id, ...doc.data() }));
            return { json: async () => documentos };
        }

        // Cámaras - GET (para residentes)
        if (endpoint === 'camaras' && method === 'GET') {
            const camarasSnap = await getDocs(collection(db, 'camaras'));
            const camaras = camarasSnap.docs.map(doc => ({ id: doc.id, ...doc.data() }));
            return { json: async () => camaras };
        }

        // Si no hay match, devolver error
        console.warn('Endpoint no implementado:', endpoint, method);
        return {
            json: async () => ({
                success: false,
                mensaje: `Endpoint ${endpoint} (${method}) no implementado en Firebase adapter`
            })
        };

    } catch (error) {
        console.error('Error en Firebase adapter:', error);
        return {
            json: async () => ({
                success: false,
                mensaje: error.message
            })
        };
    }
};

// Verificar sesión al cargar
onAuthStateChanged(auth, async (user) => {
    if (user) {
        const userDoc = await getDoc(doc(db, 'usuarios', user.uid));
        if (userDoc.exists()) {
            window.firebaseAdapter.currentUser = userDoc.data();
        }
    }
});

console.log('✅ Firebase Adapter cargado correctamente');
