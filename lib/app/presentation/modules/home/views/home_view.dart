import 'package:flutter/material.dart';

import '../../../../../main.dart';
import '../../../routes/routes.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: TextButton(
          onPressed: () {
            _submit(context);
          },
          child: Text('Sign Out'),
        ),
      ),
    );
  }

  Future<void> _submit(BuildContext context) async {
    await Injector.of(context).authenticationRepository.signOut();
    if (!context.mounted) {
      return;
    }
    Navigator.pushReplacementNamed(context, Routes.signIn);
  }
}
