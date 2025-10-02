import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../services/api_service.dart';
import '../../models/paquete.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/custom_card.dart';

class PaquetesVigilanteScreen extends StatefulWidget {
  const PaquetesVigilanteScreen({super.key});

  @override
  State<PaquetesVigilanteScreen> createState() => _PaquetesVigilanteScreenState();
}

class _PaquetesVigilanteScreenState extends State<PaquetesVigilanteScreen> {
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
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
      final paquetes = await _apiService.getPaquetes();
      setState(() {
        _paquetes = paquetes;
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
        title: const Text('Paquetes'),
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
              itemCount: _paquetes.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, i) {
                final p = _paquetes[i];
                return CustomCard(
                  child: Row(
                    children: [
                      Icon(Icons.inventory_2, color: p.retirado ? Colors.grey : user.rol.primaryColor),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Apto: ${p.apartamento}', style: const TextStyle(fontWeight: FontWeight.bold)),
                            Text(p.descripcion, style: TextStyle(color: Colors.grey.shade600)),
                          ],
                        ),
                      ),
                      Text(p.retirado ? 'Retirado' : 'Pendiente'),
                    ],
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: user.rol.primaryColor,
        child: const Icon(Icons.add),
      ),
    );
  }
}
