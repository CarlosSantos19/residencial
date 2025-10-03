import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:intl/intl.dart';
import '../../services/auth_service.dart';
import '../../services/api_service.dart';

class GenerarQRVisitanteScreen extends StatefulWidget {
  const GenerarQRVisitanteScreen({super.key});

  @override
  State<GenerarQRVisitanteScreen> createState() => _GenerarQRVisitanteScreenState();
}

class _GenerarQRVisitanteScreenState extends State<GenerarQRVisitanteScreen> {
  final ApiService _apiService = ApiService();
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _cedulaController = TextEditingController();
  final TextEditingController _vehiculoController = TextEditingController();

  DateTime _fechaValidoHasta = DateTime.now().add(const Duration(hours: 24));
  bool _tieneVehiculo = false;
  String? _qrData;
  String? _codigoAcceso;

  @override
  void dispose() {
    _nombreController.dispose();
    _cedulaController.dispose();
    _vehiculoController.dispose();
    super.dispose();
  }

  Future<void> _generarQR() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final authService = context.read<AuthService>();
      _apiService.setToken(authService.token!);

      final user = authService.currentUser!;

      // Generar código de acceso único
      final codigoAcceso = _generarCodigoAcceso();

      // Crear datos del QR
      final qrData = {
        'tipo': 'visitante',
        'codigoAcceso': codigoAcceso,
        'residenteId': user.id,
        'nombreResidente': user.nombre,
        'apartamento': user.apartamento,
        'nombreVisitante': _nombreController.text.trim(),
        'cedulaVisitante': _cedulaController.text.trim(),
        'vehiculo': _tieneVehiculo ? _vehiculoController.text.trim() : null,
        'fechaGeneracion': DateTime.now().toIso8601String(),
        'validoHasta': _fechaValidoHasta.toIso8601String(),
        'version': '1.0',
      };

      // Guardar en backend
      await _apiService.crearQRVisitante(qrData);

      setState(() {
        _qrData = jsonEncode(qrData);
        _codigoAcceso = codigoAcceso;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Código QR generado exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  String _generarCodigoAcceso() {
    // Generar código de 6 dígitos
    final random = DateTime.now().millisecondsSinceEpoch % 1000000;
    return random.toString().padLeft(6, '0');
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthService>().currentUser!;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Generar QR Visitante'),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [user.rol.gradientStart, user.rol.gradientEnd],
            ),
          ),
        ),
      ),
      body: _qrData == null ? _buildFormulario() : _buildQRGenerado(),
    );
  }

  Widget _buildFormulario() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Info card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue.shade50, Colors.blue.shade100],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.qr_code, size: 40, color: Colors.blue.shade700),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Código QR de Acceso',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Genera un código QR para que tu visitante ingrese de forma rápida y segura',
                          style: TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              'Datos del Visitante',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 16),

            // Nombre
            TextFormField(
              controller: _nombreController,
              decoration: InputDecoration(
                labelText: 'Nombre Completo *',
                prefixIcon: const Icon(Icons.person),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              textCapitalization: TextCapitalization.words,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Ingresa el nombre del visitante';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // Cédula
            TextFormField(
              controller: _cedulaController,
              decoration: InputDecoration(
                labelText: 'Cédula/Documento *',
                prefixIcon: const Icon(Icons.badge),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Ingresa el documento del visitante';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // Vehículo switch
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                children: [
                  const Icon(Icons.directions_car, color: Colors.blue),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '¿Viene en vehículo?',
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Activa si tu visitante traerá vehículo',
                          style: TextStyle(fontSize: 11, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: _tieneVehiculo,
                    onChanged: (value) {
                      setState(() => _tieneVehiculo = value);
                    },
                  ),
                ],
              ),
            ),

            // Placa vehículo
            if (_tieneVehiculo) ...[
              const SizedBox(height: 16),
              TextFormField(
                controller: _vehiculoController,
                decoration: InputDecoration(
                  labelText: 'Placa del Vehículo *',
                  prefixIcon: const Icon(Icons.local_parking),
                  hintText: 'ABC123',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                textCapitalization: TextCapitalization.characters,
                validator: (value) {
                  if (_tieneVehiculo && (value == null || value.trim().isEmpty)) {
                    return 'Ingresa la placa del vehículo';
                  }
                  return null;
                },
              ),
            ],

            const SizedBox(height: 24),

            // Validez
            const Text(
              'Validez del Código',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 16),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Icon(Icons.access_time, color: Colors.orange),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Válido hasta:',
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ),
                      Text(
                        DateFormat('dd/MM/yyyy HH:mm').format(_fechaValidoHasta),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    children: [
                      _ChipValidez(
                        label: '2 horas',
                        onTap: () => setState(() {
                          _fechaValidoHasta = DateTime.now().add(const Duration(hours: 2));
                        }),
                      ),
                      _ChipValidez(
                        label: '6 horas',
                        onTap: () => setState(() {
                          _fechaValidoHasta = DateTime.now().add(const Duration(hours: 6));
                        }),
                      ),
                      _ChipValidez(
                        label: '12 horas',
                        onTap: () => setState(() {
                          _fechaValidoHasta = DateTime.now().add(const Duration(hours: 12));
                        }),
                      ),
                      _ChipValidez(
                        label: '24 horas',
                        onTap: () => setState(() {
                          _fechaValidoHasta = DateTime.now().add(const Duration(hours: 24));
                        }),
                      ),
                      _ChipValidez(
                        label: '3 días',
                        onTap: () => setState(() {
                          _fechaValidoHasta = DateTime.now().add(const Duration(days: 3));
                        }),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Botón generar
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: _generarQR,
                icon: const Icon(Icons.qr_code_2, size: 24),
                label: const Text(
                  'GENERAR CÓDIGO QR',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade600,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQRGenerado() {
    final user = context.read<AuthService>().currentUser!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Éxito header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.green.shade400, Colors.green.shade600],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.check_circle,
                  color: Colors.white,
                  size: 60,
                ),
                const SizedBox(height: 12),
                const Text(
                  '¡Código QR Generado!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Comparte este código con tu visitante',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // QR Code
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Column(
              children: [
                QrImageView(
                  data: _qrData!,
                  version: QrVersions.auto,
                  size: 280,
                  backgroundColor: Colors.white,
                  errorCorrectionLevel: QrErrorCorrectLevel.H,
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Código: $_codigoAcceso',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 4,
                      color: Colors.blue.shade700,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Información
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow(Icons.person, 'Visitante', _nombreController.text),
                const Divider(height: 16),
                _buildInfoRow(Icons.badge, 'Documento', _cedulaController.text),
                const Divider(height: 16),
                _buildInfoRow(Icons.home, 'Apartamento', user.apartamento),
                if (_tieneVehiculo) ...[
                  const Divider(height: 16),
                  _buildInfoRow(Icons.directions_car, 'Vehículo', _vehiculoController.text),
                ],
                const Divider(height: 16),
                _buildInfoRow(
                  Icons.schedule,
                  'Válido hasta',
                  DateFormat('dd/MM/yyyy HH:mm').format(_fechaValidoHasta),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Instrucciones
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue.shade700),
                    const SizedBox(width: 8),
                    Text(
                      'Instrucciones',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildInstruccion('1', 'Comparte este código QR con tu visitante'),
                _buildInstruccion('2', 'El visitante muestra el código en portería'),
                _buildInstruccion('3', 'El vigilante escanea el código'),
                _buildInstruccion('4', 'Acceso autorizado automáticamente'),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Botones
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    setState(() {
                      _qrData = null;
                      _codigoAcceso = null;
                      _nombreController.clear();
                      _cedulaController.clear();
                      _vehiculoController.clear();
                      _tieneVehiculo = false;
                    });
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Nuevo QR'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    // TODO: Implementar compartir
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Función compartir próximamente')),
                    );
                  },
                  icon: const Icon(Icons.share),
                  label: const Text('Compartir'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey.shade600),
        const SizedBox(width: 12),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey.shade600,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  Widget _buildInstruccion(String numero, String texto) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: Colors.blue.shade700,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                numero,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              texto,
              style: const TextStyle(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChipValidez extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _ChipValidez({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      label: Text(label),
      onPressed: onTap,
      backgroundColor: Colors.blue.shade50,
      labelStyle: TextStyle(color: Colors.blue.shade700, fontSize: 12),
      side: BorderSide(color: Colors.blue.shade200),
    );
  }
}
