import 'package:dio/dio.dart';

import '../../../domain/models/inscripcion.dart';
import '../../../domain/models/job_response.dart';
import '../../../domain/models/job_status.dart';
import '../global.dart';

class InscripcionApi {
  InscripcionApi(this._dio);
  final Dio _dio;

  Future<JobResponse> inscribirMaterias(
    Inscripcion inscripcion,
  ) async {
    final response = await _dio.post(
      '$baseUrl/inscripcion/async/',
      data: inscripcion.toJson(),
    );

    if (response.statusCode == 200 ||
        response.statusCode == 201 ||
        response.statusCode == 202) {
      return JobResponse.fromJson(Map<String, dynamic>.from(response.data));
    } else {
      throw Exception('Failed to inscribir materias: ${response.statusCode}');
    }
  }

  Future<JobStatus> consultarEstadoInscripcion(String jobId) async {
    final response = await _dio.get('$baseUrl/colas/jobs/$jobId/status');

    if (response.statusCode == 200) {
      return JobStatus.fromJson(Map<String, dynamic>.from(response.data));
    } else {
      throw Exception(
        'Failed to consultar estado de inscripción: ${response.statusCode}',
      );
    }
  }
}
