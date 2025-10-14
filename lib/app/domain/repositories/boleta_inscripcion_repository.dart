import '../models/boleta_inscripcion.dart';

abstract class BoletaInscripcionRepository {
  Future<List<BoletaInscripcion>> obtenerMateriasInscritasEstudiante(
    String matricula,
  );
}
