import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../main.dart';
import '../../../../data/services/idempotency_manager.dart';
import '../../../../data/services/inscripcion_polling_service.dart';
import '../../../../domain/models/inscripcion.dart';
import '../../../../domain/models/oferta_grupo_materia.dart';
import '../../../blocs/auth/auth_bloc.dart';
import '../../../blocs/auth/auth_state.dart';
import '../../../global/widgets/grupo_materia_card.dart';
import '../../../routes/routes.dart';

class GrupoMateriaView extends StatefulWidget {
  const GrupoMateriaView({super.key});

  @override
  State<GrupoMateriaView> createState() => _GrupoMateriaViewState();
}

class _GrupoMateriaViewState extends State<GrupoMateriaView> {
  List<OfertaGrupoMateria>? ofertasGrupoMateria;
  bool isLoading = false;
  String? error;
  String? currentMaestroDeOfertaId;

  // Estado para manejar las selecciones
  Set<String> selectedGrupoMateriaIds = {};

  // Variables para el polling
  InscripcionPollingService? _pollingService;
  String? _currentJobId;
  bool _isInscriptionInProgress = false;

  // Lista de materias seleccionadas para crear la inscripción
  List<String> get selectedMateriaIds {
    if (ofertasGrupoMateria == null) return [];
    return ofertasGrupoMateria!
        .where(
          (oferta) => selectedGrupoMateriaIds.contains(oferta.grupoMateria.id),
        )
        .map((oferta) => oferta.grupoMateria.id)
        .toList();
  }

  void _crearInscripcion(String registro) {
    if (selectedGrupoMateriaIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚠️ Selecciona al menos una materia'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Crear el modelo de inscripción temporal para generar requestId
    final tempInscripcion = Inscripcion(
      registro: registro,
      materiasId: selectedMateriaIds,
      requestId: '', // Temporal
    );

    // Generar requestId basado en el contenido
    final requestId = IdempotencyManager.generateRequestId(tempInscripcion);

    // Verificar si ya hay una inscripción en progreso
    if (IdempotencyManager.hasActiveRequest(requestId)) {
      final jobId = IdempotencyManager.getJobIdForRequest(requestId);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '⚠️ Ya hay una inscripción similar en progreso (Job ID: ${jobId?.substring(0, 8)}...)',
          ),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Crear la inscripción final con requestId
    final inscripcion = Inscripcion(
      registro: registro,
      materiasId: selectedMateriaIds,
      requestId: requestId,
    );

    // Mostrar confirmación
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('🎓 Confirmar Inscripción'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Registro: ${inscripcion.registro}'),
            const SizedBox(height: 8),
            Text('Materias seleccionadas: ${inscripcion.materiasId.length}'),
            const SizedBox(height: 8),
            const Text('⚠️ Esta inscripción se procesará de forma asíncrona'),
            const SizedBox(height: 4),
            const Text('Podrás ver el progreso en tiempo real'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await _procesarInscripcion(inscripcion);
            },
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
  }

  Future<void> _procesarInscripcion(Inscripcion inscripcion) async {
    setState(() {
      _isInscriptionInProgress = true;
    });

    final injector = Injector.of(context);
    final inscripcionRepository = injector.inscripcionRepository;

    try {
      // Enviar inscripción al backend
      final jobResponse = await inscripcionRepository.inscribirMaterias(
        inscripcion,
      );

      // Registrar la request activa
      IdempotencyManager.registerActiveRequest(
        inscripcion.requestId,
        jobResponse.jobId,
      );

      setState(() {
        _currentJobId = jobResponse.jobId;
        selectedGrupoMateriaIds.clear(); // Limpiar selecciones
      });

      // Inicializar servicio de polling
      _pollingService = InscripcionPollingService(inscripcionRepository);

      // Mostrar dialog de progreso
      _showProgressDialog(jobResponse.jobId);

      // Iniciar polling
      _pollingService!
          .startPolling(jobResponse.jobId)
          .listen(
            (jobStatus) {
              print(
                '📊 Estado del job: ${jobStatus.status} - Progreso: ${jobStatus.progress}%',
              );

              if (jobStatus.isCompleted) {
                // Completar request
                IdempotencyManager.completeRequest(inscripcion.requestId);
                _handleInscripcionCompleted(jobStatus);
              } else if (jobStatus.isFailed) {
                // Completar request (incluso si falló)
                IdempotencyManager.completeRequest(inscripcion.requestId);
                _handleInscripcionFailed(jobStatus);
              }
            },
            onError: (error) {
              print('❌ Error en polling: $error');
              IdempotencyManager.completeRequest(inscripcion.requestId);
              _handlePollingError(error);
            },
          );
    } catch (e) {
      print('❌ Error al enviar inscripción: $e');
      setState(() {
        _isInscriptionInProgress = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Error al enviar inscripción: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showProgressDialog(String jobId) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('🔄 Procesando Inscripción'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text('Job ID: ${jobId.substring(0, 8)}...'),
            const SizedBox(height: 8),
            const Text('Tu inscripción está siendo procesada'),
            const Text('Por favor espera...'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // No cancelar el polling, solo cerrar el dialog
            },
            child: const Text('Continuar en segundo plano'),
          ),
        ],
      ),
    );
  }

  void _handleInscripcionCompleted(jobStatus) {
    setState(() {
      _isInscriptionInProgress = false;
      _currentJobId = null;
    });

    // Cerrar dialog de progreso si está abierto
    Navigator.of(context).popUntil((route) => route.settings.name != null);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✅ ¡Inscripción completada exitosamente!'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 3),
      ),
    );

    // Navegar a boleta de inscripción
    Navigator.pushNamed(context, Routes.boletaInscripcion);
  }

  void _handleInscripcionFailed(jobStatus) {
    setState(() {
      _isInscriptionInProgress = false;
      _currentJobId = null;
    });

    // Cerrar dialog de progreso si está abierto
    Navigator.of(context).popUntil((route) => route.settings.name != null);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '❌ Error en la inscripción: ${jobStatus.result ?? 'Error desconocido'}',
        ),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 5),
      ),
    );
  }

  void _handlePollingError(dynamic error) {
    setState(() {
      _isInscriptionInProgress = false;
      _currentJobId = null;
    });

    // Cerrar dialog de progreso si está abierto
    Navigator.of(context).popUntil((route) => route.settings.name != null);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('❌ Error de conexión: $error'),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 5),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    // No llamamos _init aquí porque ahora depende del estado de auth
  }

  @override
  void dispose() {
    // Limpiar polling service
    _pollingService?.dispose();
    super.dispose();
  }

  Widget? _buildFloatingActionButton() {
    // Si hay una inscripción en progreso, mostrar indicador
    if (_isInscriptionInProgress) {
      return FloatingActionButton.extended(
        onPressed: null, // Deshabilitado
        icon: const SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ),
        label: Text('Procesando... ${_currentJobId?.substring(0, 6) ?? ''}'),
        backgroundColor: Colors.orange,
      );
    }

    // Si hay materias seleccionadas, mostrar botón de inscripción
    if (selectedGrupoMateriaIds.isNotEmpty) {
      return FloatingActionButton.extended(
        onPressed: () {
          final authState = context.read<AuthBloc>().state;
          if (authState is AuthAuthenticated) {
            _crearInscripcion(authState.user.matricula);
          }
        },
        icon: const Icon(Icons.add),
        label: Text('Inscribir (${selectedGrupoMateriaIds.length})'),
        backgroundColor: Colors.green,
      );
    }

    // Si no hay nada seleccionado, no mostrar botón
    return null;
  }

  Future<void> _init(String maestroDeOfertaId) async {
    try {
      setState(() {
        isLoading = true;
        error = null;
      });

      final injector = Injector.of(context);
      final ofertaGrupoMateriaRepository =
          injector.ofertaGrupoMateriaRepository;

      final getGruposMaterias = await ofertaGrupoMateriaRepository
          .getOfertasGruposMaterias(maestroDeOfertaId);

      // print('✅ getGruposMaterias: $getGruposMaterias');

      setState(() {
        ofertasGrupoMateria = getGruposMaterias;
        isLoading = false;
      });
    } catch (e) {
      print('❌ Error fetching data: $e');
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.book), label: 'Materias'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
          BottomNavigationBarItem(icon: Icon(Icons.receipt), label: 'Boleta'),
        ],
        currentIndex: 0, // Cambiar según la página actual
        onTap: (index) {
          // Manejar la navegación aquí
          if (index == 1) {
            Navigator.pushNamed(context, Routes.home);
          } else if (index == 2) {
            Navigator.pushNamed(context, Routes.boletaInscripcion);
          } else {
            // Ya estamos en Materias
            Navigator.pushNamed(context, Routes.grupoMateria);
          }
        },
      ),
      appBar: AppBar(
        title: const Text('Maestro de Oferta'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, authState) {
          if (authState is AuthAuthenticated) {
            final user = authState.user;

            // Verificar si el usuario tiene maestroDeOferta
            if (user.maestroDeOferta.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.person_off, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      'No tienes permisos de Maestro de Oferta',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  ],
                ),
              );
            }

            // Obtener el primer maestroDeOfertaId
            final maestroDeOfertaId = user.maestroDeOferta.first.id;

            // Inicializar datos si es necesario o si cambió el maestroDeOfertaId
            if (currentMaestroDeOfertaId != maestroDeOfertaId) {
              currentMaestroDeOfertaId = maestroDeOfertaId;
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _init(maestroDeOfertaId);
              });
            }

            return _buildBody(maestroDeOfertaId);
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
                    'Debes iniciar sesión para ver esta información',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            );
          }
        },
      ),

      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildBody(String maestroDeOfertaId) {
    if (isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Cargando grupos de materias...'),
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
                'Error al cargar los datos:',
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
                onPressed: () => _init(maestroDeOfertaId),
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      );
    }

    if (ofertasGrupoMateria == null || ofertasGrupoMateria!.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No se encontraron grupos de materias',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    // Lista con scroll optimizado
    return Column(
      children: [
        // Header fijo
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
          ),
          child: Text(
            'Grupos Disponibles (${ofertasGrupoMateria!.length}):',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        // Lista scrolleable
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: ofertasGrupoMateria!.length,
            itemBuilder: (context, index) {
              final oferta = ofertasGrupoMateria![index];
              final grupoMateriaId = oferta.grupoMateria.id;
              final isSelected = selectedGrupoMateriaIds.contains(
                grupoMateriaId,
              );

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: GrupoMateriaCard(
                  grupoMateria: oferta.grupoMateria,
                  isSelected: isSelected,
                  onSelectionChanged: (selected) {
                    setState(() {
                      if (selected) {
                        selectedGrupoMateriaIds.add(grupoMateriaId);
                      } else {
                        selectedGrupoMateriaIds.remove(grupoMateriaId);
                      }
                    });

                    // Debug: mostrar las materias seleccionadas
                    print('📝 Materias seleccionadas: $selectedMateriaIds');
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
