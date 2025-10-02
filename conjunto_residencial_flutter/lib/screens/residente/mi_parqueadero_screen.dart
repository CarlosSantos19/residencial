import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../services/api_service.dart';
import '../../models/vehiculo.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/error_widget.dart';
import '../../widgets/custom_card.dart';

class MiParqueaderoScreen extends StatefulWidget {
  const MiParqueaderoScreen({super.key});

  @override
  State<MiParqueaderoScreen> createState() => _MiParqueaderoScreenState();
}

class _MiParqueaderoScreenState extends State<MiParqueaderoScreen> {
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  String? _error;
  Parqueadero? _miParqueadero;

  @override
  void initState() {
    super.initState();
    _loadParqueadero();
  }

  Future<void> _loadParqueadero() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final authService = context.read<AuthService>();
      _apiService.setToken(authService.token!);
      final parqueadero = await _apiService.getMiParqueadero();
      setState(() {
        _miParqueadero = parqueadero;
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
        title: const Text('Mi Parqueadero'),
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
      return const LoadingWidget(message: 'Cargando información...');
    }

    if (_error != null) {
      return ErrorDisplayWidget(message: _error!, onRetry: _loadParqueadero);
    }

    return RefreshIndicator(
      onRefresh: _loadParqueadero,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (_miParqueadero == null)
              CustomCard(
                child: Column(
                  children: [
                    Icon(Icons.local_parking, size: 80, color: Colors.grey.shade300),
                    const SizedBox(height: 16),
                    const Text(
                      'Sin Parqueadero Asignado',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Aún no tienes un parqueadero asignado. Espera al próximo sorteo.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ],
                ),
              )
            else
              CustomCard(
                child: Column(
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.local_parking, size: 40, color: Colors.blue),
                            const SizedBox(height: 8),
                            Text(
                              _miParqueadero!.numero,
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildInfoRow('Ubicación', _miParqueadero!.ubicacion),
                    const Divider(height: 24),
                    _buildInfoRow('Tipo', _miParqueadero!.tipo),
                    const Divider(height: 24),
                    _buildInfoRow('Estado', _miParqueadero!.ocupado ? 'Ocupado' : 'Disponible'),
                    const Divider(height: 24),
                    _buildInfoRow('Asignado a', context.read<AuthService>().currentUser!.apartamento),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
        ),
        Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
