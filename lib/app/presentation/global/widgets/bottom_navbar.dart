import 'package:flutter/material.dart';

import '../../routes/routes.dart';

class BottomNavbar extends StatelessWidget {
  const BottomNavbar({super.key});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      selectedFontSize: 11,
      unselectedFontSize: 10,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.book, size: 22),
          label: 'Materias',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person, size: 22),
          label: 'Perfil',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.receipt, size: 22),
          label: 'Boleta',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.file_copy, size: 22),
          label: 'Avance',
        ),
      ],
      currentIndex: 0, // Cambiar según la página actual
      onTap: (index) {
        // Manejar la navegación aquí
        if (index == 1) {
          Navigator.pushNamed(context, Routes.home);
        } else if (index == 2) {
          Navigator.pushNamed(context, Routes.boletaInscripcion);
        } else if (index == 3) {
          Navigator.pushNamed(context, Routes.avanceAcademico);
        }
      },
    );
  }
}
