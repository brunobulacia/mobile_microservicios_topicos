import 'package:flutter/material.dart';

class GrupoMateriaCard extends StatelessWidget {
  const GrupoMateriaCard({
    super.key,
    required this.isSelected,
    required this.onSelectionChanged,
    required this.materiaNombre,
    required this.materiaSigla,
    required this.docenteNombre,
    required this.aulaNumero,
    required this.horario,
    required this.grupo,
    required this.cupos,
    required this.inscritos,
  });

  final bool isSelected;
  final Function(bool) onSelectionChanged;
  final String materiaNombre;
  final String materiaSigla;
  final String docenteNombre;
  final String aulaNumero;
  final String horario;
  final String grupo;
  final int cupos;
  final int inscritos;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => onSelectionChanged(!isSelected),
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          materiaSigla,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          materiaNombre,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Checkbox(
                    value: isSelected,
                    onChanged: (value) {
                      if (value != null) {
                        onSelectionChanged(value);
                      }
                    },
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Icon(Icons.person, size: 18, color: Colors.blue.shade400),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      docenteNombre,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Icon(Icons.group, size: 18, color: Colors.blue.shade400),
                  const SizedBox(width: 4),
                  Text(grupo, style: const TextStyle(fontSize: 14)),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Icon(Icons.class_, size: 18, color: Colors.blue.shade400),
                  const SizedBox(width: 6),
                  Text(
                    'Aula $aulaNumero',
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.people, size: 18, color: Colors.blue.shade400),
                  const SizedBox(width: 4),
                  Text(
                    '$inscritos/$cupos',
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.schedule, size: 18, color: Colors.blue.shade400),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      horario,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black87,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
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
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
