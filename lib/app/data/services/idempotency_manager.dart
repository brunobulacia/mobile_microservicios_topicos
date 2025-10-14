import 'dart:convert';

import 'package:crypto/crypto.dart';

import '../../domain/models/inscripcion.dart';

class IdempotencyManager {
  // Mapa para almacenar los requestIds activos y sus jobIds
  static final Map<String, String> _activeRequests = {};

  /// Genera un requestId único basado en el contenido de la inscripción
  static String generateRequestId(Inscripcion inscripcion) {
    // Crear un hash del contenido para asegurar idempotencia
    final content =
        '${inscripcion.registro}_${inscripcion.materiasId.join(',')}';
    final bytes = utf8.encode(content);
    final digest = sha256.convert(bytes);
    return digest.toString().substring(
      0,
      16,
    ); // Tomar los primeros 16 caracteres
  }

  /// Verifica si ya existe una request activa para esta inscripción
  static bool hasActiveRequest(String requestId) {
    return _activeRequests.containsKey(requestId);
  }

  /// Obtiene el jobId asociado a un requestId
  static String? getJobIdForRequest(String requestId) {
    return _activeRequests[requestId];
  }

  /// Registra una nueva request activa
  static void registerActiveRequest(String requestId, String jobId) {
    _activeRequests[requestId] = jobId;
  }

  /// Marca una request como completada y la remueve
  static void completeRequest(String requestId) {
    _activeRequests.remove(requestId);
  }

  /// Obtiene todas las requests activas
  static Map<String, String> getActiveRequests() {
    return Map.from(_activeRequests);
  }

  /// Limpia todas las requests activas (usar con cuidado)
  static void clearAllRequests() {
    _activeRequests.clear();
  }

  /// Verifica si una inscripción específica ya está en progreso
  static bool isInscripcionInProgress(Inscripcion inscripcion) {
    final requestId = generateRequestId(inscripcion);
    return hasActiveRequest(requestId);
  }

  /// Obtiene el jobId de una inscripción si está en progreso
  static String? getJobIdForInscripcion(Inscripcion inscripcion) {
    final requestId = generateRequestId(inscripcion);
    return getJobIdForRequest(requestId);
  }
}
