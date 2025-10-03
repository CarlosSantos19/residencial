import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:confetti/confetti.dart';
import 'package:intl/intl.dart';
import '../../services/auth_service.dart';
import '../../services/api_service.dart';
import '../../services/pdf_service.dart';
import '../../models/user.dart';
import '../../models/asignacion_parqueadero.dart';

class SorteoParqueaderosMejorado extends StatefulWidget {
  const SorteoParqueaderosMejorado({super.key});

  @override
  State<SorteoParqueaderosMejorado> createState() => _SorteoParqueaderosMejoradoState();
}

class _SorteoParqueaderosMejoradoState extends State<SorteoParqueaderosMejorado>
    with SingleTickerProviderStateMixin {
  final ApiService _apiService = ApiService();
  final PdfService _pdfService = PdfService();

  late ConfettiController _confettiController;
  late AnimationController _animationController;

  bool _isLoading = false;
  bool _sorteoEnProgreso = false;
  List<AsignacionParqueadero> _asignaciones = [];
  List<AsignacionParqueadero> _ultimoSorteo = [];
  DateTime? _fechaUltimoSorteo;

  final int _totalParqueaderos = 100;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 5));
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _cargarUltimoSorteo();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _cargarUltimoSorteo() async {
    setState(() => _isLoading = true);

    try {
      final authService = context.read<AuthService>();
      _apiService.setToken(authService.token!);

      final resultado = await _apiService.getUltimoSorteoParqueaderos();

      if (resultado != null) {
        final asignacionesData = resultado['asignaciones'] as List<dynamic>?;
        setState(() {
          _ultimoSorteo = asignacionesData
              ?.map((a) => AsignacionParqueadero.fromJson(a as Map<String, dynamic>))
              .toList() ?? [];
          _fechaUltimoSorteo = resultado['fecha'] != null
              ? DateTime.parse(resultado['fecha'] as String)
              : null;
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar sorteo: $e')),
        );
      }
    }
  }

  Future<void> _realizarSorteo() async {
    // Confirmar acción
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning_amber, color: Colors.orange),
            SizedBox(width: 8),
            Text('Confirmar Sorteo'),
          ],
        ),
        content: const Text(
          '¿Estás seguro de realizar el sorteo de parqueaderos?\n\n'
          'Esta acción sobrescribirá las asignaciones anteriores.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
            ),
            child: const Text('Realizar Sorteo'),
          ),
        ],
      ),
    );

    if (confirmar != true) return;

    setState(() {
      _sorteoEnProgreso = true;
      _asignaciones = [];
    });

    try {
      final authService = context.read<AuthService>();
      _apiService.setToken(authService.token!);

      // Obtener residentes activos
      final residentes = await _apiService.getResidentesActivos();

      // Generar lista de parqueaderos (1 a 100)
      final parqueaderos = List.generate(_totalParqueaderos, (i) => i + 1);

      // Mezclar aleatoriamente
      parqueaderos.shuffle(Random());

      // Asignar parqueaderos a residentes
      final asignaciones = <AsignacionParqueadero>[];

      for (int i = 0; i < residentes.length && i < parqueaderos.length; i++) {
        // Simular delay para animación
        await Future.delayed(const Duration(milliseconds: 100));

        final asignacion = AsignacionParqueadero(
          torre: _extraerTorre(residentes[i].apartamento),
          apartamento: residentes[i].apartamento,
          nombreResidente: residentes[i].nombre,
          numeroParqueadero: parqueaderos[i],
          usuarioId: residentes[i].id,
        );

        asignaciones.add(asignacion);

        setState(() {
          _asignaciones = List.from(asignaciones);
        });
      }

      // Guardar en backend
      await _apiService.guardarSorteoParqueaderos(asignaciones);

      // Animación de éxito
      _confettiController.play();
      _animationController.forward();

      setState(() {
        _sorteoEnProgreso = false;
        _ultimoSorteo = asignaciones;
        _fechaUltimoSorteo = DateTime.now();
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Sorteo completado: ${asignaciones.length} parqueaderos asignados'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      setState(() => _sorteoEnProgreso = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error en el sorteo: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _generarReportePDF() async {
    if (_ultimoSorteo.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No hay sorteo para generar reporte')),
      );
      return;
    }

    try {
      await _pdfService.generarReporteSorteo(
        fechaSorteo: _fechaUltimoSorteo ?? DateTime.now(),
        asignaciones: _ultimoSorteo,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('📄 Reporte PDF generado'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error generando PDF: $e')),
        );
      }
    }
  }

  String _extraerTorre(String apartamento) {
    // Extraer número de torre del apartamento (ej: "101" -> "1", "502" -> "5")
    if (apartamento.length >= 1) {
      return apartamento[0];
    }
    return '1';
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthService>().currentUser!;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: Stack(
        children: [
          _buildBody(user),

          // Confetti overlay
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              numberOfParticles: 30,
              maxBlastForce: 20,
              minBlastForce: 10,
              emissionFrequency: 0.05,
              gravity: 0.3,
              colors: const [
                Colors.green,
                Colors.blue,
                Colors.pink,
                Colors.orange,
                Colors.purple,
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(User user) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          _buildHeader(),

          const SizedBox(height: 24),

          // Estadísticas
          _buildEstadisticas(),

          const SizedBox(height: 24),

          // Botón de sorteo
          if (!_sorteoEnProgreso)
            _buildBotonSorteo()
          else
            _buildAnimacionSorteo(),

          const SizedBox(height: 24),

          // Resultados
          if (_asignaciones.isNotEmpty || _ultimoSorteo.isNotEmpty)
            _buildResultados(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF16A34A), Color(0xFF22C55E)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.casino,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sorteo de Parqueaderos',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Asignación aleatoria y transparente',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          if (_fechaUltimoSorteo != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today, color: Colors.white, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    'Último sorteo: ${DateFormat('dd/MM/yyyy HH:mm').format(_fechaUltimoSorteo!)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEstadisticas() {
    final asignados = _ultimoSorteo.length;
    final disponibles = _totalParqueaderos - asignados;

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Total Parqueaderos',
            _totalParqueaderos.toString(),
            Icons.local_parking,
            Colors.blue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Asignados',
            asignados.toString(),
            Icons.check_circle,
            Colors.green,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Disponibles',
            disponibles.toString(),
            Icons.inventory_2,
            Colors.orange,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildBotonSorteo() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton.icon(
            onPressed: _realizarSorteo,
            icon: const Icon(Icons.casino, size: 24),
            label: const Text(
              'REALIZAR SORTEO',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade600,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 5,
            ),
          ),
        ),

        if (_ultimoSorteo.isNotEmpty) ...[
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton.icon(
              onPressed: _generarReportePDF,
              icon: const Icon(Icons.picture_as_pdf),
              label: const Text('Exportar a PDF'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.green.shade700,
                side: BorderSide(color: Colors.green.shade700),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildAnimacionSorteo() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          const SizedBox(
            width: 60,
            height: 60,
            child: CircularProgressIndicator(
              strokeWidth: 6,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Realizando sorteo...',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${_asignaciones.length} parqueaderos asignados',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultados() {
    final resultados = _asignaciones.isNotEmpty ? _asignaciones : _ultimoSorteo;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Resultados del Sorteo',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Chip(
              label: Text('${resultados.length} asignados'),
              backgroundColor: Colors.green.shade100,
              labelStyle: TextStyle(
                color: Colors.green.shade700,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Tabla de resultados
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
                child: Row(
                  children: [
                    _buildTableHeader('Torre', flex: 1),
                    _buildTableHeader('Apto', flex: 1),
                    _buildTableHeader('Residente', flex: 3),
                    _buildTableHeader('Parqueadero', flex: 2),
                  ],
                ),
              ),

              // Rows
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: resultados.length,
                separatorBuilder: (_, __) => Divider(
                  height: 1,
                  color: Colors.grey.shade200,
                ),
                itemBuilder: (context, index) {
                  final asignacion = resultados[index];
                  return Container(
                    padding: const EdgeInsets.all(12),
                    color: index % 2 == 0 ? Colors.white : Colors.grey.shade50,
                    child: Row(
                      children: [
                        _buildTableCell(asignacion.torre, flex: 1),
                        _buildTableCell(asignacion.apartamento, flex: 1),
                        _buildTableCell(
                          asignacion.nombreResidente,
                          flex: 3,
                          bold: false,
                        ),
                        _buildTableCell(
                          'P-${asignacion.numeroParqueadero}',
                          flex: 2,
                          color: Colors.green.shade700,
                          bold: true,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTableHeader(String text, {int flex = 1}) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 12,
          color: Colors.green.shade800,
        ),
      ),
    );
  }

  Widget _buildTableCell(
    String text, {
    int flex = 1,
    bool bold = false,
    Color? color,
  }) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: bold ? FontWeight.bold : FontWeight.normal,
          color: color ?? Colors.black87,
        ),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
