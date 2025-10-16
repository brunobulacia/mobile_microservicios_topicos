import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../main.dart';
import '../../../../data/services/idempotency_manager.dart';
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

  // Variables para refrescar cupos
  bool _isRefreshingCupos = false;

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
            onPressed: () {
              Navigator.of(context).pop();
              _navegarAProcesoInscripcion(inscripcion);
            },
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
  }

  void _navegarAProcesoInscripcion(Inscripcion inscripcion) {
    print('🧭 Navegando a inscripción iniciada...');
    print('📋 Datos de inscripción: ${inscripcion.toJson()}');

    // Limpiar selecciones
    setState(() {
      selectedGrupoMateriaIds.clear();
    });

    // Navegar a la pantalla de inscripción iniciada
    Navigator.pushNamed(
      context,
      Routes.inscripcionIniciada,
      arguments: inscripcion,
    ).then((_) {
      print('🔙 Regresó de la pantalla de inscripción iniciada');
      // Refrescar los cupos al regresar
      _refreshCupos();
    });
  }

  @override
  void initState() {
    super.initState();
    // No llamamos _init aquí porque ahora depende del estado de auth
  }

  @override
  void dispose() {
    super.dispose();
  }

  /// Refresca los cupos después de una inscripción
  Future<void> _refreshCupos() async {
    // Obtener el maestroDeOfertaId del estado de autenticación si no está disponible
    String? maestroId = currentMaestroDeOfertaId;

    if (maestroId == null) {
      final authState = context.read<AuthBloc>().state;
      if (authState is AuthAuthenticated &&
          authState.user.maestroDeOferta.isNotEmpty) {
        maestroId = authState.user.maestroDeOferta.first.id;
      }
    }

    if (maestroId == null) return;

    setState(() {
      _isRefreshingCupos = true;
    });

    try {
      print('🔄 Refrescando cupos después de inscripción...');

      final injector = Injector.of(context);
      final ofertaGrupoMateriaRepository =
          injector.ofertaGrupoMateriaRepository;

      // Hacer que el refresh sea visible por al menos 800ms
      final refreshFuture = ofertaGrupoMateriaRepository
          .getOfertasGruposMaterias(maestroId);
      final delayFuture = Future.delayed(const Duration(milliseconds: 800));

      final results = await Future.wait([refreshFuture, delayFuture]);
      final getGruposMaterias = results[0] as List<OfertaGrupoMateria>;

      setState(() {
        ofertasGrupoMateria = getGruposMaterias;
        _isRefreshingCupos = false;
      });

      print('✅ Cupos refrescados correctamente');

      // Mostrar mensaje apropiado según el resultado
      if (mounted) {
        if (getGruposMaterias.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'ℹ️ No hay materias disponibles en el maestro de oferta',
              ),
              backgroundColor: Colors.amber,
              duration: Duration(seconds: 3),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('🔄 Cupos actualizados'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      print('❌ Error al refrescar cupos: $e');
      setState(() {
        _isRefreshingCupos = false;
      });

      // Mostrar error al usuario solo para errores reales
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error al actualizar cupos: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Widget? _buildFloatingActionButton() {
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
          }
        },
      ),
      appBar: AppBar(
        title: const Text('Maestro de Oferta'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          if (_isRefreshingCupos)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            )
          else
            IconButton(
              onPressed: _refreshCupos,
              icon: const Icon(Icons.refresh),
              tooltip: 'Actualizar cupos',
            ),
        ],
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
            Icon(Icons.info_outline, size: 64, color: Colors.amber),
            SizedBox(height: 16),
            Text(
              'No hay materias disponibles',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'No se encontraron grupos de materias en el maestro de oferta actual',
              style: TextStyle(fontSize: 14, color: Colors.grey),
              textAlign: TextAlign.center,
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
