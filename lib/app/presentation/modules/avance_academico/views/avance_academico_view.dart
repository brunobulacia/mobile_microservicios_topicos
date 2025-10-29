import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../main.dart';
import '../../../../domain/models/avance_academico.dart';
import '../../../blocs/auth/auth_bloc.dart';
import '../../../blocs/auth/auth_state.dart';

class AvanceAcademicoView extends StatefulWidget {
  const AvanceAcademicoView({super.key});

  @override
  State<AvanceAcademicoView> createState() => _AvanceAcademicoViewState();
}

class _AvanceAcademicoViewState extends State<AvanceAcademicoView> {
  String? error;
  List<AvanceAcademico>? avanceData;
  bool isLoading = true;

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  @override
  void initState() {
    super.initState();
    // No llamamos _loadAvanceAcademico aquí porque depende del estado de auth
  }

  Future<void> _loadAvanceAcademico(String estudianteId) async {
    try {
      setState(() {
        isLoading = true;
        error = null;
      });

      final injector = Injector.of(context);
      final avanceAcademicoRepository = injector.avanceAcademicoRepository;

      final response = await avanceAcademicoRepository.obtenerMateriasPasadas(
        estudianteId,
      );

      print('Avance Académico cargado: $response');

      setState(() {
        avanceData = response;
        isLoading = false;
      });
    } catch (e) {
      print('Error al cargar el avance académico: $e');
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  Widget buildNotaChip(int nota) {
    Color color;
    if (nota >= 51) {
      color = Colors.green;
    } else if (nota >= 30) {
      color = Colors.orange;
    } else {
      color = Colors.red;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.grade, size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            'Nota: $nota',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Avance Académico',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, authState) {
          if (authState is AuthAuthenticated) {
            final user = authState.user;
            final id = user.id;
            // Inicializar datos si es necesario
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (avanceData == null && isLoading) {
                _loadAvanceAcademico(id);
              }
            });
            return _buildBody();
          } else if (authState is AuthLoading) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Verificando autenticación...'),
                ],
              ),
            );
          } else {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.login, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'Debes iniciar sesión para ver tu avance académico',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Cargando tu avance académico...'),
          ],
        ),
      );
    }

    if (error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 64),
              const SizedBox(height: 16),
              Text(
                'Error al cargar el avance académico:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.red[700],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                error!,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.red[600]),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  final authState = context.read<AuthBloc>().state;
                  if (authState is AuthAuthenticated) {
                    _loadAvanceAcademico(authState.user.id);
                  }
                },
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      );
    }

    if (avanceData == null || avanceData!.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.description_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No se encontró información de avance académico',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.indigo[700]!, Colors.indigo[400]!],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
            child: Column(
              children: [
                Text(
                  'Materias Aprobadas',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Total: ${avanceData!.length}',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListView.builder(
              itemCount: avanceData!.length,
              itemBuilder: (context, index) {
                final avance = avanceData![index];
                final materia = avance.materia;
                final docente = avance.docente;
                final nota = avance.nota.nota;

                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.indigo[50],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.book_outlined,
                                color: Colors.indigo[600],
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    materia.sigla,
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.indigo[700],
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    materia.nombre,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            buildNotaChip(nota),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Icon(
                              Icons.person,
                              size: 18,
                              color: Colors.indigo.shade400,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                '${docente.nombre} ${docente.apellidoPaterno}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Icon(
                              Icons.group,
                              size: 18,
                              color: Colors.indigo.shade400,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              avance.grupo,
                              style: const TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              size: 16,
                              color: Colors.indigo.shade400,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Aprobada el: ${_formatDate(avance.createdAt)}',
                              style: const TextStyle(fontSize: 13),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
