import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../services/auth_service.dart';
import '../../services/api_service.dart';
import '../../models/emprendimiento.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/error_widget.dart';
import '../../widgets/empty_state_widget.dart';
import '../../widgets/custom_card.dart';

class EmprendimientosScreen extends StatefulWidget {
  const EmprendimientosScreen({super.key});

  @override
  State<EmprendimientosScreen> createState() => _EmprendimientosScreenState();
}

class _EmprendimientosScreenState extends State<EmprendimientosScreen> {
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  String? _error;
  List<Emprendimiento> _emprendimientos = [];

  @override
  void initState() {
    super.initState();
    _loadEmprendimientos();
  }

  Future<void> _loadEmprendimientos() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final authService = context.read<AuthService>();
      _apiService.setToken(authService.token!);
      final emprendimientos = await _apiService.getEmprendimientosList();
      setState(() {
        _emprendimientos = emprendimientos;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthService>().currentUser!;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Emprendimientos'),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [user.rol.gradientStart, user.rol.gradientEnd],
            ),
          ),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const LoadingWidget(message: 'Cargando emprendimientos...');
    }

    if (_error != null) {
      return ErrorDisplayWidget(message: _error!, onRetry: _loadEmprendimientos);
    }

    if (_emprendimientos.isEmpty) {
      return const EmptyStateWidget(
        title: 'Sin Emprendimientos',
        message: 'No hay negocios registrados en el conjunto',
        icon: Icons.store,
      );
    }

    return RefreshIndicator(
      onRefresh: _loadEmprendimientos,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _emprendimientos.length,
        separatorBuilder: (_, __) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          final emprendimiento = _emprendimientos[index];
          return CustomCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.store, color: Colors.blue, size: 32),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            emprendimiento.nombre,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            emprendimiento.categoria,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  emprendimiento.descripcion,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildRatingStars(emprendimiento.calificacionPromedio),
                    const SizedBox(width: 8),
                    Text(
                      '${emprendimiento.calificacionPromedio.toStringAsFixed(1)} (${emprendimiento.resenas.length} reseñas)',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.person, size: 14, color: Colors.grey.shade600),
                    const SizedBox(width: 4),
                    Text(
                      emprendimiento.propietario,
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.phone, size: 14, color: Colors.grey.shade600),
                    const SizedBox(width: 4),
                    Text(
                      emprendimiento.contacto,
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                    ),
                  ],
                ),
                if (emprendimiento.whatsapp != null || emprendimiento.instagram != null) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      if (emprendimiento.whatsapp != null)
                        ElevatedButton.icon(
                          onPressed: () => _abrirWhatsapp(emprendimiento.whatsapp!),
                          icon: const Icon(Icons.message, size: 16),
                          label: const Text('WhatsApp'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF25D366),
                          ),
                        ),
                      if (emprendimiento.instagram != null) ...[
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          onPressed: () => _abrirInstagram(emprendimiento.instagram!),
                          icon: const Icon(Icons.camera_alt, size: 16),
                          label: const Text('Instagram'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFE4405F),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildRatingStars(double rating) {
    return Row(
      children: List.generate(5, (index) {
        if (index < rating.floor()) {
          return const Icon(Icons.star, color: Colors.amber, size: 16);
        } else if (index < rating) {
          return const Icon(Icons.star_half, color: Colors.amber, size: 16);
        } else {
          return Icon(Icons.star_border, color: Colors.grey.shade400, size: 16);
        }
      }),
    );
  }

  Future<void> _abrirWhatsapp(String numero) async {
    final url = Uri.parse('https://wa.me/$numero');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  Future<void> _abrirInstagram(String username) async {
    final url = Uri.parse('https://instagram.com/$username');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }
}
