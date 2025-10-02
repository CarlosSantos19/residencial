import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../services/api_service.dart';
import '../../models/encuesta.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/error_widget.dart';
import '../../widgets/empty_state_widget.dart';
import '../../widgets/custom_card.dart';

class EncuestasResidenteScreen extends StatefulWidget {
  const EncuestasResidenteScreen({super.key});

  @override
  State<EncuestasResidenteScreen> createState() => _EncuestasResidenteScreenState();
}

class _EncuestasResidenteScreenState extends State<EncuestasResidenteScreen> {
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  String? _error;
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
        title: const Text('Encuestas'),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [user.rol.gradientStart, user.rol.gradientEnd]),
          ),
        ),
      ),
      body: _isLoading
          ? const LoadingWidget()
          : _error != null
              ? ErrorDisplayWidget(message: _error!, onRetry: _loadEncuestas)
              : _encuestas.isEmpty
                  ? const EmptyStateWidget(title: 'Sin Encuestas', message: 'No hay encuestas disponibles', icon: Icons.poll)
                  : RefreshIndicator(
                      onRefresh: _loadEncuestas,
                      child: ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: _encuestas.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 16),
                        itemBuilder: (_, i) {
                          final enc = _encuestas[i];
                          return CustomCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(enc.pregunta, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                const SizedBox(height: 12),
                                ...List.generate(enc.opciones.length, (j) {
                                  final votos = enc.votos[j];
                                  final total = enc.votos.reduce((a, b) => a + b);
                                  final porcentaje = total > 0 ? (votos / total * 100) : 0;
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(child: Text(enc.opciones[j].texto)),
                                            Text('$votos votos (${porcentaje.toStringAsFixed(1)}%)', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        LinearProgressIndicator(value: porcentaje / 100, backgroundColor: Colors.grey.shade200),
                                      ],
                                    ),
                                  );
                                }),
                                if (!enc.cerrada && !enc.votantes.contains(user.id)) ...[
                                  const SizedBox(height: 8),
                                  ElevatedButton(
                                    onPressed: () => _mostrarDialogoVotar(enc),
                                    child: const Text('Votar'),
                                  ),
                                ],
                              ],
                            ),
                          );
                        },
                      ),
                    ),
    );
  }

  void _mostrarDialogoVotar(Encuesta encuesta) {
    int? opcionSeleccionada;
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(encuesta.pregunta),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(encuesta.opciones.length, (i) {
              return RadioListTile<int>(
                value: i,
                groupValue: opcionSeleccionada,
                onChanged: (v) => setState(() => opcionSeleccionada = v),
                title: Text(encuesta.opciones[i].texto),
              );
            }),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
            ElevatedButton(
              onPressed: opcionSeleccionada == null
                  ? null
                  : () async {
                      await _apiService.votarEncuesta(encuesta.id, opcionSeleccionada!);
                      if (mounted) {
                        Navigator.pop(context);
                        _loadEncuestas();
                      }
                    },
              child: const Text('Confirmar'),
            ),
          ],
        ),
      ),
    );
  }
}
