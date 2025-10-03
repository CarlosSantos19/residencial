import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../services/auth_service.dart';
import '../../services/api_service.dart';
import '../../models/encuesta.dart';
import '../../models/user.dart';

/// Pantalla de Encuestas Admin Mejorada
///
/// Funcionalidades:
/// - Ver todas las encuestas con resultados
/// - Crear nuevas encuestas (hasta 6 opciones)
/// - Cerrar encuestas activas
/// - Ver estadísticas detalladas con gráficos
/// - Gráfico de barras para cada encuesta
///
/// Color: Verde (Admin)

class EncuestasAdminScreenMejorado extends StatefulWidget {
  const EncuestasAdminScreenMejorado({Key? key}) : super(key: key);

  @override
  State<EncuestasAdminScreenMejorado> createState() =>
      _EncuestasAdminScreenMejoradoState();
}

class _EncuestasAdminScreenMejoradoState
    extends State<EncuestasAdminScreenMejorado> with TickerProviderStateMixin {
  final ApiService _apiService = ApiService();

  late TabController _tabController;

  List<Encuesta> _encuestasActivas = [];
  List<Encuesta> _encuestasCerradas = [];

  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _cargarEncuestas();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _cargarEncuestas() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final encuestas = await _apiService.getEncuestasActivas();

      setState(() {
        _encuestasActivas = encuestas.where((e) => e.activa).toList();
        _encuestasCerradas = encuestas.where((e) => !e.activa).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Error al cargar encuestas: $e';
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
        body: Center(child: Text('Acceso denegado. Solo administradores.')),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Administrar Encuestas'),
        backgroundColor: const Color(0xFF16A34A),
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
          tabs: [
            Tab(text: 'Activas (${_encuestasActivas.length})'),
            Tab(text: 'Cerradas (${_encuestasCerradas.length})'),
          ],
        ),
      ),
      body: _isLoading
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _mostrarFormularioCrear(user),
        backgroundColor: const Color(0xFF16A34A),
        icon: const Icon(Icons.add),
        label: const Text('Nueva Encuesta'),
      ),
    );
  }

  Widget _buildEncuestasActivas(User user) {
    if (_encuestasActivas.isEmpty) {
      return _buildEmptyState(
        'No hay encuestas activas',
        'Crea una nueva encuesta para empezar',
        Icons.poll,
      );
    }

    return RefreshIndicator(
      onRefresh: _cargarEncuestas,
      color: const Color(0xFF16A34A),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _encuestasActivas.length,
        itemBuilder: (context, index) {
          final encuesta = _encuestasActivas[index];
          return _buildEncuestaCard(encuesta, activa: true);
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
      color: const Color(0xFF16A34A),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _encuestasCerradas.length,
        itemBuilder: (context, index) {
          final encuesta = _encuestasCerradas[index];
          return _buildEncuestaCard(encuesta, activa: false);
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

  Widget _buildEncuestaCard(Encuesta encuesta, {required bool activa}) {
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
                    color: const Color(0xFF16A34A).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.poll,
                    color: Color(0xFF16A34A),
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
                if (activa)
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert),
                    onSelected: (value) {
                      if (value == 'cerrar') {
                        _cerrarEncuesta(encuesta);
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'cerrar',
                        child: Row(
                          children: [
                            Icon(Icons.close, size: 20),
                            SizedBox(width: 8),
                            Text('Cerrar encuesta'),
                          ],
                        ),
                      ),
                    ],
                  )
                else
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

            // Resultados
            _buildResultados(encuesta),

            // Gráfico
            const SizedBox(height: 16),
            _buildGraficoBarras(encuesta),

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
                Icon(Icons.people, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  '${encuesta.usuariosVotaron.length} participantes',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const Spacer(),
                Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  _formatearFecha(encuesta.fechaCreacion),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
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
                      color: Color(0xFF16A34A),
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
                    Color(0xFF16A34A),
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
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Center(
          child: Text(
            'Sin votos aún',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ),
      );
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
              color: Color(0xFF16A34A),
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
                        color: const Color(0xFF16A34A),
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

  Future<void> _cerrarEncuesta(Encuesta encuesta) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cerrar encuesta'),
        content: const Text(
          '¿Estás seguro de cerrar esta encuesta? No se podrán agregar más votos.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF16A34A),
            ),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );

    if (confirmar != true) return;

    try {
      // En API real: await _apiService.cerrarEncuesta(encuesta.id);
      // Por ahora simulamos
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Encuesta cerrada exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
        await _cargarEncuestas();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  void _mostrarFormularioCrear(User user) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _FormularioCrearEncuesta(
        user: user,
        onCreated: _cargarEncuestas,
      ),
    );
  }

  String _formatearFecha(DateTime fecha) {
    return '${fecha.day}/${fecha.month}/${fecha.year}';
  }
}

/// Formulario para crear nueva encuesta
class _FormularioCrearEncuesta extends StatefulWidget {
  final User user;
  final VoidCallback onCreated;

  const _FormularioCrearEncuesta({
    required this.user,
    required this.onCreated,
  });

  @override
  State<_FormularioCrearEncuesta> createState() =>
      _FormularioCrearEncuestaState();
}

class _FormularioCrearEncuestaState extends State<_FormularioCrearEncuesta> {
  final ApiService _apiService = ApiService();
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _preguntaController = TextEditingController();
  final List<TextEditingController> _opcionControllers = [
    TextEditingController(),
    TextEditingController(),
  ];

  bool _enviando = false;

  @override
  void dispose() {
    _preguntaController.dispose();
    for (var controller in _opcionControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF16A34A), Color(0xFF15803D)],
                  ),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const Row(
                      children: [
                        Icon(Icons.add_circle, color: Colors.white, size: 32),
                        SizedBox(width: 12),
                        Text(
                          'Crear Nueva Encuesta',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Formulario
              Expanded(
                child: Form(
                  key: _formKey,
                  child: ListView(
                    controller: scrollController,
                    padding: const EdgeInsets.all(20),
                    children: [
                      // Pregunta
                      const Text(
                        'Pregunta',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF16A34A),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _preguntaController,
                        decoration: InputDecoration(
                          hintText: '¿Cuál es tu pregunta?',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: Color(0xFF16A34A),
                            ),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'La pregunta es obligatoria';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      // Opciones
                      Row(
                        children: [
                          const Text(
                            'Opciones de respuesta',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF16A34A),
                            ),
                          ),
                          const Spacer(),
                          if (_opcionControllers.length < 6)
                            TextButton.icon(
                              onPressed: _agregarOpcion,
                              icon: const Icon(Icons.add, size: 18),
                              label: const Text('Agregar'),
                              style: TextButton.styleFrom(
                                foregroundColor: const Color(0xFF16A34A),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ..._opcionControllers.asMap().entries.map((entry) {
                        final index = entry.key;
                        final controller = entry.value;

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: controller,
                                  decoration: InputDecoration(
                                    labelText: 'Opción ${index + 1}',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: const BorderSide(
                                        color: Color(0xFF16A34A),
                                      ),
                                    ),
                                    suffixIcon: _opcionControllers.length > 2
                                        ? IconButton(
                                            icon: const Icon(Icons.delete,
                                                color: Colors.red),
                                            onPressed: () => _eliminarOpcion(index),
                                          )
                                        : null,
                                  ),
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'Esta opción no puede estar vacía';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                      const SizedBox(height: 24),
                      // Botón crear
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _enviando ? null : _crearEncuesta,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF16A34A),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: _enviando
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              : const Text(
                                  'Crear Encuesta',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _agregarOpcion() {
    if (_opcionControllers.length < 6) {
      setState(() {
        _opcionControllers.add(TextEditingController());
      });
    }
  }

  void _eliminarOpcion(int index) {
    if (_opcionControllers.length > 2) {
      setState(() {
        _opcionControllers[index].dispose();
        _opcionControllers.removeAt(index);
      });
    }
  }

  Future<void> _crearEncuesta() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _enviando = true;
    });

    try {
      final opciones = _opcionControllers
          .map((c) => c.text.trim())
          .where((t) => t.isNotEmpty)
          .toList();

      await _apiService.crearEncuesta(
        _preguntaController.text.trim(),
        opciones,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Encuesta creada exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
        widget.onCreated();
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _enviando = false;
        });
      }
    }
  }
}
