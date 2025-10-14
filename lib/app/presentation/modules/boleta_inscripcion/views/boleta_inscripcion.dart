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
  List<BoletaInscripcion>? boletaData;
  bool isLoading = true;
  String? error;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Boleta de Inscripción',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, authState) {
          if (authState is AuthAuthenticated) {
            final user = authState.user;
            final registro =
                user.matricula; // Usar matrícula del usuario autenticado

            // Inicializar datos si es necesario
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (boletaData == null && isLoading) {
                _loadBoletaInscripcion(registro);
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
                    _loadBoletaInscripcion(authState.user.matricula);
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

    // Aquí mostraremos los datos cuando estén disponibles
    return Column(
      children: [
        // Header con información general
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
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildSummaryCard(
                        'Materias',
                        boletaData!.length.toString(),
                        Icons.book,
                        Colors.blue[600]!,
                      ),
                      Container(width: 1, height: 40, color: Colors.grey[300]),
                      _buildSummaryCard(
                        'Créditos',
                        _calculateTotalCredits().toString(),
                        Icons.star,
                        Colors.orange[600]!,
                      ),
                      Container(width: 1, height: 40, color: Colors.grey[300]),
                      _buildSummaryCard(
                        'Promedio',
                        _calculateAverage().toStringAsFixed(1),
                        Icons.trending_up,
                        _getAverageColor(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        // Lista de materias
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ListView.builder(
              itemCount: boletaData!.length,
              itemBuilder: (context, index) {
                final inscripcion = boletaData![index];
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
                        // Header de la materia
                        Row(
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
                                    inscripcion.grupoMateria.materia.nombre,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(
                                          fontWeight: FontWeight.w600,
                                          color: Colors.grey[800],
                                        ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    inscripcion.grupoMateria.materia.sigla,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[600],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Nota con color
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: inscripcion.nota >= 51
                                    ? Colors.green[50]
                                    : Colors.red[50],
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: inscripcion.nota >= 51
                                      ? Colors.green[200]!
                                      : Colors.red[200]!,
                                ),
                              ),
                              child: Text(
                                inscripcion.nota.toString(),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: inscripcion.nota >= 51
                                      ? Colors.green[700]
                                      : Colors.red[700],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Información adicional
                        Row(
                          children: [
                            _buildModernChip(
                              'Grupo ${inscripcion.grupoMateria.grupo}',
                              Icons.group,
                              Colors.orange,
                            ),
                            const SizedBox(width: 8),
                            _buildModernChip(
                              '${inscripcion.grupoMateria.materia.creditos} Créditos',
                              Icons.star_border,
                              Colors.blue,
                            ),
                            const SizedBox(width: 8),
                            _buildModernChip(
                              '${inscripcion.grupoMateria.materia.nivel.semestre}° Sem',
                              Icons.timeline,
                              Colors.teal,
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

  @override
  void initState() {
    super.initState();
    // No llamamos _loadBoletaInscripcion aquí porque ahora depende del estado de auth
  }

  Future<void> _loadBoletaInscripcion(String registro) async {
    try {
      setState(() {
        isLoading = true;
        error = null;
      });

      final injector = Injector.of(context);
      final boletaInscripcionRepository = injector.boletaInscripcionRepository;

      final response = await boletaInscripcionRepository
          .obtenerMateriasInscritasEstudiante(registro);

      print('✅ Boleta cargada: $response');

      setState(() {
        boletaData = response;
        isLoading = false;
      });
    } catch (e) {
      print('❌ Error al cargar la boleta de inscripción: $e');
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  Widget _buildSummaryCard(
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

  Widget _buildModernChip(String text, IconData icon, Color color) {
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

  int _calculateTotalCredits() {
    if (boletaData == null) return 0;
    return boletaData!.fold(
      0,
      (sum, inscripcion) => sum + inscripcion.grupoMateria.materia.creditos,
    );
  }

  double _calculateAverage() {
    if (boletaData == null || boletaData!.isEmpty) return 0.0;
    final totalNota = boletaData!.fold(
      0,
      (sum, inscripcion) => sum + inscripcion.nota,
    );
    return totalNota / boletaData!.length;
  }

  Color _getAverageColor() {
    final average = _calculateAverage();
    if (average >= 70) return Colors.green[600]!;
    if (average >= 51) return Colors.orange[600]!;
    return Colors.red[600]!;
  }
}
