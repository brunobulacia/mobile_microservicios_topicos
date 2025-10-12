import 'package:dio/dio.dart';

import '../../../domain/models/oferta_grupo_materia.dart';
import '../global.dart';

class OfertaGrupoMateriaApi {
  OfertaGrupoMateriaApi(this._dio);

  final Dio _dio;

  Future<List<OfertaGrupoMateria>> getOfertasGruposMaterias(
    String maestroDeOfertaId,
  ) async {
    final response = await _dio.get(
      '$baseUrl/oferta-grupo-materias/$maestroDeOfertaId/',
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = response.data;
      return data
          .map((json) => OfertaGrupoMateria.fromJson(json))
          .toList(growable: false);
    }

    throw Exception('No se pudieron obtener los grupos de las materias');
  }
}
