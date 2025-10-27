import 'package:dio/dio.dart';

import '../../../domain/models/boleta_inscripcion.dart';
import '../global.dart';

class BoletaInscripcionApi {
  BoletaInscripcionApi(this._dio);
  final Dio _dio;

  Future<List<BoletaInscripcion>> obtenerMateriasInscritasEstudiante(
    String estudianteId,
  ) async {
    final response = await _dio.get(
      '$baseUrl/boletas-inscripcion/estudiante/$estudianteId/',
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = response.data;
      return data
          .map((item) => BoletaInscripcion.fromJson(item))
          .toList(growable: false);
    } else {
      throw Exception('Fallo al cargar las materias inscritas');
    }
  }
}
