import 'package:dio/dio.dart';

import '../../../domain/models/inscripcion.dart';
import '../global.dart';

class InscripcionApi {
  InscripcionApi(this._dio);
  final Dio _dio;

  Future<Map<String, dynamic>> inscribirMaterias(
    Inscripcion inscripcion,
  ) async {
    final response = await _dio.post(
      '$baseUrl/inscripciones/async/',
      data: inscripcion.toJson(),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return Map<String, dynamic>.from(response.data);
    } else {
      throw Exception('Failed to inscribir materias: ${response.statusCode}');
    }
  }
}
