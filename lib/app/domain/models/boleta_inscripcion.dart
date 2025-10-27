class BoletaInscripcion {
  BoletaInscripcion({
    required this.id,
    required this.grupo,
    required this.inscritos,
    required this.cupos,
    required this.materiaId,
    required this.docenteId,
    required this.periodoId,
    required this.isActive,
    required this.updatedAt,
    required this.createdAt,
    required this.aulaGrupoMateria,
    required this.docente,
    required this.materia,
  });

  factory BoletaInscripcion.fromJson(Map<String, dynamic> json) {
    return BoletaInscripcion(
      id: json['id'],
      grupo: json['grupo'],
      inscritos: json['inscritos'],
      cupos: json['cupos'],
      materiaId: json['materiaId'],
      docenteId: json['docenteId'],
      periodoId: json['periodoId'],
      isActive: json['isActive'],
      updatedAt: DateTime.parse(json['updatedAt']),
      createdAt: DateTime.parse(json['createdAt']),
      aulaGrupoMateria: (json['AulaGrupoMateria'] as List)
          .map((e) => AulaGrupoMateria.fromJson(e))
          .toList(),
      docente: Docente.fromJson(json['Docente']),
      materia: Materia.fromJson(json['materia']),
    );
  }
  final String id;
  final String grupo;
  final int inscritos;
  final int cupos;
  final String materiaId;
  final String docenteId;
  final String periodoId;
  final bool isActive;
  final DateTime updatedAt;
  final DateTime createdAt;
  final List<AulaGrupoMateria> aulaGrupoMateria;
  final Docente docente;
  final Materia materia;
  @override
  String toString() {
    return '{\n'
        '  "id": "$id",\n'
        '  "grupo": "$grupo",\n'
        '  "inscritos": $inscritos,\n'
        '  "cupos": $cupos,\n'
        '  "materiaId": "$materiaId",\n'
        '  "docenteId": "$docenteId",\n'
        '  "periodoId": "$periodoId",\n'
        '  "isActive": $isActive,\n'
        '  "updatedAt": "${updatedAt.toIso8601String()}",\n'
        '  "createdAt": "${createdAt.toIso8601String()}",\n'
        '  "aulaGrupoMateria": ${aulaGrupoMateria.map((e) => e.toString()).toList()},\n'
        '  "docente": ${docente.toString()},\n'
        '  "materia": ${materia.toString()}\n'
        '}';
  }
}

class AulaGrupoMateria {
  AulaGrupoMateria({
    required this.id,
    required this.grupoMateriaId,
    required this.aulaId,
    required this.isActive,
    required this.updatedAt,
    required this.createdAt,
    required this.aula,
    required this.horario,
  });

  factory AulaGrupoMateria.fromJson(Map<String, dynamic> json) {
    return AulaGrupoMateria(
      id: json['id'],
      grupoMateriaId: json['grupoMateriaId'],
      aulaId: json['aulaId'],
      isActive: json['isActive'],
      updatedAt: DateTime.parse(json['updatedAt']),
      createdAt: DateTime.parse(json['createdAt']),
      aula: Aula.fromJson(json['aula']),
      horario: (json['horario'] as List)
          .map((e) => Horario.fromJson(e))
          .toList(),
    );
  }
  final String id;
  final String grupoMateriaId;
  final String aulaId;
  final bool isActive;
  final DateTime updatedAt;
  final DateTime createdAt;
  final Aula aula;
  final List<Horario> horario;
  @override
  String toString() {
    return '{\n'
        '    "id": "$id",\n'
        '    "grupoMateriaId": "$grupoMateriaId",\n'
        '    "aulaId": "$aulaId",\n'
        '    "isActive": $isActive,\n'
        '    "updatedAt": "${updatedAt.toIso8601String()}",\n'
        '    "createdAt": "${createdAt.toIso8601String()}",\n'
        '    "aula": ${aula.toString()},\n'
        '    "horario": ${horario.map((e) => e.toString()).toList()}\n'
        '  }';
  }
}

class Aula {
  Aula({required this.numero});

  factory Aula.fromJson(Map<String, dynamic> json) {
    return Aula(numero: json['numero']);
  }
  final int numero;
  @override
  String toString() {
    return '{"numero": $numero}';
  }
}

class Horario {
  Horario({
    required this.diaSemana,
    required this.horaInicio,
    required this.horaFin,
  });

  factory Horario.fromJson(Map<String, dynamic> json) {
    return Horario(
      diaSemana: json['diaSemana'],
      horaInicio: json['horaInicio'],
      horaFin: json['horaFin'],
    );
  }
  final String diaSemana;
  final String horaInicio;
  final String horaFin;
  @override
  String toString() {
    return '{"diaSemana": "$diaSemana", "horaInicio": "$horaInicio", "horaFin": "$horaFin"}';
  }
}

class Docente {
  Docente({
    required this.nombre,
    required this.apellidoPaterno,
    required this.apellidoMaterno,
  });

  factory Docente.fromJson(Map<String, dynamic> json) {
    return Docente(
      nombre: json['nombre'],
      apellidoPaterno: json['apellido_paterno'],
      apellidoMaterno: json['apellido_materno'],
    );
  }
  final String nombre;
  final String apellidoPaterno;
  final String apellidoMaterno;
  @override
  String toString() {
    return '{"nombre": "$nombre", "apellidoPaterno": "$apellidoPaterno", "apellidoMaterno": "$apellidoMaterno"}';
  }
}

class Materia {
  Materia({
    required this.id,
    required this.sigla,
    required this.nombre,
    required this.creditos,
    required this.esElectiva,
    required this.isActive,
    required this.nivelId,
    required this.planDeEstudioId,
    required this.updatedAt,
    required this.createdAt,
    required this.nivel,
  });

  factory Materia.fromJson(Map<String, dynamic> json) {
    return Materia(
      id: json['id'],
      sigla: json['sigla'],
      nombre: json['nombre'],
      creditos: json['creditos'],
      esElectiva: json['esElectiva'],
      isActive: json['isActive'],
      nivelId: json['nivelId'],
      planDeEstudioId: json['planDeEstudioId'],
      updatedAt: DateTime.parse(json['updatedAt']),
      createdAt: DateTime.parse(json['createdAt']),
      nivel: Nivel.fromJson(json['nivel']),
    );
  }
  final String id;
  final String sigla;
  final String nombre;
  final int creditos;
  final bool esElectiva;
  final bool isActive;
  final String nivelId;
  final String planDeEstudioId;
  final DateTime updatedAt;
  final DateTime createdAt;
  final Nivel nivel;
  @override
  String toString() {
    return '{\n'
        '    "id": "$id",\n'
        '    "sigla": "$sigla",\n'
        '    "nombre": "$nombre",\n'
        '    "creditos": $creditos,\n'
        '    "esElectiva": $esElectiva,\n'
        '    "isActive": $isActive,\n'
        '    "nivelId": "$nivelId",\n'
        '    "planDeEstudioId": "$planDeEstudioId",\n'
        '    "updatedAt": "${updatedAt.toIso8601String()}",\n'
        '    "createdAt": "${createdAt.toIso8601String()}",\n'
        '    "nivel": ${nivel.toString()}\n'
        '  }';
  }
}

class Nivel {
  Nivel({required this.semestre});

  factory Nivel.fromJson(Map<String, dynamic> json) {
    return Nivel(semestre: json['semestre']);
  }
  final int semestre;
  @override
  String toString() {
    return '{"semestre": $semestre}';
  }
}
