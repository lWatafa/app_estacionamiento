class Usuario {
  final String? id;
  final String nombre;
  final String identificador;
  final String password;
  final String rol;
  final String? placas;
  final String? licencia;
  final String? tarjetaCirculacion;
  final String? motivo;

  Usuario({
    this.id,
    required this.nombre,
    required this.identificador,
    required this.password,
    required this.rol,
    this.placas,
    this.licencia,
    this.tarjetaCirculacion,
    this.motivo,
  });

  factory Usuario.fromMap(Map<String, dynamic> map) {
    return Usuario(
      id: map['id'],
      nombre: map['nombre'],
      identificador: map['identificador'],
      password: map['password'],
      rol: map['rol'],
      placas: map['placas'],
      licencia: map['licencia'],
      tarjetaCirculacion: map['tarjeta_circulacion'],
      motivo: map['motivo'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nombre': nombre,
      'identificador': identificador,
      'password': password,
      'rol': rol,
      'placas': placas,
      'licencia': licencia,
      'tarjeta_circulacion': tarjetaCirculacion,
      'motivo': motivo,
    };
  }
}
