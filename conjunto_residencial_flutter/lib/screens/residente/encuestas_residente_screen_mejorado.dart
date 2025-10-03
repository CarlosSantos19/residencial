import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../services/auth_service.dart';
import '../../services/api_service.dart';
import '../../models/encuesta.dart';
import '../../models/user.dart';

/// Pantalla de Encuestas Mejorada - Residente
///
/// Funcionalidades:
/// - Ver encuestas activas y cerradas
/// - Votar en encuestas activas
/// - Ver resultados en tiempo real con gráficos (BarChart)
/// - Auto-refresh cada 10 segundos para ver votos actualizados
/// - Validación: solo un voto por usuario
///
/// Color: Azul (Residente)

class EncuestasResidenteScreenMejorado extends StatefulWidget {
  const EncuestasResidenteScreenMejorado({Key? key}) : super(key: key);

  @override
  State<EncuestasResidenteScreenMejorado> createState() =>
      _EncuestasResidenteScreenMejoradoState();
}

class _EncuestasResidenteScreenMejoradoState
    extends State<EncuestasResidenteScreenMejorado> with TickerProviderStateMixin {
  final ApiService _apiService = ApiService();

  late TabController _tabController;

  List<Encuesta> _encuestasActivas = [];
  List<Encuesta> _encuestasCerradas = [];

  bool _isLoading = true;
  String? _error;

  // Auto-refresh
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _cargarEncuestas();

    // Auto-refresh cada 10 segundos para ver resultados actualizados
    Future.delayed(const Duration(seconds: 10), _autoRefresh);
  }

  void _autoRefresh() {
    if (mounted) {
      _cargarEncuestas();
      Future.delayed(const Duration(seconds: 10), _autoRefresh);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _cargarEncuestas() async {
    try {
      final encuestas = await _apiService.getEncuestasActivas();

      if (mounted) {
        setState(() {
          _encuestasActivas = encuestas.where((e) => e.activa).toList();
          _encuestasCerradas = encuestas.where((e) => !e.activa).toList();
          _isLoading = false;
          _error = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Error al cargar encuestas: $e';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final user = authService.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Usuario no autenticado')),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Encuestas'),
        backgroundColor: const Color(0xFF2563EB),
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
          tabs: const [
            Tab(text: 'Activas'),
            Tab(text: 'Cerradas'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2563EB)),
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
                      ElevatedButton(
                        onPressed: _cargarEncuestas,
                        child: const Text('Reintentar'),
                      ),
                    ],
                  ),
                )
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildEncuestasActivas(user),
                    _buildEncuestasCerradas(user),
                  ],
                ),
    );
  }

  Widget _buildEncuestasActivas(User user) {
    if (_encuestasActivas.isEmpty) {
      return _buildEmptyState(
        'No hay encuestas activas',
        'Las nuevas encuestas aparecerán aquí',
        Icons.poll,
      );
    }

    return RefreshIndicator(
      onRefresh: _cargarEncuestas,
      color: const Color(0xFF2563EB),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _encuestasActivas.length,
        itemBuilder: (context, index) {
          final encuesta = _encuestasActivas[index];
          final haVotado = encuesta.haVotado(user.id);

          return _buildEncuestaCard(
            encuesta,
            user,
            activa: true,
            haVotado: haVotado,
          );
        },
      ),
    );
  }

  Widget _buildEncuestasCerradas(User user) {
    if (_encuestasCerradas.isEmpty) {
      return _buildEmptyState(
        'No hay encuestas cerradas',
        'Las encuestas finalizadas aparecerán aquí',
        Icons.poll_outlined,
      );
    }

    return RefreshIndicator(
      onRefresh: _cargarEncuestas,
      color: const Color(0xFF2563EB),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _encuestasCerradas.length,
        itemBuilder: (context, index) {
          final encuesta = _encuestasCerradas[index];
          final haVotado = encuesta.haVotado(user.id);

          return _buildEncuestaCard(
            encuesta,
            user,
            activa: false,
            haVotado: haVotado,
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(String titulo, String subtitulo, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            titulo,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitulo,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildEncuestaCard(
    Encuesta encuesta,
    User user, {
    required bool activa,
    required bool haVotado,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2563EB).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.poll,
                    color: Color(0xFF2563EB),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        encuesta.pregunta,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Por ${encuesta.creadoPorNombre}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                if (!activa)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Cerrada',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 20),

            // Si ya votó o está cerrada, mostrar resultados
            if (haVotado || !activa) ...[
              _buildResultados(encuesta),
              const SizedBox(height: 16),
              _buildGraficoBarras(encuesta),
            ]
            // Si no ha votado y está activa, mostrar opciones para votar
            else ...[
              ...encuesta.opciones.asMap().entries.map((entry) {
                final index = entry.key;
                final opcion = entry.value;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: InkWell(
                    onTap: () => _votar(encuesta, index, user),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFF2563EB)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.radio_button_unchecked,
                            color: Color(0xFF2563EB),
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              opcion.texto,
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ],

            // Footer
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.how_to_vote, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  '${encuesta.totalVotos} ${encuesta.totalVotos == 1 ? "voto" : "votos"}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(width: 16),
                Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  _formatearFecha(encuesta.fechaCreacion),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                if (haVotado) ...[
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.green),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.check_circle, size: 14, color: Colors.green),
                        SizedBox(width: 4),
                        Text(
                          'Ya votaste',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultados(Encuesta encuesta) {
    return Column(
      children: encuesta.opciones.map((opcion) {
        final porcentaje = opcion.porcentaje(encuesta.totalVotos);

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      opcion.texto,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Text(
                    '${porcentaje.toStringAsFixed(1)}%',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2563EB),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: porcentaje / 100,
                  minHeight: 10,
                  backgroundColor: Colors.grey[200],
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    Color(0xFF2563EB),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${opcion.votos} ${opcion.votos == 1 ? "voto" : "votos"}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildGraficoBarras(Encuesta encuesta) {
    if (encuesta.totalVotos == 0) {
      return const SizedBox.shrink();
    }

    final maxVotos = encuesta.opciones
        .map((o) => o.votos)
        .reduce((a, b) => a > b ? a : b);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Distribución de votos',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2563EB),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 150,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: maxVotos.toDouble() * 1.2,
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    tooltipBgColor: Colors.grey[800]!,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final opcion = encuesta.opciones[groupIndex];
                      final porcentaje = opcion.porcentaje(encuesta.totalVotos);
                      return BarTooltipItem(
                        '${opcion.texto}\n${opcion.votos} votos (${porcentaje.toStringAsFixed(1)}%)',
                        const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
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
                        if (value.toInt() < encuesta.opciones.length) {
                          final texto = encuesta.opciones[value.toInt()].texto;
                          // Tomar primeras 10 letras
                          final textoCorto = texto.length > 10
                              ? '${texto.substring(0, 10)}...'
                              : texto;
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              textoCorto,
                              style: const TextStyle(fontSize: 9),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
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
                      reservedSize: 30,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt().toString(),
                          style: const TextStyle(fontSize: 10),
                        );
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: maxVotos > 5 ? (maxVotos / 5).toDouble() : 1,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Colors.grey[300]!,
                      strokeWidth: 1,
                    );
                  },
                ),
                borderData: FlBorderData(show: false),
                barGroups: encuesta.opciones.asMap().entries.map((entry) {
                  final index = entry.key;
                  final opcion = entry.value;

                  return BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: opcion.votos.toDouble(),
                        color: const Color(0xFF2563EB),
                        width: 20,
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

  Future<void> _votar(Encuesta encuesta, int opcionIndex, User user) async {
    try {
      await _apiService.responderEncuesta(encuesta.id, opcionIndex);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('¡Voto registrado exitosamente!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );

        // Recargar para ver resultados actualizados
        await _cargarEncuestas();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al votar: $e')),
        );
      }
    }
  }

  String _formatearFecha(DateTime fecha) {
    final ahora = DateTime.now();
    final diferencia = ahora.difference(fecha);

    if (diferencia.inDays == 0) {
      return 'Hoy';
    } else if (diferencia.inDays == 1) {
      return 'Ayer';
    } else if (diferencia.inDays < 7) {
      return 'Hace ${diferencia.inDays} días';
    } else {
      return '${fecha.day}/${fecha.month}/${fecha.year}';
    }
  }
}
