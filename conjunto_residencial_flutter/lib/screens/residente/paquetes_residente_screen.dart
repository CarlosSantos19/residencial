import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../services/api_service.dart';
import '../../models/paquete.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/error_widget.dart';
import '../../widgets/empty_state_widget.dart';
import '../../widgets/custom_card.dart';

class PaquetesResidenteScreen extends StatefulWidget {
  const PaquetesResidenteScreen({super.key});

  @override
  State<PaquetesResidenteScreen> createState() => _PaquetesResidenteScreenState();
}

class _PaquetesResidenteScreenState extends State<PaquetesResidenteScreen> {
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  String? _error;
  List<Paquete> _paquetes = [];

  @override
  void initState() {
    super.initState();
    _loadPaquetes();
  }

  Future<void> _loadPaquetes() async {
    setState(() => _isLoading = true);
    try {
      final authService = context.read<AuthService>();
      _apiService.setToken(authService.token!);
      final paquetes = await _apiService.getMisPaquetes();
      setState(() {
        _paquetes = paquetes;
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
        title: const Text('Mis Paquetes'),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [user.rol.gradientStart, user.rol.gradientEnd]),
          ),
        ),
      ),
      body: _isLoading
          ? const LoadingWidget()
          : _error != null
              ? ErrorDisplayWidget(message: _error!, onRetry: _loadPaquetes)
              : _paquetes.isEmpty
                  ? const EmptyStateWidget(title: 'Sin Paquetes', message: 'No tienes paquetes pendientes', icon: Icons.inventory_2)
                  : RefreshIndicator(
                      onRefresh: _loadPaquetes,
                      child: ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: _paquetes.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (_, i) {
                          final p = _paquetes[i];
                          return CustomCard(
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(color: p.retirado ? Colors.grey.shade100 : Colors.blue.shade50, borderRadius: BorderRadius.circular(8)),
                                  child: Icon(Icons.inventory_2, color: p.retirado ? Colors.grey : Colors.blue),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Paquete #${p.id}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                      Text('${p.descripcion}', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                                      Text('Recibido: ${p.fechaRecepcion}', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                                    ],
                                  ),
                                ),
                                if (!p.retirado)
                                  ElevatedButton(
                                    onPressed: () async {
                                      await _apiService.retirarPaquete(p.id);
                                      _loadPaquetes();
                                    },
                                    child: const Text('Retirar'),
                                  )
                                else
                                  const Icon(Icons.check_circle, color: Colors.green),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
    );
  }
}
