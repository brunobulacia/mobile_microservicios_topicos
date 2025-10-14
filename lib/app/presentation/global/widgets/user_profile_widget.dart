import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_state.dart';

class UserProfileWidget extends StatelessWidget {
  const UserProfileWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthAuthenticated) {
          final user = state.user;
          return Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Información del Usuario',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 16),
                  _buildInfoRow(
                    'Nombre',
                    '${user.nombre} ${user.apellidoPaterno} ${user.apellidoMaterno}',
                  ),
                  _buildInfoRow('Email', user.email),
                  _buildInfoRow('Matrícula', user.matricula),
                  _buildInfoRow('CI', user.ci),
                  _buildInfoRow('Teléfono', user.telefono),
                  _buildInfoRow('PPAC', user.ppac.toString()),
                  const SizedBox(height: 16),
                  /* if (user.maestroDeOferta.isNotEmpty) ...[
                    Text(
                      'Maestro de Oferta:',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    ...user.maestroDeOferta.map(
                      (maestro) => Padding(
                        padding: const EdgeInsets.only(left: 16),
                        child: Text('• ID: ${maestro.id}'),
                      ),
                    ),
                  ], */
                ],
              ),
            ),
          );
        } else if (state is AuthLoading) {
          return const Center(child: CircularProgressIndicator());
        } else {
          return const Center(child: Text('No hay usuario autenticado'));
        }
      },
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
