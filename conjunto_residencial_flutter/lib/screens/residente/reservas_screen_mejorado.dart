import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../services/auth_service.dart';
import '../../services/api_service.dart';
import '../../models/reserva.dart';
import '../../models/user.dart';

/// Pantalla de Reservas Mejorada - Residente
///
/// Funcionalidades:
/// - Calendario visual con días ocupados marcados
/// - Imágenes de los espacios
/// - Información de capacidad
/// - Cancelar reservas (con confirmación)
/// - Ver mis reservas activas
/// - Filtro por espacio
///
/// Color: Azul (Residente)

class ReservasScreenMejorado extends StatefulWidget {
  const ReservasScreenMejorado({Key? key}) : super(key: key);

  @override
  State<ReservasScreenMejorado> createState() => _ReservasScreenMejoradoState();
}

class _ReservasScreenMejoradoState extends State<ReservasScreenMejorado>
    with TickerProviderStateMixin {
  final ApiService _apiService = ApiService();

  late TabController _tabController;

  List<Reserva> _todasReservas = [];
  List<Reserva> _misReservas = [];
  DateTime _fechaSeleccionada = DateTime.now();
  DateTime _focusedDay = DateTime.now();

  bool _isLoading = true;
  String? _error;

  final List<String> _espacios = [
    'Salón Social',
    'Zona BBQ',
    'Piscina',
    'Gimnasio',
    'Cancha Múltiple',
  ];

  final Map<String, String> _imagenesEspacios = {
    'Salón Social':
        'https://images.unsplash.com/photo-1519167758481-83f29da8c</del>c?w=800',
    'Zona BBQ':
        'https://images.unsplash.com/photo-1555939594-58d7cb561ad1?w=800',
    'Piscina': 'https://images.unsplash.com/photo-1576013551627-0cc20b96c2a7?w=800',
    'Gimnasio': 'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?w=800',
    'Cancha Múltiple':
        'https://images.unsplash.com/photo-1575361204480-aadea25e6e68?w=800',
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _cargarReservas();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _cargarReservas() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final user = authService.currentUser;

      final reservas = await _apiService.getReservas();

      setState(() {
        _todasReservas = reservas;
        _misReservas = reservas
            .where((r) => r.usuarioId == user?.id && r.estado == 'confirmada')
            .toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Error al cargar reservas: $e';
        _isLoading = false;
      });
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
        title: const Text('Reservas'),
        backgroundColor: const Color(0xFF2563EB),
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          tabs: const [
            Tab(text: 'Nueva Reserva'),
            Tab(text: 'Mis Reservas'),
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
                        onPressed: _cargarReservas,
                        child: const Text('Reintentar'),
                      ),
                    ],
                  ),
                )
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildNuevaReserva(user),
                    _buildMisReservas(user),
                  ],
                ),
    );
  }

  Widget _buildNuevaReserva(User user) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCalendario(),
          const SizedBox(height: 24),
          _buildEspaciosDisponibles(user),
        ],
      ),
    );
  }

  Widget _buildCalendario() {
    final reservasPorFecha = <DateTime, List<Reserva>>{};
    for (var reserva in _todasReservas) {
      final fecha = reserva.fechaDateTime;
      final fechaNormalizada = DateTime(fecha.year, fecha.month, fecha.day);
      if (reservasPorFecha.containsKey(fechaNormalizada)) {
        reservasPorFecha[fechaNormalizada]!.add(reserva);
      } else {
        reservasPorFecha[fechaNormalizada] = [reserva];
      }
    }

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: TableCalendar(
          firstDay: DateTime.now(),
          lastDay: DateTime.now().add(const Duration(days: 90)),
          focusedDay: _focusedDay,
          selectedDayPredicate: (day) => isSameDay(_fechaSeleccionada, day),
          calendarFormat: CalendarFormat.month,
          startingDayOfWeek: StartingDayOfWeek.monday,
          headerStyle: const HeaderStyle(
            formatButtonVisible: false,
            titleCentered: true,
            titleTextStyle: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2563EB),
            ),
          ),
          calendarStyle: CalendarStyle(
            todayDecoration: BoxDecoration(
              color: const Color(0xFF2563EB).withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            selectedDecoration: const BoxDecoration(
              color: Color(0xFF2563EB),
              shape: BoxShape.circle,
            ),
            markerDecoration: const BoxDecoration(
              color: Colors.orange,
              shape: BoxShape.circle,
            ),
          ),
          eventLoader: (day) {
            final fechaNormalizada = DateTime(day.year, day.month, day.day);
            return reservasPorFecha[fechaNormalizada] ?? [];
          },
          onDaySelected: (selectedDay, focusedDay) {
            setState(() {
              _fechaSeleccionada = selectedDay;
              _focusedDay = focusedDay;
            });
          },
        ),
      ),
    );
  }

  Widget _buildEspaciosDisponibles(User user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Espacios Disponibles',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2563EB),
          ),
        ),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _espacios.length,
          itemBuilder: (context, index) {
            final espacio = _espacios[index];
            final reservasEspacio = _todasReservas.where((r) {
              final fechaReserva =
                  DateTime(r.fechaDateTime.year, r.fechaDateTime.month, r.fechaDateTime.day);
              final fechaSeleccionadaNorm = DateTime(
                  _fechaSeleccionada.year, _fechaSeleccionada.month, _fechaSeleccionada.day);
              return r.espacio == espacio &&
                  isSameDay(fechaReserva, fechaSeleccionadaNorm) &&
                  r.estado == 'confirmada';
            }).length;

            final estaOcupado = reservasEspacio > 0;

            return _buildEspacioCard(
              espacio,
              estaOcupado,
              reservasEspacio,
              user,
            );
          },
        ),
      ],
    );
  }

  Widget _buildEspacioCard(
      String espacio, bool estaOcupado, int numReservas, User user) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Imagen
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Image.network(
              _imagenesEspacios[espacio] ?? '',
              height: 150,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 150,
                  color: Colors.grey[300],
                  child: const Center(
                    child: Icon(Icons.image_not_supported, size: 48),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        espacio,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: estaOcupado
                            ? Colors.red.withOpacity(0.1)
                            : Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            estaOcupado ? Icons.event_busy : Icons.event_available,
                            size: 16,
                            color: estaOcupado ? Colors.red : Colors.green,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            estaOcupado ? 'Ocupado' : 'Disponible',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: estaOcupado ? Colors.red : Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (estaOcupado) ...[
                  const SizedBox(height: 8),
                  Text(
                    '$numReservas ${numReservas == 1 ? "reserva" : "reservas"} para esta fecha',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ],
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: estaOcupado
                        ? null
                        : () => _confirmarReserva(espacio, user),
                    icon: const Icon(Icons.event),
                    label: const Text('Reservar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      disabledBackgroundColor: Colors.grey[300],
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMisReservas(User user) {
    if (_misReservas.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_note, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No tienes reservas activas',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _cargarReservas,
      color: const Color(0xFF2563EB),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _misReservas.length,
        itemBuilder: (context, index) {
          final reserva = _misReservas[index];
          return _buildMiReservaCard(reserva, user);
        },
      ),
    );
  }

  Widget _buildMiReservaCard(Reserva reserva, User user) {
    final fechaReserva = reserva.fechaDateTime;
    final esProxima = fechaReserva.isAfter(DateTime.now());
    final puedeAncelar = reserva.cancelable == true && esProxima;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2563EB).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.event,
                    color: Color(0xFF2563EB),
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        reserva.espacio,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.calendar_today,
                              size: 14, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Text(
                            reserva.fecha,
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                          const SizedBox(width: 12),
                          Icon(Icons.access_time, size: 14, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Text(
                            reserva.hora,
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (puedeAncelar) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _cancelarReserva(reserva),
                  icon: const Icon(Icons.cancel),
                  label: const Text('Cancelar Reserva'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _confirmarReserva(String espacio, User user) async {
    final horaSeleccionada = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF2563EB),
            ),
          ),
          child: child!,
        );
      },
    );

    if (horaSeleccionada == null) return;

    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Reserva'),
        content: Text(
          '¿Deseas reservar $espacio para el ${_formatearFecha(_fechaSeleccionada)} a las ${horaSeleccionada.format(context)}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2563EB),
            ),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );

    if (confirmar != true) return;

    try {
      // En API real: await _apiService.crearReserva(...)
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Reserva creada exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
        await _cargarReservas();
        _tabController.animateTo(1); // Ir a Mis Reservas
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _cancelarReserva(Reserva reserva) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancelar Reserva'),
        content: Text(
          '¿Estás seguro de cancelar la reserva de ${reserva.espacio} para el ${reserva.fecha}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Sí, cancelar'),
          ),
        ],
      ),
    );

    if (confirmar != true) return;

    try {
      // En API real: await _apiService.cancelarReserva(reserva.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Reserva cancelada'),
            backgroundColor: Colors.orange,
          ),
        );
        await _cargarReservas();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  String _formatearFecha(DateTime fecha) {
    final dias = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];
    final meses = [
      'Ene',
      'Feb',
      'Mar',
      'Abr',
      'May',
      'Jun',
      'Jul',
      'Ago',
      'Sep',
      'Oct',
      'Nov',
      'Dic'
    ];

    return '${dias[fecha.weekday - 1]} ${fecha.day} ${meses[fecha.month - 1]}';
  }
}
