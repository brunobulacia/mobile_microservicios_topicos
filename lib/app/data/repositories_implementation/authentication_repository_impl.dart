import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../domain/either.dart';
import '../../domain/enums.dart';
import '../../domain/models/user.dart';
import '../../domain/repositories/authentication_repository.dart';
import '../services/remote/authentication_api.dart';

const _tokenKey = 'access_token';
const _userKey = 'user_data';

class AuthenticationRepositoryImpl implements AuthenticationRepository {
  AuthenticationRepositoryImpl(this._secureStorage, this._authenticationApi);
  final FlutterSecureStorage _secureStorage;
  final AuthenticationApi _authenticationApi;

  @override
  Future<bool> get isSignedIn async {
    final sessionId = await _secureStorage.read(key: _tokenKey);
    return sessionId != null;
  }

  @override
  Future<User?> getUserData() async {
    final userJson = await _secureStorage.read(key: _userKey);
    if (userJson != null) {
      final userMap = jsonDecode(userJson) as Map<String, dynamic>;
      return User.fromJson(userMap);
    }
    return null;
  }

  @override
  Future<Either<SignInFailure, User>> signIn(
    String registro,
    String password,
  ) async {
    try {
      final response = await _authenticationApi.signIn(registro, password);
      
      final accessToken = response['access_token'] as String;
      final user = User.fromJson(response);

      // Guardar el token y los datos del usuario
      await _secureStorage.write(key: _tokenKey, value: accessToken);
      await _secureStorage.write(key: _userKey, value: jsonEncode(user.toJson()));

      return Either.right(user);
    } catch (e) {
      return Either.left(SignInFailure.unauthorized);
    }
  }

  @override
  Future<void> signOut() async {
    await _secureStorage.delete(key: _tokenKey);
    await _secureStorage.delete(key: _userKey);
  }
}
