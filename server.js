// server.js
const express = require('express');
const path = require('path');
const fs = require('fs');

const app = express();
const PORT = 8081;

// Middleware
app.use(express.static('public'));
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Datos en memoria (en producción usarías una base de datos)
let data = {
  usuarios: [
    {
      id: 1,
      email: 'car-cbs@hotmail.com',
      password: 'password1',
      nombre: 'Carlos Andrés Santos Hernández',
      apartamento: 'Torre 2 - Apto 401A',
      activo: true,
      rol: 'residente'
    },
    {
      id: 7,
      email: 'shayoja@hotmail.com',
      password: 'password2',
      nombre: 'Administrador del Conjunto',
      apartamento: 'Oficina Administración',
      activo: true,
      rol: 'admin'
    },
    {
      id: 2,
      email: 'maria.gonzalez@email.com',
      password: 'demo123',
      nombre: 'María González',
      apartamento: 'Torre 1 - Apto 301',
      activo: true,
      rol: 'residente'
    },
    {
      id: 3,
      email: 'carlos.ruiz@email.com',
      password: 'demo123',
      nombre: 'Carlos Ruiz',
      apartamento: 'Torre 3 - Apto 205',
      activo: true,
      rol: 'residente'
    },
    {
      id: 4,
      email: 'ana.martinez@email.com',
      password: 'demo123',
      nombre: 'Ana Martínez',
      apartamento: 'Torre 1 - Apto 102',
      activo: true,
      rol: 'residente'
    },
    {
      id: 5,
      email: 'luis.garcia@email.com',
      password: 'demo123',
      nombre: 'Luis García',
      apartamento: 'Torre 2 - Apto 404',
      activo: true,
      rol: 'residente'
    },
    {
      id: 6,
      email: 'patricia.soto@email.com',
      password: 'demo123',
      nombre: 'Patricia Soto',
      apartamento: 'Torre 3 - Apto 303',
      activo: true,
      rol: 'residente'
    }
  ],
  residentes: [
    // Datos de residentes por apartamento para administrador
    {
      id: 1,
      apartamento: 'Torre 2 - Apto 401A',
      propietario: 'Carlos Andrés Santos Hernández',
      telefono: '300-123-4567',
      email: 'car-cbs@hotmail.com',
      tipoPropiedad: 'propietario',
      fechaIngreso: '2023-01-15',
      vehiculos: [
        { placa: 'ABC123', marca: 'Toyota', modelo: 'Corolla', color: 'Blanco' }
      ],
      mascotas: [
        { nombre: 'Max', tipo: 'Perro', raza: 'Golden Retriever' }
      ]
    }
  ],
  parqueaderosVehiculos: [
    // Vehículos asignados a cada parqueadero
    {
      id: 1,
      numeroParqueadero: 'P-001',
      nivel: 'Sótano 1',
      propietario: 'Carlos Andrés Santos Hernández',
      apartamento: 'Torre 2 - Apto 401A',
      vehiculo: {
        placa: 'ABC123',
        marca: 'Toyota',
        modelo: 'Corolla',
        color: 'Blanco'
      },
      fechaAsignacion: '2023-01-15',
      activo: true
    }
  ],
  recibosPagos: [
    // Recibos de administración subidos por admin
    {
      id: 1,
      apartamento: 'Torre 2 - Apto 401A',
      concepto: 'Administración - Agosto 2025',
      valor: 450000,
      fechaPago: '2025-08-15',
      metodoPago: 'Transferencia',
      numeroRecibo: 'REC-001-2025',
      archivo: 'recibo_apto401A_agosto2025.pdf',
      fechaSubida: '2025-08-15T10:30:00Z',
      subidoPor: 'shayoja@hotmail.com'
    }
  ],
  reservas: [
    { id: 1, espacio: 'Salón Social', fecha: '2025-08-15', hora: '10:00', usuario: 'María García - Apto 202' },
    { id: 2, espacio: 'Gimnasio', fecha: '2025-08-14', hora: '06:00', usuario: 'Carlos López - Apto 305' }
  ],
  pagos: [
    { id: 1, concepto: 'Administración', valor: 450000, mes: 'Agosto 2025', estado: 'pendiente', vencimiento: '2025-08-15' },
    { id: 2, concepto: 'Parqueadero', valor: 80000, mes: 'Agosto 2025', estado: 'pagado', vencimiento: '2025-08-15' },
    { id: 3, concepto: 'Administración', valor: 450000, mes: 'Julio 2025', estado: 'pagado', vencimiento: '2025-07-15' }
  ],
  mensajes: [
    { id: 1, usuario: 'Admin Conjunto', mensaje: 'Recordamos que mañana habrá mantenimiento del ascensor Torre B', fecha: '2025-08-12 09:00' },
    { id: 2, usuario: 'Ana Martínez - 501B', mensaje: '¿Alguien sabe hasta qué hora estará cerrada la piscina?', fecha: '2025-08-12 14:30' }
  ],
  chatsPrivados: [],
  solicitudesChat: [],
  emprendimientos: [
    { id: 1, nombre: 'Delicias Caseras', propietario: 'Laura Ruiz - 203A', tipo: 'Comida', telefono: '300-123-4567', descripcion: 'Postres y comida casera' },
    { id: 2, nombre: 'TecniFix', propietario: 'Miguel Santos - 302B', tipo: 'Técnico', telefono: '301-987-6543', descripcion: 'Reparación de electrodomésticos' }
  ],
  pqrs: [
    { id: 1, tipo: 'Reclamo', asunto: 'Ruido nocturno Torre B', estado: 'En proceso', fecha: '2025-08-10' },
    { id: 2, tipo: 'Petición', asunto: 'Solicitud nueva máquina gimnasio', estado: 'Pendiente', fecha: '2025-08-08' }
  ],
  permisos: [
    { id: 1, tipo: 'Entrada Personal', nombre: 'María Trabajadora', cedula: '12345678', fecha: '2025-08-12', vigencia: '2025-08-15' },
    { id: 2, tipo: 'Salida Objeto', objeto: 'Televisor Samsung 55"', autorizado: 'Juan Pérez', fecha: '2025-08-11' }
  ],
  noticias: [
    {
      id: 1,
      titulo: 'Asamblea General Ordinaria 2025',
      contenido: 'Se convoca a todos los propietarios y residentes del conjunto a la Asamblea General Ordinaria que se realizará el próximo 30 de septiembre de 2025 a las 3:00 PM en el salón social. Temas a tratar: aprobación de presupuesto anual, elección de nuevo consejo de administración y proyectos de mejoras.',
      categoria: 'Administrativo',
      fecha: '2025-09-10',
      fechaEvento: '2025-09-30',
      horaEvento: '15:00',
      lugar: 'Salón Social',
      prioridad: 'alta',
      activa: true
    },
    {
      id: 2,
      titulo: 'Fiesta de Integración Halloween 2025',
      contenido: '¡Prepárense para una noche de terror y diversión! El conjunto organizará la tradicional fiesta de Halloween para toda la familia. Habrá concurso de disfraces, juegos para niños, dulces y sorpresas. ¡No se lo pierdan!',
      categoria: 'Social',
      fecha: '2025-09-12',
      fechaEvento: '2025-10-31',
      horaEvento: '18:00',
      lugar: 'Zonas Comunes',
      prioridad: 'media',
      activa: true
    },
    {
      id: 3,
      titulo: 'Mantenimiento Preventivo Ascensores',
      contenido: 'Se realizará mantenimiento preventivo en todos los ascensores del conjunto los días 20 y 21 de septiembre. Durante estas fechas los ascensores estarán fuera de servicio desde las 8:00 AM hasta las 4:00 PM. Agradecemos su comprensión.',
      categoria: 'Mantenimiento',
      fecha: '2025-09-08',
      fechaEvento: '2025-09-20',
      horaEvento: '08:00',
      lugar: 'Todas las Torres',
      prioridad: 'alta',
      activa: true
    },
    {
      id: 4,
      titulo: 'Nuevas Medidas de Seguridad',
      contenido: 'A partir del 1 de octubre se implementarán nuevas medidas de seguridad: control de acceso con código QR, cámaras adicionales en parqueaderos y rondas nocturnas de vigilancia. Estas medidas buscan mejorar la seguridad de todos los residentes.',
      categoria: 'Seguridad',
      fecha: '2025-09-14',
      fechaEvento: '2025-10-01',
      horaEvento: '00:00',
      lugar: 'Todo el Conjunto',
      prioridad: 'alta',
      activa: true
    },
    {
      id: 5,
      titulo: 'Clausura Temporal de la Piscina',
      contenido: 'La piscina estará cerrada del 25 al 29 de septiembre por trabajos de limpieza profunda y mantenimiento del sistema de filtrado. Volverá a estar disponible el 30 de septiembre.',
      categoria: 'Mantenimiento',
      fecha: '2025-09-15',
      fechaEvento: '2025-09-25',
      horaEvento: '06:00',
      lugar: 'Zona de Piscina',
      prioridad: 'media',
      activa: true
    }
  ],
  apartamentosArriendo: [
    {
      id: 1,
      torre: 1,
      apartamento: '301',
      precio: 1200000,
      disponible: true,
      caracteristicas: '3 habitaciones, 2 baños, balcón',
      contacto: 'María González - 300-123-4567',
      fechaPublicacion: '2025-09-10'
    },
    {
      id: 2,
      torre: 2,
      apartamento: '505',
      precio: 1500000,
      disponible: true,
      caracteristicas: '4 habitaciones, 3 baños, terraza',
      contacto: 'Carlos Ruiz - 301-987-6543',
      fechaPublicacion: '2025-09-12'
    },
    {
      id: 3,
      torre: 3,
      apartamento: '202',
      precio: 950000,
      disponible: false,
      caracteristicas: '2 habitaciones, 1 baño',
      contacto: 'Ana Martínez - 302-456-7890',
      fechaPublicacion: '2025-09-05',
      fechaArrendado: '2025-09-14'
    }
  ],
  parqueaderos: [
    {
      id: 1,
      numero: 'A-01',
      torre: 1,
      tipo: 'Carro',
      disponible: true,
      precio: 50000
    },
    {
      id: 2,
      numero: 'A-02',
      torre: 1,
      tipo: 'Carro',
      disponible: false,
      precio: 50000,
      ocupadoPor: 'Residente - Apto 301'
    },
    {
      id: 3,
      numero: 'B-01',
      torre: 2,
      tipo: 'Moto',
      disponible: true,
      precio: 25000
    },
    {
      id: 4,
      numero: 'B-02',
      torre: 2,
      tipo: 'Carro',
      disponible: true,
      precio: 50000
    },
    {
      id: 5,
      numero: 'C-01',
      torre: 3,
      tipo: 'Carro',
      disponible: false,
      precio: 50000,
      ocupadoPor: 'Visitante - Ticket #001'
    }
  ],
  vehiculosVisitantes: [
    {
      id: 1,
      placa: 'ABC123',
      fechaIngreso: '2025-09-15T08:30:00',
      fechaSalida: null,
      tipoVehiculo: 'Carro',
      visitaA: 'Torre 1 - Apto 301',
      activo: true,
      parqueadero: 'C-01'
    },
    {
      id: 2,
      placa: 'XYZ789',
      fechaIngreso: '2025-09-15T14:15:00',
      fechaSalida: '2025-09-15T16:30:00',
      tipoVehiculo: 'Moto',
      visitaA: 'Torre 2 - Apto 505',
      activo: false,
      totalHoras: 3,
      totalCobrado: 1000,
      recibo: 'REC-001'
    }
  ],
  recibosParqueadero: [
    {
      id: 'REC-001',
      placa: 'XYZ789',
      fechaIngreso: '2025-09-15T14:15:00',
      fechaSalida: '2025-09-15T16:30:00',
      totalHoras: 3,
      horasGratis: 2,
      horasCobradas: 1,
      tarifaPorHora: 1000,
      totalCobrado: 1000,
      fechaGeneracion: '2025-09-15T16:30:00',
      visitaA: 'Torre 2 - Apto 505'
    }
  ]
};

// Rutas principales
app.get('/', (req, res) => {
  res.sendFile(path.join(__dirname, 'public', 'index.html'));
});

// API Routes

// Autenticación
app.post('/api/auth/login', (req, res) => {
  const { email, password } = req.body;

  const usuario = data.usuarios.find(u => u.email === email && u.password === password && u.activo);

  if (usuario) {
    // Generar un token simple (en producción usa JWT)
    const token = Buffer.from(`${usuario.id}:${Date.now()}`).toString('base64');

    res.json({
      success: true,
      token,
      usuario: {
        id: usuario.id,
        email: usuario.email,
        nombre: usuario.nombre,
        apartamento: usuario.apartamento,
        rol: usuario.rol
      }
    });
  } else {
    res.status(401).json({
      success: false,
      mensaje: 'Credenciales inválidas'
    });
  }
});

app.post('/api/auth/register', (req, res) => {
  const { email, password, nombre, apartamento } = req.body;

  // Verificar si el usuario ya existe
  const usuarioExistente = data.usuarios.find(u => u.email === email);
  if (usuarioExistente) {
    return res.status(400).json({
      success: false,
      mensaje: 'El email ya está registrado'
    });
  }

  // Crear nuevo usuario
  const nuevoUsuario = {
    id: data.usuarios.length + 1,
    email,
    password,
    nombre,
    apartamento,
    activo: true
  };

  data.usuarios.push(nuevoUsuario);

  res.json({
    success: true,
    mensaje: 'Usuario registrado exitosamente'
  });
});

app.get('/api/auth/verify', (req, res) => {
  const authHeader = req.headers.authorization;
  if (!authHeader) {
    return res.status(401).json({ success: false, mensaje: 'Token requerido' });
  }

  const token = authHeader.replace('Bearer ', '');
  try {
    const decoded = Buffer.from(token, 'base64').toString();
    const [userId] = decoded.split(':');
    const usuario = data.usuarios.find(u => u.id === parseInt(userId) && u.activo);

    if (usuario) {
      res.json({
        success: true,
        usuario: {
          id: usuario.id,
          email: usuario.email,
          nombre: usuario.nombre,
          apartamento: usuario.apartamento
        }
      });
    } else {
      res.status(401).json({ success: false, mensaje: 'Token inválido' });
    }
  } catch (error) {
    res.status(401).json({ success: false, mensaje: 'Token inválido' });
  }
});

// Reservas
app.get('/api/reservas', (req, res) => {
  res.json(data.reservas);
});

app.post('/api/reservas', (req, res) => {
  const { espacio, fecha, hora, usuario } = req.body;

  const nuevaReserva = {
    id: data.reservas.length + 1,
    espacio,
    fecha,
    hora,
    usuario
  };

  data.reservas.push(nuevaReserva);
  guardarDatos();

  res.json(nuevaReserva);
});

// Pagos
app.get('/api/pagos', (req, res) => {
  res.json(data.pagos);
});

app.put('/api/pagos/:id', (req, res) => {
  const id = parseInt(req.params.id);
  const pago = data.pagos.find(p => p.id === id);
  if (pago) {
    pago.estado = 'pagado';
    res.json(pago);
  } else {
    res.status(404).json({ error: 'Pago no encontrado' });
  }
});

// Chat
app.get('/api/mensajes', (req, res) => {
  res.json(data.mensajes);
});

app.post('/api/mensajes', (req, res) => {
  const { mensaje, usuario } = req.body;
  const nuevoMensaje = {
    id: data.mensajes.length + 1,
    usuario: usuario || 'Juan Pérez - 401A',
    mensaje,
    fecha: new Date().toLocaleString('es-CO')
  };
  data.mensajes.push(nuevoMensaje);
  res.json(nuevoMensaje);
});

// Emprendimientos
app.get('/api/emprendimientos', (req, res) => {
  res.json(data.emprendimientos);
});

// PQRs
app.get('/api/pqrs', (req, res) => {
  res.json(data.pqrs);
});

app.post('/api/pqrs', (req, res) => {
  const { tipo, asunto, descripcion } = req.body;
  const nuevaPqr = {
    id: data.pqrs.length + 1,
    tipo,
    asunto,
    descripcion,
    estado: 'Pendiente',
    fecha: new Date().toLocaleDateString('es-CO')
  };
  data.pqrs.push(nuevaPqr);
  res.json(nuevaPqr);
});

// Permisos
app.get('/api/permisos', (req, res) => {
  res.json(data.permisos);
});

app.post('/api/permisos', (req, res) => {
  const { tipo, nombre, cedula, objeto, vigencia } = req.body;
  const nuevoPermiso = {
    id: data.permisos.length + 1,
    tipo,
    nombre,
    cedula,
    objeto,
    autorizado: 'Juan Pérez - 401A',
    fecha: new Date().toLocaleDateString('es-CO'),
    vigencia
  };
  data.permisos.push(nuevoPermiso);
  res.json(nuevoPermiso);
});

// Noticias
app.get('/api/noticias', (req, res) => {
  // Devolver solo noticias activas, ordenadas por fecha más reciente
  const noticiasActivas = data.noticias
    .filter(noticia => noticia.activa)
    .sort((a, b) => new Date(b.fecha) - new Date(a.fecha));
  res.json(noticiasActivas);
});

app.get('/api/noticias/:id', (req, res) => {
  const id = parseInt(req.params.id);
  const noticia = data.noticias.find(n => n.id === id && n.activa);
  if (noticia) {
    res.json(noticia);
  } else {
    res.status(404).json({ error: 'Noticia no encontrada' });
  }
});

// Chat Privado
app.get('/api/usuarios', (req, res) => {
  // Devolver usuarios sin contraseñas
  const usuariosSinPassword = data.usuarios.map(u => ({
    id: u.id,
    nombre: u.nombre,
    apartamento: u.apartamento,
    activo: u.activo
  }));
  res.json(usuariosSinPassword);
});

app.post('/api/chat/solicitar', (req, res) => {
  const { destinatarioId, mensaje } = req.body;
  const token = req.headers.authorization?.replace('Bearer ', '');

  if (!token) {
    return res.status(401).json({ success: false, mensaje: 'Token requerido' });
  }

  const remitente = obtenerUsuarioPorToken(token);
  if (!remitente) {
    return res.status(401).json({ success: false, mensaje: 'Token inválido' });
  }

  const destinatario = data.usuarios.find(u => u.id === parseInt(destinatarioId));
  if (!destinatario) {
    return res.status(404).json({ success: false, mensaje: 'Usuario no encontrado' });
  }

  const solicitud = {
    id: data.solicitudesChat.length + 1,
    remitenteId: remitente.id,
    remitente: remitente.nombre,
    remitenteApto: remitente.apartamento,
    destinatarioId: parseInt(destinatarioId),
    destinatario: destinatario.nombre,
    destinatarioApto: destinatario.apartamento,
    mensaje,
    fecha: new Date().toISOString(),
    estado: 'pendiente'
  };

  data.solicitudesChat.push(solicitud);
  guardarDatos();
  res.json({ success: true, solicitud });
});

app.get('/api/chat/solicitudes', (req, res) => {
  const token = req.headers.authorization?.replace('Bearer ', '');
  const usuario = obtenerUsuarioPorToken(token);

  if (!usuario) {
    return res.status(401).json({ success: false, mensaje: 'Token inválido' });
  }

  const solicitudesRecibidas = data.solicitudesChat.filter(s =>
    s.destinatarioId === usuario.id && s.estado === 'pendiente'
  );

  res.json(solicitudesRecibidas);
});

app.post('/api/chat/responder', (req, res) => {
  const { solicitudId, respuesta } = req.body; // respuesta: 'aceptada' o 'rechazada'
  const token = req.headers.authorization?.replace('Bearer ', '');
  const usuario = obtenerUsuarioPorToken(token);

  if (!usuario) {
    return res.status(401).json({ success: false, mensaje: 'Token inválido' });
  }

  const solicitud = data.solicitudesChat.find(s => s.id === parseInt(solicitudId));
  if (!solicitud) {
    return res.status(404).json({ success: false, mensaje: 'Solicitud no encontrada' });
  }

  solicitud.estado = respuesta;

  if (respuesta === 'aceptada') {
    // Crear chat privado
    const chatId = `${Math.min(solicitud.remitenteId, solicitud.destinatarioId)}-${Math.max(solicitud.remitenteId, solicitud.destinatarioId)}`;

    const nuevoChat = {
      id: chatId,
      participantes: [solicitud.remitenteId, solicitud.destinatarioId],
      mensajes: [{
        id: 1,
        usuarioId: solicitud.remitenteId,
        usuario: solicitud.remitente,
        mensaje: solicitud.mensaje,
        fecha: solicitud.fecha
      }],
      fechaCreacion: new Date().toISOString()
    };

    data.chatsPrivados.push(nuevoChat);
  }

  guardarDatos();
  res.json({ success: true, estado: respuesta });
});

// Apartamentos en Arriendo
app.get('/api/apartamentos-arriendo', (req, res) => {
  res.json(data.apartamentosArriendo);
});

app.post('/api/apartamentos-arriendo', (req, res) => {
  const { torre, apartamento, precio, caracteristicas, contacto } = req.body;
  const nuevoApartamento = {
    id: data.apartamentosArriendo.length + 1,
    torre: parseInt(torre),
    apartamento,
    precio: parseInt(precio),
    disponible: true,
    caracteristicas,
    contacto,
    fechaPublicacion: new Date().toISOString().split('T')[0]
  };
  data.apartamentosArriendo.push(nuevoApartamento);
  res.json(nuevoApartamento);
});

app.put('/api/apartamentos-arriendo/:id', (req, res) => {
  const id = parseInt(req.params.id);
  const apartamento = data.apartamentosArriendo.find(a => a.id === id);
  if (apartamento) {
    const { disponible } = req.body;
    apartamento.disponible = disponible;
    if (!disponible) {
      apartamento.fechaArrendado = new Date().toISOString().split('T')[0];
    }
    res.json(apartamento);
  } else {
    res.status(404).json({ error: 'Apartamento no encontrado' });
  }
});

// Parqueaderos
app.get('/api/parqueaderos', (req, res) => {
  res.json(data.parqueaderos);
});

app.put('/api/parqueaderos/:id', (req, res) => {
  const id = parseInt(req.params.id);
  const parqueadero = data.parqueaderos.find(p => p.id === id);
  if (parqueadero) {
    const { disponible, ocupadoPor } = req.body;
    parqueadero.disponible = disponible;
    parqueadero.ocupadoPor = ocupadoPor;
    res.json(parqueadero);
  } else {
    res.status(404).json({ error: 'Parqueadero no encontrado' });
  }
});

// Vehículos Visitantes
app.get('/api/vehiculos-visitantes', (req, res) => {
  res.json(data.vehiculosVisitantes);
});

app.post('/api/vehiculos-visitantes/ingreso', (req, res) => {
  const { placa, tipoVehiculo, visitaA, parqueadero } = req.body;

  // Verificar si el vehículo ya está activo
  const vehiculoActivo = data.vehiculosVisitantes.find(v => v.placa === placa && v.activo);
  if (vehiculoActivo) {
    return res.status(400).json({ error: 'El vehículo ya se encuentra en el conjunto' });
  }

  const nuevoVehiculo = {
    id: data.vehiculosVisitantes.length + 1,
    placa: placa.toUpperCase(),
    fechaIngreso: new Date().toISOString(),
    fechaSalida: null,
    tipoVehiculo,
    visitaA,
    activo: true,
    parqueadero
  };

  data.vehiculosVisitantes.push(nuevoVehiculo);

  // Actualizar estado del parqueadero
  const parqueaderoObj = data.parqueaderos.find(p => p.numero === parqueadero);
  if (parqueaderoObj) {
    parqueaderoObj.disponible = false;
    parqueaderoObj.ocupadoPor = `Visitante - ${placa}`;
  }

  res.json({ success: true, vehiculo: nuevoVehiculo });
});

app.post('/api/vehiculos-visitantes/salida', (req, res) => {
  const { placa } = req.body;
  const vehiculo = data.vehiculosVisitantes.find(v => v.placa === placa && v.activo);

  if (!vehiculo) {
    return res.status(404).json({ error: 'Vehículo no encontrado o ya procesado' });
  }

  const fechaSalida = new Date();
  const fechaIngreso = new Date(vehiculo.fechaIngreso);
  const tiempoEstancia = fechaSalida - fechaIngreso;
  const horasEstancia = Math.ceil(tiempoEstancia / (1000 * 60 * 60)); // Convertir a horas

  // Calcular tarifa
  let totalCobrado = 0;
  let horasGratis = Math.min(horasEstancia, 2);
  let horasCobradas = Math.max(0, horasEstancia - 2);

  if (horasEstancia > 15) {
    // Tarifa de día completo
    totalCobrado = 12000;
    horasCobradas = 24; // Mostrar como día completo
  } else if (horasEstancia > 2) {
    // Tarifa por hora después de las 2 primeras
    totalCobrado = horasCobradas * 1000;
  }

  // Actualizar vehículo
  vehiculo.fechaSalida = fechaSalida.toISOString();
  vehiculo.activo = false;
  vehiculo.totalHoras = horasEstancia;
  vehiculo.totalCobrado = totalCobrado;

  // Generar recibo
  const reciboId = `REC-${String(data.recibosParqueadero.length + 1).padStart(3, '0')}`;
  const recibo = {
    id: reciboId,
    placa: vehiculo.placa,
    fechaIngreso: vehiculo.fechaIngreso,
    fechaSalida: vehiculo.fechaSalida,
    totalHoras: horasEstancia,
    horasGratis,
    horasCobradas,
    tarifaPorHora: 1000,
    totalCobrado,
    fechaGeneracion: fechaSalida.toISOString(),
    visitaA: vehiculo.visitaA
  };

  data.recibosParqueadero.push(recibo);
  vehiculo.recibo = reciboId;

  // Liberar parqueadero
  const parqueaderoObj = data.parqueaderos.find(p => p.numero === vehiculo.parqueadero);
  if (parqueaderoObj) {
    parqueaderoObj.disponible = true;
    parqueaderoObj.ocupadoPor = null;
  }

  res.json({ success: true, vehiculo, recibo });
});

// Recibos de Parqueadero
app.get('/api/recibos-parqueadero', (req, res) => {
  res.json(data.recibosParqueadero);
});

app.get('/api/recibos-parqueadero/:id', (req, res) => {
  const recibo = data.recibosParqueadero.find(r => r.id === req.params.id);
  if (recibo) {
    res.json(recibo);
  } else {
    res.status(404).json({ error: 'Recibo no encontrado' });
  }
});

// Endpoints para arriendos
app.post('/api/arriendos', (req, res) => {
  const { tipo, torre, numero, precio, habitaciones, banos, area, descripcion } = req.body;

  const nuevoArriendo = {
    id: data.apartamentosArriendo.length + 1,
    tipo,
    torre,
    numero,
    precio,
    habitaciones: habitaciones || null,
    banos: banos || null,
    area: area || null,
    descripcion: descripcion || '',
    estado: 'disponible',
    fechaPublicacion: new Date().toISOString(),
    propietario: 'Administración'
  };

  if (tipo === 'apartamento') {
    data.apartamentosArriendo.push(nuevoArriendo);
  } else if (tipo === 'parqueadero') {
    // Agregar a parqueaderos en arriendo
    const parqueaderoArriendo = {
      id: data.parqueaderos.length + 1,
      numero,
      nivel: torre,
      tipo: 'Visitante',
      estado: 'disponible',
      precio,
      descripcion
    };
    data.parqueaderos.push(parqueaderoArriendo);
  }

  guardarDatos();
  res.json(nuevoArriendo);
});

app.get('/api/parqueaderos-arriendo', (req, res) => {
  const parqueaderosArriendo = data.parqueaderos.filter(p => p.precio > 0);
  res.json(parqueaderosArriendo);
});

// Endpoint para ingreso de vehículos
app.post('/api/vehiculos-visitantes/ingreso', (req, res) => {
  const { placa, visitante, apartamento, tipo } = req.body;

  // Verificar si ya existe un vehículo activo con la misma placa
  const vehiculoExistente = data.vehiculosVisitantes.find(v => v.placa === placa && v.activo);
  if (vehiculoExistente) {
    return res.status(400).json({ error: 'El vehículo ya se encuentra registrado en el conjunto' });
  }

  const fechaIngreso = new Date();
  const nuevoVehiculo = {
    id: data.vehiculosVisitantes.length + 1,
    placa: placa.toUpperCase(),
    visitante,
    apartamento,
    tipo,
    fechaIngreso: fechaIngreso.toISOString(),
    horaEntrada: fechaIngreso.toLocaleTimeString('es-CO', {
      hour: '2-digit',
      minute: '2-digit',
      hour12: true
    }),
    activo: true,
    registradoPor: 'Portería'
  };

  data.vehiculosVisitantes.push(nuevoVehiculo);
  guardarDatos();

  res.json({
    success: true,
    vehiculo: nuevoVehiculo,
    horaEntrada: nuevoVehiculo.horaEntrada,
    mensaje: 'Vehículo registrado exitosamente'
  });
});

// Endpoint para obtener vehículos del día
app.get('/api/vehiculos-visitantes/hoy', (req, res) => {
  const hoy = new Date();
  const inicioDelDia = new Date(hoy.getFullYear(), hoy.getMonth(), hoy.getDate());
  const finDelDia = new Date(hoy.getFullYear(), hoy.getMonth(), hoy.getDate() + 1);

  const vehiculosHoy = data.vehiculosVisitantes.filter(vehiculo => {
    const fechaIngreso = new Date(vehiculo.fechaIngreso);
    return fechaIngreso >= inicioDelDia && fechaIngreso < finDelDia;
  });

  // Ordenar por hora de ingreso (más reciente primero)
  vehiculosHoy.sort((a, b) => new Date(b.fechaIngreso) - new Date(a.fechaIngreso));

  res.json(vehiculosHoy);
});

function guardarDatos() {
  console.log('💾 Datos guardados');
}

// ================================
// ENDPOINTS DE ADMINISTRACIÓN
// ================================

// Middleware para verificar rol de administrador
function verificarAdmin(req, res, next) {
  const token = req.headers.authorization?.replace('Bearer ', '');
  const usuario = obtenerUsuarioPorToken(token);

  if (!usuario || usuario.rol !== 'admin') {
    return res.status(403).json({
      success: false,
      mensaje: 'Acceso denegado. Solo administradores.'
    });
  }

  req.usuario = usuario;
  next();
}

// Obtener todos los residentes (solo admin)
app.get('/api/admin/residentes', verificarAdmin, (req, res) => {
  res.json({
    success: true,
    residentes: data.residentes
  });
});

// Agregar/editar residente (solo admin)
app.post('/api/admin/residentes', verificarAdmin, (req, res) => {
  const { id, apartamento, propietario, telefono, email, tipoPropiedad, fechaIngreso, vehiculos, mascotas } = req.body;

  if (id) {
    // Editar residente existente
    const index = data.residentes.findIndex(r => r.id === id);
    if (index !== -1) {
      data.residentes[index] = { id, apartamento, propietario, telefono, email, tipoPropiedad, fechaIngreso, vehiculos: vehiculos || [], mascotas: mascotas || [] };
    }
  } else {
    // Agregar nuevo residente
    const nuevoId = Math.max(0, ...data.residentes.map(r => r.id)) + 1;
    data.residentes.push({
      id: nuevoId,
      apartamento,
      propietario,
      telefono,
      email,
      tipoPropiedad,
      fechaIngreso,
      vehiculos: vehiculos || [],
      mascotas: mascotas || []
    });
  }

  guardarDatos();
  res.json({ success: true });
});

// Eliminar residente (solo admin)
app.delete('/api/admin/residentes/:id', verificarAdmin, (req, res) => {
  const id = parseInt(req.params.id);
  data.residentes = data.residentes.filter(r => r.id !== id);
  guardarDatos();
  res.json({ success: true });
});

// Obtener vehículos por parqueadero (solo admin)
app.get('/api/admin/parqueaderos-vehiculos', verificarAdmin, (req, res) => {
  res.json({
    success: true,
    parqueaderosVehiculos: data.parqueaderosVehiculos
  });
});

// Asignar vehículo a parqueadero (solo admin)
app.post('/api/admin/parqueaderos-vehiculos', verificarAdmin, (req, res) => {
  const { numeroParqueadero, nivel, propietario, apartamento, vehiculo, fechaAsignacion } = req.body;

  const nuevoId = Math.max(0, ...data.parqueaderosVehiculos.map(p => p.id)) + 1;
  data.parqueaderosVehiculos.push({
    id: nuevoId,
    numeroParqueadero,
    nivel,
    propietario,
    apartamento,
    vehiculo,
    fechaAsignacion,
    activo: true
  });

  guardarDatos();
  res.json({ success: true });
});

// Obtener recibos de pagos (solo admin)
app.get('/api/admin/recibos-pagos', verificarAdmin, (req, res) => {
  res.json({
    success: true,
    recibos: data.recibosPagos
  });
});

// Subir recibo de pago (solo admin)
app.post('/api/admin/recibos-pagos', verificarAdmin, (req, res) => {
  const { apartamento, concepto, valor, fechaPago, metodoPago, numeroRecibo, archivo } = req.body;

  const nuevoId = Math.max(0, ...data.recibosPagos.map(r => r.id)) + 1;
  data.recibosPagos.push({
    id: nuevoId,
    apartamento,
    concepto,
    valor,
    fechaPago,
    metodoPago,
    numeroRecibo,
    archivo,
    fechaSubida: new Date().toISOString(),
    subidoPor: req.usuario.email
  });

  guardarDatos();
  res.json({ success: true });
});

// Realizar sorteo de parqueaderos (solo admin)
app.post('/api/admin/sorteo-parqueaderos', verificarAdmin, (req, res) => {
  const { participantes } = req.body;

  // Generar 100 parqueaderos
  const parqueaderos = [];
  for (let i = 1; i <= 100; i++) {
    const nivel = i <= 33 ? 'Sótano 1' : i <= 66 ? 'Sótano 2' : 'Sótano 3';
    parqueaderos.push({
      numero: `P-${i.toString().padStart(3, '0')}`,
      nivel: nivel
    });
  }

  // Mezclar participantes y asignar
  const participantesMezclados = [...participantes].sort(() => Math.random() - 0.5);
  const resultados = parqueaderos.slice(0, participantesMezclados.length).map((parqueadero, index) => ({
    participante: participantesMezclados[index],
    parqueadero: parqueadero.numero,
    nivel: parqueadero.nivel
  }));

  // Guardar resultado del sorteo
  data.ultimoSorteo = {
    fecha: new Date().toISOString(),
    realizadoPor: req.usuario.email,
    resultados: resultados
  };

  guardarDatos();
  res.json({
    success: true,
    resultados: resultados
  });
});

function obtenerUsuarioPorToken(token) {
  try {
    const decoded = Buffer.from(token, 'base64').toString();
    const [userId] = decoded.split(':');
    return data.usuarios.find(u => u.id === parseInt(userId));
  } catch {
    return null;
  }
}

// Iniciar servidor
app.listen(PORT, () => {
  console.log(`🏢 Servidor del conjunto residencial corriendo en http://localhost:${PORT}`);
  console.log(`📱 Abre tu navegador y ve a la dirección de arriba`);
});

// Guardar datos cada 5 minutos (opcional)
setInterval(() => {
  fs.writeFileSync('data.json', JSON.stringify(data, null, 2));
  console.log('💾 Datos guardados');
}, 5 * 60 * 1000);