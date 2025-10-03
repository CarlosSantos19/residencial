import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../services/auth_service.dart';
import '../../services/api_service.dart';
import '../../models/user.dart';

/// Panel Admin Mejorado con Estadísticas y Gráficos Profesionales
///
/// Funcionalidades:
/// - Resumen ejecutivo con KPIs principales
/// - Gráfico de barras: Pagos mensuales (últimos 6 meses)
/// - Gráfico circular: Ocupación de áreas comunes
/// - Gráfico de líneas: Tendencia de morosidad
/// - Top 5 espacios más reservados
/// - Estadísticas de vehículos visitantes
/// - Pull-to-refresh
///
/// Colores: Verde (Admin)

class PanelAdminMejorado extends StatefulWidget {
  const PanelAdminMejorado({Key? key}) : super(key: key);

  @override
  State<PanelAdminMejorado> createState() => _PanelAdminMejoradoState();
}

class _PanelAdminMejoradoState extends State<PanelAdminMejorado> {
  final ApiService _apiService = ApiService();

  bool _isLoading = true;
  String? _error;

  // Datos estadísticas generales
  int _totalResidentes = 0;
  int _totalReservasActivas = 0;
  int _totalPagosRecibidos = 0;
  double _tasaMorosidad = 0.0;
  int _vehiculosActivos = 0;
  int _pqrsAbiertas = 0;

  // Datos para gráficos
  List<Map<String, dynamic>> _pagosMensuales = [];
  List<Map<String, dynamic>> _ocupacionAreas = [];
  List<Map<String, dynamic>> _morosidadMensual = [];
  List<Map<String, dynamic>> _topEspacios = [];

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Cargar estadísticas generales
      final estadisticas = await _apiService.getEstadisticasAdmin();

      // Cargar estadísticas de pagos
      final estadisticasPagos = await _apiService.getEstadisticasPagos();

      // Cargar estadísticas de reservas
      final estadisticasReservas = await _apiService.getEstadisticasReservas();

      setState(() {
        // KPIs principales
        _totalResidentes = estadisticas['totalResidentes'] ?? 0;
        _totalReservasActivas = estadisticas['totalReservasActivas'] ?? 0;
        _totalPagosRecibidos = estadisticas['totalPagosRecibidos'] ?? 0;
        _tasaMorosidad = (estadisticas['tasaMorosidad'] ?? 0.0).toDouble();
        _vehiculosActivos = estadisticas['vehiculosActivos'] ?? 0;
        _pqrsAbiertas = estadisticas['pqrsAbiertas'] ?? 0;

        // Datos para gráficos
        _pagosMensuales = List<Map<String, dynamic>>.from(
          estadisticasPagos['pagosMensuales'] ?? []
        );
        _ocupacionAreas = List<Map<String, dynamic>>.from(
          estadisticasReservas['ocupacionAreas'] ?? []
        );
        _morosidadMensual = List<Map<String, dynamic>>.from(
          estadisticasPagos['morosidadMensual'] ?? []
        );
        _topEspacios = List<Map<String, dynamic>>.from(
          estadisticasReservas['topEspacios'] ?? []
        );

        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Error al cargar estadísticas: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final user = authService.currentUser;

    if (user == null || user.rol != UserRole.admin) {
      return const Scaffold(
        body: Center(
          child: Text('Acceso denegado. Solo administradores.'),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: RefreshIndicator(
        onRefresh: _cargarDatos,
        color: const Color(0xFF16A34A), // Verde admin
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF16A34A)),
                ),
              )
            : _error != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 64, color: Colors.red),
                        const SizedBox(height: 16),
                        Text(_error!, textAlign: TextAlign.center),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: _cargarDatos,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Reintentar'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF16A34A),
                          ),
                        ),
                      ],
                    ),
                  )
                : SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeader(user),
                        const SizedBox(height: 24),
                        _buildKPIs(),
                        const SizedBox(height: 24),
                        _buildPagosMensualesChart(),
                        const SizedBox(height: 24),
                        _buildOcupacionAreasChart(),
                        const SizedBox(height: 24),
                        _buildMorosidadChart(),
                        const SizedBox(height: 24),
                        _buildTopEspacios(),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
      ),
    );
  }

  Widget _buildHeader(User user) {
    final ahora = DateTime.now();
    final saludo = ahora.hour < 12
        ? '¡Buenos días!'
        : ahora.hour < 18
            ? '¡Buenas tardes!'
            : '¡Buenas noches!';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF16A34A), Color(0xFF15803D)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF16A34A).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 32,
            backgroundColor: Colors.white,
            child: Icon(
              Icons.admin_panel_settings,
              size: 36,
              color: Color(0xFF16A34A),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  saludo,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user.nombre,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Administrador',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKPIs() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Resumen Ejecutivo',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF16A34A),
          ),
        ),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.5,
          children: [
            _buildKPICard(
              'Total Residentes',
              _totalResidentes.toString(),
              Icons.people,
              Colors.blue,
            ),
            _buildKPICard(
              'Reservas Activas',
              _totalReservasActivas.toString(),
              Icons.calendar_today,
              Colors.purple,
            ),
            _buildKPICard(
              'Pagos Recibidos',
              '\$${_totalPagosRecibidos.toString()}',
              Icons.attach_money,
              Colors.green,
            ),
            _buildKPICard(
              'Morosidad',
              '${_tasaMorosidad.toStringAsFixed(1)}%',
              Icons.warning,
              _tasaMorosidad > 20 ? Colors.red : Colors.orange,
            ),
            _buildKPICard(
              'Vehículos Activos',
              _vehiculosActivos.toString(),
              Icons.directions_car,
              Colors.indigo,
            ),
            _buildKPICard(
              'PQRS Abiertas',
              _pqrsAbiertas.toString(),
              Icons.support_agent,
              _pqrsAbiertas > 5 ? Colors.red : Colors.teal,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildKPICard(String titulo, String valor, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 24),
              const Spacer(),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(icon, color: color, size: 16),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            valor,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            titulo,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPagosMensualesChart() {
    if (_pagosMensuales.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.bar_chart, color: Color(0xFF16A34A), size: 24),
              const SizedBox(width: 8),
              const Text(
                'Pagos Mensuales',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Últimos ${_pagosMensuales.length} meses',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: _getMaxPago() * 1.2,
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    tooltipBgColor: Colors.grey[800]!,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final mes = _pagosMensuales[groupIndex]['mes'];
                      final total = rod.toY.toInt();
                      return BarTooltipItem(
                        '$mes\n\$${total.toString()}',
                        const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() < _pagosMensuales.length) {
                          final mes = _pagosMensuales[value.toInt()]['mes'];
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              mes.toString().substring(0, 3),
                              style: const TextStyle(fontSize: 10),
                            ),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          '\$${(value ~/ 1000)}k',
                          style: const TextStyle(fontSize: 10),
                        );
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: _getMaxPago() / 5,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Colors.grey[200]!,
                      strokeWidth: 1,
                    );
                  },
                ),
                borderData: FlBorderData(show: false),
                barGroups: _pagosMensuales.asMap().entries.map((entry) {
                  final index = entry.key;
                  final data = entry.value;
                  final total = (data['total'] ?? 0).toDouble();

                  return BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: total,
                        color: const Color(0xFF16A34A),
                        width: 16,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(4),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOcupacionAreasChart() {
    if (_ocupacionAreas.isEmpty) {
      return const SizedBox.shrink();
    }

    final total = _ocupacionAreas.fold<double>(
      0,
      (sum, item) => sum + (item['reservas'] ?? 0).toDouble(),
    );

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.pie_chart, color: Color(0xFF16A34A), size: 24),
              const SizedBox(width: 8),
              const Text(
                'Ocupación de Áreas Comunes',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Total: ${total.toInt()} reservas este mes',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 200,
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 2,
                      centerSpaceRadius: 50,
                      sections: _ocupacionAreas.asMap().entries.map((entry) {
                        final index = entry.key;
                        final data = entry.value;
                        final reservas = (data['reservas'] ?? 0).toDouble();
                        final porcentaje = total > 0 ? (reservas / total * 100) : 0;

                        return PieChartSectionData(
                          value: reservas,
                          title: '${porcentaje.toStringAsFixed(0)}%',
                          color: _getColorForIndex(index),
                          radius: 60,
                          titleStyle: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: _ocupacionAreas.asMap().entries.map((entry) {
                      final index = entry.key;
                      final data = entry.value;
                      final espacio = data['espacio'] ?? 'Desconocido';
                      final reservas = data['reservas'] ?? 0;

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: _getColorForIndex(index),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                espacio,
                                style: const TextStyle(fontSize: 12),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text(
                              reservas.toString(),
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMorosidadChart() {
    if (_morosidadMensual.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.show_chart, color: Color(0xFF16A34A), size: 24),
              const SizedBox(width: 8),
              const Text(
                'Tendencia de Morosidad',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Últimos ${_morosidadMensual.length} meses',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 5,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Colors.grey[200]!,
                      strokeWidth: 1,
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() < _morosidadMensual.length) {
                          final mes = _morosidadMensual[value.toInt()]['mes'];
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              mes.toString().substring(0, 3),
                              style: const TextStyle(fontSize: 10),
                            ),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          '${value.toInt()}%',
                          style: const TextStyle(fontSize: 10),
                        );
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                minY: 0,
                maxY: _getMaxMorosidad() * 1.2,
                lineBarsData: [
                  LineChartBarData(
                    spots: _morosidadMensual.asMap().entries.map((entry) {
                      final index = entry.key;
                      final porcentaje = (entry.value['porcentaje'] ?? 0).toDouble();
                      return FlSpot(index.toDouble(), porcentaje);
                    }).toList(),
                    isCurved: true,
                    color: Colors.red,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 4,
                          color: Colors.red,
                          strokeWidth: 2,
                          strokeColor: Colors.white,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      color: Colors.red.withOpacity(0.1),
                    ),
                  ),
                ],
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    tooltipBgColor: Colors.grey[800]!,
                    getTooltipItems: (touchedSpots) {
                      return touchedSpots.map((spot) {
                        final mes = _morosidadMensual[spot.x.toInt()]['mes'];
                        return LineTooltipItem(
                          '$mes\n${spot.y.toStringAsFixed(1)}%',
                          const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      }).toList();
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopEspacios() {
    if (_topEspacios.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.emoji_events, color: Color(0xFF16A34A), size: 24),
              const SizedBox(width: 8),
              const Text(
                'Top 5 Espacios Más Reservados',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ..._topEspacios.asMap().entries.map((entry) {
            final index = entry.key;
            final data = entry.value;
            final espacio = data['espacio'] ?? 'Desconocido';
            final reservas = data['reservas'] ?? 0;
            final maxReservas = _topEspacios[0]['reservas'] ?? 1;
            final porcentaje = (reservas / maxReservas * 100).toDouble();

            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: index == 0
                              ? const Color(0xFFFFD700) // Oro
                              : index == 1
                                  ? const Color(0xFFC0C0C0) // Plata
                                  : index == 2
                                      ? const Color(0xFFCD7F32) // Bronce
                                      : Colors.grey[300],
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '${index + 1}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: index < 3 ? Colors.white : Colors.black,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          espacio,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      Text(
                        '$reservas reservas',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF16A34A),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: porcentaje / 100,
                      minHeight: 8,
                      backgroundColor: Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        index == 0
                            ? const Color(0xFFFFD700)
                            : index == 1
                                ? const Color(0xFFC0C0C0)
                                : index == 2
                                    ? const Color(0xFFCD7F32)
                                    : const Color(0xFF16A34A),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  double _getMaxPago() {
    if (_pagosMensuales.isEmpty) return 1000000;
    return _pagosMensuales
        .map((e) => (e['total'] ?? 0).toDouble())
        .reduce((a, b) => a > b ? a : b);
  }

  double _getMaxMorosidad() {
    if (_morosidadMensual.isEmpty) return 30;
    return _morosidadMensual
        .map((e) => (e['porcentaje'] ?? 0).toDouble())
        .reduce((a, b) => a > b ? a : b);
  }

  Color _getColorForIndex(int index) {
    const colors = [
      Color(0xFF16A34A), // Verde
      Color(0xFF2563EB), // Azul
      Color(0xFFEA580C), // Naranja
      Color(0xFF9333EA), // Púrpura
      Color(0xFFDC2626), // Rojo
      Color(0xFF0891B2), // Cian
      Color(0xFFCA8A04), // Amarillo
    ];
    return colors[index % colors.length];
  }
}
