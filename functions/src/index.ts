import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import * as express from 'express';
import * as cors from 'cors';

admin.initializeApp();

const app = express();

// Middleware
app.use(cors({ origin: true }));
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Datos en memoria (en Firebase Functions se podría usar Firestore)
let data: any = {};

// Función para obtener datos por defecto
function getDefaultData() {
  return {
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
        id: 8,
        email: 'car02cbs@gmail.com',
        password: 'password3',
        nombre: 'Vigilante del Conjunto',
        apartamento: 'Portería',
        activo: true,
        rol: 'vigilante'
      }
    ],
    residentes: [],
    reservas: [],
    pagos: [],
    mensajes: [],
    emprendimientos: [],
    pqrs: [],
    permisos: [],
    vehiculosVisitantes: [],
    apartamentosArriendo: [],
    parqueaderosArriendo: [],
    noticias: [],
    sorteoParqueaderos: []
  };
}

// Inicializar datos
data = getDefaultData();

// Función para verificar token
function verificarToken(req: express.Request, res: express.Response, next: express.NextFunction) {
  const token = req.headers.authorization?.replace('Bearer ', '');

  if (!token) {
    return res.status(401).json({ success: false, mensaje: 'Token requerido' });
  }

  try {
    const decoded = JSON.parse(Buffer.from(token, 'base64').toString());
    const usuario = data.usuarios.find((u: any) => u.id === decoded.id && u.email === decoded.email);

    if (!usuario) {
      return res.status(401).json({ success: false, mensaje: 'Token inválido' });
    }

    req.body.usuario = usuario;
    next();
  } catch (error) {
    return res.status(401).json({ success: false, mensaje: 'Token inválido' });
  }
}

// Rutas de autenticación
app.post('/auth/login', (req, res) => {
  const { email, password } = req.body;

  const usuario = data.usuarios.find((u: any) => u.email === email && u.password === password && u.activo);

  if (usuario) {
    const token = Buffer.from(JSON.stringify({ id: usuario.id, email: usuario.email })).toString('base64');
    res.json({
      success: true,
      mensaje: 'Login exitoso',
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
    res.status(400).json({ success: false, mensaje: 'Credenciales inválidas' });
  }
});

app.post('/auth/register', (req, res) => {
  const { email, password, nombre, apartamento } = req.body;

  const existeUsuario = data.usuarios.find((u: any) => u.email === email);
  if (existeUsuario) {
    return res.status(400).json({ success: false, mensaje: 'El usuario ya existe' });
  }

  const nuevoUsuario = {
    id: data.usuarios.length + 1,
    email,
    password,
    nombre,
    apartamento,
    activo: true,
    rol: 'residente'
  };

  data.usuarios.push(nuevoUsuario);

  const token = Buffer.from(JSON.stringify({ id: nuevoUsuario.id, email: nuevoUsuario.email })).toString('base64');
  res.json({
    success: true,
    mensaje: 'Usuario registrado exitosamente',
    token,
    usuario: {
      id: nuevoUsuario.id,
      email: nuevoUsuario.email,
      nombre: nuevoUsuario.nombre,
      apartamento: nuevoUsuario.apartamento,
      rol: nuevoUsuario.rol
    }
  });
});

app.get('/auth/verify', verificarToken, (req, res) => {
  res.json({ success: true, usuario: req.body.usuario });
});

// Rutas de reservas
app.get('/reservas', verificarToken, (req, res) => {
  res.json({ success: true, reservas: data.reservas });
});

app.post('/reservas', verificarToken, (req, res) => {
  const { espacio, fecha, hora } = req.body;
  const usuario = req.body.usuario;

  const nuevaReserva = {
    id: data.reservas.length + 1,
    usuarioId: usuario.id,
    usuarioNombre: usuario.nombre,
    espacio,
    fecha,
    hora,
    estado: 'activa',
    fechaCreacion: new Date().toISOString()
  };

  data.reservas.push(nuevaReserva);
  res.json({ success: true, mensaje: 'Reserva creada exitosamente', reserva: nuevaReserva });
});

// Rutas de pagos
app.get('/pagos', verificarToken, (req, res) => {
  const usuario = req.body.usuario;
  let pagos = data.pagos;

  if (usuario.rol === 'residente') {
    pagos = data.pagos.filter((p: any) => p.usuarioId === usuario.id);
  }

  res.json({ success: true, pagos });
});

// Rutas de mensajes (chat)
app.get('/mensajes', verificarToken, (req, res) => {
  res.json({ success: true, mensajes: data.mensajes });
});

app.post('/mensajes', verificarToken, (req, res) => {
  const { texto, tipo = 'general' } = req.body;
  const usuario = req.body.usuario;

  const nuevoMensaje = {
    id: data.mensajes.length + 1,
    usuarioId: usuario.id,
    usuarioNombre: usuario.nombre,
    texto,
    tipo,
    fechaHora: new Date().toISOString()
  };

  data.mensajes.push(nuevoMensaje);
  res.json({ success: true, mensaje: 'Mensaje enviado', mensaje_obj: nuevoMensaje });
});

// Más rutas se agregarán en la siguiente parte...

export const api = functions.https.onRequest(app);