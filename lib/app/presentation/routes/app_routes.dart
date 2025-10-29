import 'package:flutter/material.dart';

import '../../domain/models/job_response.dart';
import '../modules/avance_academico/views/avance_academico_view.dart';
import '../modules/boleta_inscripcion/views/boleta_inscripcion.dart';
import '../modules/grupo_materia/views/grupo_materia.dart';
import '../modules/home/views/home_view.dart';
import '../modules/inscripcion_iniciada/views/inscripcion_iniciada_view.dart';
import '../modules/offline/views/offline_view.dart';
import '../modules/proceso_inscripcion/views/proceso_inscripcion_view.dart';
import '../modules/sign_in/views/sign_in_view.dart';
import '../modules/splash/views/splash_view.dart';
import 'routes.dart';

Map<String, Widget Function(BuildContext)> get appRoutes {
  return {
    Routes.splash: (context) => const SplashView(),
    Routes.signIn: (context) => const SignInView(),
    Routes.home: (context) => const HomeView(),
    Routes.offline: (context) => const OfflineView(),
    Routes.grupoMateria: (context) => const GrupoMateriaView(),
    Routes.boletaInscripcion: (context) => const BoletaInscripcionView(),
    Routes.avanceAcademico: (context) => const AvanceAcademicoView(),
    Routes.inscripcionIniciada: (context) {
      final jobResponse =
          ModalRoute.of(context)!.settings.arguments as JobResponse;
      return InscripcionIniciadaView(jobResponse: jobResponse);
    },
    Routes.procesoInscripcion: (context) {
      print('Ruta procesoInscripcion llamada');
      final route = ModalRoute.of(context);
      print('Route arguments: ${route?.settings.arguments}');

      final jobId = route!.settings.arguments as String;
      print('JobId recibido correctamente: $jobId');

      return ProcesoInscripcion(jobId: jobId);
    },
  };
}
