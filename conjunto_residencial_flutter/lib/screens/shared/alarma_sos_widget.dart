import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../services/api_service.dart';
import '../../services/notification_service.dart';

class AlarmaSosWidget extends StatelessWidget {
  const AlarmaSosWidget({super.key});

  static Future<void> mostrar(BuildContext context) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlarmaSosWidget(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.red.withOpacity(0.3),
              blurRadius: 30,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.red.withOpacity(0.5),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.warning_amber,
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
                          'ALARMA DE EMERGENCIA',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Selecciona el tipo de emergencia',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Botones de emergencia
            _BotonEmergencia(
              tipo: TipoEmergencia.robo,
              icono: Icons.shield_outlined,
              titulo: 'ROBO / SEGURIDAD',
              descripcion: 'Actividad sospechosa o robo en curso',
              color: Colors.red,
              onPressed: () => _activarAlarma(context, TipoEmergencia.robo),
            ),

            const SizedBox(height: 12),

            _BotonEmergencia(
              tipo: TipoEmergencia.incendio,
              icono: Icons.local_fire_department,
              titulo: 'INCENDIO',
              descripcion: 'Fuego o humo detectado',
              color: Colors.orange,
              onPressed: () => _activarAlarma(context, TipoEmergencia.incendio),
            ),

            const SizedBox(height: 12),

            _BotonEmergencia(
              tipo: TipoEmergencia.medica,
              icono: Icons.medical_services,
              titulo: 'EMERGENCIA MÉDICA',
              descripcion: 'Asistencia médica urgente',
              color: Colors.blue,
              onPressed: () => _activarAlarma(context, TipoEmergencia.medica),
            ),

            const SizedBox(height: 12),

            _BotonEmergencia(
              tipo: TipoEmergencia.otro,
              icono: Icons.help_outline,
              titulo: 'OTRA EMERGENCIA',
              descripcion: 'Otro tipo de emergencia',
              color: Colors.purple,
              onPressed: () => _activarAlarma(context, TipoEmergencia.otro),
            ),

            const SizedBox(height: 24),

            // Botón cancelar
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Cancelar',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _activarAlarma(BuildContext context, TipoEmergencia tipo) async {
    // Confirmar activación
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.warning, color: tipo.color),
            const SizedBox(width: 8),
            const Text('Confirmar Alarma'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '¿Confirmas que deseas activar la alarma de ${tipo.nombre}?',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, size: 20, color: Colors.orange),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Se notificará inmediatamente a vigilancia y administración',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: tipo.color,
              foregroundColor: Colors.white,
            ),
            child: const Text('ACTIVAR ALARMA'),
          ),
        ],
      ),
    );

    if (confirmar != true || !context.mounted) {
      Navigator.pop(context);
      return;
    }

    try {
      final authService = context.read<AuthService>();
      final apiService = ApiService();
      final notificationService = NotificationService();

      apiService.setToken(authService.token!);

      // Obtener ubicación del usuario
      final user = authService.currentUser!;
      final ubicacion = '${user.apartamento} - ${user.nombre}';

      // Registrar alarma en backend
      await apiService.activarAlarmaSOS(
        tipo: tipo.valor,
        ubicacion: ubicacion,
        descripcion: tipo.descripcion,
      );

      // Enviar notificación push a vigilantes y administrador
      await notificationService.enviarAlarmaSOS(tipo.nombre, user.apartamento);

      if (context.mounted) {
        Navigator.pop(context);

        // Mostrar confirmación
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => _DialogoAlarmaActivada(tipo: tipo),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al activar alarma: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

class _BotonEmergencia extends StatelessWidget {
  final TipoEmergencia tipo;
  final IconData icono;
  final String titulo;
  final String descripcion;
  final Color color;
  final VoidCallback onPressed;

  const _BotonEmergencia({
    required this.tipo,
    required this.icono,
    required this.titulo,
    required this.descripcion,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: color.withOpacity(0.3), width: 2),
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              colors: [
                color.withOpacity(0.1),
                color.withOpacity(0.05),
              ],
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icono, color: Colors.white, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titulo,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      descripcion,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, color: color, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _DialogoAlarmaActivada extends StatefulWidget {
  final TipoEmergencia tipo;

  const _DialogoAlarmaActivada({required this.tipo});

  @override
  State<_DialogoAlarmaActivada> createState() => _DialogoAlarmaActivadaState();
}

class _DialogoAlarmaActivadaState extends State<_DialogoAlarmaActivada>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icono animado
            ScaleTransition(
              scale: _scaleAnimation,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: widget.tipo.color,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: widget.tipo.color.withOpacity(0.5),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 60,
                ),
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              '¡ALARMA ACTIVADA!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 16),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.notifications_active,
                          color: Colors.green.shade700),
                      const SizedBox(width: 8),
                      const Text(
                        'Notificación enviada',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Se ha notificado a vigilancia y administración',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    '⏱️ Tiempo de respuesta estimado: 2-5 minutos',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.tipo.color,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Entendido'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Enumeración de tipos de emergencia
enum TipoEmergencia {
  robo('robo', 'Robo/Seguridad', 'Actividad sospechosa detectada', Colors.red),
  incendio('incendio', 'Incendio', 'Fuego o humo en el área', Colors.orange),
  medica('medica', 'Emergencia Médica', 'Asistencia médica requerida', Colors.blue),
  otro('otro', 'Otra Emergencia', 'Emergencia general', Colors.purple);

  final String valor;
  final String nombre;
  final String descripcion;
  final Color color;

  const TipoEmergencia(this.valor, this.nombre, this.descripcion, this.color);
}

// FloatingActionButton para agregar en cualquier pantalla
class BotonSOS extends StatelessWidget {
  const BotonSOS({super.key});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () => AlarmaSosWidget.mostrar(context),
      backgroundColor: Colors.red,
      child: const Icon(Icons.warning_amber, size: 32),
    );
  }
}

// Widget para mostrar en el Drawer/AppBar
class BotonSOSCompacto extends StatelessWidget {
  const BotonSOSCompacto({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () => AlarmaSosWidget.mostrar(context),
      icon: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.red,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.red.withOpacity(0.5),
              blurRadius: 8,
              spreadRadius: 1,
            ),
          ],
        ),
        child: const Icon(
          Icons.warning_amber,
          color: Colors.white,
          size: 20,
        ),
      ),
      tooltip: 'Alarma SOS',
    );
  }
}
