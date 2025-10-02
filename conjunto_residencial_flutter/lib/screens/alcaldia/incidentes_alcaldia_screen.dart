import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../services/api_service.dart';
import '../../models/incidente_alcaldia.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/empty_state_widget.dart';
import '../../widgets/custom_card.dart';

class IncidentesAlcaldiaScreen extends StatefulWidget {
  const IncidentesAlcaldiaScreen({super.key});

  @override
  State<IncidentesAlcaldiaScreen> createState() => _IncidentesAlcaldiaScreenState();
}

class _IncidentesAlcaldiaScreenState extends State<IncidentesAlcaldiaScreen> {
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  List<IncidenteAlcaldia> _incidentes = [];

  @override
  void initState() {
    super.initState();
    _loadIncidentes();
  }

  Future<void> _loadIncidentes() async {
    setState(() => _isLoading = true);
    try {
      final authService = context.read<AuthService>();
      _apiService.setToken(authService.token!);
      final incidentes = await _apiService.getIncidentes();
      setState(() {
        _incidentes = incidentes;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
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
        title: const Text('Incidentes Reportados'),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [user.rol.gradientStart, user.rol.gradientEnd]),
          ),
        ),
      ),
      body: _isLoading
          ? const LoadingWidget()
          : _incidentes.isEmpty
              ? const EmptyStateWidget(
                  title: 'Sin Incidentes',
                  message: 'No hay incidentes reportados',
                  icon: Icons.warning_amber_outlined,
                )
              : RefreshIndicator(
                  onRefresh: _loadIncidentes,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: _incidentes.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (_, i) {
                      final inc = _incidentes[i];
                      return CustomCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: _getTipoColor(inc.tipo),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    inc.tipo.toUpperCase(),
                                    style: const TextStyle(color: Colors.white, fontSize: 10),
                                  ),
                                ),
                                const Spacer(),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: _getEstadoColor(inc.estado),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    inc.estado.toUpperCase(),
                                    style: const TextStyle(color: Colors.white, fontSize: 10),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              inc.descripcion,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(Icons.location_on, size: 14, color: Colors.grey.shade600),
                                const SizedBox(width: 4),
                                Text(
                                  inc.ubicacion ?? 'Sin ubicación',
                                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Reportado por: ${inc.reportadoPor}',
                              style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                            ),
                            if (inc.respuesta != null) ...[
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade50,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  'Respuesta: ${inc.respuesta}',
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ),
                            ],
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                if (inc.estado == 'pendiente')
                                  ElevatedButton(
                                    onPressed: () => _responderIncidente(inc),
                                    child: const Text('Responder'),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
    );
  }

  void _responderIncidente(IncidenteAlcaldia incidente) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Responder Incidente'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Respuesta'),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              await _apiService.responderIncidente(incidente.id, controller.text);
              await _apiService.cambiarEstadoIncidente(incidente.id, 'en proceso');
              if (mounted) {
                Navigator.pop(context);
                _loadIncidentes();
              }
            },
            child: const Text('Enviar'),
          ),
        ],
      ),
    );
  }

  Color _getTipoColor(String tipo) {
    switch (tipo.toLowerCase()) {
      case 'seguridad':
        return Colors.red;
      case 'infraestructura':
        return Colors.orange;
      case 'ruido':
        return Colors.purple;
      case 'iluminación':
        return Colors.amber;
      default:
        return Colors.grey;
    }
  }

  Color _getEstadoColor(String estado) {
    switch (estado.toLowerCase()) {
      case 'pendiente':
        return Colors.orange;
      case 'en proceso':
        return Colors.blue;
      case 'resuelto':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}
