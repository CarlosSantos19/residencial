import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../widgets/custom_card.dart';

class CamarasResidenteScreen extends StatelessWidget {
  const CamarasResidenteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthService>().currentUser!;
    final camaras = [
      {'nombre': 'Entrada Principal', 'ubicacion': 'Portería', 'estado': 'Activa'},
      {'nombre': 'Parqueadero', 'ubicacion': 'Sótano 1', 'estado': 'Activa'},
      {'nombre': 'Salón Social', 'ubicacion': 'Piso 1', 'estado': 'Activa'},
      {'nombre': 'Zona BBQ', 'ubicacion': 'Terraza', 'estado': 'Activa'},
    ];

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Cámaras de Seguridad'),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [user.rol.gradientStart, user.rol.gradientEnd]),
          ),
        ),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.9,
        ),
        itemCount: camaras.length,
        itemBuilder: (context, index) {
          final camara = camaras[index];
          return CustomCard(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: Colors.blue.shade50, shape: BoxShape.circle),
                  child: const Icon(Icons.videocam, size: 40, color: Colors.blue),
                ),
                const SizedBox(height: 12),
                Text(camara['nombre']!, style: const TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                Text(camara['ubicacion']!, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(4)),
                  child: const Text('ACTIVA', style: TextStyle(color: Colors.white, fontSize: 10)),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
