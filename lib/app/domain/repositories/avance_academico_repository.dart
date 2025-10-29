import '../models/avance_academico.dart';

abstract class AvanceAcademicoRepository {
  Future<List<AvanceAcademico>> obtenerMateriasPasadas(String estudianteId);
}
