class User {
  User({
    required this.id,
    required this.nombre,
    required this.apellidoPaterno,
    required this.apellidoMaterno,
    required this.telefono,
    required this.ci,
    required this.email,
    required this.matricula,
    required this.ppac,
    required this.maestroDeOferta,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      nombre: json['nombre'] ?? '',
      apellidoPaterno: json['apellido_paterno'] ?? '',
      apellidoMaterno: json['apellido_materno'] ?? '',
      telefono: json['telefono'] ?? '',
      ci: json['ci'] ?? '',
      email: json['email'] ?? '',
      matricula: json['matricula'] ?? '',
      ppac: json['ppac'] ?? 0,
      maestroDeOferta: (json['MaestroDeOferta'] as List? ?? [])
          .map((e) => MaestroDeOferta.fromJson(e))
          .toList(),
    );
  }
  final String id;
  final String nombre;
  final String apellidoPaterno;
  final String apellidoMaterno;
  final String telefono;
  final String ci;
  final String email;
  final String matricula;
  final int ppac;
  final List<MaestroDeOferta> maestroDeOferta;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'apellido_paterno': apellidoPaterno,
      'apellido_materno': apellidoMaterno,
      'telefono': telefono,
      'ci': ci,
      'email': email,
      'matricula': matricula,
      'ppac': ppac,
      'MaestroDeOferta': maestroDeOferta.map((e) => e.toJson()).toList(),
    };
  }
}

class MaestroDeOferta {
  MaestroDeOferta({required this.id});

  factory MaestroDeOferta.fromJson(Map<String, dynamic> json) {
    return MaestroDeOferta(id: json['id'] ?? '');
  }
  final String id;

  Map<String, dynamic> toJson() {
    return {'id': id};
  }
}
