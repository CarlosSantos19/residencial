import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../services/api_service.dart';
import '../../models/vehiculo.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/custom_card.dart';

class ControlVehiculosVigilanteScreen extends StatefulWidget {
  const ControlVehiculosVigilanteScreen({super.key});

  @override
  State<ControlVehiculosVigilanteScreen> createState() => _ControlVehiculosVigilanteScreenState();
}

class _ControlVehiculosVigilanteScreenState extends State<ControlVehiculosVigilanteScreen> {
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  List<VehiculoVisitante> _vehiculos = [];

  @override
  void initState() {
    super.initState();
    _loadVehiculos();
  }

  Future<void> _loadVehiculos() async {
    setState(() => _isLoading = true);
    try {
      final authService = context.read<AuthService>();
      _apiService.setToken(authService.token!);
      final vehiculos = await _apiService.getVehiculosHoy();
      setState(() {
        _vehiculos = vehiculos;
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
        title: const Text('Control de Vehículos'),
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
              itemCount: _vehiculos.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, i) {
                final v = _vehiculos[i];
                return CustomCard(
                  child: Row(
                    children: [
                      Icon(Icons.directions_car, color: v.horaSalida == null ? Colors.green : Colors.grey),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(v.placa, style: const TextStyle(fontWeight: FontWeight.bold)),
                            Text('Apto: ${v.apartamento}', style: TextStyle(color: Colors.grey.shade600)),
                          ],
                        ),
                      ),
                      if (v.horaSalida == null)
                        ElevatedButton(
                          onPressed: () => _registrarSalida(v.id),
                          child: const Text('Salida'),
                        ),
                    ],
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _registrarIngreso,
        backgroundColor: user.rol.primaryColor,
        child: const Icon(Icons.add),
      ),
    );
  }

  void _registrarIngreso() {}
  Future<void> _registrarSalida(int vehiculoId) async {
    await _apiService.registrarSalidaVehiculo(vehiculoId);
    _loadVehiculos();
  }
}
