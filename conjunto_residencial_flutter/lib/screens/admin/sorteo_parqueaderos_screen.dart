import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../services/api_service.dart';
import '../../models/vehiculo.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/error_widget.dart';
import '../../widgets/custom_card.dart';

class SorteoParqueaderosScreen extends StatefulWidget {
  const SorteoParqueaderosScreen({super.key});

  @override
  State<SorteoParqueaderosScreen> createState() => _SorteoParqueaderosScreenState();
}

class _SorteoParqueaderosScreenState extends State<SorteoParqueaderosScreen> {
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  String? _error;
  List<Parqueadero> _parqueaderos = [];

  @override
  void initState() {
    super.initState();
    _loadParqueaderos();
  }

  Future<void> _loadParqueaderos() async {
    setState(() => _isLoading = true);
    try {
      final authService = context.read<AuthService>();
      _apiService.setToken(authService.token!);
      final parqueaderos = await _apiService.getParqueaderos();
      setState(() {
        _parqueaderos = parqueaderos;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _realizarSorteo() async {
    try {
      final authService = context.read<AuthService>();
      _apiService.setToken(authService.token!);
      await _apiService.sortearParqueaderos();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sorteo realizado exitosamente')),
        );
        _loadParqueaderos();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthService>().currentUser!;
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Sorteo de Parqueaderos'),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [user.rol.gradientStart, user.rol.gradientEnd]),
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => _confirmarSorteo(),
            icon: const Icon(Icons.casino),
            tooltip: 'Realizar Sorteo',
          ),
        ],
      ),
      body: _isLoading
          ? const LoadingWidget()
          : _error != null
              ? ErrorDisplayWidget(message: _error!, onRetry: _loadParqueaderos)
              : RefreshIndicator(
                  onRefresh: _loadParqueaderos,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: _parqueaderos.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (_, i) {
                      final p = _parqueaderos[i];
                      return CustomCard(
                        child: Row(
                          children: [
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: p.ocupado ? Colors.red.shade50 : Colors.green.shade50,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: Text(
                                  p.numero,
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: p.ocupado ? Colors.red : Colors.green,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(p.ubicacion, style: const TextStyle(fontWeight: FontWeight.bold)),
                                  Text(p.tipo, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                                  if (p.asignadoA != null)
                                    Text('Asignado a: ${p.asignadoA}', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: p.ocupado ? Colors.red : Colors.green,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                p.ocupado ? 'OCUPADO' : 'LIBRE',
                                style: const TextStyle(color: Colors.white, fontSize: 10),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
    );
  }

  void _confirmarSorteo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Sorteo'),
        content: const Text('¿Estás seguro de realizar un nuevo sorteo de parqueaderos? Esto reasignará todos los parqueaderos.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _realizarSorteo();
            },
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
  }
}
