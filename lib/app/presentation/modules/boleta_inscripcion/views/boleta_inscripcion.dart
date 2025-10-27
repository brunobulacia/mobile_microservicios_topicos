import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../main.dart';
import '../../../../domain/models/boleta_inscripcion.dart';
import '../../../blocs/auth/auth_bloc.dart';
import '../../../blocs/auth/auth_state.dart';

class BoletaInscripcionView extends StatefulWidget {
  const BoletaInscripcionView({super.key});

  @override
  State<BoletaInscripcionView> createState() => _BoletaInscripcionViewState();
}

class _BoletaInscripcionViewState extends State<BoletaInscripcionView> {
  String? error;
  List<BoletaInscripcion>? boletaData;
  bool isLoading = true;

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  @override
  void initState() {
    super.initState();
    // No llamamos _loadBoletaInscripcion aquí porque ahora depende del estado de auth
  }

  Future<void> _loadBoletaInscripcion(String estudianteId) async {
    try {
      setState(() {
        isLoading = true;
        error = null;
      });

      final injector = Injector.of(context);
      final boletaInscripcionRepository = injector.boletaInscripcionRepository;
      final ofertaGrupoMateriaRepository =
          injector.ofertaGrupoMateriaRepository;

      final response = await boletaInscripcionRepository
          .obtenerMateriasInscritasEstudiante(estudianteId);

      print('Boleta de inscripción cargada: $response');

      setState(() {
        boletaData = response;
        isLoading = false;
      });
    } catch (e) {
      print('Error al cargar la boleta de inscripción: $e');
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  Future<void> loadBoletaInscripcion(String estudianteId) async {
    try {
      setState(() {
        isLoading = true;
        error = null;
      });

      final injector = Injector.of(context);
      final boletaInscripcionRepository = injector.boletaInscripcionRepository;
      final ofertaGrupoMateriaRepository =
          injector.ofertaGrupoMateriaRepository;

      final response = await boletaInscripcionRepository
          .obtenerMateriasInscritasEstudiante(estudianteId);

      print('Boleta de inscripción cargada: $response');

      setState(() {
        boletaData = response;
        isLoading = false;
      });
    } catch (e) {
      print('Error al cargar la boleta de inscripción: $e');
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  Widget buildSummaryCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget buildModernChip(String text, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
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
          'Boleta de Inscripción',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, authState) {
          if (authState is AuthAuthenticated) {
            final user = authState.user;
            final id = user.id; // Usar matrícula del usuario autenticado

            // Inicializar datos si es necesario
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (boletaData == null && isLoading) {
                _loadBoletaInscripcion(id);
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
                    'Debes iniciar sesión para ver tu boleta',
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
            Text('Cargando tu boleta de inscripción...'),
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
                'Error al cargar la boleta:',
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
                  // Obtener el registro del usuario actual para reintentar
                  final authState = context.read<AuthBloc>().state;
                  if (authState is AuthAuthenticated) {
                    loadBoletaInscripcion(authState.user.id);
                  }
                },
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      );
    }

    if (boletaData == null) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.description_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No se encontró información de inscripción',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    // Mostrar boleta de inscripción con diseño moderno
    return Column(
      children: [
        // Header con información general (puedes agregar resumen si lo deseas)
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.blue[700]!, Colors.blue[500]!],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
            child: Column(
              children: [
                Text(
                  'Materias Inscritas',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Total: ${boletaData!.length}',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
        ),
        // Lista de materias inscritas
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListView.builder(
              itemCount: boletaData!.length,
              itemBuilder: (context, index) {
                final inscripcion = boletaData![index];
                final materia = inscripcion.materia;
                final docente = inscripcion.docente;
                final aula = inscripcion.aulaGrupoMateria.isNotEmpty
                    ? inscripcion.aulaGrupoMateria.first.aula
                    : null;
                final horarios = inscripcion.aulaGrupoMateria.isNotEmpty
                    ? inscripcion.aulaGrupoMateria.first.horario
                    : <dynamic>[];

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
                                color: Colors.blue[50],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.book_outlined,
                                color: Colors.blue[600],
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
                                      color: Colors.blue[700],
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
                            // Puedes agregar aquí un chip de estado, nota, etc.
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Icon(
                              Icons.person,
                              size: 18,
                              color: Colors.blue.shade400,
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
                              color: Colors.blue.shade400,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              inscripcion.grupo,
                              style: const TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(
                              Icons.class_,
                              size: 18,
                              color: Colors.blue.shade400,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Aula ${aula != null ? aula.numero.toString() : '-'}',
                              style: const TextStyle(fontSize: 14),
                            ),
                            const SizedBox(width: 16),
                            Icon(
                              Icons.people,
                              size: 18,
                              color: Colors.blue.shade400,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${inscripcion.inscritos}/${inscripcion.cupos}',
                              style: const TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.schedule,
                              size: 18,
                              color: Colors.blue.shade400,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                horarios.isNotEmpty
                                    ? horarios
                                          .map(
                                            (h) =>
                                                '${h.diaSemana} ${h.horaInicio}-${h.horaFin}',
                                          )
                                          .join(', ')
                                    : '-',
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Colors.black87,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              size: 16,
                              color: Colors.blue.shade400,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Inscrito el: ${_formatDate(inscripcion.createdAt)}',
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
