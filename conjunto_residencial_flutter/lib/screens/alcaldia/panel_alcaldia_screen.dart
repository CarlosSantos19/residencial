import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../widgets/stat_card.dart';

class PanelAlcaldiaScreen extends StatefulWidget {
  const PanelAlcaldiaScreen({super.key});

  @override
  State<PanelAlcaldiaScreen> createState() => _PanelAlcaldiaScreenState();
}

class _PanelAlcaldiaScreenState extends State<PanelAlcaldiaScreen> {

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthService>().currentUser!;
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Panel Alcaldía'),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [user.rol.gradientStart, user.rol.gradientEnd]),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.3,
              children: [
                StatCard(title: 'Incidentes Totales', value: '0', icon: Icons.warning, color: user.rol.primaryColor),
                StatCard(title: 'Pendientes', value: '0', icon: Icons.pending_actions, color: Colors.orange),
                StatCard(title: 'Resueltos', value: '0', icon: Icons.check_circle, color: Colors.green),
                StatCard(title: 'En Proceso', value: '0', icon: Icons.autorenew, color: Colors.blue),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
