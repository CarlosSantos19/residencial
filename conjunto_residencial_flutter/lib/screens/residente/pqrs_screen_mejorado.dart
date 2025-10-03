import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../services/auth_service.dart';
import '../../services/api_service.dart';
import '../../models/pqrs.dart';
import '../../models/user.dart';

/// Pantalla PQRS Mejorada - Residente
///
/// Funcionalidades:
/// - Ver mis PQRS con estados
/// - Crear nueva PQRS con adjuntos (cámara/galería)
/// - Ver detalle con seguimiento completo
/// - Agregar comentarios adicionales
/// - Estados visuales: Pendiente, En proceso, Resuelto, Rechazado
///
/// Color: Azul (Residente)

class PQRSScreenMejorado extends StatefulWidget {
  const PQRSScreenMejorado({Key? key}) : super(key: key);

  @override
  State<PQRSScreenMejorado> createState() => _PQRSScreenMejoradoState();
}

class _PQRSScreenMejoradoState extends State<PQRSScreenMejorado> {
  final ApiService _apiService = ApiService();
  final ImagePicker _picker = ImagePicker();

  List<PQRS> _misPQRS = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _cargarMisPQRS();
  }

  Future<void> _cargarMisPQRS() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final pqrs = await _apiService.getMisPQRS();
      setState(() {
        _misPQRS = pqrs;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Error al cargar PQRS: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final user = authService.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Usuario no autenticado')),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Mis PQRS'),
        backgroundColor: const Color(0xFF2563EB),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: _cargarMisPQRS,
        color: const Color(0xFF2563EB),
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2563EB)),
                ),
              )
            : _error != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 64, color: Colors.red),
                        const SizedBox(height: 16),
                        Text(_error!, textAlign: TextAlign.center),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _cargarMisPQRS,
                          child: const Text('Reintentar'),
                        ),
                      ],
                    ),
                  )
                : _misPQRS.isEmpty
                    ? _buildEmptyState()
                    : _buildPQRSList(),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _mostrarFormularioCrear(context, user),
        backgroundColor: const Color(0xFF2563EB),
        icon: const Icon(Icons.add),
        label: const Text('Nueva PQRS'),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.support_agent, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No tienes PQRS registradas',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Crea una nueva para reportar cualquier\npetición, queja, reclamo o sugerencia',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildPQRSList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _misPQRS.length,
      itemBuilder: (context, index) {
        final pqrs = _misPQRS[index];
        return _buildPQRSCard(pqrs);
      },
    );
  }

  Widget _buildPQRSCard(PQRS pqrs) {
    final estadoConfig = _getEstadoConfig(pqrs.estado);
    final tipoIcon = _getTipoIcon(pqrs.tipo);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: InkWell(
        onTap: () => _mostrarDetallePQRS(pqrs),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(tipoIcon, color: const Color(0xFF2563EB), size: 24),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      pqrs.asunto,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                pqrs.descripcion,
                style: TextStyle(color: Colors.grey[700]),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: estadoConfig['color'].withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: estadoConfig['color'],
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          estadoConfig['icon'],
                          size: 14,
                          color: estadoConfig['color'],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          pqrs.estado,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: estadoConfig['color'],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      pqrs.tipo,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    pqrs.fecha,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              if (pqrs.comentarios != null && pqrs.comentarios!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Row(
                    children: [
                      Icon(Icons.comment, size: 14, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        '${pqrs.comentarios!.length} ${pqrs.comentarios!.length == 1 ? "comentario" : "comentarios"}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Map<String, dynamic> _getEstadoConfig(String estado) {
    switch (estado.toLowerCase()) {
      case 'pendiente':
        return {
          'color': Colors.orange,
          'icon': Icons.schedule,
        };
      case 'en proceso':
        return {
          'color': Colors.blue,
          'icon': Icons.sync,
        };
      case 'resuelto':
        return {
          'color': Colors.green,
          'icon': Icons.check_circle,
        };
      case 'rechazado':
        return {
          'color': Colors.red,
          'icon': Icons.cancel,
        };
      default:
        return {
          'color': Colors.grey,
          'icon': Icons.help,
        };
    }
  }

  IconData _getTipoIcon(String tipo) {
    switch (tipo.toLowerCase()) {
      case 'petición':
        return Icons.request_page;
      case 'queja':
        return Icons.report_problem;
      case 'reclamo':
        return Icons.warning;
      case 'sugerencia':
        return Icons.lightbulb;
      default:
        return Icons.support_agent;
    }
  }

  void _mostrarDetallePQRS(PQRS pqrs) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _DetallePQRSSheet(
        pqrs: pqrs,
        onComentarioAgregado: _cargarMisPQRS,
      ),
    );
  }

  void _mostrarFormularioCrear(BuildContext context, User user) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _FormularioCrearPQRS(
        onCreated: _cargarMisPQRS,
      ),
    );
  }
}

/// Sheet para ver detalle de PQRS con seguimiento
class _DetallePQRSSheet extends StatefulWidget {
  final PQRS pqrs;
  final VoidCallback onComentarioAgregado;

  const _DetallePQRSSheet({
    required this.pqrs,
    required this.onComentarioAgregado,
  });

  @override
  State<_DetallePQRSSheet> createState() => _DetallePQRSSheetState();
}

class _DetallePQRSSheetState extends State<_DetallePQRSSheet> {
  final ApiService _apiService = ApiService();
  final TextEditingController _comentarioController = TextEditingController();
  bool _enviandoComentario = false;

  @override
  void dispose() {
    _comentarioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final estadoConfig = _getEstadoConfig(widget.pqrs.estado);

    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      estadoConfig['color'],
                      estadoConfig['color'].withOpacity(0.8),
                    ],
                  ),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    Row(
                      children: [
                        Icon(
                          estadoConfig['icon'],
                          color: Colors.white,
                          size: 32,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.pqrs.asunto,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${widget.pqrs.tipo} - ${widget.pqrs.estado}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Contenido
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  children: [
                    _buildSeccion(
                      'Descripción',
                      widget.pqrs.descripcion,
                      Icons.description,
                    ),
                    const SizedBox(height: 20),
                    _buildSeccion(
                      'Fecha de creación',
                      widget.pqrs.fecha,
                      Icons.calendar_today,
                    ),
                    if (widget.pqrs.adjuntos != null &&
                        widget.pqrs.adjuntos!.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      _buildAdjuntos(),
                    ],
                    if (widget.pqrs.comentarios != null &&
                        widget.pqrs.comentarios!.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      _buildSeguimiento(),
                    ],
                    const SizedBox(height: 20),
                    _buildAgregarComentario(),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSeccion(String titulo, String contenido, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: const Color(0xFF2563EB)),
            const SizedBox(width: 8),
            Text(
              titulo,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2563EB),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          contenido,
          style: const TextStyle(fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildAdjuntos() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: const [
            Icon(Icons.attach_file, size: 20, color: Color(0xFF2563EB)),
            SizedBox(width: 8),
            Text(
              'Adjuntos',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2563EB),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: widget.pqrs.adjuntos!.length,
            itemBuilder: (context, index) {
              final adjunto = widget.pqrs.adjuntos![index];
              return Container(
                width: 100,
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                  image: DecorationImage(
                    image: NetworkImage(adjunto),
                    fit: BoxFit.cover,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSeguimiento() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: const [
            Icon(Icons.timeline, size: 20, color: Color(0xFF2563EB)),
            SizedBox(width: 8),
            Text(
              'Seguimiento',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2563EB),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...widget.pqrs.comentarios!.map((comentario) {
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: comentario.esRespuestaOficial
                  ? const Color(0xFF16A34A).withOpacity(0.1)
                  : Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
              border: comentario.esRespuestaOficial
                  ? Border.all(color: const Color(0xFF16A34A), width: 2)
                  : null,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      comentario.esRespuestaOficial
                          ? Icons.verified
                          : Icons.person,
                      size: 16,
                      color: comentario.esRespuestaOficial
                          ? const Color(0xFF16A34A)
                          : Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      comentario.autorNombre,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: comentario.esRespuestaOficial
                            ? const Color(0xFF16A34A)
                            : Colors.grey[800],
                      ),
                    ),
                    if (comentario.esRespuestaOficial) ...[
                      const SizedBox(width: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF16A34A),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text(
                          'Oficial',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                    const Spacer(),
                    Text(
                      _formatearFecha(comentario.fecha),
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  comentario.comentario,
                  style: const TextStyle(fontSize: 13),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildAgregarComentario() {
    // Solo permitir agregar comentarios si no está resuelto o rechazado
    if (widget.pqrs.estado.toLowerCase() == 'resuelto' ||
        widget.pqrs.estado.toLowerCase() == 'rechazado') {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Agregar comentario',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2563EB),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _comentarioController,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'Escribe información adicional...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF2563EB)),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _enviandoComentario ? null : _agregarComentario,
            icon: _enviandoComentario
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Icon(Icons.send),
            label: Text(_enviandoComentario ? 'Enviando...' : 'Enviar comentario'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2563EB),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _agregarComentario() async {
    if (_comentarioController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Escribe un comentario')),
      );
      return;
    }

    setState(() {
      _enviandoComentario = true;
    });

    try {
      await _apiService.agregarComentarioPQRS(
        widget.pqrs.id,
        _comentarioController.text.trim(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Comentario agregado'),
            backgroundColor: Colors.green,
          ),
        );
        _comentarioController.clear();
        widget.onComentarioAgregado();
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _enviandoComentario = false;
        });
      }
    }
  }

  Map<String, dynamic> _getEstadoConfig(String estado) {
    switch (estado.toLowerCase()) {
      case 'pendiente':
        return {'color': Colors.orange, 'icon': Icons.schedule};
      case 'en proceso':
        return {'color': Colors.blue, 'icon': Icons.sync};
      case 'resuelto':
        return {'color': Colors.green, 'icon': Icons.check_circle};
      case 'rechazado':
        return {'color': Colors.red, 'icon': Icons.cancel};
      default:
        return {'color': Colors.grey, 'icon': Icons.help};
    }
  }

  String _formatearFecha(DateTime fecha) {
    final ahora = DateTime.now();
    final diferencia = ahora.difference(fecha);

    if (diferencia.inMinutes < 60) {
      return 'Hace ${diferencia.inMinutes} min';
    } else if (diferencia.inHours < 24) {
      return 'Hace ${diferencia.inHours}h';
    } else if (diferencia.inDays < 7) {
      return 'Hace ${diferencia.inDays}d';
    } else {
      return '${fecha.day}/${fecha.month}/${fecha.year}';
    }
  }
}

/// Formulario para crear nueva PQRS
class _FormularioCrearPQRS extends StatefulWidget {
  final VoidCallback onCreated;

  const _FormularioCrearPQRS({required this.onCreated});

  @override
  State<_FormularioCrearPQRS> createState() => _FormularioCrearPQRSState();
}

class _FormularioCrearPQRSState extends State<_FormularioCrearPQRS> {
  final ApiService _apiService = ApiService();
  final ImagePicker _picker = ImagePicker();
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _asuntoController = TextEditingController();
  final TextEditingController _descripcionController = TextEditingController();

  String _tipoSeleccionado = 'Petición';
  final List<String> _tipos = ['Petición', 'Queja', 'Reclamo', 'Sugerencia'];

  List<File> _imagenesSeleccionadas = [];
  bool _enviando = false;

  @override
  void dispose() {
    _asuntoController.dispose();
    _descripcionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF2563EB), Color(0xFF1E40AF)],
                  ),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const Row(
                      children: [
                        Icon(Icons.add_circle, color: Colors.white, size: 32),
                        SizedBox(width: 12),
                        Text(
                          'Nueva PQRS',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Formulario
              Expanded(
                child: Form(
                  key: _formKey,
                  child: ListView(
                    controller: scrollController,
                    padding: const EdgeInsets.all(20),
                    children: [
                      // Tipo
                      const Text(
                        'Tipo',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2563EB),
                        ),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: _tipoSeleccionado,
                        items: _tipos.map((tipo) {
                          return DropdownMenuItem(
                            value: tipo,
                            child: Text(tipo),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _tipoSeleccionado = value!;
                          });
                        },
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: Color(0xFF2563EB),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Asunto
                      const Text(
                        'Asunto',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2563EB),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _asuntoController,
                        decoration: InputDecoration(
                          hintText: 'Título breve del asunto',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: Color(0xFF2563EB),
                            ),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'El asunto es obligatorio';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      // Descripción
                      const Text(
                        'Descripción',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2563EB),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _descripcionController,
                        maxLines: 5,
                        decoration: InputDecoration(
                          hintText: 'Describe detalladamente tu solicitud...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: Color(0xFF2563EB),
                            ),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'La descripción es obligatoria';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      // Adjuntos
                      const Text(
                        'Adjuntos (Opcional)',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2563EB),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => _seleccionarImagen(ImageSource.camera),
                              icon: const Icon(Icons.camera_alt),
                              label: const Text('Cámara'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFF2563EB),
                                side: const BorderSide(color: Color(0xFF2563EB)),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => _seleccionarImagen(ImageSource.gallery),
                              icon: const Icon(Icons.photo_library),
                              label: const Text('Galería'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFF2563EB),
                                side: const BorderSide(color: Color(0xFF2563EB)),
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (_imagenesSeleccionadas.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 100,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: _imagenesSeleccionadas.length,
                            itemBuilder: (context, index) {
                              return Stack(
                                children: [
                                  Container(
                                    width: 100,
                                    margin: const EdgeInsets.only(right: 8),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: Colors.grey[300]!),
                                      image: DecorationImage(
                                        image: FileImage(_imagenesSeleccionadas[index]),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    top: 4,
                                    right: 12,
                                    child: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _imagenesSeleccionadas.removeAt(index);
                                        });
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: const BoxDecoration(
                                          color: Colors.red,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.close,
                                          size: 16,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                      ],
                      const SizedBox(height: 24),
                      // Botón enviar
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _enviando ? null : _crearPQRS,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2563EB),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: _enviando
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              : const Text(
                                  'Enviar PQRS',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _seleccionarImagen(ImageSource source) async {
    final XFile? image = await _picker.pickImage(source: source);
    if (image != null) {
      setState(() {
        _imagenesSeleccionadas.add(File(image.path));
      });
    }
  }

  Future<void> _crearPQRS() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _enviando = true;
    });

    try {
      // En una implementación real, primero subirías las imágenes
      // y obtendrías las URLs
      final adjuntosUrls = _imagenesSeleccionadas.map((f) => f.path).toList();

      await _apiService.crearPQRS(
        tipo: _tipoSeleccionado,
        asunto: _asuntoController.text.trim(),
        descripcion: _descripcionController.text.trim(),
        adjuntos: adjuntosUrls,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('PQRS creada exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
        widget.onCreated();
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _enviando = false;
        });
      }
    }
  }
}
