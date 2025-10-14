class Inscripcion {
  Inscripcion({
    required this.registro,
    required this.materiasId,
    required this.requestId,
  });

  factory Inscripcion.fromJson(Map<String, dynamic> json) {
    return Inscripcion(
      registro: json['registro'] as String,
      materiasId: List<String>.from(json['materiasId'] as List),
      requestId: json['requestId'] as String,
    );
  }

  final String registro;
  final List<String> materiasId;
  final String requestId;

  Map<String, dynamic> toJson() {
    return {
      'registro': registro,
      'materiasId': materiasId,
      'requestId': requestId,
    };
  }
}
