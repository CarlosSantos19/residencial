import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../services/api_service.dart';
import '../../models/pqrs.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/error_widget.dart';
import '../../widgets/empty_state_widget.dart';
import '../../widgets/custom_card.dart';

class PQRSScreen extends StatefulWidget {
  const PQRSScreen({super.key});

  @override
  State<PQRSScreen> createState() => _PQRSScreenState();
}

class _PQRSScreenState extends State<PQRSScreen> {
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  String? _error;
  List<PQRS> _pqrsList = [];

  @override
  void initState() {
    super.initState();
    _loadPQRS();
  }

  Future<void> _loadPQRS() async {
    setState(() => _isLoading = true);
    try {
      final authService = context.read<AuthService>();
      _apiService.setToken(authService.token!);
      final pqrs = await _apiService.getPQRSList();
      setState(() {
        _pqrsList = pqrs;
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
        title: const Text('PQRS'),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [user.rol.gradientStart, user.rol.gradientEnd]),
          ),
        ),
      ),
      body: _isLoading
          ? const LoadingWidget()
          : _error != null
              ? ErrorDisplayWidget(message: _error!, onRetry: _loadPQRS)
              : _pqrsList.isEmpty
                  ? EmptyStateWidget(
                      title: 'Sin PQRS',
                      message: 'No has enviado peticiones, quejas, reclamos o sugerencias',
                      icon: Icons.support_agent,
                      action: ElevatedButton(
                        onPressed: _showNuevaPQRS,
                        child: const Text('Nueva PQRS'),
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadPQRS,
                      child: ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: _pqrsList.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (_, i) {
                          final pqrs = _pqrsList[i];
                          return CustomCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(color: _getTipoColor(pqrs.tipo), borderRadius: BorderRadius.circular(4)),
                                      child: Text(pqrs.tipo.toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 10)),
                                    ),
                                    const Spacer(),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(color: _getEstadoColor(pqrs.estado), borderRadius: BorderRadius.circular(4)),
                                      child: Text(pqrs.estado.toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 10)),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(pqrs.asunto, style: const TextStyle(fontWeight: FontWeight.bold)),
                                Text(pqrs.descripcion, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                                if (pqrs.respuesta != null) ...[
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(4)),
                                    child: Text('Respuesta: ${pqrs.respuesta}', style: const TextStyle(fontSize: 12)),
                                  ),
                                ],
                              ],
                            ),
                          );
                        },
                      ),
                    ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showNuevaPQRS,
        backgroundColor: user.rol.primaryColor,
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showNuevaPQRS() {
    final asuntoController = TextEditingController();
    final descripcionController = TextEditingController();
    String tipo = 'Petición';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nueva PQRS'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: tipo,
                items: ['Petición', 'Queja', 'Reclamo', 'Sugerencia'].map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                onChanged: (v) => tipo = v!,
                decoration: const InputDecoration(labelText: 'Tipo'),
              ),
              TextField(controller: asuntoController, decoration: const InputDecoration(labelText: 'Asunto')),
              TextField(controller: descripcionController, decoration: const InputDecoration(labelText: 'Descripción'), maxLines: 3),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () async {
              await _apiService.crearPQRS(
                tipo: tipo,
                asunto: asuntoController.text,
                descripcion: descripcionController.text,
              );
              if (mounted) {
                Navigator.pop(context);
                _loadPQRS();
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
      case 'petición':
        return Colors.blue;
      case 'queja':
        return Colors.orange;
      case 'reclamo':
        return Colors.red;
      default:
        return Colors.green;
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
