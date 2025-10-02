import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../services/api_service.dart';
import '../../models/noticia.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/error_widget.dart';
import '../../widgets/custom_card.dart';

class NoticiasAdminScreen extends StatefulWidget {
  const NoticiasAdminScreen({super.key});

  @override
  State<NoticiasAdminScreen> createState() => _NoticiasAdminScreenState();
}

class _NoticiasAdminScreenState extends State<NoticiasAdminScreen> {
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  String? _error;
  List<Noticia> _noticias = [];

  @override
  void initState() {
    super.initState();
    _loadNoticias();
  }

  Future<void> _loadNoticias() async {
    setState(() => _isLoading = true);
    try {
      final authService = context.read<AuthService>();
      _apiService.setToken(authService.token!);
      final noticias = await _apiService.getNoticias();
      setState(() {
        _noticias = noticias;
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
        title: const Text('Gestión de Noticias'),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [user.rol.gradientStart, user.rol.gradientEnd]),
          ),
        ),
      ),
      body: _isLoading
          ? const LoadingWidget()
          : _error != null
              ? ErrorDisplayWidget(message: _error!, onRetry: _loadNoticias)
              : RefreshIndicator(
                  onRefresh: _loadNoticias,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: _noticias.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (_, i) {
                      final n = _noticias[i];
                      return CustomCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(color: _getTipoColor(n.categoria), borderRadius: BorderRadius.circular(4)),
                                  child: Text(n.categoria.toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 10)),
                                ),
                                const Spacer(),
                                IconButton(icon: const Icon(Icons.delete), onPressed: () => _eliminarNoticia(n.id)),
                              ],
                            ),
                            Text(n.titulo, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            Text(n.contenido, style: TextStyle(color: Colors.grey.shade600)),
                            Text(n.fechaPublicacion, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                          ],
                        ),
                      );
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _mostrarDialogoNuevaNoticia,
        backgroundColor: user.rol.primaryColor,
        child: const Icon(Icons.add),
      ),
    );
  }

  void _mostrarDialogoNuevaNoticia() {
    final tituloController = TextEditingController();
    final contenidoController = TextEditingController();
    String tipo = 'general';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nueva Noticia'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: tituloController, decoration: const InputDecoration(labelText: 'Título')),
              TextField(controller: contenidoController, decoration: const InputDecoration(labelText: 'Contenido'), maxLines: 3),
              DropdownButtonFormField<String>(
                value: tipo,
                items: ['general', 'urgente', 'importante'].map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                onChanged: (v) => tipo = v!,
                decoration: const InputDecoration(labelText: 'Tipo'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () async {
              await _apiService.crearNoticia(tituloController.text, contenidoController.text, tipo);
              if (mounted) {
                Navigator.pop(context);
                _loadNoticias();
              }
            },
            child: const Text('Crear'),
          ),
        ],
      ),
    );
  }

  Future<void> _eliminarNoticia(int id) async {
    await _apiService.eliminarNoticia(id);
    _loadNoticias();
  }

  Color _getTipoColor(String tipo) {
    switch (tipo.toLowerCase()) {
      case 'urgente':
        return Colors.red;
      case 'importante':
        return Colors.orange;
      default:
        return Colors.blue;
    }
  }
}
