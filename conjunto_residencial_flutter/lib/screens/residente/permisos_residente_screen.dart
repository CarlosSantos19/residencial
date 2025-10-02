import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../services/api_service.dart';
import '../../models/permiso.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/error_widget.dart';
import '../../widgets/empty_state_widget.dart';
import '../../widgets/custom_card.dart';

class PermisosResidenteScreen extends StatefulWidget {
  const PermisosResidenteScreen({super.key});

  @override
  State<PermisosResidenteScreen> createState() => _PermisosResidenteScreenState();
}

class _PermisosResidenteScreenState extends State<PermisosResidenteScreen> {
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  String? _error;
  List<Permiso> _permisos = [];

  @override
  void initState() {
    super.initState();
    _loadPermisos();
  }

  Future<void> _loadPermisos() async {
    setState(() => _isLoading = true);
    try {
      final authService = context.read<AuthService>();
      _apiService.setToken(authService.token!);
      final permisos = await _apiService.getMisPermisos();
      setState(() {
        _permisos = permisos;
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
        title: const Text('Mis Permisos'),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [user.rol.gradientStart, user.rol.gradientEnd]),
          ),
        ),
      ),
      body: _isLoading
          ? const LoadingWidget()
          : _error != null
              ? ErrorDisplayWidget(message: _error!, onRetry: _loadPermisos)
              : _permisos.isEmpty
                  ? const EmptyStateWidget(title: 'Sin Permisos', message: 'No tienes permisos solicitados', icon: Icons.shield)
                  : RefreshIndicator(
                      onRefresh: _loadPermisos,
                      child: ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: _permisos.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (_, i) {
                          final p = _permisos[i];
                          return CustomCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.person, color: user.rol.primaryColor),
                                    const SizedBox(width: 8),
                                    Expanded(child: Text(p.nombreVisitante, style: const TextStyle(fontWeight: FontWeight.bold))),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(color: p.estado == 'aprobado' ? Colors.green : Colors.orange, borderRadius: BorderRadius.circular(4)),
                                      child: Text(p.estado.toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 10)),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text('Fecha: ${p.fechaInicio}', style: TextStyle(color: Colors.grey.shade600)),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: user.rol.primaryColor,
        child: const Icon(Icons.add),
      ),
    );
  }
}
