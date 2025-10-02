import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../widgets/custom_card.dart';

class CamarasAdminScreen extends StatelessWidget {
  const CamarasAdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthService>().currentUser!;
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Cámaras'),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [user.rol.gradientStart, user.rol.gradientEnd]),
          ),
        ),
      ),
      body: GridView.count(
        padding: const EdgeInsets.all(16),
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        children: [
          _buildCamara('Entrada', 'Activa'),
          _buildCamara('Parqueadero', 'Activa'),
          _buildCamara('Salón', 'Activa'),
          _buildCamara('BBQ', 'Activa'),
        ],
      ),
    );
  }

  Widget _buildCamara(String nombre, String estado) {
    return CustomCard(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.videocam, size: 48, color: Colors.blue),
          const SizedBox(height: 8),
          Text(nombre, style: const TextStyle(fontWeight: FontWeight.bold)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(4)),
            child: const Text('ACTIVA', style: TextStyle(color: Colors.white, fontSize: 10)),
          ),
        ],
      ),
    );
  }
}
