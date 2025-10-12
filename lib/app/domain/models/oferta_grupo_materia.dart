class OfertaGrupoMateria {
  OfertaGrupoMateria({
    required this.id,
    required this.grupoMateriaId,
    required this.maestroDeOfertaId,
    required this.grupoMateria,
  });

  factory OfertaGrupoMateria.fromJson(Map<String, dynamic> json) {
    return OfertaGrupoMateria(
      id: json['id'],
      grupoMateriaId: json['grupoMateriaId'],
      maestroDeOfertaId: json['maestroDeOfertaId'],
      grupoMateria: GrupoMateria.fromJson(json['GrupoMateria']),
    );
  }

  final String id;
  final String grupoMateriaId;
  final String maestroDeOfertaId;
  final GrupoMateria grupoMateria;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'grupoMateriaId': grupoMateriaId,
      'maestroDeOfertaId': maestroDeOfertaId,
      'GrupoMateria': grupoMateria.toJson(),
    };
  }

  @override
  String toString() {
    return 'OfertaGrupoMateria(id: $id, grupoMateriaId: $grupoMateriaId, maestroDeOfertaId: $maestroDeOfertaId, grupoMateria: $grupoMateria)';
  }
}

class GrupoMateria {
  GrupoMateria({
    required this.id,
    required this.grupo,
    required this.cupos,
    required this.materia,
    required this.docente,
  });

  factory GrupoMateria.fromJson(Map<String, dynamic> json) {
    return GrupoMateria(
      id: json['id'],
      grupo: json['grupo'],
      cupos: json['cupos'],
      materia: Materia.fromJson(json['materia']),
      docente: Docente.fromJson(json['docente']),
    );
  }

  final String id;
  final String grupo;
  final int cupos;
  final Materia materia;
  final Docente docente;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'grupo': grupo,
      'cupos': cupos,
      'materia': materia.toJson(),
      'docente': docente.toJson(),
    };
  }

  @override
  String toString() {
    return 'GrupoMateria(id: $id, grupo: $grupo, cupos: $cupos, materia: $materia, docente: $docente)';
  }
}

class Materia {
  Materia({required this.nombre});

  factory Materia.fromJson(Map<String, dynamic> json) {
    return Materia(nombre: json['nombre']);
  }

  final String nombre;

  Map<String, dynamic> toJson() {
    return {'nombre': nombre};
  }

  @override
  String toString() {
    return 'Materia(nombre: $nombre)';
  }
}

class Docente {
  Docente({required this.nombre, required this.apellidoPaterno});

  factory Docente.fromJson(Map<String, dynamic> json) {
    return Docente(
      nombre: json['nombre'],
      apellidoPaterno: json['apellido_paterno'],
    );
  }

  final String nombre;
  final String apellidoPaterno;

  Map<String, dynamic> toJson() {
    return {'nombre': nombre, 'apellido_paterno': apellidoPaterno};
  }

  @override
  String toString() {
    return 'Docente(nombre: $nombre, apellidoPaterno: $apellidoPaterno)';
  }
}
