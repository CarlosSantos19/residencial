import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../services/auth_service.dart';
import '../../services/api_service.dart';
import '../../services/payment_service.dart';
import '../../services/pdf_service.dart';
import '../../models/vehiculo.dart';

class ControlVehiculosMejorado extends StatefulWidget {
  final TipoUsuario tipoUsuario; // residente, vigilante, admin

  const ControlVehiculosMejorado({
    super.key,
    required this.tipoUsuario,
  });

  @override
  State<ControlVehiculosMejorado> createState() => _ControlVehiculosMejoradoState();
}

class _ControlVehiculosMejoradoState extends State<ControlVehiculosMejorado> {
  final ApiService _apiService = ApiService();
  final PaymentService _paymentService = PaymentService();
  final PdfService _pdfService = PdfService();

  List<VehiculoVisitante> _vehiculos = [];
  bool _isLoading = true;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _cargarVehiculos();

    // Actualizar cada segundo para mostrar el tiempo en vivo
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _cargarVehiculos() async {
    setState(() => _isLoading = true);

    try {
      final authService = context.read<AuthService>();
      _apiService.setToken(authService.token!);

      List<VehiculoVisitante> vehiculos;

      switch (widget.tipoUsuario) {
        case TipoUsuario.residente:
          // Solo vehículos visitando SU apartamento
          vehiculos = await _apiService.getVehiculosDeApartamento(
            authService.currentUser!.apartamento,
          );
          break;
        case TipoUsuario.vigilante:
        case TipoUsuario.admin:
          // Todos los vehículos activos
          vehiculos = await _apiService.getTodosVehiculosActivos();
          break;
      }

      setState(() {
        _vehiculos = vehiculos;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _registrarSalida(VehiculoVisitante vehiculo) async {
    // Mostrar diálogo con resumen y método de pago
    final metodoPago = await showDialog<MetodoPago>(
      context: context,
      builder: (context) => _DialogoSalidaVehiculo(vehiculo: vehiculo),
    );

    if (metodoPago == null) return;

    try {
      final authService = context.read<AuthService>();
      _apiService.setToken(authService.token!);

      // Registrar salida en backend
      await _apiService.registrarSalidaVehiculo(
        vehiculo.id,
        metodoPago: metodoPago.name,
      );

      // Generar recibo PDF
      await _generarRecibo(vehiculo, metodoPago);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Salida registrada y recibo generado'),
            backgroundColor: Colors.green,
          ),
        );
      }

      _cargarVehiculos();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _generarRecibo(
    VehiculoVisitante vehiculo,
    MetodoPago metodoPago,
  ) async {
    final tiempoTotal = vehiculo.tiempoTranscurrido;
    final valorTotal = vehiculo.valorAPagar;

    await _pdfService.generarReciboVehiculo(
      placa: vehiculo.placa,
      apartamento: vehiculo.apartamentoDestino,
      horaEntrada: vehiculo.horaEntrada,
      horaSalida: vehiculo.fechaSalida ?? DateTime.now(),
      tiempoTotal: tiempoTotal,
      valorTotal: valorTotal.toDouble(),
      metodoPago: metodoPago.displayName,
      detalleCalculo: _generarDetalleCalculo(vehiculo),
    );
  }

  String _generarDetalleCalculo(VehiculoVisitante vehiculo) {
    final horas = vehiculo.tiempoTranscurrido.inHours;
    final dias = vehiculo.tiempoTranscurrido.inDays;

    if (dias >= 1) {
      return '''
Tiempo total: $dias día(s) + ${horas % 24} hora(s)
Tarifa aplicada: \$12,000 por día
Cálculo: $dias × \$12,000 = \$${vehiculo.valorAPagar}
''';
    }

    if (horas <= 2) {
      return '''
Tiempo total: $horas hora(s)
Tarifa aplicada: GRATIS (primeras 2 horas)
Total: \$0
''';
    }

    if (horas <= 10) {
      final horasCobradas = horas - 2;
      return '''
Tiempo total: $horas hora(s)
Primeras 2 horas: GRATIS
Horas adicionales: $horasCobradas × \$1,000 = \$${vehiculo.valorAPagar}
''';
    }

    return '''
Tiempo total: $horas hora(s)
Tarifa aplicada: \$12,000 (más de 10 horas)
''';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _cargarVehiculos,
              child: _vehiculos.isEmpty
                  ? _buildEstadoVacio()
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _vehiculos.length,
                      itemBuilder: (context, index) {
                        return _buildVehiculoCard(_vehiculos[index]);
                      },
                    ),
            ),
      floatingActionButton: (widget.tipoUsuario == TipoUsuario.vigilante ||
              widget.tipoUsuario == TipoUsuario.admin)
          ? FloatingActionButton.extended(
              onPressed: _mostrarFormularioIngreso,
              icon: const Icon(Icons.add),
              label: const Text('Registrar Ingreso'),
            )
          : null,
    );
  }

  Widget _buildEstadoVacio() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.directions_car_outlined,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'No hay vehículos visitantes',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.tipoUsuario == TipoUsuario.residente
                ? 'No tienes vehículos visitándote'
                : 'No hay vehículos en el conjunto',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVehiculoCard(VehiculoVisitante vehiculo) {
    final tiempoTranscurrido = vehiculo.tiempoTranscurrido;
    final valorActual = vehiculo.valorAPagar;
    final esGratis = valorActual == 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          // Header con placa
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: vehiculo.activo
                    ? [Colors.green.shade600, Colors.green.shade400]
                    : [Colors.grey.shade600, Colors.grey.shade400],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.black, width: 2),
                  ),
                  child: Text(
                    vehiculo.placa.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                ),
                const Spacer(),
                if (vehiculo.activo)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          'EN VISITA',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),

          // Información del vehículo
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildInfoRow(
                  Icons.home,
                  'Apartamento',
                  vehiculo.apartamentoDestino,
                ),
                const Divider(height: 24),
                _buildInfoRow(
                  Icons.login,
                  'Entrada',
                  _formatearFechaHora(vehiculo.horaEntrada),
                ),
                if (!vehiculo.activo && vehiculo.fechaSalida != null) ...[
                  const SizedBox(height: 8),
                  _buildInfoRow(
                    Icons.logout,
                    'Salida',
                    _formatearFechaHora(vehiculo.fechaSalida!),
                  ),
                ],
                const Divider(height: 24),

                // Timer en vivo
                _buildTimerDisplay(tiempoTranscurrido, vehiculo.activo),

                const SizedBox(height: 16),

                // Valor acumulado
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: esGratis
                          ? [Colors.green.shade50, Colors.green.shade100]
                          : [Colors.orange.shade50, Colors.orange.shade100],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            vehiculo.activo ? 'Valor Acumulado' : 'Total Pagado',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '\$${_formatearValor(valorActual)}',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: esGratis
                                  ? Colors.green.shade700
                                  : Colors.orange.shade700,
                            ),
                          ),
                          if (esGratis && vehiculo.activo)
                            Text(
                              '¡Aún es gratis!',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.green.shade600,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                        ],
                      ),
                      if (vehiculo.activo)
                        Icon(
                          Icons.attach_money,
                          size: 48,
                          color: esGratis
                              ? Colors.green.shade300
                              : Colors.orange.shade300,
                        ),
                    ],
                  ),
                ),

                // Botón de acción (solo para vigilante/admin)
                if (vehiculo.activo &&
                    (widget.tipoUsuario == TipoUsuario.vigilante ||
                        widget.tipoUsuario == TipoUsuario.admin)) ...[
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _registrarSalida(vehiculo),
                      icon: const Icon(Icons.stop_circle),
                      label: const Text('REGISTRAR SALIDA'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade600,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey.shade600),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildTimerDisplay(Duration duration, bool activo) {
    final horas = duration.inHours;
    final minutos = duration.inMinutes.remainder(60);
    final segundos = duration.inSeconds.remainder(60);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: activo ? Colors.blue.shade50 : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: activo ? Colors.blue.shade200 : Colors.grey.shade300,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.timer,
            color: activo ? Colors.blue.shade700 : Colors.grey.shade600,
          ),
          const SizedBox(width: 12),
          Column(
            children: [
              Text(
                activo ? 'Tiempo Transcurrido' : 'Tiempo Total',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  _buildTimeUnit(horas, 'h'),
                  const Text(' : ', style: TextStyle(fontSize: 20)),
                  _buildTimeUnit(minutos, 'm'),
                  const Text(' : ', style: TextStyle(fontSize: 20)),
                  _buildTimeUnit(segundos, 's'),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimeUnit(int value, String unit) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        children: [
          Text(
            value.toString().padLeft(2, '0'),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            unit,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  String _formatearFechaHora(DateTime fecha) {
    return DateFormat('dd/MM/yyyy HH:mm').format(fecha);
  }

  String _formatearValor(num valor) {
    return NumberFormat('#,###', 'es_CO').format(valor);
  }

  Future<void> _mostrarFormularioIngreso() async {
    final TextEditingController placaController = TextEditingController();
    final TextEditingController aptoController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Registrar Ingreso de Vehículo'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: placaController,
              decoration: const InputDecoration(
                labelText: 'Placa',
                hintText: 'ABC123',
                prefixIcon: Icon(Icons.directions_car),
              ),
              textCapitalization: TextCapitalization.characters,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: aptoController,
              decoration: const InputDecoration(
                labelText: 'Apartamento Destino',
                hintText: '101',
                prefixIcon: Icon(Icons.home),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (placaController.text.isEmpty ||
                  aptoController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Complete todos los campos')),
                );
                return;
              }

              try {
                final authService = context.read<AuthService>();
                _apiService.setToken(authService.token!);

                await _apiService.registrarIngresoVehiculo(
                  placa: placaController.text.toUpperCase(),
                  apartamento: aptoController.text,
                );

                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('✅ Ingreso registrado'),
                      backgroundColor: Colors.green,
                    ),
                  );
                  _cargarVehiculos();
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              }
            },
            child: const Text('Registrar'),
          ),
        ],
      ),
    );
  }
}

// Diálogo para registrar salida
class _DialogoSalidaVehiculo extends StatefulWidget {
  final VehiculoVisitante vehiculo;

  const _DialogoSalidaVehiculo({required this.vehiculo});

  @override
  State<_DialogoSalidaVehiculo> createState() => _DialogoSalidaVehiculoState();
}

class _DialogoSalidaVehiculoState extends State<_DialogoSalidaVehiculo> {
  MetodoPago _metodoPagoSeleccionado = MetodoPago.efectivo;

  @override
  Widget build(BuildContext context) {
    final tiempoTotal = widget.vehiculo.tiempoTranscurrido;
    final valorTotal = widget.vehiculo.valorAPagar;

    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.stop_circle, color: Colors.red),
          SizedBox(width: 8),
          Text('Registrar Salida'),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Placa: ${widget.vehiculo.placa.toUpperCase()}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildDetalle('Tiempo total',
                '${tiempoTotal.inHours}h ${tiempoTotal.inMinutes.remainder(60)}m'),
            _buildDetalle('Apartamento', widget.vehiculo.apartamentoDestino),
            const Divider(height: 24),
            Text(
              'Total a pagar:',
              style: TextStyle(color: Colors.grey.shade700),
            ),
            Text(
              '\$${NumberFormat('#,###', 'es_CO').format(valorTotal)}',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: valorTotal == 0 ? Colors.green : Colors.orange.shade700,
              ),
            ),
            if (valorTotal > 0) ...[
              const SizedBox(height: 24),
              const Text(
                'Método de pago:',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              ...MetodoPago.values.map((metodo) {
                return RadioListTile<MetodoPago>(
                  title: Text(metodo.displayName),
                  value: metodo,
                  groupValue: _metodoPagoSeleccionado,
                  onChanged: (value) {
                    setState(() => _metodoPagoSeleccionado = value!);
                  },
                  dense: true,
                );
              }).toList(),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, _metodoPagoSeleccionado),
          child: const Text('Confirmar Salida'),
        ),
      ],
    );
  }

  Widget _buildDetalle(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey.shade600)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

// Enum para tipo de usuario
enum TipoUsuario {
  residente,
  vigilante,
  admin,
}
