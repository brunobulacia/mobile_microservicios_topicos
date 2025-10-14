import '../../domain/models/boleta_inscripcion.dart';
import '../../domain/repositories/boleta_inscripcion_repository.dart';
import '../services/remote/boleta_inscripcion_api.dart';

class BoletaInscripcionRepositoryImpl implements BoletaInscripcionRepository {
  BoletaInscripcionRepositoryImpl(this._boletaInscripcionApi);

  final BoletaInscripcionApi _boletaInscripcionApi;
  @override
  Future<List<BoletaInscripcion>> obtenerMateriasInscritasEstudiante(
    String matricula,
  ) {
    final response = _boletaInscripcionApi.obtenerMateriasInscritasEstudiante(
      matricula,
    );
    return response;
  }
}
