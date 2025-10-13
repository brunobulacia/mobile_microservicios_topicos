import 'package:flutter/material.dart';

class BoletaInscripcionView extends StatefulWidget {
  const BoletaInscripcionView({super.key});

  @override
  State<BoletaInscripcionView> createState() => _BoletaInscripcionViewState();
}

class _BoletaInscripcionViewState extends State<BoletaInscripcionView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Boleta de Inscripción')),
      body: const Center(
        child: Text('Aquí se mostrará la boleta de inscripción.'),
      ),
    );
  }
}
