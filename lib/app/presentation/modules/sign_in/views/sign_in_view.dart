import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../blocs/auth/auth_bloc.dart';
import '../../../blocs/auth/auth_event.dart';
import '../../../blocs/auth/auth_state.dart';
import '../../../routes/routes.dart';

class SignInView extends StatefulWidget {
  const SignInView({super.key});

  @override
  State<SignInView> createState() => _SignInViewState();
}

class _SignInViewState extends State<SignInView> {
  String _registro = '';
  String _password = '';
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: BlocListener<AuthBloc, AuthState>(
            listener: (context, state) {
              if (state is AuthAuthenticated) {
                Navigator.pushReplacementNamed(context, Routes.home);
              } else if (state is AuthError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.message)),
                );
              }
            },
            child: Form(
              key: _formKey,
              child: BlocBuilder<AuthBloc, AuthState>(
                builder: (context, state) {
                  final isLoading = state is AuthLoading;
                  
                  return AbsorbPointer(
                    absorbing: isLoading,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextFormField(
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          onChanged: (text) {
                            _registro = text.trim().toLowerCase();
                          },
                          decoration: const InputDecoration(hintText: 'Registro'),
                          validator: (text) {
                            text = text?.trim() ?? '';
                            if (text.isEmpty) {
                              return 'Registro inválido';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          onChanged: (text) {
                            _password = text.replaceAll(' ', '');
                          },
                          obscureText: true,
                          decoration: const InputDecoration(hintText: 'Contraseña'),
                          validator: (text) {
                            text = text?.replaceAll(' ', '') ?? '';
                            if (text.length < 4) {
                              return 'Contraseña incorrecta';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        if (isLoading)
                          const CircularProgressIndicator()
                        else
                          MaterialButton(
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                context.read<AuthBloc>().add(
                                  AuthSignInRequested(
                                    registro: _registro,
                                    password: _password,
                                  ),
                                );
                              }
                            },
                            color: Colors.blue,
                            child: const Text('Iniciar Sesión'),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
