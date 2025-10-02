import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../services/api_service.dart';
import '../../models/noticia.dart';
import '../../models/pago.dart';
import '../../models/reserva.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/error_widget.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/custom_card.dart';

class DashboardResidenteScreen extends StatefulWidget {
  const DashboardResidenteScreen({super.key});

  @override
  State<DashboardResidenteScreen> createState() => _DashboardResidenteScreenState();
}

class _DashboardResidenteScreenState extends State<DashboardResidenteScreen> {
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  String? _error;
  List<Noticia> _noticias = [];
  List<Pago> _pagosPendientes = [];
  List<Reserva> _proximasReservas = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final authService = context.read<AuthService>();
      _apiService.setToken(authService.token!);

      final results = await Future.wait([
        _apiService.getNoticias(),
        _apiService.getPagos(),
        _apiService.getMisReservas(),
      ]);

      setState(() {
        _noticias = (results[0] as List<Noticia>).take(3).toList();
        _pagosPendientes = (results[1] as List<Pago>).where((p) => p.estado == 'pendiente').toList();
        _proximasReservas = (results[2] as List<Reserva>).take(3).toList();
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
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Dashboard', style: TextStyle(fontSize: 20)),
            Text(
              'Bienvenido, ${user.nombre}',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
            ),
          ],
        ),
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
      return ErrorDisplayWidget(
        message: _error!,
        onRetry: _loadData,
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatsGrid(),
            const SizedBox(height: 24),
            _buildNoticias(),
            const SizedBox(height: 24),
            _buildPagosPendientes(),
            const SizedBox(height: 24),
            _buildProximasReservas(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsGrid() {
    final user = context.read<AuthService>().currentUser!;
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.3,
      children: [
        StatCard(
          title: 'Pagos Pendientes',
          value: '${_pagosPendientes.length}',
          icon: Icons.payment,
          color: user.rol.primaryColor,
        ),
        StatCard(
          title: 'Próximas Reservas',
          value: '${_proximasReservas.length}',
          icon: Icons.calendar_today,
          color: const Color(0xFF10B981),
        ),
        StatCard(
          title: 'Mi Apartamento',
          value: user.apartamento,
          icon: Icons.home,
          color: const Color(0xFFF59E0B),
        ),
        StatCard(
          title: 'Notificaciones',
          value: '0',
          icon: Icons.notifications,
          color: const Color(0xFFEF4444),
        ),
      ],
    );
  }

  Widget _buildNoticias() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Noticias Recientes',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        if (_noticias.isEmpty)
          const CustomCard(
            child: Text('No hay noticias disponibles'),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _noticias.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final noticia = _noticias[index];
              return CustomCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _getNoticiaColor(noticia.categoria),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            noticia.categoria.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          _formatDate(noticia.fechaPublicacion),
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      noticia.titulo,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      noticia.contenido,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                    ),
                  ],
                ),
              );
            },
          ),
      ],
    );
  }

  Widget _buildPagosPendientes() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Pagos Pendientes',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        if (_pagosPendientes.isEmpty)
          const CustomCard(
            child: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green),
                SizedBox(width: 12),
                Text('No tienes pagos pendientes'),
              ],
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _pagosPendientes.take(3).length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final pago = _pagosPendientes[index];
              return CustomCard(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.payment, color: Colors.red),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            pago.concepto,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '\$${pago.monto.toStringAsFixed(0)}',
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: context.read<AuthService>().currentUser!.rol.primaryColor,
                      ),
                      child: const Text('Pagar'),
                    ),
                  ],
                ),
              );
            },
          ),
      ],
    );
  }

  Widget _buildProximasReservas() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Próximas Reservas',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        if (_proximasReservas.isEmpty)
          const CustomCard(
            child: Text('No tienes reservas próximas'),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _proximasReservas.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final reserva = _proximasReservas[index];
              return CustomCard(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.calendar_today, color: Colors.blue),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            reserva.espacio,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '${reserva.fecha} - ${reserva.hora}',
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
      ],
    );
  }

  Color _getNoticiaColor(String tipo) {
    switch (tipo.toLowerCase()) {
      case 'urgente':
        return Colors.red;
      case 'importante':
        return Colors.orange;
      default:
        return Colors.blue;
    }
  }

  String _formatDate(String fecha) {
    try {
      final date = DateTime.parse(fecha);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return fecha;
    }
  }
}
