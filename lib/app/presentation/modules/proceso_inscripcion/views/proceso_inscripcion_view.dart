import 'package:flutter/material.dart';

import '../../../../../main.dart';
import '../../../../data/services/inscripcion_polling_service.dart';
import '../../../../domain/models/job_status.dart';
import '../../../routes/routes.dart';

class ProcesoInscripcion extends StatefulWidget {
  const ProcesoInscripcion({super.key, required this.jobId});
  final String jobId;

  @override
  _ProcesoInscripcionState createState() => _ProcesoInscripcionState();
}

class _ProcesoInscripcionState extends State<ProcesoInscripcion> {
  InscripcionPollingService? _pollingService;
  JobStatus? _jobStatus;
  String _statusMessage = 'Iniciando inscripción...';
  bool _isInProgress = true;
  bool _hasError = false;
  String? _errorMessage;
  double _progress = 0.0;

  @override
  void initState() {
    super.initState();
    print('ProcesoInscripcion initState iniciado');
    print('Job ID recibido: ${widget.jobId}');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _iniciarPolling();
    });
  }

  @override
  void dispose() {
    _pollingService?.stopAllPolling();
    super.dispose();
  }

  void _iniciarPolling() {
    final injector = Injector.of(context);
    final inscripcionRepository = injector.inscripcionRepository;
    _pollingService = InscripcionPollingService(inscripcionRepository);
    setState(() {
      _statusMessage = 'Consultando estado de inscripción...';
      _progress = 0.1;
    });
    _pollingService!
        .startPolling(widget.jobId)
        .listen(
          (jobStatus) {
            print(
              'Estado del job: ${jobStatus.status} - Progress: ${jobStatus.progress}',
            );
            setState(() {
              _jobStatus = jobStatus;
              _statusMessage = _getStatusMessage(jobStatus.status);
              _progress = _calculateProgress(jobStatus.status);
            });
            if (jobStatus.status == Status.completed) {
              _handleInscripcionCompleted(jobStatus);
            } else if (jobStatus.status == Status.failed) {
              _handleInscripcionFailed(jobStatus);
            }
          },
          onError: (error) {
            print('Error en polling: $error');
            _handlePollingError(error);
          },
        );
  }

  double _calculateProgress(Status status) {
    switch (status) {
      case Status.waiting:
      case Status.active:
      case Status.delayed:
        return 0.3;
      case Status.paused:
        return 0.5;
      case Status.completed:
        return 1.0;
      case Status.failed:
        return 0.0;
    }
  }

  String _getStatusMessage(Status status) {
    switch (status) {
      case Status.waiting:
        return 'Esperando turno de procesamiento...';
      case Status.active:
        return 'Procesando inscripción...';
      case Status.delayed:
        return 'Inscripción en espera (delayed)...';
      case Status.paused:
        return 'Inscripción pausada.';
      case Status.completed:
        return 'Inscripción completada exitosamente';
      case Status.failed:
        return 'Error en el procesamiento';
    }
  }

  void _handleInscripcionCompleted(JobStatus jobStatus) {
    setState(() {
      _isInProgress = false;
      _statusMessage = 'Inscripción completada exitosamente';
      _progress = 1.0;
    });

    // Mostrar mensaje de éxito por un momento antes de navegar
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.of(context).pushReplacementNamed(Routes.boletaInscripcion);
      }
    });
  }

  void _handleInscripcionFailed(JobStatus jobStatus) {
    setState(() {
      _isInProgress = false;
      _hasError = true;
      _errorMessage = 'Error en la inscripción';
      _statusMessage = 'Error en la inscripción';
      _progress = 0.0;
    });
  }

  void _handlePollingError(dynamic error) {
    print('Manejando error de polling: $error');
    setState(() {
      _isInProgress = false;
      _hasError = true;
      _errorMessage = error.toString();
      _statusMessage = 'Error de conexión';
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
      'Building ProcesoInscripcion widget - Status: $_statusMessage, Progress: $_progress, HasError: $_hasError',
    );

    return WillPopScope(
      onWillPop: () async {
        // Prevenir que el usuario regrese mientras está en progreso
        if (_isInProgress) {
          final shouldPop = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Inscripción en progreso'),
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
              if (_jobStatus != null) ...[
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
                        _buildDetailRow('Registro:', _jobStatus!.data.registro),
                        const SizedBox(height: 8),
                        _buildDetailRow(
                          'Ofertas:',
                          _jobStatus!.data.ofertaId.join(', '),
                        ),
                        const SizedBox(height: 8),
                        _buildDetailRow('Estado:', _statusMessage),
                        const SizedBox(height: 8),
                        _buildDetailRow(
                          'Progreso:',
                          '${_jobStatus!.progress}%',
                        ),
                      ],
                    ),
                  ),
                ),
              ],

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
                        _iniciarPolling();
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
