class Empresa {
  Empresa({required this.id, required this.nombre, required this.nit});

  final int id;
  final String nombre;
  final String nit;

  factory Empresa.fromJson(Map<String, dynamic> json) => Empresa(
        id: json['id'] as int,
        nombre: json['nombre'] as String,
        nit: json['nit'] as String,
      );
}
