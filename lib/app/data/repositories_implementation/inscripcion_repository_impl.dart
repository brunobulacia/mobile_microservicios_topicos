import '../../domain/models/inscripcion.dart';
import '../../domain/models/job_response.dart';
import '../../domain/models/job_status.dart';
import '../../domain/repositories/inscripcion_repository.dart';
import '../services/remote/inscripcion_api.dart';

class InscripcionRepositoryImpl implements InscripcionRepository {
  InscripcionRepositoryImpl(this._inscripcionApi);
  final InscripcionApi _inscripcionApi;

  @override
  Future<JobResponse> inscribirMaterias(
    Inscripcion inscripcion,
  ) async {
    final response = await _inscripcionApi.inscribirMaterias(inscripcion);
    return response;
  }

  @override
  Future<JobStatus> consultarEstadoInscripcion(String jobId) {
    final result = _inscripcionApi.consultarEstadoInscripcion(jobId);
    return result;
  }
}
