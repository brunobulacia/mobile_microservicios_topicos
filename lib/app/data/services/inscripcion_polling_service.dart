import 'dart:async';
import 'dart:math';

import '../../domain/models/job_status.dart';
import '../../domain/repositories/inscripcion_repository.dart';

class InscripcionPollingService {
  InscripcionPollingService(this._inscripcionRepository);

  final InscripcionRepository _inscripcionRepository;
  final Map<String, Timer> _activePolls = {};
  final Map<String, StreamController<JobStatus>> _statusStreams = {};

  /// Inicia el polling para un jobId específico
  Stream<JobStatus> startPolling(
    String jobId, {
    Duration interval = const Duration(seconds: 2),
  }) {
    // Si ya existe un stream para este jobId, retornamos el existente
    if (_statusStreams.containsKey(jobId)) {
      return _statusStreams[jobId]!.stream;
    }

    // Crear un nuevo stream controller
    final controller = StreamController<JobStatus>.broadcast();
    _statusStreams[jobId] = controller;

    // Iniciar el polling
    _startPollingTimer(jobId, interval, controller);

    return controller.stream;
  }

  void _startPollingTimer(
    String jobId,
    Duration interval,
    StreamController<JobStatus> controller,
  ) {
    // Cancelar timer existente si existe
    _activePolls[jobId]?.cancel();

    // Crear nuevo timer
    _activePolls[jobId] = Timer.periodic(interval, (timer) async {
      try {
        final status = await _inscripcionRepository.consultarEstadoInscripcion(
          jobId,
        );

        // Emitir el estado actual
        if (!controller.isClosed) {
          controller.add(status);
        }

        // Si el job está completado o falló, detener el polling
        if (status.isCompleted || status.isFailed) {
          stopPolling(jobId);
        }
      } catch (e) {
        // En caso de error, emitir un estado de error
        if (!controller.isClosed) {
          controller.addError(e);
        }

        // Opcional: implementar retry con backoff exponencial
        _implementRetryWithBackoff(jobId, interval, controller, e);
      }
    });
  }

  void _implementRetryWithBackoff(
    String jobId,
    Duration originalInterval,
    StreamController<JobStatus> controller,
    dynamic error,
  ) {
    // Detener el timer actual
    _activePolls[jobId]?.cancel();

    // Calcular nuevo intervalo con backoff exponencial (máximo 30 segundos)
    final newInterval = Duration(
      milliseconds: min(originalInterval.inMilliseconds * 2, 30000),
    );

    // Reintentar después de un delay
    Timer(const Duration(seconds: 5), () {
      if (_statusStreams.containsKey(jobId) && !controller.isClosed) {
        _startPollingTimer(jobId, newInterval, controller);
      }
    });
  }

  /// Detiene el polling para un jobId específico
  void stopPolling(String jobId) {
    _activePolls[jobId]?.cancel();
    _activePolls.remove(jobId);

    _statusStreams[jobId]?.close();
    _statusStreams.remove(jobId);
  }

  /// Detiene todos los pollings activos
  void stopAllPolling() {
    for (final timer in _activePolls.values) {
      timer.cancel();
    }
    _activePolls.clear();

    for (final controller in _statusStreams.values) {
      controller.close();
    }
    _statusStreams.clear();
  }

  /// Verifica si hay polling activo para un jobId
  bool isPollingActive(String jobId) {
    return _activePolls.containsKey(jobId) && _statusStreams.containsKey(jobId);
  }

  /// Obtiene todos los jobIds que están siendo monitoreados
  List<String> getActiveJobIds() {
    return _activePolls.keys.toList();
  }

  /// Limpia recursos al destruir el servicio
  void dispose() {
    stopAllPolling();
  }
}
