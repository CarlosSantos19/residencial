import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../services/api_service.dart';
import '../../models/pago.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/error_widget.dart';
import '../../widgets/custom_card.dart';

class PagosAdminScreen extends StatefulWidget {
  const PagosAdminScreen({super.key});

  @override
  State<PagosAdminScreen> createState() => _PagosAdminScreenState();
}

class _PagosAdminScreenState extends State<PagosAdminScreen> {
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  String? _error;
  List<Pago> _pagos = [];

  @override
  void initState() {
    super.initState();
    _loadPagos();
  }

  Future<void> _loadPagos() async {
    setState(() => _isLoading = true);
    try {
      final authService = context.read<AuthService>();
      _apiService.setToken(authService.token!);
      final pagos = await _apiService.getPagos();
      setState(() {
        _pagos = pagos;
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
        title: const Text('Gestión de Pagos'),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [user.rol.gradientStart, user.rol.gradientEnd]),
          ),
        ),
      ),
      body: _isLoading
          ? const LoadingWidget()
          : _error != null
              ? ErrorDisplayWidget(message: _error!, onRetry: _loadPagos)
              : RefreshIndicator(
                  onRefresh: _loadPagos,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: _pagos.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (_, i) {
                      final p = _pagos[i];
                      return CustomCard(
                        child: Row(
                          children: [
                            Icon(Icons.payment, color: p.estado == 'pagado' ? Colors.green : Colors.red),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(p.concepto, style: const TextStyle(fontWeight: FontWeight.bold)),
                                  Text('Vence: ${p.fechaVencimiento}', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text('\$${p.monto.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(color: p.estado == 'pagado' ? Colors.green : Colors.orange, borderRadius: BorderRadius.circular(4)),
                                  child: Text(p.estado.toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 10)),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
