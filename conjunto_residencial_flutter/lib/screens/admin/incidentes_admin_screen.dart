import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../services/api_service.dart';
import '../../models/incidente_alcaldia.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/custom_card.dart';

class IncidentesAdminScreen extends StatefulWidget {
  const IncidentesAdminScreen({super.key});

  @override
  State<IncidentesAdminScreen> createState() => _IncidentesAdminScreenState();
}

class _IncidentesAdminScreenState extends State<IncidentesAdminScreen> {
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
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthService>().currentUser!;
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Incidentes Alcaldía'),
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
              itemCount: _incidentes.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, i) {
                final inc = _incidentes[i];
                return CustomCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(inc.tipo, style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text(inc.descripcion, style: TextStyle(color: Colors.grey.shade600)),
                      Text('Ubicación: ${inc.ubicacion}', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
