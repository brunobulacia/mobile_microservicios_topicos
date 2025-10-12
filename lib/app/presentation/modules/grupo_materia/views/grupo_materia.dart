import 'package:flutter/material.dart';

import '../../../../domain/models/oferta_grupo_materia.dart';
import '../../../global/widgets/grupo_materia_card.dart';

class GrupoMateriaView extends StatelessWidget {
  const GrupoMateriaView({super.key});

  @override
  Widget build(BuildContext context) {
    // Ejemplo de uso con tu JSON
    final Map<String, dynamic> jsonData = {
      "GrupoMateria": {
        "id": "1", // Agregué un ID porque está en el modelo
        "grupo": "SC",
        "cupos": 10,
        "materia": {"nombre": "Calculo I"},
        "docente": {"nombre": "Miguel Jesus", "apellido_paterno": "Peinado"},
      },
    };

    // Crear el objeto GrupoMateria desde el JSON
    final grupoMateria = GrupoMateria.fromJson(jsonData['GrupoMateria']);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ejemplo GrupoMateria Card'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Usar el card con los datos del JSON
            GrupoMateriaCard(grupoMateria: grupoMateria),

            const SizedBox(height: 20),

            // Ejemplo de múltiples cards
            const Text(
              'Ejemplo con múltiples materias:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            // Más ejemplos
            GrupoMateriaCard(
              grupoMateria: GrupoMateria(
                id: '2',
                grupo: 'SA',
                cupos: 15,
                materia: Materia(nombre: 'Física II'),
                docente: Docente(
                  nombre: 'Ana María',
                  apellidoPaterno: 'González',
                ),
              ),
            ),

            GrupoMateriaCard(
              grupoMateria: GrupoMateria(
                id: '3',
                grupo: 'SB',
                cupos: 12,
                materia: Materia(nombre: 'Programación I'),
                docente: Docente(
                  nombre: 'Carlos',
                  apellidoPaterno: 'Rodríguez',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
