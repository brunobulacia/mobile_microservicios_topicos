import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../domain/either.dart';
import '../../domain/enums.dart';
import '../../domain/models/user.dart';
import '../../domain/repositories/authentication_repository.dart';
import '../services/remote/authentication_api.dart';

const _key = 'access_token';

class AuthenticationRepositoryImpl implements AuthenticationRepository {
  AuthenticationRepositoryImpl(this._secureStorage, this._authenticationApi);
  final FlutterSecureStorage _secureStorage;
  final AuthenticationApi _authenticationApi;

  @override
  Future<bool> get isSignedIn async {
    final sessionId = await _secureStorage.read(key: _key);
    return sessionId != null;
  }

  @override
  //RETORNAR UNA INSTANCIA DE LA CLASE USER
  Future<User?> getUserData() async {
    return Future.value(User());
  }

  @override
  Future<Either<SignInFailure, User>> signIn(
    String registro,
    String password,
  ) async {
    try {
      final accessToken = await _authenticationApi.signIn(registro, password);

      await _secureStorage.write(key: _key, value: accessToken);

      return Either.right(User());
    } catch (e) {
      return Either.left(SignInFailure.unauthorized);
    }
  }

  @override
  Future<void> signOut() {
    return _secureStorage.delete(key: _key);
  }
}
