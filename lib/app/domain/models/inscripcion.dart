class Inscripcion {
  Inscripcion({required this.registro, required this.materiaId});

  factory Inscripcion.fromJson(Map<String, dynamic> json) {
    return Inscripcion(
      registro: json['registro'] as String,
      materiaId: List<String>.from(json['materiaId'] as List),
    );
  }
  final String registro;
  final List<String> materiaId;

  Map<String, dynamic> toJson() {
    return {'registro': registro, 'materiaId': materiaId};
  }
}
