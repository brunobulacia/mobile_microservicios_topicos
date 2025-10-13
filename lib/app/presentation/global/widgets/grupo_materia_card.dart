import 'package:flutter/material.dart';

import '../../../domain/models/oferta_grupo_materia.dart';

class GrupoMateriaCard extends StatelessWidget {
  const GrupoMateriaCard({
    super.key,
    required this.grupoMateria,
    required this.isSelected,
    required this.onSelectionChanged,
  });

  final GrupoMateria grupoMateria;
  final bool isSelected;
  final Function(bool) onSelectionChanged;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    grupoMateria.materia.nombre,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ),
                Checkbox(
                  value: isSelected,
                  onChanged: (value) {
                    if (value != null) {
                      onSelectionChanged(value);
                      print(
                        '${isSelected ? "Deseleccionado" : "Seleccionado"}: ${grupoMateria.id}',
                      );
                    }
                  },
                ),
              ],
            ),

            // Título de la materia
            const SizedBox(height: 12),
            // Información del grupo y cupos
            Row(
              children: [
                Expanded(
                  child: _buildInfoItem(
                    icon: Icons.group,
                    label: 'Grupo',
                    value: grupoMateria.grupo,
                  ),
                ),
                Expanded(
                  child: _buildInfoItem(
                    icon: Icons.people,
                    label: 'Cupos',
                    value: grupoMateria.cupos.toString(),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Información del docente
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  const Icon(Icons.person, color: Colors.grey, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Docente: ',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      '${grupoMateria.docente.nombre} ${grupoMateria.docente.apellidoPaterno}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.blue),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              value,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ],
    );
  }
}
