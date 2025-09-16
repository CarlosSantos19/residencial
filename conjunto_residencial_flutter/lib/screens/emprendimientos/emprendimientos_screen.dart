import 'package:flutter/material.dart';

class EmprendimientosScreen extends StatelessWidget {
  const EmprendimientosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.8,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) => _buildEmprendimientoCard(_emprendimientos[index]),
                childCount: _emprendimientos.length,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 100,
      floating: false,
      pinned: true,
      backgroundColor: const Color(0xFF8B5CF6),
      flexibleSpace: FlexibleSpaceBar(
        title: const Text(
          'Emprendimientos',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF8B5CF6), Color(0xFFA855F7)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmprendimientoCard(_Emprendimiento emprendimiento) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Imagen/Header
          Container(
            height: 100,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: emprendimiento.colores,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Center(
              child: Icon(
                emprendimiento.icono,
                size: 40,
                color: Colors.white,
              ),
            ),
          ),

          // Contenido
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          emprendimiento.nombre,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1F2937),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: emprendimiento.colores.first.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          emprendimiento.categoria,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: emprendimiento.colores.first,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 4),

                  Text(
                    emprendimiento.propietario,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 8),

                  Text(
                    emprendimiento.descripcion,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade700,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const Spacer(),

                  // Botones de acción
                  Row(
                    children: [
                      Expanded(
                        child: _buildActionButton(
                          icon: Icons.phone,
                          label: 'Llamar',
                          color: const Color(0xFF10B981),
                          onTap: () {
                            // TODO: Implementar llamada
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildActionButton(
                          icon: Icons.chat,
                          label: 'Chat',
                          color: const Color(0xFF3B82F6),
                          onTap: () {
                            // TODO: Implementar chat directo
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static final List<_Emprendimiento> _emprendimientos = [
    _Emprendimiento(
      nombre: 'Delicias Caseras',
      propietario: 'Laura Ruiz - 203A',
      categoria: 'Comida',
      descripcion: 'Postres artesanales y comida casera. Especialidad en tortas y platos típicos.',
      telefono: '300-123-4567',
      icono: Icons.cake,
      colores: [Color(0xFFEF4444), Color(0xFFF87171)],
    ),
    _Emprendimiento(
      nombre: 'TecniFix',
      propietario: 'Miguel Santos - 302B',
      categoria: 'Técnico',
      descripcion: 'Reparación de electrodomésticos y servicios técnicos a domicilio.',
      telefono: '301-987-6543',
      icono: Icons.build,
      colores: [Color(0xFF3B82F6), Color(0xFF60A5FA)],
    ),
    _Emprendimiento(
      nombre: 'Belleza en Casa',
      propietario: 'Carmen Torres - 104C',
      categoria: 'Belleza',
      descripcion: 'Servicios de manicure, pedicure y tratamientos de belleza a domicilio.',
      telefono: '302-555-0123',
      icono: Icons.spa,
      colores: [Color(0xFFEC4899), Color(0xFFF472B6)],
    ),
    _Emprendimiento(
      nombre: 'Verde Hogar',
      propietario: 'Ana Morales - 601A',
      categoria: 'Plantas',
      descripcion: 'Venta de plantas ornamentales y servicio de jardinería.',
      telefono: '304-777-8899',
      icono: Icons.local_florist,
      colores: [Color(0xFF10B981), Color(0xFF34D399)],
    ),
    _Emprendimiento(
      nombre: 'Fit Coach',
      propietario: 'Roberto Díaz - 205B',
      categoria: 'Fitness',
      descripcion: 'Entrenamiento personal y clases grupales de ejercicio.',
      telefono: '305-444-5566',
      icono: Icons.fitness_center,
      colores: [Color(0xFFF59E0B), Color(0xFFFBBF24)],
    ),
    _Emprendimiento(
      nombre: 'Costura Ideal',
      propietario: 'María González - 403C',
      categoria: 'Textil',
      descripcion: 'Arreglos de ropa, confección y servicios de costura.',
      telefono: '306-222-3344',
      icono: Icons.content_cut,
      colores: [Color(0xFF8B5CF6), Color(0xFFA78BFA)],
    ),
  ];
}

class _Emprendimiento {
  final String nombre;
  final String propietario;
  final String categoria;
  final String descripcion;
  final String telefono;
  final IconData icono;
  final List<Color> colores;

  _Emprendimiento({
    required this.nombre,
    required this.propietario,
    required this.categoria,
    required this.descripcion,
    required this.telefono,
    required this.icono,
    required this.colores,
  });
}