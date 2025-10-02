import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../services/api_service.dart';
import '../../models/vehiculo.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/error_widget.dart';
import '../../widgets/empty_state_widget.dart';
import '../../widgets/custom_card.dart';

class ControlVehiculosResidenteScreen extends StatefulWidget {
  const ControlVehiculosResidenteScreen({super.key});

  @override
  State<ControlVehiculosResidenteScreen> createState() => _ControlVehiculosResidenteScreenState();
}

class _ControlVehiculosResidenteScreenState extends State<ControlVehiculosResidenteScreen> {
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  String? _error;
  List<VehiculoVisitante> _vehiculos = [];

  @override
  void initState() {
    super.initState();
    _loadVehiculos();
  }

  Future<void> _loadVehiculos() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final authService = context.read<AuthService>();
      _apiService.setToken(authService.token!);
      final user = authService.currentUser!;
      final vehiculos = await _apiService.getVehiculosVisitantes();
      setState(() {
        _vehiculos = vehiculos.where((v) => v.apartamento == user.apartamento).toList();
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
        title: const Text('Control Vehículos'),
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
      return const LoadingWidget(message: 'Cargando vehículos...');
    }

    if (_error != null) {
      return ErrorDisplayWidget(message: _error!, onRetry: _loadVehiculos);
    }

    if (_vehiculos.isEmpty) {
      return const EmptyStateWidget(
        title: 'Sin Vehículos',
        message: 'No tienes vehículos visitantes registrados',
        icon: Icons.directions_car,
      );
    }

    return RefreshIndicator(
      onRefresh: _loadVehiculos,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _vehiculos.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final vehiculo = _vehiculos[index];
          final esActivo = vehiculo.horaSalida == null;
          return CustomCard(
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: esActivo ? Colors.green.shade50 : Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.directions_car,
                    color: esActivo ? Colors.green : Colors.grey,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        vehiculo.placa,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Ingreso: ${vehiculo.horaIngreso}',
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                      ),
                      if (vehiculo.horaSalida != null)
                        Text(
                          'Salida: ${vehiculo.horaSalida}',
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                        ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: esActivo ? Colors.green : Colors.grey,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    esActivo ? 'DENTRO' : 'SALIÓ',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
