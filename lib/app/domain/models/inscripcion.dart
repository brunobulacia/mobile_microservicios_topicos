class Inscripcion {
  Inscripcion({required this.registro, required this.ofertaId});

  factory Inscripcion.fromJson(Map<String, dynamic> json) {
    return Inscripcion(
      registro: json['registro'] as String,
      ofertaId: List<String>.from(json['ofertaId'] as List),
    );
  }
  final String registro;
  final List<String> ofertaId;

  Map<String, dynamic> toJson() {
    return {'registro': registro, 'ofertaId': ofertaId};
  }
}
