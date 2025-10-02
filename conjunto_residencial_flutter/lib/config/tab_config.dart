import 'package:flutter/material.dart';
import '../models/user.dart';

// RESIDENTE
import '../screens/residente/dashboard_residente_screen.dart';
import '../screens/residente/mis_reservas_screen.dart';
import '../screens/residente/mis_pagos_screen.dart';
import '../screens/residente/emprendimientos_screen.dart';
import '../screens/residente/ver_arriendos_screen.dart';
import '../screens/residente/mi_parqueadero_screen.dart';
import '../screens/residente/control_vehiculos_residente_screen.dart';
import '../screens/residente/permisos_residente_screen.dart';
import '../screens/residente/paquetes_residente_screen.dart';
import '../screens/chat/chat_screen.dart';
import '../screens/residente/camaras_residente_screen.dart';
import '../screens/residente/juegos_screen.dart';
import '../screens/residente/documentos_screen.dart';
import '../screens/residente/pqrs_screen.dart';
import '../screens/residente/encuestas_residente_screen.dart';

// ADMIN
import '../screens/admin/panel_admin_screen.dart';
import '../screens/admin/sorteo_parqueaderos_screen.dart';
import '../screens/admin/control_vehiculos_admin_screen.dart';
import '../screens/admin/noticias_admin_screen.dart';
import '../screens/admin/pagos_admin_screen.dart';
import '../screens/admin/reservas_admin_screen.dart';
import '../screens/admin/usuarios_screen.dart';
import '../screens/admin/permisos_admin_screen.dart';
import '../screens/admin/camaras_admin_screen.dart';
import '../screens/admin/pqrs_admin_screen.dart';
import '../screens/admin/incidentes_admin_screen.dart';
import '../screens/admin/encuestas_admin_screen.dart';
import '../screens/admin/paquetes_admin_screen.dart';

// VIGILANTE
import '../screens/vigilante/panel_seguridad_screen.dart';
import '../screens/vigilante/control_vehiculos_vigilante_screen.dart';
import '../screens/vigilante/permisos_vigilante_screen.dart';
import '../screens/vigilante/registros_screen.dart';
import '../screens/vigilante/camaras_vigilante_screen.dart';
import '../screens/vigilante/paquetes_vigilante_screen.dart';

// ALCALDIA
import '../screens/alcaldia/panel_alcaldia_screen.dart';
import '../screens/alcaldia/incidentes_alcaldia_screen.dart';

class TabItem {
  final String id;
  final String titulo;
  final IconData icon;
  final Widget screen;

  TabItem({
    required this.id,
    required this.titulo,
    required this.icon,
    required this.screen,
  });
}

class TabConfig {
  // Obtener tabs según el rol del usuario
  static List<TabItem> getTabsForRole(UserRole role) {
    switch (role) {
      case UserRole.residente:
        return _residenteTabs;
      case UserRole.admin:
        return _adminTabs;
      case UserRole.vigilante:
        return _vigilanteTabs;
      case UserRole.alcaldia:
        return _alcaldiaTabs;
    }
  }

  // RESIDENTE: 15 módulos
  static final List<TabItem> _residenteTabs = [
    TabItem(
      id: 'dashboard',
      titulo: 'Dashboard',
      icon: Icons.dashboard,
      screen: const DashboardResidenteScreen(),
    ),
    TabItem(
      id: 'mis_reservas',
      titulo: 'Mis Reservas',
      icon: Icons.calendar_today,
      screen: const MisReservasScreen(),
    ),
    TabItem(
      id: 'mis_pagos',
      titulo: 'Mis Pagos',
      icon: Icons.payment,
      screen: const MisPagosScreen(),
    ),
    TabItem(
      id: 'emprendimientos',
      titulo: 'Emprendimientos',
      icon: Icons.store,
      screen: const EmprendimientosScreen(),
    ),
    TabItem(
      id: 'arriendos',
      titulo: 'Ver Arriendos',
      icon: Icons.home_outlined,
      screen: const VerArriendosScreen(),
    ),
    TabItem(
      id: 'mi_parqueadero',
      titulo: 'Mi Parqueadero',
      icon: Icons.local_parking,
      screen: const MiParqueaderoScreen(),
    ),
    TabItem(
      id: 'control_vehiculos',
      titulo: 'Control Vehículos',
      icon: Icons.directions_car,
      screen: const ControlVehiculosResidenteScreen(),
    ),
    TabItem(
      id: 'permisos',
      titulo: 'Permisos',
      icon: Icons.shield,
      screen: const PermisosResidenteScreen(),
    ),
    TabItem(
      id: 'paquetes',
      titulo: 'Paquetes',
      icon: Icons.inventory_2,
      screen: const PaquetesResidenteScreen(),
    ),
    TabItem(
      id: 'chat',
      titulo: 'Chat',
      icon: Icons.chat_bubble,
      screen: const ChatScreen(),
    ),
    TabItem(
      id: 'camaras',
      titulo: 'Cámaras',
      icon: Icons.videocam,
      screen: const CamarasResidenteScreen(),
    ),
    TabItem(
      id: 'juegos',
      titulo: 'Juegos',
      icon: Icons.games,
      screen: const JuegosScreen(),
    ),
    TabItem(
      id: 'documentos',
      titulo: 'Documentos',
      icon: Icons.description,
      screen: const DocumentosScreen(),
    ),
    TabItem(
      id: 'pqrs',
      titulo: 'PQRS',
      icon: Icons.support_agent,
      screen: const PQRSScreen(),
    ),
    TabItem(
      id: 'encuestas',
      titulo: 'Encuestas',
      icon: Icons.poll,
      screen: const EncuestasResidenteScreen(),
    ),
  ];

  // ADMIN: 13 módulos
  static final List<TabItem> _adminTabs = [
    TabItem(
      id: 'panel_admin',
      titulo: 'Panel Admin',
      icon: Icons.admin_panel_settings,
      screen: const PanelAdminScreen(),
    ),
    TabItem(
      id: 'sorteo_parqueaderos',
      titulo: 'Sorteo Parqueaderos',
      icon: Icons.casino,
      screen: const SorteoParqueaderosScreen(),
    ),
    TabItem(
      id: 'control_vehiculos',
      titulo: 'Control Vehículos',
      icon: Icons.directions_car,
      screen: const ControlVehiculosAdminScreen(),
    ),
    TabItem(
      id: 'noticias',
      titulo: 'Noticias',
      icon: Icons.article,
      screen: const NoticiasAdminScreen(),
    ),
    TabItem(
      id: 'pagos',
      titulo: 'Pagos',
      icon: Icons.attach_money,
      screen: const PagosAdminScreen(),
    ),
    TabItem(
      id: 'reservas',
      titulo: 'Reservas',
      icon: Icons.calendar_today,
      screen: const ReservasAdminScreen(),
    ),
    TabItem(
      id: 'usuarios',
      titulo: 'Usuarios',
      icon: Icons.people,
      screen: const UsuariosScreen(),
    ),
    TabItem(
      id: 'permisos',
      titulo: 'Permisos',
      icon: Icons.shield,
      screen: const PermisosAdminScreen(),
    ),
    TabItem(
      id: 'camaras',
      titulo: 'Cámaras',
      icon: Icons.videocam,
      screen: const CamarasAdminScreen(),
    ),
    TabItem(
      id: 'pqrs',
      titulo: 'PQRS',
      icon: Icons.support_agent,
      screen: const PQRSAdminScreen(),
    ),
    TabItem(
      id: 'incidentes',
      titulo: 'Incidentes Alcaldía',
      icon: Icons.warning,
      screen: const IncidentesAdminScreen(),
    ),
    TabItem(
      id: 'encuestas',
      titulo: 'Encuestas',
      icon: Icons.poll,
      screen: const EncuestasAdminScreen(),
    ),
    TabItem(
      id: 'paquetes',
      titulo: 'Paquetes',
      icon: Icons.inventory_2,
      screen: const PaquetesAdminScreen(),
    ),
  ];

  // VIGILANTE: 6 módulos
  static final List<TabItem> _vigilanteTabs = [
    TabItem(
      id: 'panel_seguridad',
      titulo: 'Panel Seguridad',
      icon: Icons.security,
      screen: const PanelSeguridadScreen(),
    ),
    TabItem(
      id: 'control_vehiculos',
      titulo: 'Control Vehículos',
      icon: Icons.directions_car,
      screen: const ControlVehiculosVigilanteScreen(),
    ),
    TabItem(
      id: 'permisos',
      titulo: 'Gestión Permisos',
      icon: Icons.shield,
      screen: const PermisosVigilanteScreen(),
    ),
    TabItem(
      id: 'registros',
      titulo: 'Registros',
      icon: Icons.assignment,
      screen: const RegistrosScreen(),
    ),
    TabItem(
      id: 'camaras',
      titulo: 'Cámaras',
      icon: Icons.videocam,
      screen: const CamarasVigilanteScreen(),
    ),
    TabItem(
      id: 'paquetes',
      titulo: 'Paquetes',
      icon: Icons.inventory_2,
      screen: const PaquetesVigilanteScreen(),
    ),
  ];

  // ALCALDIA: 2 módulos
  static final List<TabItem> _alcaldiaTabs = [
    TabItem(
      id: 'panel_alcaldia',
      titulo: 'Panel Alcaldía',
      icon: Icons.account_balance,
      screen: const PanelAlcaldiaScreen(),
    ),
    TabItem(
      id: 'incidentes',
      titulo: 'Incidentes Reportados',
      icon: Icons.warning_amber,
      screen: const IncidentesAlcaldiaScreen(),
    ),
  ];
}
