class BoletaInscripcion {
  BoletaInscripcion({
    required this.id,
    required this.boletaInscripcionId,
    required this.grupoMateriaId,
    required this.nota,
    required this.grupoMateria,
  });

  factory BoletaInscripcion.fromMap(Map<String, dynamic> map) {
    return BoletaInscripcion(
      id: map['id'] ?? '',
      boletaInscripcionId: map['boletaInscripcionId'] ?? '',
      grupoMateriaId: map['grupoMateriaId'] ?? '',
      nota: map['nota'] ?? 0,
      grupoMateria: GrupoMateria.fromMap(map['grupoMateria'] ?? {}),
    );
  }

  final String id;
  final String boletaInscripcionId;
  final String grupoMateriaId;
  final int nota;
  final GrupoMateria grupoMateria;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'boletaInscripcionId': boletaInscripcionId,
      'grupoMateriaId': grupoMateriaId,
      'nota': nota,
      'grupoMateria': grupoMateria.toMap(),
    };
  }
}

class GrupoMateria {
  GrupoMateria({required this.grupo, required this.materia});

  factory GrupoMateria.fromMap(Map<String, dynamic> map) {
    return GrupoMateria(
      grupo: map['grupo'] ?? '',
      materia: Materia.fromMap(map['materia'] ?? {}),
    );
  }
  final String grupo;
  final Materia materia;

  Map<String, dynamic> toMap() {
    return {'grupo': grupo, 'materia': materia.toMap()};
  }
}

class Materia {
  Materia({
    required this.nombre,
    required this.creditos,
    required this.sigla,
    required this.nivel,
  });

  factory Materia.fromMap(Map<String, dynamic> map) {
    return Materia(
      nombre: map['nombre'] ?? '',
      creditos: map['creditos'] ?? 0,
      sigla: map['sigla'] ?? '',
      nivel: Nivel.fromMap(map['nivel'] ?? {}),
    );
  }
  final String nombre;
  final int creditos;
  final String sigla;
  final Nivel nivel;

  Map<String, dynamic> toMap() {
    return {
      'nombre': nombre,
      'creditos': creditos,
      'sigla': sigla,
      'nivel': nivel.toMap(),
    };
  }
}

class Nivel {
  Nivel({required this.semestre});
  factory Nivel.fromMap(Map<String, dynamic> map) {
    return Nivel(semestre: map['semestre'] ?? 0);
  }
  final int semestre;
  Map<String, dynamic> toMap() {
    return {'semestre': semestre};
  }
}
