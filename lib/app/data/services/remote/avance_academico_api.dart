import 'package:dio/dio.dart';

import '../../../domain/models/avance_academico.dart';
import '../global.dart';

class AvanceAcademicoApi {
  AvanceAcademicoApi(this._dio);
  final Dio _dio;

  Future<List<AvanceAcademico>> obtenerMateriasPasadas(
    String estudianteId,
  ) async {
    final response = await _dio.get(
      '$baseUrl/avance-academico/vencidas/$estudianteId/',
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = response.data;
      return data
          .map((item) => AvanceAcademico.fromJson(item))
          .toList(growable: false);
    } else {
      throw Exception('Fallo al cargar las materias inscritas');
    }
  }
}
