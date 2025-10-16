import 'package:flutter/material.dart';

import '../../../../../main.dart';
import '../../../../data/services/idempotency_manager.dart';
import '../../../../data/services/inscripcion_polling_service.dart';
import '../../../../domain/models/inscripcion.dart';
import '../../../routes/routes.dart';

class ProcesoInscripcion extends StatefulWidget {
  const ProcesoInscripcion({super.key, required this.inscripcion});
  final Inscripcion inscripcion;

  @override
  State<ProcesoInscripcion> createState() => _ProcesoInscripcionState();
}

class _ProcesoInscripcionState extends State<ProcesoInscripcion> {
  InscripcionPollingService? _pollingService;
  String? _currentJobId;
  String _statusMessage = 'Iniciando inscripción...';
  bool _isInProgress = true;
  bool _hasError = false;
  String? _errorMessage;
  double _progress = 0.0;

  @override
  void initState() {
    super.initState();
    print('🏗️ ProcesoInscripcion initState iniciado');
    print('📋 Inscripción recibida: ${widget.inscripcion.toJson()}');

    // Ejecutar el procesamiento en el siguiente frame para asegurar que el widget esté construido
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _procesarInscripcion();
    });
  }

  @override
  void dispose() {
    _pollingService?.dispose();
    super.dispose();
  }

  Future<void> _procesarInscripcion() async {
    print('🚀 Iniciando proceso de inscripción...');
    print('📋 Inscripción: ${widget.inscripcion.toJson()}');

    try {
      final injector = Injector.of(context);
      final inscripcionRepository = injector.inscripcionRepository;

      print('✅ Injector y repository obtenidos correctamente');

      setState(() {
        _statusMessage = 'Enviando solicitud de inscripción...';
        _progress = 0.1;
      });

      print('📤 Enviando inscripción al backend...');

      // Enviar inscripción al backend
      final jobResponse = await inscripcionRepository.inscribirMaterias(
        widget.inscripcion,
      );

      print('✅ Job response recibido: ${jobResponse.jobId}');

      // Registrar la request activa
      IdempotencyManager.registerActiveRequest(
        widget.inscripcion.requestId,
        jobResponse.jobId,
      );

      setState(() {
        _currentJobId = jobResponse.jobId;
        _statusMessage = 'Procesando inscripción...';
        _progress = 0.3;
      });

      print('🔄 Iniciando servicio de polling para job: ${jobResponse.jobId}');

      // Inicializar servicio de polling
      _pollingService = InscripcionPollingService(inscripcionRepository);

      // Iniciar polling
      _pollingService!
          .startPolling(jobResponse.jobId)
          .listen(
            (jobStatus) {
              print(
                '📊 Estado del job: ${jobStatus.status} - Progress: ${jobStatus.progress}',
              );

              setState(() {
                _statusMessage = _getStatusMessage(jobStatus.status);
                _progress = _calculateProgress(jobStatus.status);
              });

              if (jobStatus.isCompleted) {
                print('✅ Job completado exitosamente');
                _handleInscripcionCompleted(jobStatus);
              } else if (jobStatus.isFailed) {
                print('❌ Job falló: ${jobStatus.error}');
                _handleInscripcionFailed(jobStatus);
              }
            },
            onError: (error) {
              print('❌ Error en polling: $error');
              IdempotencyManager.completeRequest(widget.inscripcion.requestId);
              _handlePollingError(error);
            },
          );
    } catch (e, stackTrace) {
      print('❌ Error al enviar inscripción: $e');
      print('📍 Stack trace: $stackTrace');
      _handlePollingError(e);
    }
  }

  double _calculateProgress(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
      case 'iniciado':
        return 0.3;
      case 'processing':
      case 'procesando':
        return 0.6;
      case 'completed':
      case 'completado':
        return 1.0;
      case 'failed':
      case 'fallido':
        return 0.0;
      default:
        return 0.5;
    }
  }

  String _getStatusMessage(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Inscripción en cola de procesamiento...';
      case 'waiting':
        return 'Esperando turno de procesamiento...';
      case 'processing':
        return 'Procesando inscripción...';
      case 'completed':
        return '✅ ¡Inscripción completada exitosamente!';
      case 'failed':
        return '❌ Error en el procesamiento';
      default:
        return 'Procesando...';
    }
  }

  void _handleInscripcionCompleted(jobStatus) {
    setState(() {
      _isInProgress = false;
      _statusMessage = '✅ ¡Inscripción completada exitosamente!';
      _progress = 1.0;
    });

    // Mostrar mensaje de éxito por un momento antes de navegar
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.of(context).pushReplacementNamed(Routes.boletaInscripcion);
      }
    });
  }

  void _handleInscripcionFailed(jobStatus) {
    setState(() {
      _isInProgress = false;
      _hasError = true;
      _errorMessage = jobStatus.error ?? 'Error desconocido';
      _statusMessage = '❌ Error en la inscripción';
      _progress = 0.0;
    });
  }

  void _handlePollingError(dynamic error) {
    print('🔥 Manejando error de polling: $error');
    setState(() {
      _isInProgress = false;
      _hasError = true;
      _errorMessage = error.toString();
      _statusMessage = '❌ Error de conexión';
      _progress = 0.0;
    });

    // Mostrar snackbar con el error
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${error.toString()}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    print(
      '🎨 Building ProcesoInscripcion widget - Status: $_statusMessage, Progress: $_progress, HasError: $_hasError',
    );

    return WillPopScope(
      onWillPop: () async {
        // Prevenir que el usuario regrese mientras está en progreso
        if (_isInProgress) {
          final shouldPop = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('⚠️ Inscripción en progreso'),
              content: const Text(
                'Tu inscripción está siendo procesada. ¿Estás seguro de que quieres salir?',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Continuar esperando'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Salir'),
                ),
              ],
            ),
          );
          return shouldPop ?? false;
        }
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Proceso de Inscripción'),
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          automaticallyImplyLeading: !_isInProgress,
        ),
        body: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icono principal
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _hasError
                      ? Colors.red.withOpacity(0.1)
                      : _isInProgress
                      ? Colors.blue.withOpacity(0.1)
                      : Colors.green.withOpacity(0.1),
                ),
                child: Icon(
                  _hasError
                      ? Icons.error_outline
                      : _isInProgress
                      ? Icons.hourglass_top
                      : Icons.check_circle_outline,
                  size: 50,
                  color: _hasError
                      ? Colors.red
                      : _isInProgress
                      ? Colors.blue
                      : Colors.green,
                ),
              ),

              const SizedBox(height: 32),

              // Job ID
              /* if (_currentJobId != null) ...[
                Text(
                  'Job ID: ${_currentJobId!.substring(0, 8)}...',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontFamily: 'monospace',
                  ),
                ),
                const SizedBox(height: 16),
              ], */

              // Mensaje de estado
              Text(
                _statusMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 24),

              // Información de la inscripción
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Detalles de Inscripción',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildDetailRow('Registro:', widget.inscripcion.registro),
                      const SizedBox(height: 8),
                      _buildDetailRow(
                        'Materias:',
                        '${widget.inscripcion.materiasId.length} seleccionadas',
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Barra de progreso
              if (_isInProgress) ...[
                LinearProgressIndicator(
                  value: _progress,
                  backgroundColor: Colors.grey[300],
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
                ),
                const SizedBox(height: 16),
                Text(
                  '${(_progress * 100).toInt()}%',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],

              // Mensaje de error
              if (_hasError && _errorMessage != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: Colors.red),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // Botones de acción
              if (_hasError) ...[
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          _hasError = false;
                          _isInProgress = true;
                          _errorMessage = null;
                          _statusMessage = 'Reintentando...';
                          _progress = 0.0;
                        });
                        _procesarInscripcion();
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Reintentar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('Volver'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }
}
