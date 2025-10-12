import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../main.dart';
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

  @override
  void initState() {
    super.initState();
    // No llamamos _init aquí porque ahora depende del estado de auth
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

      print('✅ getGruposMaterias: $getGruposMaterias');

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
        ],
        currentIndex: 0, // Cambiar según la página actual
        onTap: (index) {
          // Manejar la navegación aquí
          if (index == 1) {
            Navigator.pushNamed(context, Routes.home);
          } else {
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
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: GrupoMateriaCard(grupoMateria: oferta.grupoMateria),
              );
            },
          ),
        ),
      ],
    );
  }
}
