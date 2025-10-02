import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../services/api_service.dart';
import '../../models/encuesta.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/custom_card.dart';

class EncuestasAdminScreen extends StatefulWidget {
  const EncuestasAdminScreen({super.key});

  @override
  State<EncuestasAdminScreen> createState() => _EncuestasAdminScreenState();
}

class _EncuestasAdminScreenState extends State<EncuestasAdminScreen> {
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  List<Encuesta> _encuestas = [];

  @override
  void initState() {
    super.initState();
    _loadEncuestas();
  }

  Future<void> _loadEncuestas() async {
    setState(() => _isLoading = true);
    try {
      final authService = context.read<AuthService>();
      _apiService.setToken(authService.token!);
      final encuestas = await _apiService.getEncuestas();
      setState(() {
        _encuestas = encuestas;
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
        title: const Text('Encuestas'),
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
              itemCount: _encuestas.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, i) {
                final e = _encuestas[i];
                return CustomCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(child: Text(e.pregunta, style: const TextStyle(fontWeight: FontWeight.bold))),
                          IconButton(icon: const Icon(Icons.delete), onPressed: () => _eliminar(e.id)),
                        ],
                      ),
                      ...e.opciones.asMap().entries.map((entry) {
                        return Text('${entry.key + 1}. ${entry.value.texto} (${entry.value.votos} votos)');
                      }).toList(),
                    ],
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _crearEncuesta,
        backgroundColor: user.rol.primaryColor,
        child: const Icon(Icons.add),
      ),
    );
  }

  void _crearEncuesta() {}

  Future<void> _eliminar(int id) async {
    await _apiService.eliminarEncuesta(id);
    _loadEncuestas();
  }
}
