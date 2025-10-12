import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../main.dart';
import '../../../blocs/auth/auth_bloc.dart';
import '../../../blocs/auth/auth_event.dart';
import '../../../blocs/auth/auth_state.dart';
import '../../../routes/routes.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _init();
    });
  }

  Future<void> _init() async {
    final injector = Injector.of(context);
    final connectivityRepository = injector.connectivityRepository;

    final hasInternet = await connectivityRepository.hasInternet;
    print('✅ hasInternet: $hasInternet');

    if (hasInternet) {
      // Usar Bloc para verificar el estado de autenticación
      if (mounted) {
        context.read<AuthBloc>().add(AuthCheckRequested());
      }
    } else {
      // Si no hay internet, ir a la página offline
      _goTo(Routes.offline);
    }
  }

  void _goTo(String routeName) {
    Navigator.pushReplacementNamed(context, routeName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            _goTo(Routes.home);
          } else if (state is AuthUnauthenticated || state is AuthError) {
            _goTo(Routes.signIn);
          }
        },
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 80,
                height: 80,
                child: CircularProgressIndicator(),
              ),
              SizedBox(height: 20),
              Text(
                'Cargando...',
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
