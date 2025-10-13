import '../../domain/models/inscripcion.dart';

abstract class InscripcionRepository {
  Future<Map<String, dynamic>> inscribirMaterias(Inscripcion inscripcion);
}
