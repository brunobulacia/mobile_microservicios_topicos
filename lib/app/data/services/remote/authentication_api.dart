import 'package:dio/dio.dart';

class AuthenticationApi {
  AuthenticationApi(this._dio);
  final Dio _dio;
  final _baseUrl = 'http://localhost:4000/api';

  Future<String> signIn(String username, String password) async {
    final response = await _dio.post(
      '$_baseUrl/auth/login',
      data: {'matricula': username, 'password': password},
    );
    // print(response.data);
    return response.data['access_token'];
  }
}
