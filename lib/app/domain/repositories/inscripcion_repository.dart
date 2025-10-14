import '../../domain/models/inscripcion.dart';
import '../../domain/models/job_response.dart';
import '../../domain/models/job_status.dart';

abstract class InscripcionRepository {
  Future<JobResponse> inscribirMaterias(Inscripcion inscripcion);
  Future<JobStatus> consultarEstadoInscripcion(String jobId);
}
