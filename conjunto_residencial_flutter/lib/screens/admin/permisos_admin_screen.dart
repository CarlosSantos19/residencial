import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../services/api_service.dart';
import '../../models/permiso.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/custom_card.dart';

class PermisosAdminScreen extends StatefulWidget {
  const PermisosAdminScreen({super.key});

  @override
  State<PermisosAdminScreen> createState() => _PermisosAdminScreenState();
}

class _PermisosAdminScreenState extends State<PermisosAdminScreen> {
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
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
      final permisos = await _apiService.getPermisosList();
      setState(() {
        _permisos = permisos;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthService>().currentUser!;
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Permisos'),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [user.rol.gradientStart, user.rol.gradientEnd]),
          ),
        ),
      ),
      body: _isLoading
          ? const LoadingWidget()
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _permisos.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, i) {
                final p = _permisos[i];
                return CustomCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(p.nombreVisitante, style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text('Apto: ${p.apartamento}', style: TextStyle(color: Colors.grey.shade600)),
                      Text('${p.fechaInicio} - ${p.fechaFin}', style: TextStyle(color: Colors.grey.shade600)),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
