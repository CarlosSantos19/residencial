import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../widgets/stat_card.dart';

class PanelSeguridadScreen extends StatefulWidget {
  const PanelSeguridadScreen({super.key});

  @override
  State<PanelSeguridadScreen> createState() => _PanelSeguridadScreenState();
}

class _PanelSeguridadScreenState extends State<PanelSeguridadScreen> {

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthService>().currentUser!;
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Panel de Seguridad'),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [user.rol.gradientStart, user.rol.gradientEnd]),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 1.3,
          children: [
            StatCard(title: 'Vehículos Hoy', value: '12', icon: Icons.directions_car, color: user.rol.primaryColor),
            StatCard(title: 'Permisos Activos', value: '5', icon: Icons.shield, color: Colors.green),
            StatCard(title: 'Paquetes Hoy', value: '8', icon: Icons.inventory_2, color: Colors.blue),
            StatCard(title: 'Cámaras', value: '4', icon: Icons.videocam, color: Colors.purple),
          ],
        ),
      ),
    );
  }
}
