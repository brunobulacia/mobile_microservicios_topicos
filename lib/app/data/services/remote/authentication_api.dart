import 'package:dio/dio.dart';

import '../global.dart';

class AuthenticationApi {
  AuthenticationApi(this._dio);
  final Dio _dio;

  Future<Map<String, dynamic>> signIn(String username, String password) async {
    final response = await _dio.post(
      '$baseUrl/auth/login',
      data: {'matricula': username, 'password': password},
    );
    return response.data;
  }
}
