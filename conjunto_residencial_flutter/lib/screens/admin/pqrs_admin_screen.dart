import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../services/api_service.dart';
import '../../models/pqrs.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/custom_card.dart';

class PQRSAdminScreen extends StatefulWidget {
  const PQRSAdminScreen({super.key});

  @override
  State<PQRSAdminScreen> createState() => _PQRSAdminScreenState();
}

class _PQRSAdminScreenState extends State<PQRSAdminScreen> {
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  List<PQRS> _pqrsList = [];

  @override
  void initState() {
    super.initState();
    _loadPQRS();
  }

  Future<void> _loadPQRS() async {
    setState(() => _isLoading = true);
    try {
      final authService = context.read<AuthService>();
      _apiService.setToken(authService.token!);
      final pqrs = await _apiService.getPQRSList();
      setState(() {
        _pqrsList = pqrs;
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
        title: const Text('PQRS'),
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
              itemCount: _pqrsList.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, i) {
                final p = _pqrsList[i];
                return CustomCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(color: Colors.blue, borderRadius: BorderRadius.circular(4)),
                            child: Text(p.tipo.toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 10)),
                          ),
                          const Spacer(),
                          ElevatedButton(onPressed: () => _responder(p), child: const Text('Responder')),
                        ],
                      ),
                      Text(p.asunto, style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text(p.descripcion, style: TextStyle(color: Colors.grey.shade600)),
                    ],
                  ),
                );
              },
            ),
    );
  }

  void _responder(PQRS pqrs) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Responder PQRS'),
        content: TextField(controller: controller, decoration: const InputDecoration(labelText: 'Respuesta'), maxLines: 3),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () async {
              await _apiService.responderPQRS(pqrs.id, controller.text);
              if (mounted) {
                Navigator.pop(context);
                _loadPQRS();
              }
            },
            child: const Text('Enviar'),
          ),
        ],
      ),
    );
  }
}
