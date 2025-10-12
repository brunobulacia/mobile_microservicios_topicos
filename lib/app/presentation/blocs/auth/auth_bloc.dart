import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/repositories/authentication_repository.dart';
import '../../../domain/enums.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthenticationRepository _authRepository;

  AuthBloc(this._authRepository) : super(AuthInitial()) {
    on<AuthSignInRequested>(_onSignInRequested);
    on<AuthSignOutRequested>(_onSignOutRequested);
    on<AuthCheckRequested>(_onCheckRequested);
  }

  Future<void> _onSignInRequested(
    AuthSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final result = await _authRepository.signIn(
      event.registro,
      event.password,
    );

    result.when(
      (failure) {
        final message = {
          SignInFailure.notFound: 'No encontrado',
          SignInFailure.unauthorized: 'Credenciales no válidas',
          SignInFailure.unknown: 'Error desconocido',
        }[failure]!;
        emit(AuthError(message));
      },
      (user) {
        emit(AuthAuthenticated(user));
      },
    );
  }

  Future<void> _onSignOutRequested(
    AuthSignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await _authRepository.signOut();
    emit(AuthUnauthenticated());
  }

  Future<void> _onCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    final isSignedIn = await _authRepository.isSignedIn;
    if (isSignedIn) {
      final user = await _authRepository.getUserData();
      if (user != null) {
        emit(AuthAuthenticated(user));
      } else {
        emit(AuthUnauthenticated());
      }
    } else {
      emit(AuthUnauthenticated());
    }
  }
}