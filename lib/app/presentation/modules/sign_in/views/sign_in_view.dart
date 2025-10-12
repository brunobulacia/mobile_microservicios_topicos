import 'package:flutter/material.dart';

import '../../../../../main.dart';
import '../../../../domain/enums.dart';
import '../../../routes/routes.dart';

class SignInView extends StatefulWidget {
  const SignInView({super.key});

  @override
  State<SignInView> createState() => _SignInViewState();
}

class _SignInViewState extends State<SignInView> {
  String _registro = '', _password = '';
  bool _fetching = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Form(
            child: AbsorbPointer(
              absorbing: _fetching,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextFormField(
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    onChanged: (text) {
                      setState(() {
                        _registro = text.trim().toLowerCase();
                      });
                    },
                    decoration: const InputDecoration(hintText: 'Registro'),
                    validator: (text) {
                      text = text?.trim() ?? '';
                      if (text.isEmpty) {
                        return 'Registro invalido';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    onChanged: (text) {
                      setState(() {
                        _password = text.replaceAll(' ', '');
                      });
                    },
                    decoration: const InputDecoration(hintText: '......'),
                    validator: (text) {
                      text = text?.replaceAll(' ', '').toLowerCase() ?? '';
                      if (text.length < 4) {
                        return 'Contraseña incorrecta';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  Builder(
                    builder: (context) {
                      if (_fetching) {
                        return CircularProgressIndicator();
                      }
                      return MaterialButton(
                        onPressed: () {
                          final isValid = Form.of(context).validate();
                          if (isValid) {
                            _submit(context);
                          }
                        },
                        color: Colors.blue,
                        child: Text('Iniciar Sesión'),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submit(BuildContext context) async {
    setState(() {
      _fetching = true;
    });

    print(_registro);
    print(_password);

    final result = await Injector.of(
      context,
    ).authenticationRepository.signIn(_registro, _password);

    if (!mounted) {
      return;
    }

    result.when(
      (failure) {
        setState(() {
          _fetching = false;
        });
        final message = {
          SignInFailure.notFound: 'No encontrado',
          SignInFailure.unauthorized: 'Credenciales no validas',
          SignInFailure.unknown: 'Desconocido',
        }[failure];
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message!)));
      },
      (user) {
        Navigator.pushReplacementNamed(context, Routes.home);
      },
    );
  }
}
