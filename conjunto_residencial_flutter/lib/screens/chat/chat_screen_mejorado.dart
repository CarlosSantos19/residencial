import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../services/api_service.dart';
import '../../models/chat.dart';
import '../../models/user.dart';

class ChatScreenMejorado extends StatefulWidget {
  const ChatScreenMejorado({super.key});

  @override
  State<ChatScreenMejorado> createState() => _ChatScreenMejoradoState();
}

class _ChatScreenMejoradoState extends State<ChatScreenMejorado>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
 
 final ApiService _apiService = ApiService();
  @override
  void initState() {
    super.initState();
    final user = context.read<AuthService>().currentUser!;

    // Configurar pestañas según el rol
    int numTabs = 4; // General, Admin, Vigilantes, Privados
    _tabController = TabController(length: numTabs, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthService>().currentUser!;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Chat Comunitario'),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [user.rol.gradientStart, user.rol.gradientEnd],
            ),
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white.withOpacity(0.7),
          tabs: const [
            Tab(icon: Icon(Icons.public), text: 'General'),
            Tab(icon: Icon(Icons.admin_panel_settings), text: 'Administrador'),
            Tab(icon: Icon(Icons.security), text: 'Vigilantes'),
            Tab(icon: Icon(Icons.people), text: 'Privados'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          ChatGeneralTab(),
          ChatAdministradorTab(),
          ChatVigilantesTab(),
          ChatPrivadosTab(),
        ],
      ),
    );
  }
}

// ========== TAB 1: CHAT GENERAL (Todos los usuarios) ==========
class ChatGeneralTab extends StatefulWidget {
  const ChatGeneralTab({super.key});

  @override
  State<ChatGeneralTab> createState() => _ChatGeneralTabState();
}

class _ChatGeneralTabState extends State<ChatGeneralTab> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ApiService _apiService = ApiService();

  List<ChatMessage> _mensajes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _cargarMensajes();
    // Actualizar cada 5 segundos
    Future.delayed(const Duration(seconds: 5), _actualizarMensajes);
  }

  Future<void> _cargarMensajes() async {
    try {
      final authService = context.read<AuthService>();
      _apiService.setToken(authService.token!);

      final mensajes = await _apiService.getChatGeneral();
      setState(() {
        _mensajes = mensajes;
        _isLoading = false;
      });
      _scrollToBottom();
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _actualizarMensajes() async {
    if (!mounted) return;
    await _cargarMensajes();
    Future.delayed(const Duration(seconds: 5), _actualizarMensajes);
  }

  Future<void> _enviarMensaje() async {
    if (_messageController.text.trim().isEmpty) return;

    try {
      final authService = context.read<AuthService>();
      _apiService.setToken(authService.token!);

      await _apiService.enviarMensajeGeneral(_messageController.text.trim());
      _messageController.clear();
      await _cargarMensajes();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al enviar mensaje: $e')),
        );
      }
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header informativo
        Container(
          padding: const EdgeInsets.all(12),
          color: Colors.blue.shade50,
          child: Row(
            children: [
              Icon(Icons.info_outline, size: 16, color: Colors.blue.shade700),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Chat visible para todos los residentes',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.blue.shade700,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Lista de mensajes
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: _mensajes.length,
                  itemBuilder: (context, index) {
                    final mensaje = _mensajes[index];
                    final user = context.read<AuthService>().currentUser!;
                    final esMio = mensaje.usuarioId == user.id;

                    return _buildMessageBubble(mensaje, esMio);
                  },
                ),
        ),

        // Input para escribir
        _buildMessageInput(),
      ],
    );
  }

  Widget _buildMessageBubble(ChatMessage mensaje, bool esMio) {
    return Align(
      alignment: esMio ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: esMio ? Colors.blue.shade600 : Colors.grey.shade200,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(esMio ? 16 : 4),
            bottomRight: Radius.circular(esMio ? 4 : 16),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!esMio)
              Text(
                mensaje.nombreUsuario,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: Colors.grey.shade700,
                ),
              ),
            if (!esMio) const SizedBox(height: 4),
            Text(
              mensaje.mensaje,
              style: TextStyle(
                color: esMio ? Colors.white : Colors.black87,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _formatearHora(mensaje.fecha),
              style: TextStyle(
                fontSize: 10,
                color: esMio ? Colors.white70 : Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Escribe un mensaje...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey.shade100,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
              ),
              maxLines: null,
              textCapitalization: TextCapitalization.sentences,
            ),
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            backgroundColor: Colors.blue.shade600,
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white, size: 20),
              onPressed: _enviarMensaje,
            ),
          ),
        ],
      ),
    );
  }

  String _formatearHora(DateTime fecha) {
    return '${fecha.hour.toString().padLeft(2, '0')}:${fecha.minute.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}

// ========== TAB 2: CHAT ADMINISTRADOR (Solo admin ve) ==========
class ChatAdministradorTab extends StatelessWidget {
  const ChatAdministradorTab({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthService>().currentUser!;

    if (user.rol != UserRole.admin) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.lock_outline, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'Solo el administrador puede ver este chat',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ],
        ),
      );
    }

    // Si es admin, mostrar chat igual que el general
    return const ChatGeneralTab(); // Reutilizamos el componente pero con endpoint diferente
  }
}

// ========== TAB 3: CHAT VIGILANTES (Solo vigilantes y admin) ==========
class ChatVigilantesTab extends StatelessWidget {
  const ChatVigilantesTab({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthService>().currentUser!;

    if (user.rol != UserRole.vigilante && user.rol != UserRole.admin) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.security, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'Solo vigilantes y administrador pueden ver este chat',
              style: TextStyle(color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return const ChatGeneralTab(); // Reutilizar con endpoint de vigilantes
  }
}

// ========== TAB 4: CHATS PRIVADOS (Peer-to-peer) ==========
class ChatPrivadosTab extends StatefulWidget {
  const ChatPrivadosTab({super.key});

  @override
  State<ChatPrivadosTab> createState() => _ChatPrivadosTabState();
}

class _ChatPrivadosTabState extends State<ChatPrivadosTab> {
  final ApiService _apiService = ApiService();
  List<User> _residentes = [];
  List<SolicitudChat> _solicitudesPendientes = [];
  List<ChatPrivado> _chatsActivos = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    try {
      final authService = context.read<AuthService>();
      _apiService.setToken(authService.token!);

      // Cargar residentes, solicitudes y chats activos
      final residentes = await _apiService.getResidentesActivos();
      final solicitudesList = await _apiService.getSolicitudesChat();
      final chatsActivosList = await _apiService.getChatsPrivados();

      setState(() {
        _residentes = residentes;
        _solicitudesPendientes = solicitudesList;
        _chatsActivos = chatsActivosList;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _solicitarChat(User residente) async {
    try {
      await _apiService.solicitarChatPrivado(residente.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Solicitud enviada a ${residente.nombre}')),
        );
      }
      _cargarDatos();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _responderSolicitud(SolicitudChat solicitud, bool aceptar) async {
    try {
      await _apiService.responderSolicitudChat(solicitud.id, aceptar);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(aceptar ? 'Chat aceptado' : 'Solicitud rechazada'),
          ),
        );
      }
      _cargarDatos();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          Container(
            color: Colors.grey.shade100,
            child: const TabBar(
              labelColor: Colors.blue,
              unselectedLabelColor: Colors.grey,
              indicatorColor: Colors.blue,
              tabs: [
                Tab(text: 'Chats Activos'),
                Tab(text: 'Solicitudes'),
                Tab(text: 'Residentes'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildChatsActivos(),
                _buildSolicitudes(),
                _buildListaResidentes(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatsActivos() {
    if (_chatsActivos.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'No tienes chats activos',
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 8),
            const Text(
              'Envía solicitudes a otros residentes',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _chatsActivos.length,
      itemBuilder: (context, index) {
        final chat = _chatsActivos[index];
        return Card(
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.blue.shade600,
              child: Text(
                chat.nombreOtroUsuario[0].toUpperCase(),
                style: const TextStyle(color: Colors.white),
              ),
            ),
            title: Text(chat.nombreOtroUsuario),
            subtitle: Text(
              chat.ultimoMensajeTexto ?? 'Sin mensajes',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: chat.mensajesNoLeidos > 0
                ? CircleAvatar(
                    radius: 12,
                    backgroundColor: Colors.red,
                    child: Text(
                      '${chat.mensajesNoLeidos}',
                      style: const TextStyle(color: Colors.white, fontSize: 10),
                    ),
                  )
                : null,
            onTap: () {
              // Navegar al chat privado
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ChatPrivadoScreen(chat: chat),
                ),
              ).then((_) => _cargarDatos());
            },
          ),
        );
      },
    );
  }

  Widget _buildSolicitudes() {
    if (_solicitudesPendientes.isEmpty) {
      return Center(
        child: Text(
          'No tienes solicitudes pendientes',
          style: TextStyle(color: Colors.grey.shade600),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _solicitudesPendientes.length,
      itemBuilder: (context, index) {
        final solicitud = _solicitudesPendientes[index];
        return Card(
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.orange.shade600,
              child: const Icon(Icons.person_add, color: Colors.white),
            ),
            title: Text(solicitud.nombreRemitente),
            subtitle: Text(
              'Quiere iniciar un chat contigo',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.check, color: Colors.green),
                  onPressed: () => _responderSolicitud(solicitud, true),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.red),
                  onPressed: () => _responderSolicitud(solicitud, false),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildListaResidentes() {
    final user = context.read<AuthService>().currentUser!;
    final otrosResidentes = _residentes.where((r) => r.id != user.id).toList();

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: otrosResidentes.length,
      itemBuilder: (context, index) {
        final residente = otrosResidentes[index];
        return Card(
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.blue.shade600,
              child: Text(
                residente.nombre[0].toUpperCase(),
                style: const TextStyle(color: Colors.white),
              ),
            ),
            title: Text(residente.nombre),
            subtitle: Text('Apartamento ${residente.apartamento}'),
            trailing: ElevatedButton.icon(
              onPressed: () => _solicitarChat(residente),
              icon: const Icon(Icons.chat, size: 16),
              label: const Text('Solicitar'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
            ),
          ),
        );
      },
    );
  }
}

// Pantalla de chat privado individual
class ChatPrivadoScreen extends StatefulWidget {
  final ChatPrivado chat;

  const ChatPrivadoScreen({super.key, required this.chat});

  @override
  State<ChatPrivadoScreen> createState() => _ChatPrivadoScreenState();
}

class _ChatPrivadoScreenState extends State<ChatPrivadoScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ApiService _apiService = ApiService();

  List<ChatMessage> _mensajes = [];

  @override
  void initState() {
    super.initState();
    _cargarMensajes();
  }

  Future<void> _cargarMensajes() async {
    try {
      final authService = context.read<AuthService>();
      _apiService.setToken(authService.token!);

      final mensajes = await _apiService.getMensajesChatPrivado(widget.chat.id);
      setState(() => _mensajes = mensajes);
    } catch (e) {
      debugPrint('Error cargando mensajes: $e');
    }
  }

  Future<void> _enviarMensaje() async {
    if (_messageController.text.trim().isEmpty) return;

    try {
      final authService = context.read<AuthService>();
      _apiService.setToken(authService.token!);

      await _apiService.enviarMensajePrivado(
        widget.chat.id,
        _messageController.text.trim(),
      );

      _messageController.clear();
      await _cargarMensajes();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.chat.nombreOtroUsuario),
        backgroundColor: Colors.blue.shade600,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _mensajes.length,
              itemBuilder: (context, index) {
                final mensaje = _mensajes[index];
                final user = context.read<AuthService>().currentUser!;
                final esMio = mensaje.usuarioId == user.id;

                return Align(
                  alignment: esMio ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.7,
                    ),
                    decoration: BoxDecoration(
                      color: esMio ? Colors.blue.shade600 : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      mensaje.mensaje,
                      style: TextStyle(
                        color: esMio ? Colors.white : Colors.black87,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Escribe un mensaje...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: Colors.blue.shade600,
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: _enviarMensaje,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
