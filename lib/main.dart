import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'app/data/repositories_implementation/authentication_repository_impl.dart';
import 'app/data/repositories_implementation/connectivity_repository_impl.dart';
import 'app/data/repositories_implementation/inscripcion_repository_impl.dart';
import 'app/data/repositories_implementation/oferta_grupo_materia_repository_impl.dart';
import 'app/data/services/remote/authentication_api.dart';
import 'app/data/services/remote/inscripcion_api.dart';
import 'app/data/services/remote/internet_checker.dart';
import 'app/data/services/remote/oferta_grupo_materia_api.dart';
import 'app/domain/repositories/authentication_repository.dart';
import 'app/domain/repositories/connectivity_repository.dart';
import 'app/domain/repositories/inscripcion_repository.dart';
import 'app/domain/repositories/oferta_grupo_materia_repository.dart';
import 'app/my_app.dart';
import 'app/presentation/blocs/auth/auth_bloc.dart';

void main() {
  final authRepository = AuthenticationRepositoryImpl(
    const FlutterSecureStorage(),
    AuthenticationApi(Dio()),
  );

  runApp(
    Injector(
      connectivityRepository: ConnectivityRepositoryImpl(
        Connectivity(),
        InternetChecker(),
      ),
      authenticationRepository: authRepository,
      ofertaGrupoMateriaRepository: OfertaGrupoMateriaRepositoryImpl(
        OfertaGrupoMateriaApi(Dio()),
      ),
      inscripcionRepository: InscripcionRepositoryImpl(InscripcionApi(Dio())),
      child: BlocProvider(
        create: (context) => AuthBloc(authRepository),
        child: const MyApp(),
      ),
    ),
  );
}

class Injector extends InheritedWidget {
  const Injector({
    super.key,
    required super.child,
    required this.connectivityRepository,
    required this.authenticationRepository,
    required this.ofertaGrupoMateriaRepository,
    required this.inscripcionRepository,
  });

  final ConnectivityRepository connectivityRepository;
  final AuthenticationRepository authenticationRepository;
  final OfertaGrupoMateriaRepository ofertaGrupoMateriaRepository;
  final InscripcionRepository inscripcionRepository;

  @override
  bool updateShouldNotify(_) => false;

  static Injector of(BuildContext context) {
    final injector = context.dependOnInheritedWidgetOfExactType<Injector>();
    assert(injector != null, 'No Injector found in context');
    return injector!;
  }
}
