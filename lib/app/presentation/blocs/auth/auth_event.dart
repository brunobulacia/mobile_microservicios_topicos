import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

class AuthSignInRequested extends AuthEvent {
  final String registro;
  final String password;

  const AuthSignInRequested({
    required this.registro,
    required this.password,
  });

  @override
  List<Object> get props => [registro, password];
}

class AuthSignOutRequested extends AuthEvent {}

class AuthCheckRequested extends AuthEvent {}