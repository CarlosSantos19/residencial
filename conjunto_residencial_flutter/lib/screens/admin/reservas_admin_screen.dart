import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../services/api_service.dart';
import '../../models/reserva.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/error_widget.dart';
import '../../widgets/custom_card.dart';

class ReservasAdminScreen extends StatefulWidget {
  const ReservasAdminScreen({super.key});

  @override
  State<ReservasAdminScreen> createState() => _ReservasAdminScreenState();
}

class _ReservasAdminScreenState extends State<ReservasAdminScreen> {
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  String? _error;
  List<Reserva> _reservas = [];

  @override
  void initState() {
    super.initState();
    _loadReservas();
  }

  Future<void> _loadReservas() async {
    setState(() => _isLoading = true);
    try {
      final authService = context.read<AuthService>();
      _apiService.setToken(authService.token!);
      final reservas = await _apiService.getReservas();
      setState(() {
        _reservas = reservas;
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
        title: const Text('Gestión de Reservas'),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [user.rol.gradientStart, user.rol.gradientEnd]),
          ),
        ),
      ),
      body: _isLoading
          ? const LoadingWidget()
          : _error != null
              ? ErrorDisplayWidget(message: _error!, onRetry: _loadReservas)
              : RefreshIndicator(
                  onRefresh: _loadReservas,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: _reservas.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (_, i) {
                      final r = _reservas[i];
                      return CustomCard(
                        child: Row(
                          children: [
                            Icon(Icons.calendar_today, color: Colors.blue),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(r.espacio, style: const TextStyle(fontWeight: FontWeight.bold)),
                                  Text('${r.fecha} - ${r.hora}', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                                ],
                              ),
                            ),
                            IconButton(icon: const Icon(Icons.delete), onPressed: () => _eliminarReserva(r.id)),
                          ],
                        ),
                      );
                    },
                  ),
                ),
    );
  }

  Future<void> _eliminarReserva(int id) async {
    await _apiService.eliminarReserva(id);
    _loadReservas();
  }
}
