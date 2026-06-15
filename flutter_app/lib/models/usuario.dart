class Usuario {
  Usuario({required this.id, required this.nombre, required this.username, required this.rol});

  final int id;
  final String nombre;
  final String username;
  final String rol;

  bool get esAdmin => rol == 'admin';

  factory Usuario.fromJson(Map<String, dynamic> json) => Usuario(
        id: json['id'] as int,
        nombre: json['nombre'] as String,
        username: json['username'] as String,
        rol: json['rol'] as String,
      );
}
