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
    currentUser: null,

    // Función helper para obtener colecciones completas
    async getCollection(collectionName) {
        try {
            const snapshot = await getDocs(collection(db, collectionName));
            return snapshot.docs.map(doc => ({ id: doc.id, ...doc.data() }));
        } catch (error) {
            console.error(`Error obteniendo colección ${collectionName}:`, error);
            throw error;
        }
    },

    // Función helper para obtener un documento por ID
    async getDocument(collectionName, docId) {
        try {
            const docSnap = await getDoc(doc(db, collectionName, docId));
            if (docSnap.exists()) {
                return { id: docSnap.id, ...docSnap.data() };
            }
            return null;
        } catch (error) {
            console.error(`Error obteniendo documento ${docId} de ${collectionName}:`, error);
            throw error;
        }
    },

    // Función helper para agregar documento
    async addDocument(collectionName, data) {
        try {
            const docRef = await addDoc(collection(db, collectionName), {
                ...data,
                fechaCreacion: data.fechaCreacion || new Date().toISOString()
            });
            return { success: true, id: docRef.id };
        } catch (error) {
            console.error(`Error agregando documento a ${collectionName}:`, error);
            throw error;
        }
    },

    // Función helper para actualizar documento
    async updateDocument(collectionName, docId, data) {
        try {
            await updateDoc(doc(db, collectionName, docId), {
                ...data,
                fechaActualizacion: new Date().toISOString()
            });
            return { success: true };
        } catch (error) {
            console.error(`Error actualizando documento ${docId} en ${collectionName}:`, error);
            throw error;
        }
    },

    // Función helper para eliminar documento
    async deleteDocument(collectionName, docId) {
        try {
            await deleteDoc(doc(db, collectionName, docId));
            return { success: true };
        } catch (error) {
            console.error(`Error eliminando documento ${docId} de ${collectionName}:`, error);
            throw error;
        }
    },

    // Función helper para queries con filtros
    async queryCollection(collectionName, filters = []) {
        try {
            let q = collection(db, collectionName);

            // Aplicar filtros
            const constraints = [];
            for (const filter of filters) {
                if (filter.type === 'where') {
                    constraints.push(where(filter.field, filter.operator, filter.value));
                } else if (filter.type === 'orderBy') {
                    constraints.push(orderBy(filter.field, filter.direction || 'asc'));
                } else if (filter.type === 'limit') {
                    constraints.push(limit(filter.value));
                }
            }

            if (constraints.length > 0) {
                q = query(q, ...constraints);
            }

            const snapshot = await getDocs(q);
            return snapshot.docs.map(doc => ({ id: doc.id, ...doc.data() }));
        } catch (error) {
            console.error(`Error en query de ${collectionName}:`, error);
            throw error;
        }
    }
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
            window.firebaseAdapter.currentUser = {
                uid: user.uid,  // UID de Firebase Auth
                ...userData  // Datos de Firestore
            };

            console.log('✅ Login exitoso. Usuario:', window.firebaseAdapter.currentUser);

            // Registrar inicio de sesión
            try {
                await addDoc(collection(db, 'sesiones'), {
                    usuarioId: user.uid,
                    email: userData.email,
                    nombre: userData.nombre,
                    rol: userData.rol,
                    fecha: new Date().toISOString(),
                    timestamp: new Date().getTime()
                });
            } catch (error) {
                console.log('Error registrando sesión:', error);
            }

            // Retornar en formato compatible con la app
            return {
                success: true,
                token: await user.getIdToken(),
                usuario: {
                    uid: user.uid,
                    ...userData
                }
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

    // Extraer endpoint y remover query params
    let endpoint = url.replace('/api/', '');
    // Remover query params si existen
    if (endpoint.includes('?')) {
        endpoint = endpoint.split('?')[0];
    }
    const parts = endpoint.split('/');

    try {
        // RUTAS DE AUTENTICACIÓN
        if (endpoint === 'auth/login') {
            const result = await window.firebaseLogin(body.email, body.password);
            return { ok: true, json: async () => result };
        }

        // RUTAS DE NOTICIAS
        if (endpoint === 'noticias' && method === 'GET') {
            const noticiasSnap = await getDocs(query(collection(db, 'noticias'), orderBy('fechaPublicacion', 'desc')));
            const noticias = noticiasSnap.docs.map(doc => ({ id: doc.id, ...doc.data() }));
            return { ok: true, json: async () => noticias };
        }

        // RUTAS DE RESERVAS
        if (endpoint === 'reservas' && method === 'GET') {
            const reservasSnap = await getDocs(collection(db, 'reservas'));
            const reservas = reservasSnap.docs.map(doc => ({ id: doc.id, ...doc.data() }));
            return { ok: true, json: async () => reservas };
        }

        if (endpoint === 'reservas' && method === 'POST') {
            const docRef = await addDoc(collection(db, 'reservas'), {
                ...body,
                usuarioId: window.firebaseAdapter.currentUser?.id,
                usuario: window.firebaseAdapter.currentUser?.nombre,
                fechaCreacion: new Date().toISOString()
            });
            return {
                ok: true,
                json: async () => ({ success: true, id: docRef.id })
            };
        }

        // RUTAS DE PQRS
        if (endpoint === 'pqrs' && method === 'GET') {
            const pqrsSnap = await getDocs(collection(db, 'pqrs'));
            const pqrs = pqrsSnap.docs.map(doc => ({ id: doc.id, ...doc.data() }));
            return { ok: true, json: async () => pqrs };
        }

        if (endpoint === 'pqrs' && method === 'POST') {
            const docRef = await addDoc(collection(db, 'pqrs'), {
                ...body,
                usuarioId: window.firebaseAdapter.currentUser?.id,
                estado: 'Pendiente',
                fechaCreacion: new Date().toISOString()
            });
            return { ok: true, json: async () => ({ success: true, id: docRef.id }) };
        }

        // PQRS - Cambiar estado
        if (endpoint.startsWith('pqrs/') && endpoint.endsWith('/estado') && method === 'PUT') {
            const pqrsId = parts[1];
            await updateDoc(doc(db, 'pqrs', pqrsId), {
                estado: body.estado,
                fechaActualizacion: new Date().toISOString(),
                actualizadoPor: window.firebaseAdapter.currentUser?.nombre
            });
            return { ok: true, json: async () => ({ success: true }) };
        }

        // PQRS - Responder
        if (endpoint.startsWith('pqrs/') && endpoint.endsWith('/responder') && (method === 'POST' || method === 'PUT')) {
            const pqrsId = parts[1];
            await updateDoc(doc(db, 'pqrs', pqrsId), {
                respuesta: body.respuesta,
                estado: body.estado || 'Respondida',
                fechaRespuesta: new Date().toISOString(),
                respondidoPor: window.firebaseAdapter.currentUser?.nombre
            });
            return { ok: true, json: async () => ({ success: true }) };
        }

        // RUTAS DE PAGOS
        if (endpoint === 'pagos' && method === 'GET') {
            const pagosSnap = await getDocs(collection(db, 'pagos'));
            const pagos = pagosSnap.docs.map(doc => ({ id: doc.id, ...doc.data() }));
            return { ok: true, json: async () => pagos };
        }

        // ADMIN - Crear pago individual
        if (endpoint === 'admin/pagos' && method === 'POST') {
            const docRef = await addDoc(collection(db, 'pagos'), {
                ...body,
                fechaCreacion: body.fechaCreacion || new Date().toISOString(),
                estado: body.estado || 'Pendiente'
            });
            return { ok: true, json: async () => ({ success: true, id: docRef.id }) };
        }

        // Actualizar estado de pago
        if (endpoint.startsWith('pagos/') && endpoint.endsWith('/estado') && method === 'PUT') {
            const pagoId = parts[1];
            await updateDoc(doc(db, 'pagos', pagoId), {
                estado: body.estado,
                fechaPago: body.fechaPago,
                fechaActualizacion: new Date().toISOString()
            });
            return { ok: true, json: async () => ({ success: true }) };
        }

        // RUTAS DE EMPRENDIMIENTOS
        if (endpoint === 'emprendimientos' && method === 'GET') {
            const empSnap = await getDocs(collection(db, 'emprendimientos'));
            const emprendimientos = empSnap.docs.map(doc => ({ id: doc.id, ...doc.data() }));
            return { ok: true, json: async () => emprendimientos };
        }

        if (endpoint === 'residente/emprendimientos' && method === 'GET') {
            const empSnap = await getDocs(collection(db, 'emprendimientos'));
            const emprendimientos = await Promise.all(empSnap.docs.map(async (empDoc) => {
                const empData = { id: empDoc.id, ...empDoc.data() };

                // Obtener reseñas del emprendimiento
                const resenasSnap = await getDocs(
                    query(collection(db, 'resenas'), where('emprendimientoId', '==', empDoc.id))
                );
                empData.resenas = resenasSnap.docs.map(doc => ({ id: doc.id, ...doc.data() }));

                return empData;
            }));
            return { ok: true, json: async () => ({ success: true, emprendimientos }) };
        }

        // RESIDENTE - Escribir reseña
        if (endpoint === 'residente/emprendimientos/resena' && method === 'POST') {
            const docRef = await addDoc(collection(db, 'resenas'), {
                ...body,
                usuarioId: window.firebaseAdapter.currentUser?.id,
                usuario: window.firebaseAdapter.currentUser?.nombre,
                fecha: new Date().toISOString()
            });
            return { ok: true, json: async () => ({ success: true, id: docRef.id }) };
        }

        // RESIDENTE - Ver reseñas de emprendimiento
        if (endpoint.startsWith('residente/emprendimientos/') && endpoint.endsWith('/resenas') && method === 'GET') {
            const emprendimientoId = endpoint.split('/')[2];
            const resenasSnap = await getDocs(
                query(collection(db, 'resenas'), where('emprendimientoId', '==', emprendimientoId))
            );
            const resenas = resenasSnap.docs.map(doc => ({ id: doc.id, ...doc.data() }));
            return { ok: true, json: async () => ({ success: true, resenas }) };
        }

        // RESIDENTE - Registrar emprendimiento
        if (endpoint === 'residente/emprendimiento' && method === 'POST') {
            const docRef = await addDoc(collection(db, 'emprendimientos'), {
                ...body,
                propietario: window.firebaseAdapter.currentUser?.nombre,
                usuarioId: window.firebaseAdapter.currentUser?.id,
                torre: window.firebaseAdapter.currentUser?.torre,
                apartamento: window.firebaseAdapter.currentUser?.apartamento,
                fechaRegistro: new Date().toISOString(),
                activo: true
            });
            return { ok: true, json: async () => ({ success: true, id: docRef.id }) };
        }

        // RESIDENTE - Ver arriendos (apartamentos y parqueaderos)
        if (endpoint === 'residente/arriendos' && method === 'GET') {
            const [apartamentosSnap, parqueaderosSnap] = await Promise.all([
                getDocs(query(collection(db, 'apartamentosArriendo'), where('disponible', '==', true))),
                getDocs(query(collection(db, 'parqueaderosArriendo'), where('disponible', '==', true)))
            ]);

            const apartamentos = apartamentosSnap.docs.map(doc => ({
                id: doc.id,
                tipo: 'apartamento',
                ...doc.data()
            }));

            const parqueaderos = parqueaderosSnap.docs.map(doc => ({
                id: doc.id,
                tipo: 'parqueadero',
                ...doc.data()
            }));

            return { ok: true, json: async () => ({
                success: true,
                apartamentos,
                parqueaderos
            })};
        }

        // RESIDENTE - Publicar arriendo
        if (endpoint === 'residente/publicar-arriendo' && method === 'POST') {
            const collectionName = body.tipo === 'apartamento' ? 'apartamentosArriendo' : 'parqueaderosArriendo';
            const docRef = await addDoc(collection(db, collectionName), {
                ...body,
                propietario: window.firebaseAdapter.currentUser?.nombre,
                usuarioId: window.firebaseAdapter.currentUser?.id,
                torre: window.firebaseAdapter.currentUser?.torre,
                apartamento: window.firebaseAdapter.currentUser?.apartamento,
                disponible: true,
                fechaPublicacion: new Date().toISOString()
            });
            return { ok: true, json: async () => ({ success: true, id: docRef.id }) };
        }

        // RUTAS DE CHAT
        if (endpoint.startsWith('chat/general') && method === 'GET') {
            const mensajesSnap = await getDocs(query(collection(db, 'chats', 'general', 'mensajes'), orderBy('fecha', 'asc')));
            const mensajes = mensajesSnap.docs.map(doc => ({ id: doc.id, ...doc.data() }));
            return { ok: true, json: async () => ({ success: true, mensajes }) };
        }

        if (endpoint.startsWith('chat/general') && method === 'POST') {
            const docRef = await addDoc(collection(db, 'chats', 'general', 'mensajes'), {
                ...body,
                usuarioId: window.firebaseAdapter.currentUser?.id,
                usuarioNombre: window.firebaseAdapter.currentUser?.nombre,
                fecha: new Date().toISOString()
            });
            return { ok: true, json: async () => ({ success: true, id: docRef.id }) };
        }

        // Chat Admin
        if (endpoint.startsWith('chat/admin') && method === 'GET') {
            const mensajesSnap = await getDocs(query(collection(db, 'chats', 'admin', 'mensajes'), orderBy('fecha', 'asc')));
            const mensajes = mensajesSnap.docs.map(doc => ({ id: doc.id, ...doc.data() }));
            return { ok: true, json: async () => ({ success: true, mensajes }) };
        }

        if (endpoint.startsWith('chat/admin') && method === 'POST') {
            const docRef = await addDoc(collection(db, 'chats', 'admin', 'mensajes'), {
                mensaje: body.mensaje,
                usuario: window.firebaseAdapter.currentUser?.nombre,
                usuarioEmail: window.firebaseAdapter.currentUser?.email,
                usuarioId: window.firebaseAdapter.currentUser?.id,
                timestamp: new Date().toISOString(),
                fecha: new Date().toISOString()
            });
            return { ok: true, json: async () => ({ success: true, id: docRef.id }) };
        }

        // Chat Vigilantes
        if (endpoint.startsWith('chat/vigilantes') && method === 'GET') {
            const mensajesSnap = await getDocs(query(collection(db, 'chats', 'vigilantes', 'mensajes'), orderBy('fecha', 'asc')));
            const mensajes = mensajesSnap.docs.map(doc => ({ id: doc.id, ...doc.data() }));
            return { ok: true, json: async () => ({ success: true, mensajes }) };
        }

        if (endpoint.startsWith('chat/vigilantes') && method === 'POST') {
            const docRef = await addDoc(collection(db, 'chats', 'vigilantes', 'mensajes'), {
                mensaje: body.mensaje,
                usuario: window.firebaseAdapter.currentUser?.nombre,
                usuarioEmail: window.firebaseAdapter.currentUser?.email,
                usuarioId: window.firebaseAdapter.currentUser?.id,
                timestamp: new Date().toISOString(),
                fecha: new Date().toISOString()
            });
            return { ok: true, json: async () => ({ success: true, id: docRef.id }) };
        }

        // Chat enviar - endpoint genérico para enviar mensajes
        if (endpoint === 'chat/enviar' && method === 'POST') {
            const { tipo, mensaje } = body;
            const chatPath = tipo === 'general' ? 'general' : tipo === 'admin' ? 'admin' : 'vigilantes';

            const docRef = await addDoc(collection(db, 'chats', chatPath, 'mensajes'), {
                mensaje: mensaje,
                usuario: window.firebaseAdapter.currentUser?.nombre,
                usuarioEmail: window.firebaseAdapter.currentUser?.email,
                usuarioId: window.firebaseAdapter.currentUser?.id,
                timestamp: new Date().toISOString(),
                fecha: new Date().toISOString()
            });
            return { ok: true, json: async () => ({ success: true, id: docRef.id }) };
        }

        // Usuarios conectados (simulado - devuelve todos los usuarios activos)
        if (endpoint === 'chat/usuarios-conectados' && method === 'GET') {
            const usuariosSnap = await getDocs(collection(db, 'usuarios'));
            const usuarios = usuariosSnap.docs
                .map(doc => ({ id: doc.id, ...doc.data() }))
                .filter(u => u.activo !== false)
                .map(u => ({ id: u.id, nombre: u.nombre, apartamento: u.apartamento }));
            return { ok: true, json: async () => ({ success: true, usuarios }) };
        }

        // RUTAS DE CHAT PRIVADO
        if (endpoint === 'chat/solicitar' && method === 'POST') {
            const docRef = await addDoc(collection(db, 'solicitudesChat'), {
                ...body,
                remitenteId: window.firebaseAdapter.currentUser?.id,
                remitenteNombre: window.firebaseAdapter.currentUser?.nombre,
                estado: 'pendiente',
                fecha: new Date().toISOString()
            });
            return { ok: true, json: async () => ({ success: true, id: docRef.id }) };
        }

        if (endpoint === 'chat/solicitudes' && method === 'GET') {
            const userId = window.firebaseAdapter.currentUser?.id;
            const solicitudesSnap = await getDocs(
                query(collection(db, 'solicitudesChat'), where('destinatarioId', '==', userId))
            );
            const solicitudes = solicitudesSnap.docs.map(doc => ({ id: doc.id, ...doc.data() }));
            return { ok: true, json: async () => ({ success: true, solicitudes }) };
        }

        if (endpoint === 'chat/responder' && method === 'POST') {
            const { solicitudId, aceptar } = body;
            await updateDoc(doc(db, 'solicitudesChat', solicitudId), {
                estado: aceptar ? 'aceptada' : 'rechazada',
                fechaRespuesta: new Date().toISOString()
            });
            return { ok: true, json: async () => ({ success: true }) };
        }

        if (endpoint.startsWith('chat/privado/') && method === 'GET') {
            const chatId = endpoint.split('/')[2];
            const mensajesSnap = await getDocs(
                query(collection(db, 'chats', 'privados', chatId, 'mensajes'), orderBy('fecha', 'asc'))
            );
            const mensajes = mensajesSnap.docs.map(doc => ({ id: doc.id, ...doc.data() }));
            return { ok: true, json: async () => ({ mensajes }) };
        }

        if (endpoint.startsWith('chat/privado/') && method === 'POST') {
            const chatId = endpoint.split('/')[2];
            const docRef = await addDoc(collection(db, 'chats', 'privados', chatId, 'mensajes'), {
                ...body,
                usuarioId: window.firebaseAdapter.currentUser?.id,
                usuarioNombre: window.firebaseAdapter.currentUser?.nombre,
                fecha: new Date().toISOString()
            });
            return { ok: true, json: async () => ({ success: true, id: docRef.id }) };
        }

        // RUTAS DE USUARIOS
        if (endpoint === 'usuarios' && method === 'GET') {
            const usuariosSnap = await getDocs(collection(db, 'usuarios'));
            const usuarios = usuariosSnap.docs.map(doc => ({ id: doc.id, ...doc.data() }));
            return { ok: true, json: async () => usuarios };
        }

        // RUTAS DE ENCUESTAS
        if (endpoint === 'encuestas' && method === 'GET') {
            const encuestasSnap = await getDocs(collection(db, 'encuestas'));
            const encuestas = encuestasSnap.docs.map(doc => {
                const data = doc.data();
                return {
                    id: doc.id,
                    ...data,
                    opciones: data.opciones || [],
                    votantes: data.votantes || [],
                    estado: data.activa ? 'activa' : 'cerrada'
                };
            });
            return { ok: true, json: async () => ({ encuestas }) };
        }

        if (endpoint === 'encuestas' && method === 'POST') {
            const opciones = body.opciones.map(texto => ({
                texto,
                votos: 0
            }));

            const docRef = await addDoc(collection(db, 'encuestas'), {
                titulo: body.titulo,
                descripcion: body.descripcion,
                opciones: opciones,
                fechaCreacion: new Date().toISOString(),
                creadoPor: window.firebaseAdapter.currentUser?.nombre || 'Admin',
                activa: true,
                votantes: []
            });
            return { ok: true, json: async () => ({ success: true, id: docRef.id }) };
        }

        // RUTAS DE FORMULARIOS DE REGISTRO
        if (endpoint === 'formularios' && method === 'GET') {
            const formulariosSnap = await getDocs(collection(db, 'formularios'));
            const formularios = formulariosSnap.docs.map(doc => ({ id: doc.id, ...doc.data() }));
            return { ok: true, json: async () => formularios };
        }

        if (endpoint === 'formularios' && method === 'POST') {
            const docRef = await addDoc(collection(db, 'formularios'), {
                ...body,
                fechaCreacion: new Date().toISOString(),
                creadoPor: window.firebaseAdapter.currentUser?.nombre || 'Admin',
                activo: true
            });
            return { ok: true, json: async () => ({ success: true, id: docRef.id }) };
        }

        // Obtener respuestas de un formulario específico
        if (endpoint.startsWith('formularios/') && endpoint.endsWith('/respuestas') && method === 'GET') {
            const formularioId = parts[1];
            const respuestasSnap = await getDocs(
                query(collection(db, 'respuestasFormulario'), where('formularioId', '==', formularioId))
            );
            const respuestas = respuestasSnap.docs.map(doc => ({ id: doc.id, ...doc.data() }));
            return { ok: true, json: async () => respuestas };
        }

        // Enviar respuesta a un formulario
        if (endpoint === 'respuestas-formulario' && method === 'POST') {
            const docRef = await addDoc(collection(db, 'respuestasFormulario'), {
                ...body,
                fechaRespuesta: new Date().toISOString()
            });
            return { ok: true, json: async () => ({ success: true, id: docRef.id }) };
        }

        // RUTAS DE REGISTROS DE EVENTOS
        if (endpoint === 'registros-eventos' && method === 'GET') {
            const userId = window.firebaseAdapter.currentUser?.id;
            const registrosSnap = await getDocs(
                query(collection(db, 'registrosEventos'), where('usuarioId', '==', userId), orderBy('fechaRegistro', 'desc'))
            );
            const registros = registrosSnap.docs.map(doc => ({ id: doc.id, ...doc.data() }));
            return { ok: true, json: async () => ({ success: true, registros }) };
        }

        if (endpoint === 'registros-eventos' && method === 'POST') {
            const currentUser = window.firebaseAdapter.currentUser;
            const docRef = await addDoc(collection(db, 'registrosEventos'), {
                nombreEvento: body.nombreEvento,
                asistentes: body.asistentes,
                notas: body.notas || '',
                usuarioId: currentUser?.id,
                apartamento: currentUser?.apartamento,
                fechaRegistro: new Date().toISOString()
            });
            return { ok: true, json: async () => ({ success: true, id: docRef.id }) };
        }

        // RUTAS DE VEHICULOS VISITANTES
        if (endpoint === 'vehiculos-visitantes' && method === 'GET') {
            const vehiculosSnap = await getDocs(collection(db, 'vehiculosVisitantes'));
            const vehiculos = vehiculosSnap.docs.map(doc => ({ id: doc.id, ...doc.data() }));
            return { ok: true, json: async () => vehiculos };
        }

        // RUTAS DE PARQUEADEROS
        if (endpoint === 'parqueaderos' && method === 'GET') {
            const parqueaderosSnap = await getDocs(collection(db, 'parqueaderos'));
            const parqueaderos = parqueaderosSnap.docs.map(doc => ({ numero: doc.id, ...doc.data() }));
            return { ok: true, json: async () => parqueaderos };
        }

        // RUTAS DE APARTAMENTOS EN ARRIENDO
        if (endpoint === 'apartamentos-arriendo' && method === 'GET') {
            const aptosSnap = await getDocs(collection(db, 'apartamentosArriendo'));
            const apartamentos = aptosSnap.docs.map(doc => ({ id: doc.id, ...doc.data() }));
            return { ok: true, json: async () => apartamentos };
        }

        // ============= RUTAS DE ADMINISTRADOR =============

        // ADMIN - Estadísticas
        if (endpoint === 'admin/estadisticas' && method === 'GET') {
            const [usuarios, reservas, pagos, pqrs, vehiculos] = await Promise.all([
                getDocs(collection(db, 'usuarios')),
                getDocs(collection(db, 'reservas')),
                getDocs(collection(db, 'pagos')),
                getDocs(collection(db, 'pqrs')),
                getDocs(collection(db, 'vehiculosVisitantes'))
            ]);

            // Contar solo residentes (rol: residente)
            const residentes = usuarios.docs.filter(d => d.data().rol === 'residente');

            // Contar inicios de sesión del administrador en el mes actual
            const now = new Date();
            const mesActual = now.getMonth();
            const añoActual = now.getFullYear();

            // Obtener registros de sesión (si existen)
            let sesionesAdminMes = 0;
            try {
                const sesionesSnap = await getDocs(collection(db, 'sesiones'));
                sesionesAdminMes = sesionesSnap.docs.filter(d => {
                    const data = d.data();
                    if (data.rol !== 'admin') return false;
                    if (!data.fecha) return false;
                    const fecha = new Date(data.fecha);
                    return fecha.getMonth() === mesActual && fecha.getFullYear() === añoActual;
                }).length;
            } catch (error) {
                console.log('Colección sesiones no existe aún, se creará en el próximo login');
            }

            // Vehículos visitantes activos (sin fecha de salida)
            const vehiculosActivos = vehiculos.docs.filter(d => !d.data().horaSalida).length;

            // PQRS pendientes (estado: Pendiente o En proceso)
            const pqrsPendientes = pqrs.docs.filter(d => {
                const estado = d.data().estado;
                return estado === 'Pendiente' || estado === 'En proceso';
            }).length;

            return { ok: true, json: async () => ({
                success: true,
                totalResidentes: residentes.length,
                sesionesAdminMes: sesionesAdminMes,
                vehiculosActivos: vehiculosActivos,
                pqrsPendientes: pqrsPendientes,
                // Datos adicionales compatibles con endpoints anteriores
                totalUsuarios: usuarios.size,
                totalReservas: reservas.size,
                totalPagos: pagos.size,
                totalPQRS: pqrs.size,
                reservasActivas: reservas.docs.filter(d => d.data().estado === 'activa').length,
                pagosPendientes: pagos.docs.filter(d => d.data().estado === 'pendiente').length
            })};
        }

        // Estadísticas por torre
        if (endpoint === 'admin/torres' && method === 'GET') {
            const [usuarios, pqrs] = await Promise.all([
                getDocs(collection(db, 'usuarios')),
                getDocs(collection(db, 'pqrs'))
            ]);

            // Extraer número de torre del formato "Torre X - Apto YYY"
            const extraerNumeroTorre = (apartamento) => {
                if (!apartamento) return null;
                const match = apartamento.match(/Torre\s*(\d+)/i);
                return match ? parseInt(match[1]) : null;
            };

            // Obtener residentes y agrupar por torre
            const residentes = usuarios.docs.filter(d => d.data().rol === 'residente');
            const torreStats = {};

            // Inicializar torres (asumiendo 10 torres con 40 apartamentos cada una)
            for (let i = 1; i <= 10; i++) {
                torreStats[i] = {
                    numero: i,
                    totalApartamentos: 40,
                    ocupados: 0,
                    residentes: [],
                    pqrsActivos: 0
                };
            }

            // Contar residentes por torre
            residentes.forEach(doc => {
                const data = doc.data();
                const numeroTorre = extraerNumeroTorre(data.apartamento);
                if (numeroTorre && torreStats[numeroTorre]) {
                    torreStats[numeroTorre].ocupados++;
                    torreStats[numeroTorre].residentes.push({
                        nombre: data.nombre,
                        apartamento: data.apartamento
                    });
                }
            });

            // Contar PQRS activos por torre
            pqrs.docs.forEach(doc => {
                const data = doc.data();
                const estado = data.estado;
                if (estado === 'Pendiente' || estado === 'En proceso') {
                    // Buscar usuario que creó el PQRS
                    const usuario = usuarios.docs.find(u => u.id === data.usuarioId);
                    if (usuario) {
                        const numeroTorre = extraerNumeroTorre(usuario.data().apartamento);
                        if (numeroTorre && torreStats[numeroTorre]) {
                            torreStats[numeroTorre].pqrsActivos++;
                        }
                    }
                }
            });

            // Convertir a array y calcular porcentajes
            const torres = Object.values(torreStats).map(torre => ({
                numero: torre.numero,
                ocupados: torre.ocupados,
                total: torre.totalApartamentos,
                porcentaje: Math.round((torre.ocupados / torre.totalApartamentos) * 100),
                pqrsActivos: torre.pqrsActivos,
                estado: torre.pqrsActivos > 3 ? 'alerta' : 'normal'
            }));

            return { ok: true, json: async () => ({ success: true, torres }) };
        }

        // ADMIN - Noticias
        if (endpoint === 'admin/noticias' && method === 'POST') {
            const docRef = await addDoc(collection(db, 'noticias'), {
                ...body,
                fechaPublicacion: new Date().toISOString(),
                activa: true,
                autor: window.firebaseAdapter.currentUser?.nombre || 'Admin'
            });
            return { ok: true, json: async () => ({ success: true, id: docRef.id }) };
        }

        if (endpoint.startsWith('admin/noticias/') && method === 'DELETE') {
            const noticiaId = parts[2];
            await deleteDoc(doc(db, 'noticias', noticiaId));
            return { ok: true, json: async () => ({ success: true }) };
        }

        // ADMIN - Usuarios
        if (endpoint === 'admin/usuarios' && method === 'POST') {
            const docRef = await addDoc(collection(db, 'usuarios'), {
                ...body,
                fechaRegistro: new Date().toISOString(),
                activo: true
            });
            return { ok: true, json: async () => ({ success: true, id: docRef.id }) };
        }

        if (endpoint === 'admin/usuarios/todos' && method === 'GET') {
            const usuariosSnap = await getDocs(collection(db, 'usuarios'));
            const usuarios = usuariosSnap.docs.map(doc => {
                const data = doc.data();
                return {
                    id: data.uid || doc.id,  // Usar UID de Auth si existe, sino el ID del documento
                    docId: doc.id,
                    ...data
                };
            });
            return { ok: true, json: async () => ({ success: true, usuarios }) };
        }

        // ADMIN - Reservas
        if (endpoint === 'admin/reservas/reporte' && method === 'GET') {
            const reservasSnap = await getDocs(collection(db, 'reservas'));
            const reservas = reservasSnap.docs.map(doc => ({ id: doc.id, ...doc.data() }));
            return { ok: true, json: async () => reservas };
        }

        if (endpoint.startsWith('admin/reservas/') && method === 'DELETE') {
            const reservaId = parts[2];
            await deleteDoc(doc(db, 'reservas', reservaId));
            return { ok: true, json: async () => ({ success: true }) };
        }

        if (endpoint.startsWith('admin/reservas/') && method === 'PUT') {
            const reservaId = parts[2];
            await updateDoc(doc(db, 'reservas', reservaId), body);
            return { ok: true, json: async () => ({ success: true }) };
        }

        // ADMIN - Pagos
        if (endpoint === 'admin/pagos/reporte' && method === 'GET') {
            const pagosSnap = await getDocs(collection(db, 'pagos'));
            const pagos = pagosSnap.docs.map(doc => ({ id: doc.id, ...doc.data() }));
            return { ok: true, json: async () => pagos };
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
            return { ok: true, json: async () => ({ success: true, cantidad: pagos.length }) };
        }

        if (endpoint === 'admin/estadisticas/pagos' && method === 'GET') {
            const pagosSnap = await getDocs(collection(db, 'pagos'));
            const pagos = pagosSnap.docs.map(doc => doc.data());

            const totalRecaudado = pagos.reduce((sum, p) => sum + (p.monto || 0), 0);
            const pagosPendientes = pagos.filter(p => p.estado === 'pendiente').length;
            const pagosPagados = pagos.filter(p => p.estado === 'pagado').length;

            return { ok: true, json: async () => ({
                totalRecaudado,
                pagosPendientes,
                pagosPagados,
                totalPagos: pagos.length
            })};
        }

        if (endpoint === 'admin/estadisticas/reservas' && method === 'GET') {
            const reservasSnap = await getDocs(collection(db, 'reservas'));
            const reservas = reservasSnap.docs.map(doc => doc.data());

            return { ok: true, json: async () => ({
                totalReservas: reservas.length,
                reservasActivas: reservas.filter(r => r.estado === 'activa').length,
                reservasCanceladas: reservas.filter(r => r.estado === 'cancelada').length
            })};
        }

        // ADMIN - PQRS
        if (endpoint === 'admin/pqrs/todas' && method === 'GET') {
            const pqrsSnap = await getDocs(collection(db, 'pqrs'));
            const pqrs = pqrsSnap.docs.map(doc => ({ id: doc.id, ...doc.data() }));
            return { ok: true, json: async () => pqrs };
        }

        if (endpoint.startsWith('admin/pqrs/') && method === 'PUT') {
            const pqrsId = parts[2];
            await updateDoc(doc(db, 'pqrs', pqrsId), body);
            return { ok: true, json: async () => ({ success: true }) };
        }

        // ADMIN - Encuestas
        if (endpoint === 'admin/encuestas' && method === 'POST') {
            const docRef = await addDoc(collection(db, 'encuestas'), {
                ...body,
                fechaCreacion: new Date().toISOString(),
                activa: true,
                votos: []
            });
            return { ok: true, json: async () => ({ success: true, id: docRef.id }) };
        }

        if (endpoint.startsWith('admin/encuestas/') && endpoint.endsWith('/resultados') && method === 'GET') {
            const encuestaId = parts[2];
            const encuestaDoc = await getDoc(doc(db, 'encuestas', encuestaId));
            if (encuestaDoc.exists()) {
                return { ok: true, json: async () => ({ success: true, encuesta: encuestaDoc.data() }) };
            }
            return { ok: true, json: async () => ({ success: false, mensaje: 'Encuesta no encontrada' }) };
        }

        // ADMIN - Sorteo Parqueaderos
        if (endpoint === 'admin/sorteo-parqueaderos' && method === 'POST') {
            const { participantes } = body;

            if (!participantes || !Array.isArray(participantes) || participantes.length === 0) {
                return { ok: false, json: async () => ({ success: false, mensaje: 'No hay participantes para el sorteo' }) };
            }

            const resultados = participantes.map((p, i) => ({
                participante: p.nombre || p.participante || p.usuario || 'Sin nombre',
                apartamento: p.apartamento || 'N/A',
                parqueadero: `P-${String(i + 1).padStart(3, '0')}`,
                nivel: i < 33 ? 'Sótano 1' : i < 66 ? 'Sótano 2' : 'Sótano 3'
            }));

            const docRef = await addDoc(collection(db, 'sorteoParqueaderos'), {
                fecha: new Date().toISOString(),
                resultados,
                realizado: true,
                realizadoPor: window.firebaseAdapter.currentUser?.nombre || 'Admin',
                totalParticipantes: participantes.length
            });

            return { ok: true, json: async () => ({ success: true, resultados, id: docRef.id }) };
        }

        if (endpoint === 'admin/sorteo-parqueaderos/ultimo' && method === 'GET') {
            const sorteosSnap = await getDocs(
                query(collection(db, 'sorteoParqueaderos'), orderBy('fecha', 'desc'), limit(1))
            );

            if (!sorteosSnap.empty) {
                const sorteoData = sorteosSnap.docs[0].data();
                return { ok: true, json: async () => ({
                    success: true,
                    fecha: sorteoData.fecha,
                    realizadoPor: sorteoData.realizadoPor || 'Admin',
                    resultados: sorteoData.resultados || []
                })};
            }
            return { ok: true, json: async () => ({
                success: false,
                mensaje: 'No hay sorteos realizados aún',
                resultados: []
            }) };
        }

        // ADMIN - Residentes
        if (endpoint === 'admin/residentes' && method === 'GET') {
            const residentesSnap = await getDocs(collection(db, 'residentes'));
            const residentes = residentesSnap.docs.map(doc => ({ id: doc.id, ...doc.data() }));
            return { ok: true, json: async () => ({ success: true, residentes }) };
        }

        if (endpoint === 'admin/residentes/activos' && method === 'GET') {
            const residentesSnap = await getDocs(
                query(collection(db, 'residentes'), where('activo', '==', true))
            );
            const residentes = residentesSnap.docs.map(doc => ({ id: doc.id, ...doc.data() }));
            return { ok: true, json: async () => residentes };
        }

        if (endpoint === 'admin/residentes' && method === 'POST') {
            const docRef = await addDoc(collection(db, 'residentes'), {
                ...body,
                fechaRegistro: new Date().toISOString(),
                activo: true
            });
            return { ok: true, json: async () => ({ success: true, id: docRef.id }) };
        }

        if (endpoint.startsWith('admin/residentes/') && method === 'DELETE') {
            const residenteId = parts[2];
            await deleteDoc(doc(db, 'residentes', residenteId));
            return { ok: true, json: async () => ({ success: true }) };
        }

        // ADMIN - Vehículos
        if (endpoint === 'admin/vehiculos/reporte' && method === 'GET') {
            const vehiculosSnap = await getDocs(collection(db, 'vehiculosVisitantes'));
            const vehiculos = vehiculosSnap.docs.map(doc => ({ id: doc.id, ...doc.data() }));
            return { ok: true, json: async () => vehiculos };
        }

        // ADMIN - Cámaras
        if (endpoint === 'admin/camaras' && method === 'GET') {
            const camarasSnap = await getDocs(collection(db, 'camaras'));
            const camaras = camarasSnap.docs.map(doc => ({ id: doc.id, ...doc.data() }));
            return { ok: true, json: async () => camaras };
        }

        if (endpoint === 'admin/camaras' && method === 'POST') {
            const docRef = await addDoc(collection(db, 'camaras'), body);
            return { ok: true, json: async () => ({ success: true, id: docRef.id }) };
        }

        if (endpoint.startsWith('admin/camaras/') && method === 'PUT') {
            const camaraId = parts[2];
            await updateDoc(doc(db, 'camaras', camaraId), body);
            return { ok: true, json: async () => ({ success: true }) };
        }

        // ADMIN - Documentos
        if (endpoint === 'admin/documentos' && method === 'POST') {
            const docRef = await addDoc(collection(db, 'documentos'), {
                ...body,
                fechaSubida: new Date().toISOString()
            });
            return { ok: true, json: async () => ({ success: true, id: docRef.id }) };
        }

        if (endpoint.startsWith('admin/documentos/') && method === 'DELETE') {
            const documentoId = parts[2];
            await deleteDoc(doc(db, 'documentos', documentoId));
            return { ok: true, json: async () => ({ success: true }) };
        }

        if (endpoint.startsWith('admin/documentos/') && method === 'PUT') {
            const documentoId = parts[2];
            await updateDoc(doc(db, 'documentos', documentoId), body);
            return { ok: true, json: async () => ({ success: true }) };
        }

        // ADMIN - Solicitudes
        if (endpoint === 'admin/solicitudes' && method === 'GET') {
            const solicitudesSnap = await getDocs(collection(db, 'solicitudes'));
            const solicitudes = solicitudesSnap.docs.map(doc => ({ id: doc.id, ...doc.data() }));
            return { ok: true, json: async () => solicitudes };
        }

        if (endpoint.startsWith('admin/solicitudes/') && method === 'PUT') {
            const solicitudId = parts[2];
            await updateDoc(doc(db, 'solicitudes', solicitudId), body);
            return { ok: true, json: async () => ({ success: true }) };
        }

        // ============= RUTAS DE VIGILANTE =============

        // VIGILANTE - Solicitudes
        if (endpoint === 'vigilante/solicitudes' && method === 'GET') {
            const solicitudesSnap = await getDocs(collection(db, 'solicitudes'));
            const solicitudes = solicitudesSnap.docs.map(doc => ({ id: doc.id, ...doc.data() }));
            return { ok: true, json: async () => solicitudes };
        }

        if (endpoint.startsWith('vigilante/solicitudes/') && method === 'PUT') {
            const solicitudId = parts[2];
            await updateDoc(doc(db, 'solicitudes', solicitudId), {
                ...body,
                procesadoPor: window.firebaseAdapter.currentUser?.nombre,
                fechaProceso: new Date().toISOString()
            });
            return { ok: true, json: async () => ({ success: true }) };
        }

        // VIGILANTE - Vehículos
        if (endpoint === 'vehiculos-visitantes/ingreso' && method === 'POST') {
            const docRef = await addDoc(collection(db, 'vehiculosVisitantes'), {
                ...body,
                fechaIngreso: new Date().toISOString(),
                activo: true,
                registradoPor: window.firebaseAdapter.currentUser?.nombre || 'Vigilante'
            });
            return { ok: true, json: async () => ({ success: true, vehiculo: { id: docRef.id, ...body } }) };
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
                return { ok: true, json: async () => ({ success: true, vehiculo: vehiculoDoc.data() }) };
            }
            return { ok: true, json: async () => ({ success: false, mensaje: 'Vehículo no encontrado' }) };
        }

        if (endpoint === 'vehiculos-visitantes/salida-calculada' && method === 'POST') {
            const vehiculoId = body.vehiculoId || body.id;

            // Obtener el vehículo
            const vehiculoDoc = await getDoc(doc(db, 'vehiculosVisitantes', vehiculoId));

            if (!vehiculoDoc.exists()) {
                return { ok: false, json: async () => ({ success: false, error: 'Vehículo no encontrado' }) };
            }

            const vehiculo = vehiculoDoc.data();
            // Intentar obtener la hora de ingreso de diferentes campos posibles
            const horaIngreso = new Date(vehiculo.horaIngreso || vehiculo.fechaIngreso || vehiculo.timestamp);
            const horaSalida = new Date();

            // Calcular tiempo transcurrido
            const milisegundos = horaSalida - horaIngreso;
            const minutos = Math.floor(milisegundos / (1000 * 60));
            const horas = Math.ceil(milisegundos / (1000 * 60 * 60)); // Redondear hacia arriba para cobro

            // Calcular tiempo exacto para mostrar
            const horasExactas = Math.floor(milisegundos / (1000 * 60 * 60));
            const minutosRestantes = minutos % 60;

            // Calcular costo según la lógica:
            // - Primeras 2 horas: GRATIS
            // - Hora 3 a 9: $3,000 por hora
            // - Más de 9 horas: $16,000 por día
            // - Más de 24 horas: Días completos + horas adicionales (con 2h gratis por día)
            let costo = 0;
            let detalleCalculo = '';
            const tiempoExacto = `${horasExactas}h ${minutosRestantes}min`;

            if (horas <= 2) {
                // Primeras 2 horas gratis
                costo = 0;
                detalleCalculo = `Tiempo: ${tiempoExacto} - Cortesía (primeras 2 horas gratis)`;
            } else if (horas <= 9) {
                // De 3 a 9 horas: cobrar por hora (descontando las 2 primeras)
                const horasCobradas = horas - 2;
                costo = horasCobradas * 3000;
                detalleCalculo = `Tiempo: ${tiempoExacto} (${horas}h para cobro) - 2h gratis + ${horasCobradas}h × $3,000 = $${costo.toLocaleString('es-CO')}`;
            } else if (horas <= 24) {
                // De 10 a 24 horas: tarifa fija de 1 día
                costo = 16000;
                detalleCalculo = `Tiempo: ${tiempoExacto} - Tarifa fija (1 día completo) = $16,000`;
            } else {
                // Más de 24 horas: calcular días completos y horas adicionales
                const diasCompletos = Math.floor(horas / 24);
                const horasRestantes = horas % 24;

                // Costo de días completos
                let costoDias = diasCompletos * 16000;
                let costoHoras = 0;
                let detalleHoras = '';

                // Calcular costo de horas restantes
                if (horasRestantes <= 2) {
                    // 2 horas gratis en el nuevo día
                    costoHoras = 0;
                    detalleHoras = `${horasRestantes}h gratis`;
                } else if (horasRestantes <= 9) {
                    // Cobrar horas adicionales (descontando 2h gratis)
                    const horasAdicionales = horasRestantes - 2;
                    costoHoras = horasAdicionales * 3000;
                    detalleHoras = `${horasRestantes}h (${horasAdicionales}h cobradas × $3,000)`;
                } else {
                    // Más de 9 horas adicionales = otro día completo
                    costoHoras = 16000;
                    detalleHoras = `${horasRestantes}h (día completo)`;
                }

                costo = costoDias + costoHoras;
                detalleCalculo = `Tiempo: ${tiempoExacto} - ${diasCompletos} día(s) × $16,000 + ${detalleHoras} = $${costo.toLocaleString('es-CO')}`;
            }

            // Actualizar el vehículo con la salida y marcarlo como pagado
            await updateDoc(doc(db, 'vehiculosVisitantes', vehiculoId), {
                horaSalida: horaSalida.toISOString(),
                horasEstadia: horas,
                tiempoExacto: tiempoExacto,
                costoParkeo: costo,
                detalleCalculo: detalleCalculo,
                procesadoPor: window.firebaseAdapter.currentUser?.nombre || 'Vigilante',
                activo: false,
                pagado: true,
                fechaPago: horaSalida.toISOString()
            });

            // Crear recibo - solo incluir campos que existen
            const reciboData = {
                vehiculoId: vehiculoId,
                placa: vehiculo.placa || '',
                nombreConductor: vehiculo.nombreConductor || vehiculo.conductor || 'No especificado',
                apartamento: vehiculo.apartamento || vehiculo.destino || 'No especificado',
                horaIngreso: vehiculo.horaIngreso || vehiculo.fechaIngreso,
                horaSalida: horaSalida.toISOString(),
                horasEstadia: horas,
                tiempoExacto: tiempoExacto,
                costo: costo,
                detalleCalculo: detalleCalculo,
                fechaEmision: horaSalida.toISOString(),
                emitidoPor: window.firebaseAdapter.currentUser?.nombre || 'Vigilante',
                pagado: true,
                fechaPago: horaSalida.toISOString(),
                metodoPago: 'Efectivo',
                confirmado: true
            };

            const reciboRef = await addDoc(collection(db, 'recibosParqueadero'), reciboData);

            return { ok: true, json: async () => ({
                success: true,
                vehiculo: {
                    ...vehiculo,
                    horaSalida: horaSalida.toISOString(),
                    horasEstadia: horas,
                    costoParkeo: costo,
                    detalleCalculo: detalleCalculo
                },
                recibo: {
                    id: reciboRef.id,
                    ...reciboData
                },
                resumen: {
                    totalCobrado: costo,
                    detalleCobro: detalleCalculo,
                    horasEstadia: horas
                }
            }) };
        }

        // VIGILANTE - Permisos
        if (endpoint === 'permisos' && method === 'GET') {
            const permisosSnap = await getDocs(collection(db, 'permisos'));
            const permisos = permisosSnap.docs.map(doc => ({ id: doc.id, ...doc.data() }));
            return { ok: true, json: async () => permisos };
        }

        if (endpoint === 'permisos' && method === 'POST') {
            const docRef = await addDoc(collection(db, 'permisos'), {
                ...body,
                fechaSolicitud: new Date().toISOString(),
                estado: 'pendiente'
            });
            return { ok: true, json: async () => ({ success: true, id: docRef.id }) };
        }

        if (endpoint.startsWith('permisos/') && endpoint.endsWith('/ingresar') && method === 'PUT') {
            const permisoId = parts[1];
            await updateDoc(doc(db, 'permisos', permisoId), {
                estado: 'ingresado',
                fechaIngreso: new Date().toISOString(),
                procesadoPor: window.firebaseAdapter.currentUser?.nombre
            });
            return { ok: true, json: async () => ({ success: true }) };
        }

        if (endpoint.startsWith('permisos/') && endpoint.endsWith('/salir') && method === 'PUT') {
            const permisoId = parts[1];
            await updateDoc(doc(db, 'permisos', permisoId), {
                estado: 'salida',
                fechaSalida: new Date().toISOString()
            });
            return { ok: true, json: async () => ({ success: true }) };
        }

        // Confirmar ingreso mediante QR
        if (endpoint.startsWith('permisos/') && endpoint.endsWith('/confirmar-ingreso') && method === 'PUT') {
            const permisoId = parts[1];

            // Verificar que el permiso existe y está vigente
            const permisoDoc = await getDoc(doc(db, 'permisos', permisoId));

            if (!permisoDoc.exists()) {
                return { ok: false, json: async () => ({ success: false, mensaje: 'Permiso no encontrado' }) };
            }

            const permisoData = permisoDoc.data();

            if (!permisoData.vigente) {
                return { ok: false, json: async () => ({ success: false, mensaje: 'Este permiso ya no está vigente' }) };
            }

            // Actualizar el permiso con confirmación de ingreso
            await updateDoc(doc(db, 'permisos', permisoId), {
                estado: 'ingresado',
                vigente: false,
                fechaIngresoReal: new Date().toISOString(),
                escanedoPor: body.escanedoPor || window.firebaseAdapter.currentUser?.nombre,
                fechaEscaneo: body.fechaEscaneo || new Date().toISOString()
            });

            return { ok: true, json: async () => ({ success: true, mensaje: 'Ingreso confirmado exitosamente' }) };
        }

        // VIGILANTE/ADMIN - Paquetes (todos)
        // RESIDENTE - Paquetes (solo los suyos)
        if (endpoint === 'paquetes' && method === 'GET') {
            const userRole = window.firebaseAdapter.currentUser?.rol;
            const userId = window.firebaseAdapter.currentUser?.id;

            console.log('[DEBUG] GET Paquetes - userRole:', userRole, 'userId:', userId);

            let paquetesSnap;

            // Si es residente, filtrar solo sus paquetes
            if (userRole === 'residente') {
                paquetesSnap = await getDocs(
                    query(collection(db, 'paquetes'), where('usuarioId', '==', userId))
                );
                console.log('[DEBUG] Paquetes encontrados para residente:', paquetesSnap.docs.length);
            } else {
                // Admin y vigilante ven todos
                paquetesSnap = await getDocs(collection(db, 'paquetes'));
                console.log('[DEBUG] Total paquetes (admin/vigilante):', paquetesSnap.docs.length);
            }

            const paquetes = paquetesSnap.docs.map(doc => {
                const data = { id: doc.id, ...doc.data() };
                if (userRole === 'residente') {
                    console.log('[DEBUG] Paquete:', {
                        id: data.id,
                        usuarioId: data.usuarioId,
                        estado: data.estado,
                        match: data.usuarioId === userId,
                        currentUserId: userId
                    });
                }
                return data;
            });

            // Si es residente y no encuentra paquetes, mostrar todos para debugging
            if (userRole === 'residente' && paquetes.length === 0) {
                console.log('[DEBUG] No se encontraron paquetes. Mostrando TODOS los paquetes para debug:');
                const todosSnap = await getDocs(collection(db, 'paquetes'));
                console.log(`[DEBUG] Total de paquetes en DB: ${todosSnap.docs.length}`);
                todosSnap.docs.forEach(doc => {
                    const data = doc.data();
                    console.log('[DEBUG] Paquete en DB:', {
                        id: doc.id,
                        usuarioId: data.usuarioId,
                        nombreResidente: data.nombreResidente,
                        apartamento: data.apartamento,
                        currentUserId: userId,
                        match: data.usuarioId === userId,
                        type_usuarioId: typeof data.usuarioId,
                        type_currentUserId: typeof userId
                    });
                });
            }

            return { ok: true, json: async () => ({ success: true, paquetes }) };
        }

        if (endpoint === 'paquetes' && method === 'POST') {
            const paqueteData = {
                ...body,
                // Si viene residenteId, también guardarlo como usuarioId para compatibilidad
                usuarioId: body.residenteId || body.usuarioId,
                fechaLlegada: new Date().toISOString(),
                fechaRecepcion: new Date().toISOString(),
                estado: 'Pendiente',  // Mayúscula para coincidir con frontend
                registradoPor: window.firebaseAdapter.currentUser?.nombre || 'Vigilante',
                recibidoPor: window.firebaseAdapter.currentUser?.nombre || 'Vigilante'
            };

            console.log('[DEBUG] POST Paquete - Guardando:', {
                usuarioId: paqueteData.usuarioId,
                residenteId: paqueteData.residenteId,
                apartamento: paqueteData.apartamento,
                nombreResidente: paqueteData.nombreResidente
            });

            const docRef = await addDoc(collection(db, 'paquetes'), paqueteData);
            return { ok: true, json: async () => ({ success: true, id: docRef.id }) };
        }

        // ENDPOINT DEBUG: Ver todos los paquetes y usuarios
        if (endpoint === 'admin/debug-paquetes' && method === 'GET') {
            const paquetesSnap = await getDocs(collection(db, 'paquetes'));
            const usuariosSnap = await getDocs(collection(db, 'usuarios'));

            const paquetes = paquetesSnap.docs.map(doc => ({
                id: doc.id,
                ...doc.data()
            }));

            const usuarios = usuariosSnap.docs.map(doc => {
                const data = doc.data();
                return {
                    docId: doc.id,
                    uid: data.uid,
                    nombre: data.nombre,
                    apartamento: data.apartamento,
                    rol: data.rol
                };
            });

            return {
                ok: true,
                json: async () => ({ paquetes, usuarios })
            };
        }

        // ENDPOINT TEMPORAL: Corregir usuarioId de paquetes antiguos
        if (endpoint === 'admin/corregir-paquetes' && method === 'POST') {
            console.log('[DEBUG] Iniciando corrección de paquetes...');

            const paquetesSnap = await getDocs(collection(db, 'paquetes'));
            const usuariosSnap = await getDocs(collection(db, 'usuarios'));

            // Crear mapas de búsqueda: nombre -> UID y apartamento -> UID
            const nombreToUid = {};
            const apartamentoToUid = {};

            usuariosSnap.docs.forEach(doc => {
                const data = doc.data();
                const uid = data.uid || doc.id;

                if (data.nombre) {
                    nombreToUid[data.nombre.toLowerCase().trim()] = uid;
                }
                if (data.apartamento) {
                    apartamentoToUid[data.apartamento] = uid;
                }
            });

            console.log('[DEBUG] Mapa de nombres:', nombreToUid);
            console.log('[DEBUG] Mapa de apartamentos:', apartamentoToUid);

            let corregidos = 0;
            const promesas = [];
            const detalles = [];

            paquetesSnap.docs.forEach(doc => {
                const data = doc.data();
                let uidCorrecto = null;

                // Intento 1: Buscar por nombre del residente (más preciso)
                if (data.nombreResidente) {
                    const nombreBusqueda = data.nombreResidente.toLowerCase().trim();
                    uidCorrecto = nombreToUid[nombreBusqueda];

                    if (uidCorrecto) {
                        console.log(`[DEBUG] Match por NOMBRE: "${data.nombreResidente}" -> UID: ${uidCorrecto}`);
                    }
                }

                // Intento 2: Si no encontró por nombre, buscar por apartamento
                if (!uidCorrecto && data.apartamento) {
                    // Extraer número de apartamento (ej: "Torre 2 - Apto 401A" -> "401A")
                    const match = data.apartamento.match(/Apto\s+(\w+)/i);
                    const numApto = match ? match[1] : null;

                    if (numApto && apartamentoToUid[numApto]) {
                        uidCorrecto = apartamentoToUid[numApto];
                        console.log(`[DEBUG] Match por APARTAMENTO: "${data.apartamento}" -> UID: ${uidCorrecto}`);
                    }
                }

                // Si encontró un UID correcto, actualizar el paquete
                if (uidCorrecto && data.usuarioId !== uidCorrecto) {
                    console.log(`[DEBUG] Corrigiendo paquete ${doc.id}: ${data.usuarioId} -> ${uidCorrecto}`);

                    promesas.push(
                        updateDoc(doc.ref, { usuarioId: uidCorrecto })
                    );

                    detalles.push({
                        id: doc.id,
                        nombreResidente: data.nombreResidente,
                        apartamento: data.apartamento,
                        antiguoId: data.usuarioId,
                        nuevoId: uidCorrecto
                    });

                    corregidos++;
                }
            });

            await Promise.all(promesas);

            console.log(`[DEBUG] Corrección completada. ${corregidos} paquetes corregidos.`);
            console.table(detalles);

            return {
                ok: true,
                json: async () => ({
                    success: true,
                    corregidos,
                    detalles,
                    mensaje: `Se corrigieron ${corregidos} paquetes`
                })
            };
        }

        // ============= RUTAS DE PERMISOS =============

        // GET /api/permisos - Vigilante/Admin ve todos los permisos
        if (endpoint === 'permisos' && method === 'GET') {
            const permisosSnap = await getDocs(collection(db, 'permisos'));
            const permisos = permisosSnap.docs.map(doc => ({
                id: doc.id,
                ...doc.data()
            }));
            return { ok: true, json: async () => ({ success: true, permisos }) };
        }

        // GET /api/residente/mis-permisos - Residente ve solo sus permisos
        if (endpoint === 'residente/mis-permisos' && method === 'GET') {
            console.log('[DEBUG] Endpoint mis-permisos detectado');
            const userId = window.firebaseAdapter.currentUser?.id;
            console.log('[DEBUG] UserId:', userId);
            const permisosSnap = await getDocs(
                query(collection(db, 'permisos'), where('usuarioId', '==', userId))
            );
            const permisos = permisosSnap.docs.map(doc => ({
                id: doc.id,
                ...doc.data()
            }));
            console.log('[DEBUG] Permisos encontrados:', permisos.length);
            console.log('[DEBUG] Primer permiso:', permisos[0]);
            return { ok: true, json: async () => ({ success: true, permisos }) };
        }

        // POST /api/residente/solicitar-permiso - Residente crea nuevo permiso
        if (endpoint === 'residente/solicitar-permiso' && method === 'POST') {
            const currentUser = window.firebaseAdapter.currentUser;
            const permisoData = {
                ...body,
                usuarioId: currentUser.id,
                residenteNombre: currentUser.nombre,
                apartamento: currentUser.apartamento,
                estado: 'Vigente',  // Cambiado de 'Pendiente' a 'Vigente'
                fechaSolicitud: new Date().toISOString(),
                vigente: true
            };

            const docRef = await addDoc(collection(db, 'permisos'), permisoData);
            return { ok: true, json: async () => ({ success: true, id: docRef.id, permiso: permisoData }) };
        }

        // PUT /api/permisos/:id/aprobar - Vigilante aprueba permiso
        if (endpoint.match(/^permisos\/[^/]+\/aprobar$/) && method === 'PUT') {
            const permisoId = parts[1];
            await updateDoc(doc(db, 'permisos', permisoId), {
                estado: 'Aprobado',
                fechaAprobacion: new Date().toISOString(),
                aprobadoPor: window.firebaseAdapter.currentUser?.nombre || 'Vigilante'
            });
            return { ok: true, json: async () => ({ success: true }) };
        }

        // PUT /api/permisos/:id/rechazar - Vigilante rechaza permiso
        if (endpoint.match(/^permisos\/[^/]+\/rechazar$/) && method === 'PUT') {
            const permisoId = parts[1];
            await updateDoc(doc(db, 'permisos', permisoId), {
                estado: 'Rechazado',
                fechaRechazo: new Date().toISOString(),
                rechazadoPor: window.firebaseAdapter.currentUser?.nombre || 'Vigilante',
                motivoRechazo: body.motivo || 'No especificado'
            });
            return { ok: true, json: async () => ({ success: true }) };
        }

        // PUT /api/permisos/:id/usar - Vigilante marca permiso como usado
        if (endpoint.match(/^permisos\/[^/]+\/usar$/) && method === 'PUT') {
            const permisoId = parts[1];
            await updateDoc(doc(db, 'permisos', permisoId), {
                estado: 'Usado',
                fechaUso: new Date().toISOString(),
                usadoPor: window.firebaseAdapter.currentUser?.nombre || 'Vigilante',
                vigente: false
            });
            return { ok: true, json: async () => ({ success: true }) };
        }

        // DELETE /api/residente/mis-permisos/:id - Residente cancela su permiso
        if (endpoint.match(/^residente\/mis-permisos\/[^/]+$/) && method === 'DELETE') {
            const permisoId = parts[2];
            await deleteDoc(doc(db, 'permisos', permisoId));
            return { ok: true, json: async () => ({ success: true }) };
        }

        // Marcar paquete como entregado mediante QR
        if (endpoint.match(/^paquetes\/[^/]+\/entregar-qr$/) && method === 'PUT') {
            const paqueteId = parts[1];

            console.log('[DEBUG] Entregar paquete por QR:', paqueteId);

            try {
                const paqueteRef = doc(db, 'paquetes', paqueteId);
                const paqueteDoc = await getDoc(paqueteRef);

                if (!paqueteDoc.exists()) {
                    return {
                        ok: false,
                        json: async () => ({ success: false, error: 'Paquete no encontrado' })
                    };
                }

                const paqueteData = paqueteDoc.data();

                // Verificar si ya fue entregado
                if (paqueteData.estado === 'Entregado') {
                    return {
                        ok: false,
                        json: async () => ({ success: false, error: 'Este paquete ya fue entregado anteriormente' })
                    };
                }

                // Actualizar el paquete
                await updateDoc(paqueteRef, {
                    estado: 'Entregado',
                    fechaEntrega: new Date().toISOString(),
                    entregadoPor: window.firebaseAdapter.currentUser?.nombre || 'Vigilante',
                    entregadoA: paqueteData.nombreResidente || 'Residente'
                });

                console.log('[DEBUG] Paquete marcado como entregado:', paqueteId);

                return {
                    ok: true,
                    json: async () => ({
                        success: true,
                        paquete: {
                            id: paqueteId,
                            ...paqueteData
                        }
                    })
                };

            } catch (error) {
                console.error('[ERROR] Error al entregar paquete:', error);
                return {
                    ok: false,
                    json: async () => ({ success: false, error: error.message })
                };
            }
        }

        // ============= RUTAS DE ALCALDÍA =============

        // ALCALDÍA - Incidentes
        if (endpoint === 'incidentes' && method === 'GET') {
            const incidentesSnap = await getDocs(collection(db, 'incidentes'));
            const incidentes = incidentesSnap.docs.map(doc => ({ id: doc.id, ...doc.data() }));
            return { ok: true, json: async () => incidentes };
        }

        if (endpoint === 'incidentes' && method === 'POST') {
            const docRef = await addDoc(collection(db, 'incidentes'), {
                ...body,
                fechaReporte: new Date().toISOString(),
                estado: 'Reportado',
                reportadoPor: window.firebaseAdapter.currentUser?.nombre || window.firebaseAdapter.currentUser?.email
            });
            return { ok: true, json: async () => ({ success: true, id: docRef.id }) };
        }

        if (endpoint.startsWith('incidentes/') && endpoint.endsWith('/responder') && (method === 'POST' || method === 'PUT')) {
            const incidenteId = parts[1];
            await updateDoc(doc(db, 'incidentes', incidenteId), {
                respuestaAlcaldia: body.respuesta,
                estado: 'En atención',
                fechaRespuesta: new Date().toISOString(),
                respondidoPor: window.firebaseAdapter.currentUser?.nombre
            });
            return { ok: true, json: async () => ({ success: true }) };
        }

        if (endpoint.startsWith('incidentes/') && endpoint.endsWith('/estado') && method === 'PUT') {
            const incidenteId = parts[1];
            await updateDoc(doc(db, 'incidentes', incidenteId), {
                estado: body.estado,
                fechaActualizacion: new Date().toISOString()
            });
            return { ok: true, json: async () => ({ success: true }) };
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
                return { ok: true, json: async () => ({ success: true }) };
            }
            return { ok: true, json: async () => ({ success: false, mensaje: 'Encuesta no encontrada' }) };
        }

        // Documentos - GET
        if (endpoint === 'documentos' && method === 'GET') {
            const documentosSnap = await getDocs(collection(db, 'documentos'));
            const documentos = documentosSnap.docs.map(doc => ({ id: doc.id, ...doc.data() }));
            return { ok: true, json: async () => documentos };
        }

        // Cámaras - GET (para residentes)
        if (endpoint === 'camaras' && method === 'GET') {
            const camarasSnap = await getDocs(collection(db, 'camaras'));
            const camaras = camarasSnap.docs.map(doc => ({ id: doc.id, ...doc.data() }));
            return { ok: true, json: async () => camaras };
        }

        // ============= RUTAS DE RESIDENTE =============

        // RESIDENTE - Mis Reservas
        if (endpoint === 'residente/mis-reservas' && method === 'GET') {
            const userId = window.firebaseAdapter.currentUser?.id;
            const reservasSnap = await getDocs(query(collection(db, 'reservas'), where('usuarioId', '==', userId)));
            const misReservas = reservasSnap.docs.map(doc => ({ id: doc.id, ...doc.data() }));
            return { ok: true, json: async () => ({ success: true, misReservas }) };
        }

        // RESIDENTE - Mis Pagos
        if (endpoint === 'residente/mis-pagos' && method === 'GET') {
            const userId = window.firebaseAdapter.currentUser?.id;
            const apartamento = window.firebaseAdapter.currentUser?.apartamento;
            const pagosSnap = await getDocs(query(collection(db, 'pagos'), where('apartamento', '==', apartamento)));
            const pagos = pagosSnap.docs.map(doc => ({ id: doc.id, ...doc.data() }));
            return { ok: true, json: async () => ({ success: true, pagos }) };
        }

        // RESIDENTE - Mi Parqueadero
        if (endpoint === 'residente/mi-parqueadero' && method === 'GET') {
            const nombreUsuario = window.firebaseAdapter.currentUser?.nombre;

            // Buscar en el último sorteo
            const sorteosSnap = await getDocs(
                query(collection(db, 'sorteoParqueaderos'), orderBy('fecha', 'desc'), limit(1))
            );

            if (!sorteosSnap.empty) {
                const sorteoData = sorteosSnap.docs[0].data();
                const resultado = sorteoData.resultados?.find(r => r.participante === nombreUsuario);

                if (resultado) {
                    return { ok: true, json: async () => ({
                        success: true,
                        asignado: true,
                        parqueadero: resultado.parqueadero,
                        nivel: resultado.nivel,
                        fechaSorteo: sorteoData.fecha
                    })};
                }
            }

            return { ok: true, json: async () => ({
                success: false,
                asignado: false,
                mensaje: 'No tienes parqueadero asignado aún'
            })};
        }

        // RESIDENTE - Mis PQRS
        if (endpoint === 'residente/mis-pqrs' && method === 'GET') {
            const userId = window.firebaseAdapter.currentUser?.id;
            const pqrsSnap = await getDocs(query(collection(db, 'pqrs'), where('usuarioId', '==', userId)));
            const pqrs = pqrsSnap.docs.map(doc => ({ id: doc.id, ...doc.data() }));
            return { ok: true, json: async () => ({ success: true, pqrs }) };
        }

        // RESIDENTE - Publicar Arriendo
        if (endpoint === 'residente/publicar-arriendo' && method === 'POST') {
            const docRef = await addDoc(collection(db, 'apartamentosArriendo'), {
                ...body,
                usuarioId: window.firebaseAdapter.currentUser?.id,
                propietario: window.firebaseAdapter.currentUser?.nombre,
                disponible: true,
                fechaPublicacion: new Date().toISOString()
            });
            return { ok: true, json: async () => ({ success: true, id: docRef.id }) };
        }

        // Si no hay match, devolver error
        console.warn('Endpoint no implementado:', endpoint, method);
        return {
            ok: false,
            json: async () => ({
                success: false,
                mensaje: `Endpoint ${endpoint} (${method}) no implementado en Firebase adapter`
            })
        };

    } catch (error) {
        console.error('Error en Firebase adapter:', error);
        return {
            ok: false,
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
            window.firebaseAdapter.currentUser = {
                uid: user.uid,  // UID de Firebase Auth
                ...userDoc.data()  // Datos de Firestore
            };
            console.log('✅ Usuario autenticado:', window.firebaseAdapter.currentUser);
        }
    } else {
        window.firebaseAdapter.currentUser = null;
    }
});

console.log('✅ Firebase Adapter cargado correctamente');
