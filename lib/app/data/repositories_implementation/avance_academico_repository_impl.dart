import '../../domain/models/avance_academico.dart';
import '../../domain/repositories/avance_academico_repository.dart';
import '../services/remote/avance_academico_api.dart';

class AvanceAcademicoRepositoryImpl implements AvanceAcademicoRepository {
  AvanceAcademicoRepositoryImpl(this._avanceAcademicoApi);

  final AvanceAcademicoApi _avanceAcademicoApi;
  @override
  Future<List<AvanceAcademico>> obtenerMateriasPasadas(String estudianteId) {
    final response = _avanceAcademicoApi.obtenerMateriasPasadas(estudianteId);
    return response;
  }
}
