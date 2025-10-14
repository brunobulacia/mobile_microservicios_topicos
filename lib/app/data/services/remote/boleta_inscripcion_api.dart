import 'package:dio/dio.dart';

import '../../../domain/models/boleta_inscripcion.dart';
import '../global.dart';

class BoletaInscripcionApi {
  BoletaInscripcionApi(this._dio);
  final Dio _dio;

  Future<List<BoletaInscripcion>> obtenerMateriasInscritasEstudiante(
    String matricula,
  ) async {
    final response = await _dio.get(
      '$baseUrl/boleta-grupo-materias/$matricula/',
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = response.data;
      return data
          .map((item) => BoletaInscripcion.fromMap(item))
          .toList(growable: false);
    } else {
      throw Exception('Fallo al cargar las materias inscritas');
    }
  }
}
