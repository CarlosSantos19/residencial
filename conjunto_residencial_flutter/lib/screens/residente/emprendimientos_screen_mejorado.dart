import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../services/auth_service.dart';
import '../../services/api_service.dart';
import '../../models/emprendimiento.dart';
import '../../models/user.dart';

/// Pantalla de Emprendimientos Mejorada - Residente
///
/// Funcionalidades:
/// - Listado de emprendimientos con calificación visual (estrellas)
/// - Filtro por categoría
/// - Detalle con galería de imágenes (swiper)
/// - Llamada directa (tel:), WhatsApp (wa.me), Instagram
/// - Sistema de resenas: ver y crear (1-5 estrellas + comentario)
/// - Horario de atención
///
/// Color: Azul (Residente)

class EmprendimientosScreenMejorado extends StatefulWidget {
  const EmprendimientosScreenMejorado({Key? key}) : super(key: key);

  @override
  State<EmprendimientosScreenMejorado> createState() =>
      _EmprendimientosScreenMejoradoState();
}

class _EmprendimientosScreenMejoradoState
    extends State<EmprendimientosScreenMejorado> {
  final ApiService _apiService = ApiService();

  List<Emprendimiento> _emprendimientos = [];
  List<Emprendimiento> _emprendimientosFiltrados = [];
  List<String> _categorias = ['Todos'];
  String _categoriaSeleccionada = 'Todos';

  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _cargarEmprendimientos();
  }

  Future<void> _cargarEmprendimientos() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final emprendimientosList = await _apiService.getEmprendimientosList();

      // Extraer categorías únicas
      final categorias = emprendimientosList
          .map((e) => e.categoria)
          .toSet()
          .toList()
        ..sort();

      setState(() {
        _emprendimientos = emprendimientosList;
        _emprendimientosFiltrados = emprendimientosList;
        _categorias = ['Todos', ...categorias];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Error al cargar emprendimientos: $e';
        _isLoading = false;
      });
    }
  }

  void _filtrarPorCategoria(String categoria) {
    setState(() {
      _categoriaSeleccionada = categoria;
      if (categoria == 'Todos') {
        _emprendimientosFiltrados = _emprendimientos;
      } else {
        _emprendimientosFiltrados = _emprendimientos
            .where((e) => e.categoria == categoria)
            .toList();
      }
    });
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
        title: const Text('Emprendimientos'),
        backgroundColor: const Color(0xFF2563EB),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
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
                        onPressed: _cargarEmprendimientos,
                        child: const Text('Reintentar'),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    _buildFiltrosCategorias(),
                    Expanded(
                      child: _emprendimientosFiltrados.isEmpty
                          ? _buildEmptyState()
                          : _buildListaEmprendimientos(user),
                    ),
                  ],
                ),
    );
  }

  Widget _buildFiltrosCategorias() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SizedBox(
        height: 40,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: _categorias.length,
          itemBuilder: (context, index) {
            final categoria = _categorias[index];
            final isSelected = categoria == _categoriaSeleccionada;

            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(categoria),
                selected: isSelected,
                onSelected: (selected) {
                  if (selected) {
                    _filtrarPorCategoria(categoria);
                  }
                },
                selectedColor: const Color(0xFF2563EB),
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : Colors.grey[700],
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.storefront, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No hay emprendimientos en esta categoría',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListaEmprendimientos(User user) {
    return RefreshIndicator(
      onRefresh: _cargarEmprendimientos,
      color: const Color(0xFF2563EB),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _emprendimientosFiltrados.length,
        itemBuilder: (context, index) {
          final emprendimiento = _emprendimientosFiltrados[index];
          return _buildEmprendimientoCard(emprendimiento, user);
        },
      ),
    );
  }

  Widget _buildEmprendimientoCard(Emprendimiento emprendimiento, User user) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: InkWell(
        onTap: () => _mostrarDetalle(emprendimiento, user),
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen principal
            if (emprendimiento.imagenes != null &&
                emprendimiento.imagenes!.isNotEmpty)
              ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(16)),
                child: Image.network(
                  emprendimiento.imagenes!.first,
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return _buildImagenPlaceholder(180);
                  },
                ),
              )
            else
              _buildImagenPlaceholder(180),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          emprendimiento.nombreNegocio,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2563EB).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          emprendimiento.categoria,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF2563EB),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    emprendimiento.descripcion,
                    style: TextStyle(color: Colors.grey[700]),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _buildEstrellas(emprendimiento.calificacionPromedio),
                      const SizedBox(width: 8),
                      Text(
                        emprendimiento.calificacionPromedio.toStringAsFixed(1),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2563EB),
                        ),
                      ),
                      Text(
                        ' (${emprendimiento.totalResenas})',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                      const Spacer(),
                      Icon(Icons.person, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        emprendimiento.residenteNombre,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  if (emprendimiento.horarioAtencion != null) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.schedule, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          emprendimiento.horarioAtencion!,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 12),
                  _buildBotonesContacto(emprendimiento),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagenPlaceholder(double height) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Center(
        child: Icon(
          Icons.storefront,
          size: 64,
          color: Colors.grey[400],
        ),
      ),
    );
  }

  Widget _buildEstrellas(double calificacion) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        if (index < calificacion.floor()) {
          return const Icon(Icons.star, size: 18, color: Colors.amber);
        } else if (index < calificacion) {
          return const Icon(Icons.star_half, size: 18, color: Colors.amber);
        } else {
          return Icon(Icons.star_border, size: 18, color: Colors.grey[400]);
        }
      }),
    );
  }

  Widget _buildBotonesContacto(Emprendimiento emprendimiento) {
    return Row(
      children: [
        if (emprendimiento.telefono != null)
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => _llamar(emprendimiento.telefono!),
              icon: const Icon(Icons.phone, size: 18),
              label: const Text('Llamar', style: TextStyle(fontSize: 12)),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF2563EB),
                side: const BorderSide(color: Color(0xFF2563EB)),
                padding: const EdgeInsets.symmetric(vertical: 8),
              ),
            ),
          ),
        if (emprendimiento.telefono != null && emprendimiento.whatsapp != null)
          const SizedBox(width: 8),
        if (emprendimiento.whatsapp != null)
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => _abrirWhatsApp(emprendimiento.whatsapp!),
              icon: const Icon(Icons.chat, size: 18),
              label: const Text('WhatsApp', style: TextStyle(fontSize: 12)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF25D366),
                padding: const EdgeInsets.symmetric(vertical: 8),
              ),
            ),
          ),
      ],
    );
  }

  void _mostrarDetalle(Emprendimiento emprendimiento, User user) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _DetalleEmprendimientoSheet(
        emprendimiento: emprendimiento,
        user: user,
        onResenaCreada: _cargarEmprendimientos,
      ),
    );
  }

  Future<void> _llamar(String telefono) async {
    final Uri uri = Uri.parse('tel:$telefono');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo abrir el marcador')),
        );
      }
    }
  }

  Future<void> _abrirWhatsApp(String whatsapp) async {
    final numero = whatsapp.replaceAll(RegExp(r'[^0-9]'), '');
    final Uri uri = Uri.parse('https://wa.me/$numero');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo abrir WhatsApp')),
        );
      }
    }
  }
}

/// Sheet para ver detalle de emprendimiento con galería y resenas
class _DetalleEmprendimientoSheet extends StatefulWidget {
  final Emprendimiento emprendimiento;
  final User user;
  final VoidCallback onResenaCreada;

  const _DetalleEmprendimientoSheet({
    required this.emprendimiento,
    required this.user,
    required this.onResenaCreada,
  });

  @override
  State<_DetalleEmprendimientoSheet> createState() =>
      _DetalleEmprendimientoSheetState();
}

class _DetalleEmprendimientoSheetState
    extends State<_DetalleEmprendimientoSheet> {
  final PageController _pageController = PageController();
  int _currentImageIndex = 0;

  @override
  void dispose() {
    _pageController.dispose();
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
              // Galería de imágenes
              _buildGaleria(),
              // Contenido
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 16),
                    _buildDescripcion(),
                    const SizedBox(height: 16),
                    _buildContactoCompleto(),
                    const SizedBox(height: 24),
                    _buildResenas(),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGaleria() {
    final imagenes = widget.emprendimiento.imagenes;

    if (imagenes == null || imagenes.isEmpty) {
      return Container(
        height: 250,
        decoration: const BoxDecoration(
          color: Colors.grey,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: const Center(
          child: Icon(Icons.storefront, size: 80, color: Colors.white),
        ),
      );
    }

    return Stack(
      children: [
        SizedBox(
          height: 250,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentImageIndex = index;
              });
            },
            itemCount: imagenes.length,
            itemBuilder: (context, index) {
              return Image.network(
                imagenes[index],
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[300],
                    child: const Center(
                      child: Icon(Icons.error, size: 64),
                    ),
                  );
                },
              );
            },
          ),
        ),
        // Indicador de página
        if (imagenes.length > 1)
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(imagenes.length, (index) {
                return Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentImageIndex == index
                        ? Colors.white
                        : Colors.white.withOpacity(0.5),
                  ),
                );
              }),
            ),
          ),
        // Botón cerrar
        Positioned(
          top: 16,
          right: 16,
          child: CircleAvatar(
            backgroundColor: Colors.black.withOpacity(0.5),
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                widget.emprendimiento.nombreNegocio,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF2563EB).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                widget.emprendimiento.categoria,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2563EB),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _buildEstrellas(widget.emprendimiento.calificacionPromedio),
            const SizedBox(width: 8),
            Text(
              widget.emprendimiento.calificacionPromedio.toStringAsFixed(1),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2563EB),
              ),
            ),
            Text(
              ' (${widget.emprendimiento.totalResenas} resenas)',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDescripcion() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Descripción',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2563EB),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          widget.emprendimiento.descripcion,
          style: const TextStyle(fontSize: 14),
        ),
        if (widget.emprendimiento.horarioAtencion != null) ...[
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.schedule, size: 20, color: Color(0xFF2563EB)),
              const SizedBox(width: 8),
              Text(
                widget.emprendimiento.horarioAtencion!,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildContactoCompleto() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Contacto',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2563EB),
          ),
        ),
        const SizedBox(height: 12),
        if (widget.emprendimiento.telefono != null)
          _buildContactoItem(
            Icons.phone,
            widget.emprendimiento.telefono!,
            () => _llamar(widget.emprendimiento.telefono!),
          ),
        if (widget.emprendimiento.whatsapp != null)
          _buildContactoItem(
            Icons.chat,
            'WhatsApp',
            () => _abrirWhatsApp(widget.emprendimiento.whatsapp!),
            color: const Color(0xFF25D366),
          ),
        if (widget.emprendimiento.instagram != null)
          _buildContactoItem(
            Icons.camera_alt,
            '@${widget.emprendimiento.instagram}',
            () => _abrirInstagram(widget.emprendimiento.instagram!),
            color: const Color(0xFFE1306C),
          ),
        if (widget.emprendimiento.correo != null)
          _buildContactoItem(
            Icons.email,
            widget.emprendimiento.correo!,
            () => _enviarCorreo(widget.emprendimiento.correo!),
          ),
      ],
    );
  }

  Widget _buildContactoItem(IconData icon, String texto, VoidCallback onTap,
      {Color? color}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Icon(icon, size: 20, color: color ?? const Color(0xFF2563EB)),
              const SizedBox(width: 12),
              Text(
                texto,
                style: TextStyle(
                  fontSize: 14,
                  color: color ?? const Color(0xFF2563EB),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResenas() {
    final yaResenado = widget.emprendimiento.resenas
        .any((r) => r.usuarioId == widget.user.id);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Resenas',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2563EB),
              ),
            ),
            const Spacer(),
            if (!yaResenado)
              TextButton.icon(
                onPressed: _mostrarFormularioResena,
                icon: const Icon(Icons.rate_review, size: 18),
                label: const Text('Escribir'),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF2563EB),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        if (widget.emprendimiento.resenas.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                'No hay resenas aún',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
          )
        else
          ...widget.emprendimiento.resenas.map((resena) {
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: const Color(0xFF2563EB),
                        child: Text(
                          resena.usuarioNombre[0].toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              resena.usuarioNombre,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            _buildEstrellas(resena.calificacion.toDouble()),
                          ],
                        ),
                      ),
                      Text(
                        _formatearFecha(resena.fecha),
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  if (resena.comentario != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      resena.comentario!,
                      style: const TextStyle(fontSize: 13),
                    ),
                  ],
                ],
              ),
            );
          }).toList(),
      ],
    );
  }

  Widget _buildEstrellas(double calificacion) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        if (index < calificacion.floor()) {
          return const Icon(Icons.star, size: 16, color: Colors.amber);
        } else if (index < calificacion) {
          return const Icon(Icons.star_half, size: 16, color: Colors.amber);
        } else {
          return Icon(Icons.star_border, size: 16, color: Colors.grey[400]);
        }
      }),
    );
  }

  void _mostrarFormularioResena() {
    showDialog(
      context: context,
      builder: (context) => _FormularioResenaDialog(
        emprendimiento: widget.emprendimiento,
        user: widget.user,
        onCreated: () {
          widget.onResenaCreada();
          Navigator.pop(context); // Cerrar sheet
        },
      ),
    );
  }

  Future<void> _llamar(String telefono) async {
    final Uri uri = Uri.parse('tel:$telefono');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _abrirWhatsApp(String whatsapp) async {
    final numero = whatsapp.replaceAll(RegExp(r'[^0-9]'), '');
    final Uri uri = Uri.parse('https://wa.me/$numero');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _abrirInstagram(String instagram) async {
    final usuario = instagram.replaceAll('@', '');
    final Uri uri = Uri.parse('https://instagram.com/$usuario');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _enviarCorreo(String correo) async {
    final Uri uri = Uri.parse('mailto:$correo');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  String _formatearFecha(DateTime fecha) {
    final ahora = DateTime.now();
    final diferencia = ahora.difference(fecha);

    if (diferencia.inDays == 0) return 'Hoy';
    if (diferencia.inDays == 1) return 'Ayer';
    if (diferencia.inDays < 7) return 'Hace ${diferencia.inDays}d';
    return '${fecha.day}/${fecha.month}/${fecha.year}';
  }
}

/// Dialog para crear resena
class _FormularioResenaDialog extends StatefulWidget {
  final Emprendimiento emprendimiento;
  final User user;
  final VoidCallback onCreated;

  const _FormularioResenaDialog({
    required this.emprendimiento,
    required this.user,
    required this.onCreated,
  });

  @override
  State<_FormularioResenaDialog> createState() =>
      _FormularioResenaDialogState();
}

class _FormularioResenaDialogState extends State<_FormularioResenaDialog> {
  final ApiService _apiService = ApiService();
  final TextEditingController _comentarioController = TextEditingController();

  int _calificacion = 5;
  bool _enviando = false;

  @override
  void dispose() {
    _comentarioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Escribir resena'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Calificación',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return IconButton(
                  onPressed: () {
                    setState(() {
                      _calificacion = index + 1;
                    });
                  },
                  icon: Icon(
                    index < _calificacion ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                    size: 36,
                  ),
                );
              }),
            ),
            const SizedBox(height: 16),
            const Text(
              'Comentario (opcional)',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _comentarioController,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'Comparte tu experiencia...',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _enviando ? null : () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _enviando ? null : _crearResena,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2563EB),
          ),
          child: _enviando
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Publicar'),
        ),
      ],
    );
  }

  Future<void> _crearResena() async {
    setState(() {
      _enviando = true;
    });

    try {
      await _apiService.crearResena(
        emprendimientoId: widget.emprendimiento.id,
        calificacion: _calificacion,
        comentario: _comentarioController.text.trim().isEmpty
            ? null
            : _comentarioController.text.trim(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Resena publicada exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
        widget.onCreated();
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
        Navigator.pop(context);
      }
    }
  }
}
