import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../services/api_service.dart';
import '../../models/vehiculo.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/error_widget.dart';
import '../../widgets/custom_card.dart';

class ControlVehiculosAdminScreen extends StatefulWidget {
  const ControlVehiculosAdminScreen({super.key});

  @override
  State<ControlVehiculosAdminScreen> createState() => _ControlVehiculosAdminScreenState();
}

class _ControlVehiculosAdminScreenState extends State<ControlVehiculosAdminScreen> with SingleTickerProviderStateMixin {
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  String? _error;
  List<VehiculoVisitante> _vehiculos = [];
  List<ReciboParqueadero> _recibos = [];
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final authService = context.read<AuthService>();
      _apiService.setToken(authService.token!);
      final vehiculos = await _apiService.getVehiculosVisitantes();
      final recibos = await _apiService.getRecibosParqueadero();
      setState(() {
        _vehiculos = vehiculos;
        _recibos = recibos;
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
        title: const Text('Control de Vehículos'),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [user.rol.gradientStart, user.rol.gradientEnd]),
          ),
        ),
        bottom: TabBar(controller: _tabController, tabs: const [Tab(text: 'Vehículos'), Tab(text: 'Recibos')]),
      ),
      body: _isLoading
          ? const LoadingWidget()
          : _error != null
              ? ErrorDisplayWidget(message: _error!, onRetry: _loadData)
              : TabBarView(controller: _tabController, children: [_buildVehiculos(), _buildRecibos()]),
    );
  }

  Widget _buildVehiculos() {
    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _vehiculos.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (_, i) {
          final v = _vehiculos[i];
          return CustomCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.directions_car, color: v.horaSalida == null ? Colors.green : Colors.grey),
                    const SizedBox(width: 8),
                    Expanded(child: Text(v.placa, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18))),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: v.horaSalida == null ? Colors.green : Colors.grey, borderRadius: BorderRadius.circular(4)),
                      child: Text(v.horaSalida == null ? 'DENTRO' : 'SALIÓ', style: const TextStyle(color: Colors.white, fontSize: 10)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text('Apartamento: ${v.apartamento}', style: TextStyle(color: Colors.grey.shade600)),
                Text('Ingreso: ${v.horaIngreso}', style: TextStyle(color: Colors.grey.shade600)),
                if (v.horaSalida != null) Text('Salida: ${v.horaSalida}', style: TextStyle(color: Colors.grey.shade600)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildRecibos() {
    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _recibos.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (_, i) {
          final r = _recibos[i];
          return CustomCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.receipt, color: Colors.blue),
                    const SizedBox(width: 8),
                    Expanded(child: Text('Recibo #${r.id}', style: const TextStyle(fontWeight: FontWeight.bold))),
                    Text('\$${r.monto.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  ],
                ),
                const SizedBox(height: 8),
                Text('Placa: ${r.placa}', style: TextStyle(color: Colors.grey.shade600)),
                Text('Fecha: ${r.fecha}', style: TextStyle(color: Colors.grey.shade600)),
                Text('Tiempo: ${r.detalles}', style: TextStyle(color: Colors.grey.shade600)),
              ],
            ),
          );
        },
      ),
    );
  }
}
