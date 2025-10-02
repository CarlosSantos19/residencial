import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../services/auth_service.dart';
import '../../services/api_service.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/error_widget.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/custom_card.dart';

class PanelAdminScreen extends StatefulWidget {
  const PanelAdminScreen({super.key});

  @override
  State<PanelAdminScreen> createState() => _PanelAdminScreenState();
}

class _PanelAdminScreenState extends State<PanelAdminScreen> {
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  String? _error;
  Map<String, dynamic> _estadisticas = {};

  @override
  void initState() {
    super.initState();
    _loadEstadisticas();
  }

  Future<void> _loadEstadisticas() async {
    setState(() => _isLoading = true);
    try {
      final authService = context.read<AuthService>();
      _apiService.setToken(authService.token!);
      final stats = await _apiService.getEstadisticas();
      setState(() {
        _estadisticas = stats;
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
        title: const Text('Panel de Administración'),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [user.rol.gradientStart, user.rol.gradientEnd]),
          ),
        ),
      ),
      body: _isLoading
          ? const LoadingWidget(message: 'Cargando estadísticas...')
          : _error != null
              ? ErrorDisplayWidget(message: _error!, onRetry: _loadEstadisticas)
              : RefreshIndicator(
                  onRefresh: _loadEstadisticas,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildStatsGrid(),
                        const SizedBox(height: 24),
                        const Text('Resumen Mensual', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        CustomCard(
                          child: SizedBox(
                            height: 200,
                            child: _buildChart(),
                          ),
                        ),
                        const SizedBox(height: 24),
                        _buildAccesosRapidos(),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildStatsGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.3,
      children: [
        StatCard(
          title: 'Total Residentes',
          value: '${_estadisticas['totalResidentes'] ?? 0}',
          icon: Icons.people,
          color: const Color(0xFF16A34A),
        ),
        StatCard(
          title: 'Pagos Pendientes',
          value: '${_estadisticas['pagosPendientes'] ?? 0}',
          icon: Icons.payment,
          color: const Color(0xFFEF4444),
        ),
        StatCard(
          title: 'Reservas Activas',
          value: '${_estadisticas['reservasActivas'] ?? 0}',
          icon: Icons.calendar_today,
          color: const Color(0xFF3B82F6),
        ),
        StatCard(
          title: 'PQRS Abiertas',
          value: '${_estadisticas['pqrsAbiertas'] ?? 0}',
          icon: Icons.support_agent,
          color: const Color(0xFFF59E0B),
        ),
      ],
    );
  }

  Widget _buildChart() {
    return LineChart(
      LineChartData(
        gridData: FlGridData(show: false),
        titlesData: FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: [
              const FlSpot(0, 3),
              const FlSpot(1, 1),
              const FlSpot(2, 4),
              const FlSpot(3, 2),
              const FlSpot(4, 5),
              const FlSpot(5, 3),
            ],
            isCurved: true,
            color: const Color(0xFF16A34A),
            barWidth: 3,
            dotData: FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: const Color(0xFF16A34A).withOpacity(0.1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccesosRapidos() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Accesos Rápidos', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 3,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          children: [
            _buildQuickAction(Icons.people, 'Usuarios', Colors.blue),
            _buildQuickAction(Icons.attach_money, 'Pagos', Colors.green),
            _buildQuickAction(Icons.apartment, 'Sorteo', Colors.orange),
            _buildQuickAction(Icons.article, 'Noticias', Colors.purple),
            _buildQuickAction(Icons.poll, 'Encuestas', Colors.indigo),
            _buildQuickAction(Icons.support, 'PQRS', Colors.red),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickAction(IconData icon, String label, Color color) {
    return CustomCard(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
