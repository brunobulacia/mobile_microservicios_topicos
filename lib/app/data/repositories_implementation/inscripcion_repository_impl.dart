import '../../domain/models/inscripcion.dart';
import '../../domain/repositories/inscripcion_repository.dart';
import '../services/remote/inscripcion_api.dart';

class InscripcionRepositoryImpl implements InscripcionRepository {
  InscripcionRepositoryImpl(this._inscripcionApi);
  final InscripcionApi _inscripcionApi;

  @override
  Future<Map<String, dynamic>> inscribirMaterias(
    Inscripcion inscripcion,
  ) async {
    final response = await _inscripcionApi.inscribirMaterias(inscripcion);
    return response;
  }
}
