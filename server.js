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

// CORS - Permitir peticiones desde Flutter (puerto 3000)
app.use((req, res, next) => {
  res.header('Access-Control-Allow-Origin', '*');
  res.header('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS');
  res.header('Access-Control-Allow-Headers', 'Origin, X-Requested-With, Content-Type, Accept, Authorization');

  // Manejar preflight requests
  if (req.method === 'OPTIONS') {
    return res.sendStatus(200);
  }

  next();
});

// Manejar favicon.ico
app.get('/favicon.ico', (req, res) => {
  res.status(204).end(); // No Content - evita el error 404
});

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
      id: 8,
      email: 'car02cbs@gmail.com',
      password: 'password3',
      nombre: 'Vigilante de Seguridad',
      apartamento: 'Portería Principal',
      activo: true,
      rol: 'vigilante'
    },
    {
      id: 6,
      email: 'patricia.soto@email.com',
      password: 'demo123',
      nombre: 'Patricia Soto',
      apartamento: 'Torre 3 - Apto 303',
      activo: true,
      rol: 'residente'
    },
    {
      id: 9,
      email: 'alcaldia@conjunto.com',
      password: 'alcaldia123',
      nombre: 'Oficial de Alcaldía',
      apartamento: 'Oficina Alcaldía',
      activo: true,
      rol: 'alcaldia'
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
  solicitudesChat: [],
  chats: {
    general: [
      {
        id: 1,
        usuario: 'Carlos Andrés Santos Hernández',
        apartamento: 'Torre 2 - Apto 401A',
        mensaje: '¡Hola a todos! Buenos días',
        fecha: new Date().toISOString(),
        tipo: 'general'
      }
    ],
    admin: [],
    vigilantes: [],
    privados: {}
  },
  incidentes: [
    {
      id: 1,
      tipo: 'Infraestructura',
      titulo: 'Daño en vía principal',
      descripcion: 'Hueco grande en la entrada del conjunto',
      ubicacion: 'Entrada Principal',
      prioridad: 'Alta',
      estado: 'Reportado',
      reportadoPor: 'Administrador del Conjunto',
      fecha: new Date().toISOString(),
      fotos: [],
      respuestaAlcaldia: null,
      fechaRespuesta: null
    }
  ],
  emprendimientos: [
    {
      id: 1,
      nombre: 'Delicias Caseras',
      propietario: 'Laura Ruiz - Torre 2 Apto 203A',
      tipo: 'Comida',
      telefono: '300-123-4567',
      descripcion: 'Postres artesanales, tortas personalizadas y comida casera. Hacemos delivery dentro del conjunto.',
      imagen: 'https://images.unsplash.com/photo-1578985545062-69928b1d9587?w=400&h=300&fit=crop',
      calificacion: 4.8,
      horario: 'Lun-Sáb 9am-7pm'
    },
    {
      id: 2,
      nombre: 'TecniFix',
      propietario: 'Miguel Santos - Torre 1 Apto 302B',
      tipo: 'Técnico',
      telefono: '301-987-6543',
      descripcion: 'Reparación y mantenimiento de electrodomésticos, aires acondicionados, neveras, lavadoras. Servicio a domicilio.',
      imagen: 'https://images.unsplash.com/photo-1581092921461-eab62e97a780?w=400&h=300&fit=crop',
      calificacion: 4.5,
      horario: 'Lun-Vie 8am-6pm'
    },
    {
      id: 3,
      nombre: 'CodeFlow Solutions',
      propietario: 'Carlos Andrés Santos Hernández - Torre 2 Apto 401A',
      tipo: 'Tecnología',
      telefono: '310-555-7890',
      descripcion: 'Desarrollo de aplicaciones web y móviles, automatizaciones, sistemas de gestión. Soluciones tecnológicas personalizadas para negocios y emprendimientos.',
      imagen: 'https://images.unsplash.com/photo-1498050108023-c5249f4df085?w=400&h=300&fit=crop',
      calificacion: 5.0,
      horario: 'Lun-Vie 9am-6pm, Sáb 10am-2pm'
    }
  ],
  arriendos: [],
  permisos: [
    // Tipos: visitante, objeto, trasteo, domicilio
  ],
  ultimoSorteo: null,
  paquetes: [],
  pqrs: [
    {
      id: 1,
      tipo: 'Reclamo',
      asunto: 'Ruido nocturno Torre B',
      descripcion: 'Constantemente hay ruido después de las 10pm en el apartamento 301B',
      estado: 'En proceso',
      fecha: '2025-08-10',
      residente: 'Carlos Andrés Santos Hernández',
      apartamento: 'Torre 2 - Apto 401A',
      respuesta: null,
      fechaRespuesta: null,
      respondidoPor: null
    },
    {
      id: 2,
      tipo: 'Petición',
      asunto: 'Solicitud nueva máquina gimnasio',
      descripcion: 'Se solicita la compra de una caminadora adicional para el gimnasio',
      estado: 'Pendiente',
      fecha: '2025-08-08',
      residente: 'María González',
      apartamento: 'Torre 1 - Apto 301',
      respuesta: null,
      fechaRespuesta: null,
      respondidoPor: null
    }
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
  // Nuevas estructuras de datos
  solicitudesPermisos: [],
  camaras: [
    { id: 1, nombre: 'Entrada Principal', ubicacion: 'Portería', url: 'rtsp://camera1', tipo: 'fija', visible_residentes: true, activa: true },
    { id: 2, nombre: 'Parqueadero Sótano 1', ubicacion: 'Parqueadero', url: 'rtsp://camera2', tipo: 'PTZ', visible_residentes: false, activa: true },
    { id: 3, nombre: 'Zona Social', ubicacion: 'Zonas Comunes', url: 'rtsp://camera3', tipo: 'fija', visible_residentes: true, activa: true }
  ],
  encuestas: [
    {
      id: 1,
      titulo: 'Horario de uso de la piscina',
      descripcion: '¿Cuál horario prefieres para el uso de la piscina?',
      opciones: [
        { id: 1, texto: '6:00 AM - 12:00 PM', votos: 15 },
        { id: 2, texto: '12:00 PM - 6:00 PM', votos: 28 },
        { id: 3, texto: '6:00 PM - 10:00 PM', votos: 42 }
      ],
      votantes: [], // Array de IDs de usuarios que ya votaron
      estado: 'activa', // activa, cerrada
      fechaCreacion: new Date().toISOString(),
      fechaCierre: null,
      creadoPor: 'Administrador del Conjunto'
    }
  ],
  documentos: [
    {
      id: 1,
      titulo: 'Manual de Convivencia',
      descripcion: 'Reglamento interno del conjunto residencial Aralia de Castilla',
      categoria: 'Reglamento',
      archivo: '#',
      fechaPublicacion: '2024-01-15',
      publicadoPor: 'Administración'
    },
    {
      id: 2,
      titulo: 'Balance Financiero 2024 - Primer Trimestre',
      descripcion: 'Estado financiero del conjunto correspondiente a Enero - Marzo 2024',
      categoria: 'Balance',
      archivo: '#',
      fechaPublicacion: '2024-04-10',
      publicadoPor: 'Administración'
    },
    {
      id: 3,
      titulo: 'Balance Financiero 2024 - Segundo Trimestre',
      descripcion: 'Estado financiero del conjunto correspondiente a Abril - Junio 2024',
      categoria: 'Balance',
      archivo: '#',
      fechaPublicacion: '2024-07-10',
      publicadoPor: 'Administración'
    },
    {
      id: 4,
      titulo: 'Balance Financiero 2024 - Tercer Trimestre',
      descripcion: 'Estado financiero del conjunto correspondiente a Julio - Septiembre 2024',
      categoria: 'Balance',
      archivo: '#',
      fechaPublicacion: '2024-10-10',
      publicadoPor: 'Administración'
    }
  ],
  asignacionesParqueaderos: [],
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
  res.sendFile(path.join(__dirname, 'public', 'conjunto-aralia-completo.html'));
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
  const token = req.headers.authorization?.replace('Bearer ', '');
  const usuario = obtenerUsuarioPorToken(token);

  if (!usuario) {
    return res.status(401).json({ success: false, mensaje: 'No autorizado' });
  }

  const { espacio, fecha, hora, observaciones } = req.body;

  // Validar que el espacio esté disponible
  const reservaExistente = data.reservas.find(r =>
    r.espacio === espacio && r.fecha === fecha && r.hora === hora
  );

  if (reservaExistente) {
    return res.status(400).json({ success: false, mensaje: 'Este espacio ya está reservado para esa fecha y hora' });
  }

  const nuevaReserva = {
    id: data.reservas.length + 1,
    espacio,
    fecha,
    hora,
    usuario: usuario.nombre,
    apartamento: usuario.apartamento,
    observaciones: observaciones || '',
    fechaCreacion: new Date().toISOString(),
    estado: 'Confirmada'
  };

  data.reservas.push(nuevaReserva);
  guardarDatos();

  res.json({ success: true, reserva: nuevaReserva });
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

app.get('/api/residente/emprendimientos', (req, res) => {
  res.json({ success: true, emprendimientos: data.emprendimientos });
});

// Arriendos
app.get('/api/arriendos', (req, res) => {
  res.json(data.arriendos);
});

app.post('/api/residente/publicar-arriendo', (req, res) => {
  const token = req.headers.authorization?.replace('Bearer ', '');
  const usuario = obtenerUsuarioPorToken(token);

  if (!usuario) {
    return res.status(401).json({ success: false, mensaje: 'No autorizado' });
  }

  const nuevoArriendo = {
    id: data.arriendos.length + 1,
    ...req.body,
    propietario: usuario.nombre,
    propietarioId: usuario.id,
    email: usuario.email,
    fechaPublicacion: new Date().toISOString(),
    estado: 'Activo'
  };

  data.arriendos.push(nuevoArriendo);
  guardarDatos();
  res.json({ success: true, arriendo: nuevoArriendo });
});

// Endpoint para solicitar permiso (residente)
app.post('/api/residente/solicitar-permiso', (req, res) => {
  const token = req.headers.authorization?.replace('Bearer ', '');
  const usuario = obtenerUsuarioPorToken(token);

  if (!usuario) {
    return res.status(401).json({ success: false, mensaje: 'No autorizado' });
  }

  const { tipo, nombre, cedula, placa, empresa, descripcion, fechaIngreso, horaIngreso, tiempoEstimado } = req.body;

  const nuevoPermiso = {
    id: data.permisos.length + 1,
    tipo, // visitante, objeto, trasteo, domicilio
    residente: usuario.nombre,
    apartamento: usuario.apartamento,
    nombre,
    cedula: cedula || null,
    placa: placa || null,
    empresa: empresa || null,
    descripcion: descripcion || null,
    fechaIngreso,
    horaIngreso,
    tiempoEstimado: tiempoEstimado || null,
    fechaSolicitud: new Date().toISOString(),
    estado: 'Vigente', // Vigente, Ingresado, Finalizado, Vencido
    autorizadoPor: usuario.nombre,
    horaIngresoReal: null,
    horaSalidaReal: null
  };

  data.permisos.push(nuevoPermiso);
  guardarDatos();
  res.json({ success: true, permiso: nuevoPermiso });
});

// Endpoint para obtener permisos (admin y vigilante)
app.get('/api/permisos', verificarVigilante, (req, res) => {
  const { tipo, estado } = req.query;

  let permisosFiltrados = data.permisos;

  if (tipo) {
    permisosFiltrados = permisosFiltrados.filter(p => p.tipo === tipo);
  }

  if (estado) {
    permisosFiltrados = permisosFiltrados.filter(p => p.estado === estado);
  }

  res.json({ success: true, permisos: permisosFiltrados });
});

// Endpoint para registrar ingreso de permiso
app.put('/api/permisos/:id/ingresar', verificarVigilante, (req, res) => {
  const { id } = req.params;
  const permiso = data.permisos.find(p => p.id === parseInt(id));

  if (!permiso) {
    return res.status(404).json({ success: false, mensaje: 'Permiso no encontrado' });
  }

  permiso.estado = 'Ingresado';
  permiso.horaIngresoReal = new Date().toISOString();
  guardarDatos();

  res.json({ success: true, permiso });
});

// Endpoint para registrar salida de permiso
app.put('/api/permisos/:id/salir', verificarVigilante, (req, res) => {
  const { id } = req.params;
  const permiso = data.permisos.find(p => p.id === parseInt(id));

  if (!permiso) {
    return res.status(404).json({ success: false, mensaje: 'Permiso no encontrado' });
  }

  permiso.estado = 'Finalizado';
  permiso.horaSalidaReal = new Date().toISOString();
  guardarDatos();

  res.json({ success: true, permiso });
});

// Endpoint para obtener mis permisos (residente)
app.get('/api/residente/mis-permisos', (req, res) => {
  const token = req.headers.authorization?.replace('Bearer ', '');
  const usuario = obtenerUsuarioPorToken(token);

  if (!usuario) {
    return res.status(401).json({ success: false, mensaje: 'No autorizado' });
  }

  const misPermisos = data.permisos.filter(p =>
    p.apartamento === usuario.apartamento
  );

  res.json({ success: true, permisos: misPermisos });
});

// Paquetes
app.get('/api/paquetes', (req, res) => {
  res.json(data.paquetes);
});

app.post('/api/paquetes/registrar', (req, res) => {
  const token = req.headers.authorization?.replace('Bearer ', '');
  const usuario = obtenerUsuarioPorToken(token);

  if (!usuario || usuario.rol !== 'vigilante') {
    return res.status(403).json({ success: false, mensaje: 'No autorizado' });
  }

  const { torre, apartamento, descripcion, remitente, empresa } = req.body;

  const nuevoPaquete = {
    id: data.paquetes.length + 1,
    torre,
    apartamento,
    descripcion,
    remitente,
    empresa,
    fechaLlegada: new Date().toISOString(),
    registradoPor: usuario.nombre,
    estado: 'Pendiente',
    retirado: false
  };

  data.paquetes.push(nuevoPaquete);
  guardarDatos();
  res.json({ success: true, paquete: nuevoPaquete });
});

app.put('/api/paquetes/:id/retirar', (req, res) => {
  const id = parseInt(req.params.id);
  const paquete = data.paquetes.find(p => p.id === id);

  if (paquete) {
    paquete.retirado = true;
    paquete.fechaRetiro = new Date().toISOString();
    paquete.estado = 'Retirado';
    guardarDatos();
    res.json({ success: true, paquete });
  } else {
    res.status(404).json({ success: false, mensaje: 'Paquete no encontrado' });
  }
});

app.get('/api/residente/mis-paquetes', (req, res) => {
  const token = req.headers.authorization?.replace('Bearer ', '');
  const usuario = obtenerUsuarioPorToken(token);

  if (!usuario) {
    return res.status(401).json({ success: false, mensaje: 'No autorizado' });
  }

  // Normalizar el formato del apartamento del usuario para comparación
  const apartamentoUsuario = usuario.apartamento.toLowerCase().trim();

  const misPaquetes = data.paquetes.filter(p => {
    if (!p.apartamento) return false;

    // Normalizar el apartamento del paquete
    const apartamentoPaquete = p.apartamento.toLowerCase().trim();

    // Comparar directamente o verificar si coinciden normalizados
    return apartamentoPaquete === apartamentoUsuario ||
           apartamentoUsuario.includes(apartamentoPaquete) ||
           apartamentoPaquete.includes(apartamentoUsuario);
  });

  res.json({ success: true, paquetes: misPaquetes });
});

// PQRs
app.get('/api/pqrs', (req, res) => {
  res.json(data.pqrs);
});

app.post('/api/pqrs', (req, res) => {
  const token = req.headers.authorization?.replace('Bearer ', '');
  const usuario = obtenerUsuarioPorToken(token);

  if (!usuario) {
    return res.status(401).json({ success: false, mensaje: 'No autorizado' });
  }

  const { tipo, asunto, descripcion } = req.body;
  const nuevaPqr = {
    id: data.pqrs.length + 1,
    tipo,
    asunto,
    descripcion,
    estado: 'Pendiente',
    fecha: new Date().toISOString(),
    residente: usuario.nombre,
    apartamento: usuario.apartamento,
    respuesta: null,
    fechaRespuesta: null,
    respondidoPor: null
  };
  data.pqrs.push(nuevaPqr);
  guardarDatos();
  res.json({ success: true, pqr: nuevaPqr });
});

// Endpoint para responder PQRS (solo admin)
app.put('/api/pqrs/:id/responder', verificarAdmin, (req, res) => {
  const { id } = req.params;
  const { respuesta } = req.body;
  const token = req.headers.authorization?.replace('Bearer ', '');
  const usuario = obtenerUsuarioPorToken(token);

  const pqr = data.pqrs.find(p => p.id === parseInt(id));

  if (!pqr) {
    return res.status(404).json({ success: false, mensaje: 'PQRS no encontrada' });
  }

  pqr.respuesta = respuesta;
  pqr.fechaRespuesta = new Date().toISOString();
  pqr.respondidoPor = usuario.nombre;
  pqr.estado = 'Respondida';
  guardarDatos();

  res.json({ success: true, pqr });
});

// Endpoint para cambiar estado de PQRS (solo admin)
app.put('/api/pqrs/:id/estado', verificarAdmin, (req, res) => {
  const { id } = req.params;
  const { estado } = req.body;

  const pqr = data.pqrs.find(p => p.id === parseInt(id));

  if (!pqr) {
    return res.status(404).json({ success: false, mensaje: 'PQRS no encontrada' });
  }

  pqr.estado = estado;
  guardarDatos();

  res.json({ success: true, pqr });
});

// ============= ENDPOINTS DE CHAT =============

// Obtener mensajes de un canal de chat
app.get('/api/chat/:canal', (req, res) => {
  const token = req.headers.authorization?.replace('Bearer ', '');
  const usuario = obtenerUsuarioPorToken(token);

  if (!usuario) {
    return res.status(401).json({ success: false, mensaje: 'No autorizado' });
  }

  const { canal } = req.params;

  // Verificar permisos según el canal
  if (canal === 'admin' && usuario.rol !== 'admin') {
    return res.status(403).json({ success: false, mensaje: 'No autorizado para este canal' });
  }

  if (canal === 'vigilantes' && usuario.rol !== 'vigilante' && usuario.rol !== 'admin') {
    return res.status(403).json({ success: false, mensaje: 'No autorizado para este canal' });
  }

  const mensajes = data.chats[canal] || [];
  res.json({ success: true, mensajes });
});

// Enviar mensaje a un canal
app.post('/api/chat/:canal', (req, res) => {
  const token = req.headers.authorization?.replace('Bearer ', '');
  const usuario = obtenerUsuarioPorToken(token);

  if (!usuario) {
    return res.status(401).json({ success: false, mensaje: 'No autorizado' });
  }

  const { canal } = req.params;
  const { mensaje } = req.body;

  // Verificar permisos según el canal
  if (canal === 'admin' && usuario.rol !== 'admin') {
    return res.status(403).json({ success: false, mensaje: 'No autorizado para este canal' });
  }

  if (canal === 'vigilantes' && usuario.rol !== 'vigilante' && usuario.rol !== 'admin') {
    return res.status(403).json({ success: false, mensaje: 'No autorizado para este canal' });
  }

  if (!data.chats[canal]) {
    data.chats[canal] = [];
  }

  const nuevoMensaje = {
    id: data.chats[canal].length + 1,
    usuario: usuario.nombre,
    usuarioId: usuario.id,
    apartamento: usuario.apartamento,
    rol: usuario.rol,
    mensaje,
    fecha: new Date().toISOString(),
    tipo: canal
  };

  data.chats[canal].push(nuevoMensaje);
  guardarDatos();

  res.json({ success: true, mensaje: nuevoMensaje });
});

// Obtener lista de chats privados del usuario
app.get('/api/chat/privados/lista', (req, res) => {
  const token = req.headers.authorization?.replace('Bearer ', '');
  const usuario = obtenerUsuarioPorToken(token);

  if (!usuario) {
    return res.status(401).json({ success: false, mensaje: 'No autorizado' });
  }

  // Obtener todos los chats privados donde participa el usuario
  const misChats = Object.keys(data.chats.privados)
    .filter(chatId => chatId.includes(`-${usuario.id}-`) || chatId.includes(`-${usuario.id}`))
    .map(chatId => {
      const mensajes = data.chats.privados[chatId] || [];
      const ultimoMensaje = mensajes[mensajes.length - 1];

      // Extraer IDs de los participantes del chatId
      const ids = chatId.split('-').map(id => parseInt(id));
      const otroId = ids.find(id => id !== usuario.id);
      const otroUsuario = data.usuarios.find(u => u.id === otroId);

      return {
        chatId,
        otroUsuario: otroUsuario ? {
          id: otroUsuario.id,
          nombre: otroUsuario.nombre,
          apartamento: otroUsuario.apartamento
        } : null,
        ultimoMensaje,
        cantidadMensajes: mensajes.length
      };
    });

  res.json({ success: true, chats: misChats });
});

// Obtener mensajes de un chat privado
app.get('/api/chat/privado/:otroUsuarioId', (req, res) => {
  const token = req.headers.authorization?.replace('Bearer ', '');
  const usuario = obtenerUsuarioPorToken(token);

  if (!usuario) {
    return res.status(401).json({ success: false, mensaje: 'No autorizado' });
  }

  const otroUsuarioId = parseInt(req.params.otroUsuarioId);
  const chatId = [usuario.id, otroUsuarioId].sort().join('-');

  const mensajes = data.chats.privados[chatId] || [];

  const otroUsuario = data.usuarios.find(u => u.id === otroUsuarioId);

  res.json({
    success: true,
    mensajes,
    otroUsuario: otroUsuario ? {
      id: otroUsuario.id,
      nombre: otroUsuario.nombre,
      apartamento: otroUsuario.apartamento
    } : null
  });
});

// Enviar mensaje privado
app.post('/api/chat/privado/:otroUsuarioId', (req, res) => {
  const token = req.headers.authorization?.replace('Bearer ', '');
  const usuario = obtenerUsuarioPorToken(token);

  if (!usuario) {
    return res.status(401).json({ success: false, mensaje: 'No autorizado' });
  }

  const otroUsuarioId = parseInt(req.params.otroUsuarioId);
  const { mensaje } = req.body;

  const chatId = [usuario.id, otroUsuarioId].sort().join('-');

  if (!data.chats.privados[chatId]) {
    data.chats.privados[chatId] = [];
  }

  const nuevoMensaje = {
    id: data.chats.privados[chatId].length + 1,
    usuarioId: usuario.id,
    usuario: usuario.nombre,
    mensaje,
    fecha: new Date().toISOString()
  };

  data.chats.privados[chatId].push(nuevoMensaje);
  guardarDatos();

  res.json({ success: true, mensaje: nuevoMensaje });
});

// Obtener lista de residentes para iniciar chat
app.get('/api/residentes/lista', (req, res) => {
  const token = req.headers.authorization?.replace('Bearer ', '');
  const usuario = obtenerUsuarioPorToken(token);

  if (!usuario) {
    return res.status(401).json({ success: false, mensaje: 'No autorizado' });
  }

  // Devolver todos los residentes excepto el usuario actual
  const residentes = data.usuarios
    .filter(u => u.id !== usuario.id && u.rol === 'residente')
    .map(u => ({
      id: u.id,
      nombre: u.nombre,
      apartamento: u.apartamento
    }));

  res.json({ success: true, residentes });
});

// ============= ENDPOINTS DE INCIDENTES (ALCALDÍA) =============

// Obtener todos los incidentes
app.get('/api/incidentes', (req, res) => {
  res.json({ success: true, incidentes: data.incidentes });
});

// Crear nuevo incidente (admin)
app.post('/api/incidentes', verificarAdmin, (req, res) => {
  const token = req.headers.authorization?.replace('Bearer ', '');
  const usuario = obtenerUsuarioPorToken(token);

  const { tipo, titulo, descripcion, ubicacion, prioridad, fotos } = req.body;

  const nuevoIncidente = {
    id: data.incidentes.length + 1,
    tipo,
    titulo,
    descripcion,
    ubicacion,
    prioridad,
    estado: 'Reportado',
    reportadoPor: usuario.nombre,
    fecha: new Date().toISOString(),
    fotos: fotos || [],
    respuestaAlcaldia: null,
    fechaRespuesta: null
  };

  data.incidentes.push(nuevoIncidente);
  guardarDatos();

  res.json({ success: true, incidente: nuevoIncidente });
});

// Responder incidente (alcaldia)
app.put('/api/incidentes/:id/responder', (req, res) => {
  const token = req.headers.authorization?.replace('Bearer ', '');
  const usuario = obtenerUsuarioPorToken(token);

  if (!usuario || usuario.rol !== 'alcaldia') {
    return res.status(403).json({ success: false, mensaje: 'No autorizado. Solo la Alcaldía puede responder.' });
  }

  const { id } = req.params;
  const { respuesta } = req.body;

  const incidente = data.incidentes.find(i => i.id === parseInt(id));
  if (!incidente) {
    return res.status(404).json({ success: false, mensaje: 'Incidente no encontrado' });
  }

  incidente.respuestaAlcaldia = respuesta;
  incidente.fechaRespuesta = new Date().toISOString();
  incidente.estado = 'En atención';
  guardarDatos();

  res.json({ success: true, incidente });
});

// Cambiar estado de incidente (alcaldia)
app.put('/api/incidentes/:id/estado', (req, res) => {
  const token = req.headers.authorization?.replace('Bearer ', '');
  const usuario = obtenerUsuarioPorToken(token);

  if (!usuario || usuario.rol !== 'alcaldia') {
    return res.status(403).json({ success: false, mensaje: 'No autorizado. Solo la Alcaldía puede cambiar el estado.' });
  }

  const { id } = req.params;
  const { estado } = req.body;

  const incidente = data.incidentes.find(i => i.id === parseInt(id));
  if (!incidente) {
    return res.status(404).json({ success: false, mensaje: 'Incidente no encontrado' });
  }

  incidente.estado = estado;
  guardarDatos();

  res.json({ success: true, incidente });
});

// ============= ENDPOINTS DE ENCUESTAS =============

// Obtener todas las encuestas
app.get('/api/encuestas', (req, res) => {
  res.json({ success: true, encuestas: data.encuestas });
});

// Crear encuesta (admin)
app.post('/api/encuestas', verificarAdmin, (req, res) => {
  const token = req.headers.authorization?.replace('Bearer ', '');
  const usuario = obtenerUsuarioPorToken(token);

  const { titulo, descripcion, opciones } = req.body;

  if (!opciones || opciones.length < 2) {
    return res.status(400).json({ success: false, mensaje: 'Debe haber al menos 2 opciones' });
  }

  const nuevaEncuesta = {
    id: data.encuestas.length + 1,
    titulo,
    descripcion,
    opciones: opciones.map((texto, index) => ({
      id: index + 1,
      texto: texto.trim(),
      votos: 0
    })),
    votantes: [],
    estado: 'activa',
    fechaCreacion: new Date().toISOString(),
    fechaCierre: null,
    creadoPor: usuario.nombre
  };

  data.encuestas.push(nuevaEncuesta);
  guardarDatos();

  res.json({ success: true, encuesta: nuevaEncuesta });
});

// Votar en encuesta
app.post('/api/encuestas/:id/votar', (req, res) => {
  const token = req.headers.authorization?.replace('Bearer ', '');
  const usuario = obtenerUsuarioPorToken(token);

  if (!usuario) {
    return res.status(401).json({ success: false, mensaje: 'No autorizado' });
  }

  const { id } = req.params;
  const { opcionId } = req.body;

  const encuesta = data.encuestas.find(e => e.id === parseInt(id));
  if (!encuesta) {
    return res.status(404).json({ success: false, mensaje: 'Encuesta no encontrada' });
  }

  if (encuesta.estado !== 'activa') {
    return res.status(400).json({ success: false, mensaje: 'Esta encuesta ya está cerrada' });
  }

  if (encuesta.votantes.includes(usuario.id)) {
    return res.status(400).json({ success: false, mensaje: 'Ya has votado en esta encuesta' });
  }

  const opcion = encuesta.opciones.find(o => o.id === parseInt(opcionId));
  if (!opcion) {
    return res.status(404).json({ success: false, mensaje: 'Opción no encontrada' });
  }

  opcion.votos++;
  encuesta.votantes.push(usuario.id);
  guardarDatos();

  res.json({ success: true, encuesta });
});

// Cerrar encuesta (admin)
app.put('/api/encuestas/:id/cerrar', verificarAdmin, (req, res) => {
  const { id } = req.params;

  const encuesta = data.encuestas.find(e => e.id === parseInt(id));
  if (!encuesta) {
    return res.status(404).json({ success: false, mensaje: 'Encuesta no encontrada' });
  }

  encuesta.estado = 'cerrada';
  encuesta.fechaCierre = new Date().toISOString();
  guardarDatos();

  res.json({ success: true, encuesta });
});

// Eliminar encuesta (admin)
app.delete('/api/encuestas/:id', verificarAdmin, (req, res) => {
  const { id } = req.params;
  const index = data.encuestas.findIndex(e => e.id === parseInt(id));

  if (index === -1) {
    return res.status(404).json({ success: false, mensaje: 'Encuesta no encontrada' });
  }

  data.encuestas.splice(index, 1);
  guardarDatos();

  res.json({ success: true, mensaje: 'Encuesta eliminada' });
});

// ============= ENDPOINTS DE PAQUETES =============

// Obtener paquetes
app.get('/api/paquetes', (req, res) => {
  const token = req.headers.authorization?.replace('Bearer ', '');
  const usuario = obtenerUsuarioPorToken(token);

  if (!usuario) {
    return res.status(401).json({ success: false, mensaje: 'No autorizado' });
  }

  // Si es residente, solo ve sus paquetes
  if (usuario.rol === 'residente') {
    const paquetesUsuario = data.paquetes.filter(p => p.apartamento === usuario.apartamento);
    return res.json({ success: true, paquetes: paquetesUsuario });
  }

  // Admin y vigilante ven todos
  res.json({ success: true, paquetes: data.paquetes });
});

// Registrar paquete (vigilante)
app.post('/api/paquetes', verificarVigilante, (req, res) => {
  const token = req.headers.authorization?.replace('Bearer ', '');
  const usuario = obtenerUsuarioPorToken(token);

  const { apartamento, nombreResidente, empresa, descripcion, guia } = req.body;

  const nuevoPaquete = {
    id: data.paquetes.length + 1,
    apartamento,
    nombreResidente,
    empresa,
    descripcion,
    guia: guia || 'N/A',
    estado: 'Pendiente', // Pendiente, Entregado
    fechaRecepcion: new Date().toISOString(),
    fechaEntrega: null,
    recibidoPor: usuario.nombre,
    entregadoA: null
  };

  data.paquetes.push(nuevoPaquete);
  guardarDatos();

  res.json({ success: true, paquete: nuevoPaquete });
});

// Marcar paquete como entregado
app.put('/api/paquetes/:id/entregar', (req, res) => {
  const token = req.headers.authorization?.replace('Bearer ', '');
  const usuario = obtenerUsuarioPorToken(token);

  if (!usuario) {
    return res.status(401).json({ success: false, mensaje: 'No autorizado' });
  }

  const { id } = req.params;
  const paquete = data.paquetes.find(p => p.id === parseInt(id));

  if (!paquete) {
    return res.status(404).json({ success: false, mensaje: 'Paquete no encontrado' });
  }

  // Solo vigilante o el residente dueño puede marcar como entregado
  if (usuario.rol !== 'vigilante' && usuario.rol !== 'admin' && paquete.apartamento !== usuario.apartamento) {
    return res.status(403).json({ success: false, mensaje: 'No autorizado' });
  }

  paquete.estado = 'Entregado';
  paquete.fechaEntrega = new Date().toISOString();
  paquete.entregadoA = usuario.nombre;
  guardarDatos();

  res.json({ success: true, paquete });
});

// ============= ENDPOINTS DE ARRIENDOS =============

// Obtener arriendos
app.get('/api/residente/arriendos', (req, res) => {
  const apartamentos = data.arriendos.filter(a => a.tipo === 'apartamento');
  const parqueaderos = data.arriendos.filter(a => a.tipo === 'parqueadero');

  res.json({ success: true, apartamentos, parqueaderos });
});

// Publicar arriendo
app.post('/api/residente/publicar-arriendo', (req, res) => {
  const token = req.headers.authorization?.replace('Bearer ', '');
  const usuario = obtenerUsuarioPorToken(token);

  if (!usuario) {
    return res.status(401).json({ success: false, mensaje: 'No autorizado' });
  }

  const arriendoData = req.body;

  const nuevoArriendo = {
    id: data.arriendos.length + 1,
    ...arriendoData,
    propietario: usuario.nombre,
    fechaPublicacion: new Date().toISOString().split('T')[0],
    disponible: true
  };

  data.arriendos.push(nuevoArriendo);
  guardarDatos();

  res.json({ success: true, arriendo: nuevoArriendo });
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

// Consultar parqueadero asignado (residente)
app.get('/api/residente/mi-parqueadero', (req, res) => {
  const token = req.headers.authorization?.replace('Bearer ', '');
  const usuario = obtenerUsuarioPorToken(token);

  if (!usuario) {
    return res.status(401).json({ success: false, mensaje: 'No autorizado' });
  }

  if (!data.ultimoSorteo) {
    return res.json({ success: true, asignado: false, mensaje: 'No se ha realizado sorteo aún' });
  }

  const asignacion = data.ultimoSorteo.resultados.find(r =>
    r.participante.includes(usuario.nombre) || r.participante.includes(usuario.apartamento)
  );

  if (asignacion) {
    res.json({
      success: true,
      asignado: true,
      parqueadero: asignacion.parqueadero,
      nivel: asignacion.nivel,
      fechaSorteo: data.ultimoSorteo.fecha
    });
  } else {
    res.json({
      success: true,
      asignado: false,
      mensaje: 'No participaste en el último sorteo'
    });
  }
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

// ================================
// NUEVOS ENDPOINTS MÓDULO ADMINISTRADOR
// ================================

// Middleware para verificar rol de vigilante
function verificarVigilante(req, res, next) {
  const token = req.headers.authorization?.replace('Bearer ', '');
  const usuario = obtenerUsuarioPorToken(token);

  if (!usuario || (usuario.rol !== 'vigilante' && usuario.rol !== 'admin')) {
    return res.status(403).json({
      success: false,
      mensaje: 'Acceso denegado. Solo vigilantes y administradores.'
    });
  }

  req.usuario = usuario;
  next();
}

// === NOTICIAS ===
app.post('/api/admin/noticias', verificarAdmin, (req, res) => {
  const { titulo, contenido, categoria, fechaEvento, horaEvento, lugar, prioridad } = req.body;

  const nuevaNoticia = {
    id: data.noticias.length + 1,
    titulo,
    contenido,
    categoria,
    fecha: new Date().toISOString().split('T')[0],
    fechaEvento,
    horaEvento,
    lugar,
    prioridad: prioridad || 'media',
    activa: true,
    creadaPor: req.usuario.email
  };

  data.noticias.push(nuevaNoticia);
  guardarDatos();

  res.json({ success: true, noticia: nuevaNoticia });
});

app.delete('/api/admin/noticias/:id', verificarAdmin, (req, res) => {
  const id = parseInt(req.params.id);
  const index = data.noticias.findIndex(n => n.id === id);

  if (index !== -1) {
    data.noticias[index].activa = false;
    guardarDatos();
    res.json({ success: true });
  } else {
    res.status(404).json({ success: false, mensaje: 'Noticia no encontrada' });
  }
});

// === PAGOS MASIVOS ===
app.post('/api/admin/pagos/cargar-masivo', verificarAdmin, (req, res) => {
  const { pagos } = req.body; // Array de pagos [{torre, apartamento, concepto, valor, mes, vencimiento}]

  const nuevos = [];
  pagos.forEach(pago => {
    const nuevo = {
      id: data.pagos.length + nuevos.length + 1,
      torre: pago.torre,
      apartamento: pago.apartamento,
      concepto: pago.concepto,
      valor: parseFloat(pago.valor),
      mes: pago.mes,
      estado: 'pendiente',
      vencimiento: pago.vencimiento,
      fechaCreacion: new Date().toISOString()
    };
    nuevos.push(nuevo);
  });

  data.pagos.push(...nuevos);
  guardarDatos();

  res.json({ success: true, cantidad: nuevos.length, pagos: nuevos });
});

app.get('/api/admin/pagos/reporte', verificarAdmin, (req, res) => {
  const { tipo, filtro } = req.query; // tipo: 'residente' o 'torre', filtro: valor específico

  let pagosFiltrados = data.pagos;

  if (tipo === 'torre' && filtro) {
    pagosFiltrados = data.pagos.filter(p => p.torre === filtro);
  } else if (tipo === 'apartamento' && filtro) {
    pagosFiltrados = data.pagos.filter(p => p.apartamento === filtro);
  }

  const total = pagosFiltrados.reduce((sum, p) => sum + p.valor, 0);
  const pagados = pagosFiltrados.filter(p => p.estado === 'pagado').reduce((sum, p) => sum + p.valor, 0);
  const pendientes = total - pagados;

  res.json({
    success: true,
    pagos: pagosFiltrados,
    resumen: { total, pagados, pendientes }
  });
});

// === RESERVAS ADMIN ===
app.delete('/api/admin/reservas/:id', verificarAdmin, (req, res) => {
  const id = parseInt(req.params.id);
  const index = data.reservas.findIndex(r => r.id === id);

  if (index !== -1) {
    data.reservas.splice(index, 1);
    guardarDatos();
    res.json({ success: true });
  } else {
    res.status(404).json({ success: false, mensaje: 'Reserva no encontrada' });
  }
});

app.put('/api/admin/reservas/:id', verificarAdmin, (req, res) => {
  const id = parseInt(req.params.id);
  const { espacio, fecha, hora, estado } = req.body;
  const index = data.reservas.findIndex(r => r.id === id);

  if (index !== -1) {
    data.reservas[index] = {
      ...data.reservas[index],
      espacio: espacio || data.reservas[index].espacio,
      fecha: fecha || data.reservas[index].fecha,
      hora: hora || data.reservas[index].hora,
      estado: estado || data.reservas[index].estado
    };
    guardarDatos();
    res.json({ success: true, reserva: data.reservas[index] });
  } else {
    res.status(404).json({ success: false, mensaje: 'Reserva no encontrada' });
  }
});

app.get('/api/admin/reservas/reporte', verificarAdmin, (req, res) => {
  const reportePorEspacio = {};

  data.reservas.forEach(r => {
    if (!reportePorEspacio[r.espacio]) {
      reportePorEspacio[r.espacio] = { cantidad: 0, reservas: [] };
    }
    reportePorEspacio[r.espacio].cantidad++;
    reportePorEspacio[r.espacio].reservas.push(r);
  });

  res.json({ success: true, reporte: reportePorEspacio });
});

// === USUARIOS ===
app.post('/api/admin/usuarios', verificarAdmin, (req, res) => {
  const { nombre, email, password, torre, apartamento, rol } = req.body;

  // Verificar si el email ya existe
  if (data.usuarios.find(u => u.email === email)) {
    return res.status(400).json({ success: false, mensaje: 'El email ya está registrado' });
  }

  const nuevoUsuario = {
    id: data.usuarios.length + 1,
    nombre,
    email,
    password,
    apartamento: `${torre} - Apto ${apartamento}`,
    rol: rol || 'residente',
    activo: true,
    fechaCreacion: new Date().toISOString()
  };

  data.usuarios.push(nuevoUsuario);

  // Si es residente, asignar parqueadero automáticamente
  if (rol === 'residente') {
    const parqueaderosDisponibles = data.parqueaderos.filter(p => p.disponible);
    if (parqueaderosDisponibles.length > 0) {
      const parqueadero = parqueaderosDisponibles[0];
      parqueadero.disponible = false;
      parqueadero.ocupadoPor = `${nuevoUsuario.nombre} - ${nuevoUsuario.apartamento}`;

      data.asignacionesParqueaderos.push({
        id: data.asignacionesParqueaderos.length + 1,
        usuarioId: nuevoUsuario.id,
        parqueaderoId: parqueadero.id,
        fechaAsignacion: new Date().toISOString()
      });
    }
  }

  guardarDatos();
  res.json({ success: true, usuario: nuevoUsuario });
});

app.get('/api/admin/usuarios/todos', verificarAdmin, (req, res) => {
  const usuariosSinPassword = data.usuarios.map(u => ({
    id: u.id,
    nombre: u.nombre,
    email: u.email,
    apartamento: u.apartamento,
    rol: u.rol,
    activo: u.activo
  }));

  res.json({ success: true, usuarios: usuariosSinPassword });
});

// === PERMISOS/SOLICITUDES ===
app.post('/api/residente/solicitudes', (req, res) => {
  const token = req.headers.authorization?.replace('Bearer ', '');
  const usuario = obtenerUsuarioPorToken(token);

  if (!usuario) {
    return res.status(401).json({ success: false, mensaje: 'No autorizado' });
  }

  const { tipo, descripcion, fecha, datos } = req.body;

  const nuevaSolicitud = {
    id: data.solicitudesPermisos.length + 1,
    tipo, // 'visitante', 'objeto', 'mudanza', 'trabajo'
    descripcion,
    fecha,
    datos,
    estado: 'pendiente',
    solicitadoPor: usuario.nombre,
    apartamento: usuario.apartamento,
    fechaSolicitud: new Date().toISOString()
  };

  data.solicitudesPermisos.push(nuevaSolicitud);
  guardarDatos();

  res.json({ success: true, solicitud: nuevaSolicitud });
});

app.get('/api/admin/solicitudes', verificarAdmin, (req, res) => {
  res.json({ success: true, solicitudes: data.solicitudesPermisos });
});

app.get('/api/vigilante/solicitudes', verificarVigilante, (req, res) => {
  res.json({ success: true, solicitudes: data.solicitudesPermisos });
});

app.put('/api/admin/solicitudes/:id', verificarAdmin, (req, res) => {
  const id = parseInt(req.params.id);
  const { estado, observaciones } = req.body; // estado: 'aprobado', 'rechazado'

  const solicitud = data.solicitudesPermisos.find(s => s.id === id);
  if (solicitud) {
    solicitud.estado = estado;
    solicitud.observaciones = observaciones;
    solicitud.procesadoPor = req.usuario.nombre;
    solicitud.fechaProceso = new Date().toISOString();

    guardarDatos();
    res.json({ success: true, solicitud });
  } else {
    res.status(404).json({ success: false, mensaje: 'Solicitud no encontrada' });
  }
});

app.put('/api/vigilante/solicitudes/:id', verificarVigilante, (req, res) => {
  const id = parseInt(req.params.id);
  const { estado, observaciones } = req.body;

  const solicitud = data.solicitudesPermisos.find(s => s.id === id);
  if (solicitud) {
    solicitud.estado = estado;
    solicitud.observaciones = observaciones;
    solicitud.procesadoPor = req.usuario.nombre;
    solicitud.fechaProceso = new Date().toISOString();

    guardarDatos();
    res.json({ success: true, solicitud });
  } else {
    res.status(404).json({ success: false, mensaje: 'Solicitud no encontrada' });
  }
});

// === CÁMARAS ===
app.get('/api/admin/camaras', verificarAdmin, (req, res) => {
  res.json({ success: true, camaras: data.camaras });
});

app.post('/api/admin/camaras', verificarAdmin, (req, res) => {
  const { nombre, ubicacion, url, tipo, visible_residentes } = req.body;

  const nuevaCamara = {
    id: data.camaras.length + 1,
    nombre,
    ubicacion,
    url,
    tipo: tipo || 'fija',
    visible_residentes: visible_residentes || false,
    activa: true
  };

  data.camaras.push(nuevaCamara);
  guardarDatos();

  res.json({ success: true, camara: nuevaCamara });
});

app.put('/api/admin/camaras/:id', verificarAdmin, (req, res) => {
  const id = parseInt(req.params.id);
  const camara = data.camaras.find(c => c.id === id);

  if (camara) {
    Object.assign(camara, req.body);
    guardarDatos();
    res.json({ success: true, camara });
  } else {
    res.status(404).json({ success: false, mensaje: 'Cámara no encontrada' });
  }
});

app.get('/api/residente/camaras', (req, res) => {
  const camarasVisibles = data.camaras.filter(c => c.visible_residentes && c.activa);
  res.json({ success: true, camaras: camarasVisibles });
});

app.get('/api/residente/mis-reservas', (req, res) => {
  const token = req.headers.authorization?.replace('Bearer ', '');
  const usuario = obtenerUsuarioPorToken(token);

  if (!usuario) {
    return res.status(401).json({ success: false, mensaje: 'No autorizado' });
  }

  const reservasUsuario = data.reservas.filter(r => r.usuario === usuario.nombre || r.usuarioId === usuario.id);
  res.json({ success: true, misReservas: reservasUsuario });
});

// === PQRS ===
app.put('/api/admin/pqrs/:id', verificarAdmin, (req, res) => {
  const id = parseInt(req.params.id);
  const { estado, respuesta } = req.body; // estado: 'En proceso', 'Resuelto', 'Rechazado'

  const pqr = data.pqrs.find(p => p.id === id);
  if (pqr) {
    pqr.estado = estado;
    pqr.respuesta = respuesta;
    pqr.respondidoPor = req.usuario.nombre;
    pqr.fechaRespuesta = new Date().toISOString();

    guardarDatos();
    res.json({ success: true, pqr });
  } else {
    res.status(404).json({ success: false, mensaje: 'PQRS no encontrada' });
  }
});

app.get('/api/admin/pqrs/todas', verificarAdmin, (req, res) => {
  res.json({ success: true, pqrs: data.pqrs });
});

// === ENCUESTAS ===
app.post('/api/admin/encuestas', verificarAdmin, (req, res) => {
  const { titulo, descripcion, tipo, opciones, fechaCierre } = req.body;
  // tipo: 'encuesta' o 'votacion'

  const nuevaEncuesta = {
    id: data.encuestas.length + 1,
    titulo,
    descripcion,
    tipo,
    opciones: opciones.map((op, i) => ({ id: i + 1, texto: op, votos: 0 })),
    fechaCreacion: new Date().toISOString(),
    fechaCierre,
    activa: true,
    votos: [],
    creadaPor: req.usuario.email
  };

  data.encuestas.push(nuevaEncuesta);
  guardarDatos();

  res.json({ success: true, encuesta: nuevaEncuesta });
});

app.get('/api/encuestas', (req, res) => {
  const encuestasActivas = data.encuestas.filter(e => e.activa);
  res.json({ success: true, encuestas: encuestasActivas });
});

app.post('/api/encuestas/:id/votar', (req, res) => {
  const id = parseInt(req.params.id);
  const { opcionId } = req.body;
  const token = req.headers.authorization?.replace('Bearer ', '');
  const usuario = obtenerUsuarioPorToken(token);

  if (!usuario) {
    return res.status(401).json({ success: false, mensaje: 'No autorizado' });
  }

  const encuesta = data.encuestas.find(e => e.id === id);
  if (!encuesta) {
    return res.status(404).json({ success: false, mensaje: 'Encuesta no encontrada' });
  }

  // Verificar si ya votó
  if (encuesta.votos.find(v => v.usuarioId === usuario.id)) {
    return res.status(400).json({ success: false, mensaje: 'Ya votaste en esta encuesta' });
  }

  // Registrar voto
  const opcion = encuesta.opciones.find(o => o.id === opcionId);
  if (opcion) {
    opcion.votos++;
    encuesta.votos.push({
      usuarioId: usuario.id,
      opcionId,
      fecha: new Date().toISOString()
    });

    guardarDatos();
    res.json({ success: true });
  } else {
    res.status(400).json({ success: false, mensaje: 'Opción no válida' });
  }
});

app.get('/api/admin/encuestas/:id/resultados', verificarAdmin, (req, res) => {
  const id = parseInt(req.params.id);
  const encuesta = data.encuestas.find(e => e.id === id);

  if (encuesta) {
    const totalVotos = encuesta.votos.length;
    const resultados = encuesta.opciones.map(op => ({
      ...op,
      porcentaje: totalVotos > 0 ? ((op.votos / totalVotos) * 100).toFixed(2) : 0
    }));

    res.json({
      success: true,
      encuesta: {
        ...encuesta,
        opciones: resultados,
        totalVotos
      }
    });
  } else {
    res.status(404).json({ success: false, mensaje: 'Encuesta no encontrada' });
  }
});

// === DOCUMENTOS ===
app.post('/api/admin/documentos', verificarAdmin, (req, res) => {
  const { titulo, tipo, descripcion, url, categoria } = req.body;
  // tipo: 'reglamento', 'acta', 'comunicado', 'otro'

  const nuevoDocumento = {
    id: data.documentos.length + 1,
    titulo,
    tipo,
    descripcion,
    url,
    categoria,
    fechaSubida: new Date().toISOString(),
    subidoPor: req.usuario.email,
    activo: true
  };

  data.documentos.push(nuevoDocumento);
  guardarDatos();

  res.json({ success: true, documento: nuevoDocumento });
});

app.get('/api/documentos', (req, res) => {
  const documentosActivos = data.documentos.filter(d => d.activo);
  res.json({ success: true, documentos: documentosActivos });
});

app.delete('/api/admin/documentos/:id', verificarAdmin, (req, res) => {
  const id = parseInt(req.params.id);
  const documento = data.documentos.find(d => d.id === id);

  if (documento) {
    documento.activo = false;
    guardarDatos();
    res.json({ success: true });
  } else {
    res.status(404).json({ success: false, mensaje: 'Documento no encontrado' });
  }
});

app.put('/api/admin/documentos/:id', verificarAdmin, (req, res) => {
  const id = parseInt(req.params.id);
  const documento = data.documentos.find(d => d.id === id);

  if (documento) {
    Object.assign(documento, req.body);
    documento.fechaActualizacion = new Date().toISOString();
    guardarDatos();
    res.json({ success: true, documento });
  } else {
    res.status(404).json({ success: false, mensaje: 'Documento no encontrado' });
  }
});

// === ESTADÍSTICAS ADMIN ===
app.get('/api/admin/estadisticas', verificarAdmin, (req, res) => {
  const totalResidentes = data.usuarios.filter(u => u.rol === 'residente' && u.activo).length;
  const ingresosMes = data.pagos
    .filter(p => p.estado === 'pagado')
    .reduce((sum, p) => sum + p.valor, 0);
  const vehiculosActivos = data.vehiculosVisitantes.filter(v => v.activo).length;
  const pqrsPendientes = data.pqrs.filter(p => p.estado === 'Pendiente').length;

  res.json({
    success: true,
    totalResidentes,
    ingresosMes,
    vehiculosActivos,
    pqrsPendientes
  });
});

// === CONTROL VEHÍCULOS MEJORADO ===
app.post('/api/vehiculos-visitantes/salida-calculada', verificarAdmin, (req, res) => {
  const { id } = req.body;
  const vehiculo = data.vehiculosVisitantes.find(v => v.id === id && v.activo);

  if (!vehiculo) {
    return res.status(404).json({ success: false, mensaje: 'Vehículo no encontrado' });
  }

  const fechaSalida = new Date();
  const fechaIngreso = new Date(vehiculo.fechaIngreso);
  const tiempoEstancia = fechaSalida - fechaIngreso;

  // Calcular días y horas
  const diasCompletos = Math.floor(tiempoEstancia / (1000 * 60 * 60 * 24));
  const horasRestantes = Math.ceil((tiempoEstancia % (1000 * 60 * 60 * 24)) / (1000 * 60 * 60));

  let totalCobrado = 0;
  let detalleCobro = '';

  if (diasCompletos > 0) {
    // Cobrar por días
    totalCobrado = diasCompletos * 12000;
    detalleCobro = `${diasCompletos} día(s) x $12,000`;

    if (horasRestantes > 2) {
      totalCobrado += (horasRestantes - 2) * 1000;
      detalleCobro += ` + ${horasRestantes - 2} hora(s) adicional(es) x $1,000`;
    }
  } else {
    // Solo horas
    const horasTotales = Math.ceil(tiempoEstancia / (1000 * 60 * 60));

    if (horasTotales <= 2) {
      totalCobrado = 0;
      detalleCobro = `${horasTotales} hora(s) - Gratis`;
    } else if (horasTotales <= 10) {
      const horasCobradas = horasTotales - 2;
      totalCobrado = horasCobradas * 1000;
      detalleCobro = `2 horas gratis + ${horasCobradas} hora(s) x $1,000`;
    } else {
      totalCobrado = 12000;
      detalleCobro = `Más de 10 horas - Tarifa plena $12,000`;
    }
  }

  vehiculo.fechaSalida = fechaSalida.toISOString();
  vehiculo.activo = false;
  vehiculo.totalCobrado = totalCobrado;
  vehiculo.detalleCobro = detalleCobro;
  vehiculo.diasCompletos = diasCompletos;
  vehiculo.horasTotales = diasCompletos * 24 + horasRestantes;

  // Liberar parqueadero
  if (vehiculo.parqueadero) {
    const parqueadero = data.parqueaderos.find(p => p.numero === vehiculo.parqueadero);
    if (parqueadero) {
      parqueadero.disponible = true;
      parqueadero.ocupadoPor = null;
    }
  }

  guardarDatos();

  res.json({
    success: true,
    vehiculo,
    resumen: {
      totalCobrado,
      detalleCobro,
      diasCompletos,
      horasTotales: diasCompletos * 24 + horasRestantes
    }
  });
});

app.get('/api/admin/vehiculos/reporte', verificarAdmin, (req, res) => {
  const { fechaInicio, fechaFin } = req.query;

  let vehiculos = data.vehiculosVisitantes;

  if (fechaInicio && fechaFin) {
    vehiculos = vehiculos.filter(v => {
      const fecha = new Date(v.fechaIngreso);
      return fecha >= new Date(fechaInicio) && fecha <= new Date(fechaFin);
    });
  }

  const totalRecaudado = vehiculos
    .filter(v => !v.activo && v.totalCobrado)
    .reduce((sum, v) => sum + v.totalCobrado, 0);

  res.json({
    success: true,
    vehiculos,
    totalRecaudado,
    totalVehiculos: vehiculos.length
  });
});

// ==================== ENDPOINTS PARA FLUTTER APP ====================

// Dashboard Residente - Noticias recientes
app.get('/api/noticias/recientes', (req, res) => {
  const limit = parseInt(req.query.limit) || 5;
  const noticiasRecientes = data.noticias
    .sort((a, b) => new Date(b.fecha) - new Date(a.fecha))
    .slice(0, limit);

  res.json(noticiasRecientes);
});

// Dashboard Residente - Próximas reservas del usuario
app.get('/api/reservas/proximas', (req, res) => {
  const token = req.headers.authorization?.split(' ')[1];
  const usuario = obtenerUsuarioPorToken(token);

  if (!usuario) {
    return res.status(401).json({ error: 'No autorizado' });
  }

  const ahora = new Date();
  const proximasReservas = data.reservas
    .filter(r => r.usuarioId === usuario.id && new Date(r.fecha) >= ahora)
    .sort((a, b) => new Date(a.fecha) - new Date(b.fecha))
    .slice(0, 5);

  res.json(proximasReservas);
});

// Dashboard Residente - Pagos pendientes
app.get('/api/pagos/pendientes', (req, res) => {
  const token = req.headers.authorization?.split(' ')[1];
  const usuario = obtenerUsuarioPorToken(token);

  if (!usuario) {
    return res.status(401).json({ error: 'No autorizado' });
  }

  const pagosPendientes = data.pagos.filter(p =>
    p.apartamento === usuario.apartamento &&
    p.torre === usuario.torre &&
    p.estado === 'pendiente'
  );

  res.json(pagosPendientes);
});

// Dashboard Residente - Estadísticas
app.get('/api/estadisticas/residente', (req, res) => {
  const token = req.headers.authorization?.split(' ')[1];
  const usuario = obtenerUsuarioPorToken(token);

  if (!usuario) {
    return res.status(401).json({ error: 'No autorizado' });
  }

  const misReservas = data.reservas.filter(r => r.usuarioId === usuario.id);
  const misPagos = data.pagos.filter(p =>
    p.apartamento === usuario.apartamento &&
    p.torre === usuario.torre
  );
  const misPQRS = data.pqrs.filter(p => p.usuarioId === usuario.id);
  const misPaquetes = data.paquetes.filter(p => p.apartamento === usuario.apartamento);

  res.json({
    totalReservas: misReservas.length,
    reservasActivas: misReservas.filter(r => new Date(r.fecha) >= new Date()).length,
    pagosPendientes: misPagos.filter(p => p.estado === 'pendiente').length,
    pagosRealizados: misPagos.filter(p => p.estado === 'pagado').length,
    pqrsAbiertas: misPQRS.filter(p => p.estado !== 'resuelto' && p.estado !== 'rechazado').length,
    paquetesPendientes: misPaquetes.filter(p => !p.recogido).length,
  });
});

// Vehículos por apartamento (para residentes)
app.get('/api/vehiculos-visitantes/por-apartamento/:apartamento', (req, res) => {
  const { apartamento } = req.params;
  const vehiculos = data.vehiculosVisitantes.filter(v =>
    v.apartamentoDestino === apartamento
  );

  res.json(vehiculos);
});

// Todos los vehículos activos (para vigilante/admin)
app.get('/api/vehiculos-visitantes/activos', (req, res) => {
  const vehiculosActivos = data.vehiculosVisitantes.filter(v => v.activo === true);
  res.json(vehiculosActivos);
});

// PQRS - Crear con adjuntos y comentarios
app.post('/api/pqrs/crear', (req, res) => {
  const token = req.headers.authorization?.split(' ')[1];
  const usuario = obtenerUsuarioPorToken(token);

  if (!usuario) {
    return res.status(401).json({ error: 'No autorizado' });
  }

  const { tipo, asunto, descripcion, adjuntos } = req.body;

  const nuevaPQRS = {
    id: data.pqrs.length + 1,
    tipo,
    asunto,
    descripcion,
    adjuntos: adjuntos || [],
    comentarios: [],
    estado: 'pendiente',
    usuarioId: usuario.id,
    nombreUsuario: usuario.nombre,
    apartamento: usuario.apartamento,
    torre: usuario.torre,
    fechaCreacion: new Date().toISOString(),
    fechaRespuesta: null,
    respuesta: null,
  };

  data.pqrs.push(nuevaPQRS);
  guardarDatos();

  res.json({ success: true, pqrs: nuevaPQRS });
});

// PQRS - Mis solicitudes
app.get('/api/pqrs/mis-solicitudes', (req, res) => {
  const token = req.headers.authorization?.split(' ')[1];
  const usuario = obtenerUsuarioPorToken(token);

  if (!usuario) {
    return res.status(401).json({ error: 'No autorizado' });
  }

  const misPQRS = data.pqrs.filter(p => p.usuarioId === usuario.id);
  res.json(misPQRS);
});

// PQRS - Actualizar estado (admin)
app.put('/api/pqrs/:id/estado', verificarAdmin, (req, res) => {
  const { id } = req.params;
  const { estado, respuesta } = req.body;

  const pqrs = data.pqrs.find(p => p.id === parseInt(id));
  if (!pqrs) {
    return res.status(404).json({ error: 'PQRS no encontrada' });
  }

  pqrs.estado = estado;
  if (respuesta) {
    pqrs.respuesta = respuesta;
    pqrs.fechaRespuesta = new Date().toISOString();
  }

  guardarDatos();
  res.json({ success: true, pqrs });
});

// PQRS - Agregar comentario
app.post('/api/pqrs/:id/comentario', (req, res) => {
  const token = req.headers.authorization?.split(' ')[1];
  const usuario = obtenerUsuarioPorToken(token);

  if (!usuario) {
    return res.status(401).json({ error: 'No autorizado' });
  }

  const { id } = req.params;
  const { comentario } = req.body;

  const pqrs = data.pqrs.find(p => p.id === parseInt(id));
  if (!pqrs) {
    return res.status(404).json({ error: 'PQRS no encontrada' });
  }

  if (!pqrs.comentarios) {
    pqrs.comentarios = [];
  }

  const nuevoComentario = {
    id: pqrs.comentarios.length + 1,
    usuarioId: usuario.id,
    nombreUsuario: usuario.nombre,
    comentario,
    fecha: new Date().toISOString(),
    esOficial: usuario.rol === 'admin',
  };

  pqrs.comentarios.push(nuevoComentario);
  guardarDatos();

  res.json({ success: true, comentario: nuevoComentario });
});

// Encuestas - Activas
app.get('/api/encuestas/activas', (req, res) => {
  const ahora = new Date();
  const encuestasActivas = data.encuestas.filter(e => {
    const inicio = new Date(e.fechaInicio);
    const fin = new Date(e.fechaFin);
    return inicio <= ahora && fin >= ahora && e.activa;
  });

  res.json(encuestasActivas);
});

// Encuestas - Crear (admin)
app.post('/api/encuestas/crear', verificarAdmin, (req, res) => {
  const { titulo, descripcion, opciones, fechaInicio, fechaFin } = req.body;

  const nuevaEncuesta = {
    id: data.encuestas.length + 1,
    titulo,
    descripcion,
    opciones: opciones.map((op, index) => ({
      id: index + 1,
      texto: op,
      votos: 0,
    })),
    votantes: [],
    fechaInicio: fechaInicio || new Date().toISOString(),
    fechaFin,
    activa: true,
    fechaCreacion: new Date().toISOString(),
  };

  data.encuestas.push(nuevaEncuesta);
  guardarDatos();

  res.json({ success: true, encuesta: nuevaEncuesta });
});

// Encuestas - Votar
app.post('/api/encuestas/:id/votar', (req, res) => {
  const token = req.headers.authorization?.split(' ')[1];
  const usuario = obtenerUsuarioPorToken(token);

  if (!usuario) {
    return res.status(401).json({ error: 'No autorizado' });
  }

  const { id } = req.params;
  const { opcionId } = req.body;

  const encuesta = data.encuestas.find(e => e.id === parseInt(id));
  if (!encuesta) {
    return res.status(404).json({ error: 'Encuesta no encontrada' });
  }

  // Verificar si ya votó
  if (encuesta.votantes && encuesta.votantes.includes(usuario.id)) {
    return res.status(400).json({ error: 'Ya has votado en esta encuesta' });
  }

  // Registrar voto
  const opcion = encuesta.opciones.find(o => o.id === opcionId);
  if (!opcion) {
    return res.status(404).json({ error: 'Opción no encontrada' });
  }

  opcion.votos += 1;

  if (!encuesta.votantes) {
    encuesta.votantes = [];
  }
  encuesta.votantes.push(usuario.id);

  guardarDatos();
  res.json({ success: true, encuesta });
});

// Encuestas - Cerrar (admin)
app.post('/api/encuestas/:id/cerrar', verificarAdmin, (req, res) => {
  const { id } = req.params;

  const encuesta = data.encuestas.find(e => e.id === parseInt(id));
  if (!encuesta) {
    return res.status(404).json({ error: 'Encuesta no encontrada' });
  }

  encuesta.activa = false;
  encuesta.fechaCierre = new Date().toISOString();

  guardarDatos();
  res.json({ success: true, encuesta });
});

// Encuestas - Resultados
app.get('/api/encuestas/:id/resultados', (req, res) => {
  const { id } = req.params;

  const encuesta = data.encuestas.find(e => e.id === parseInt(id));
  if (!encuesta) {
    return res.status(404).json({ error: 'Encuesta no encontrada' });
  }

  const totalVotos = encuesta.opciones.reduce((sum, op) => sum + op.votos, 0);

  const resultados = {
    ...encuesta,
    totalVotos,
    porcentajes: encuesta.opciones.map(op => ({
      ...op,
      porcentaje: totalVotos > 0 ? ((op.votos / totalVotos) * 100).toFixed(1) : 0,
    })),
  };

  res.json(resultados);
});

// Reseñas - Por emprendimiento
app.get('/api/emprendimientos/:id/resenas', (req, res) => {
  const { id } = req.params;
  const resenas = data.resenas ? data.resenas.filter(r => r.emprendimientoId === parseInt(id)) : [];
  res.json(resenas);
});

// Reseñas - Crear
app.post('/api/emprendimientos/:id/resena', (req, res) => {
  const token = req.headers.authorization?.split(' ')[1];
  const usuario = obtenerUsuarioPorToken(token);

  if (!usuario) {
    return res.status(401).json({ error: 'No autorizado' });
  }

  const { id } = req.params;
  const { calificacion, comentario } = req.body;

  if (!data.resenas) {
    data.resenas = [];
  }

  // Verificar si ya dejó reseña
  const yaReseno = data.resenas.find(r =>
    r.emprendimientoId === parseInt(id) && r.usuarioId === usuario.id
  );

  if (yaReseno) {
    return res.status(400).json({ error: 'Ya has dejado una reseña para este emprendimiento' });
  }

  const nuevaResena = {
    id: data.resenas.length + 1,
    emprendimientoId: parseInt(id),
    usuarioId: usuario.id,
    nombreUsuario: usuario.nombre,
    calificacion,
    comentario: comentario || '',
    fecha: new Date().toISOString(),
  };

  data.resenas.push(nuevaResena);

  // Actualizar calificación promedio del emprendimiento
  const emprendimiento = data.emprendimientos.find(e => e.id === parseInt(id));
  if (emprendimiento) {
    const resenasEmprendimiento = data.resenas.filter(r => r.emprendimientoId === parseInt(id));
    const promedioCalificacion = resenasEmprendimiento.reduce((sum, r) => sum + r.calificacion, 0) / resenasEmprendimiento.length;
    emprendimiento.calificacion = parseFloat(promedioCalificacion.toFixed(1));
    emprendimiento.numResenas = resenasEmprendimiento.length;
  }

  guardarDatos();
  res.json({ success: true, resena: nuevaResena });
});

// Reservas - Disponibilidad por fecha
app.get('/api/reservas/disponibilidad/:fecha', (req, res) => {
  const { fecha } = req.params;
  const reservasDelDia = data.reservas.filter(r => {
    const fechaReserva = new Date(r.fecha).toISOString().split('T')[0];
    return fechaReserva === fecha;
  });

  res.json({
    fecha,
    reservas: reservasDelDia,
    espaciosOcupados: [...new Set(reservasDelDia.map(r => r.espacio))],
  });
});

// Reservas - Cancelar
app.put('/api/reservas/:id/cancelar', (req, res) => {
  const token = req.headers.authorization?.split(' ')[1];
  const usuario = obtenerUsuarioPorToken(token);

  if (!usuario) {
    return res.status(401).json({ error: 'No autorizado' });
  }

  const { id } = req.params;
  const reserva = data.reservas.find(r => r.id === parseInt(id));

  if (!reserva) {
    return res.status(404).json({ error: 'Reserva no encontrada' });
  }

  // Verificar que sea su reserva
  if (reserva.usuarioId !== usuario.id && usuario.rol !== 'admin') {
    return res.status(403).json({ error: 'No autorizado para cancelar esta reserva' });
  }

  reserva.estado = 'cancelada';
  reserva.fechaCancelacion = new Date().toISOString();

  guardarDatos();
  res.json({ success: true, reserva });
});

// Estadísticas Admin
app.get('/api/admin/estadisticas', verificarAdmin, (req, res) => {
  const totalResidentes = data.usuarios.filter(u => u.rol === 'residente').length;
  const reservasActivas = data.reservas.filter(r => new Date(r.fecha) >= new Date()).length;
  const vehiculosActivos = data.vehiculosVisitantes.filter(v => v.activo).length;
  const pqrsAbiertas = data.pqrs.filter(p => p.estado !== 'resuelto' && p.estado !== 'rechazado').length;

  const pagosPendientes = data.pagos.filter(p => p.estado === 'pendiente');
  const totalPendiente = pagosPendientes.reduce((sum, p) => sum + (p.valorAdministracion || 0) + (p.valorParqueadero || 0), 0);
  const pagosRealizados = data.pagos.filter(p => p.estado === 'pagado');
  const totalRecaudado = pagosRealizados.reduce((sum, p) => sum + (p.valorAdministracion || 0) + (p.valorParqueadero || 0), 0);

  const morosidad = totalPendiente / (totalPendiente + totalRecaudado) * 100;

  res.json({
    totalResidentes,
    reservasActivas,
    vehiculosActivos,
    pqrsAbiertas,
    pagosPendientes: pagosPendientes.length,
    totalPendiente,
    totalRecaudado,
    morosidad: morosidad.toFixed(1),
  });
});

// Estadísticas Admin - Pagos mensuales
app.get('/api/admin/estadisticas/pagos', verificarAdmin, (req, res) => {
  const pagosPorMes = {};

  data.pagos.filter(p => p.estado === 'pagado').forEach(pago => {
    const mes = `${pago.mes} ${pago.año}`;
    if (!pagosPorMes[mes]) {
      pagosPorMes[mes] = 0;
    }
    pagosPorMes[mes] += (pago.valorAdministracion || 0) + (pago.valorParqueadero || 0);
  });

  res.json(pagosPorMes);
});

// Estadísticas Admin - Ocupación de áreas
app.get('/api/admin/estadisticas/reservas', verificarAdmin, (req, res) => {
  const reservasPorEspacio = {};

  data.reservas.forEach(reserva => {
    const espacio = reserva.espacio;
    if (!reservasPorEspacio[espacio]) {
      reservasPorEspacio[espacio] = 0;
    }
    reservasPorEspacio[espacio]++;
  });

  res.json(reservasPorEspacio);
});

// ========== SORTEO DE PARQUEADEROS ==========

// Obtener último sorteo realizado
app.get('/api/admin/sorteo-parqueaderos/ultimo', verificarAdmin, (req, res) => {
  const sorteos = data.sorteoParqueaderos || [];
  if (sorteos.length === 0) {
    return res.status(404).json({ error: 'No hay sorteos previos' });
  }
  const ultimo = sorteos[sorteos.length - 1];
  res.json(ultimo);
});

// Obtener residentes activos para sorteo
app.get('/api/admin/residentes/activos', verificarAdmin, (req, res) => {
  const activos = data.usuarios.filter(u => u.rol === 'residente' && u.activo !== false);
  res.json(activos);
});

// Guardar resultado de sorteo
app.post('/api/admin/sorteo-parqueaderos', verificarAdmin, (req, res) => {
  const { asignaciones, fecha } = req.body;

  if (!asignaciones || !Array.isArray(asignaciones)) {
    return res.status(400).json({ error: 'Asignaciones inválidas' });
  }

  const nuevoSorteo = {
    id: (data.sorteoParqueaderos || []).length + 1,
    fecha: fecha || new Date().toISOString(),
    asignaciones,
  };

  if (!data.sorteoParqueaderos) {
    data.sorteoParqueaderos = [];
  }

  data.sorteoParqueaderos.push(nuevoSorteo);

  // Actualizar campo parqueadero de cada residente
  asignaciones.forEach(asignacion => {
    const usuario = data.usuarios.find(u => u.id === asignacion.usuarioId);
    if (usuario) {
      usuario.parqueadero = asignacion.numeroParqueadero;
    }
  });

  guardarDatos();
  res.json({ success: true, sorteo: nuevoSorteo });
});

// ==================== FIN ENDPOINTS FLUTTER ====================

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