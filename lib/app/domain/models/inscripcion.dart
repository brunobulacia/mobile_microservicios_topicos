class Inscripcion {
  Inscripcion({required this.registro, required this.materiasId});

  factory Inscripcion.fromJson(Map<String, dynamic> json) {
    return Inscripcion(
      registro: json['registro'] as String,
      materiasId: List<String>.from(json['materiasId'] as List),
    );
  }
  final String registro;
  final List<String> materiasId;

  Map<String, dynamic> toJson() {
    return {'registro': registro, 'materiasId': materiasId};
  }
}
