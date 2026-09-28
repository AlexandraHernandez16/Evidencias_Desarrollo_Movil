class Planta {
  Planta({required this.id, required this.nombre, required this.precio});

  final int id;
  final String nombre;
  final double precio;

  factory Planta.desdeJson(Map<String, dynamic> json) => Planta(
        id: json['id'] as int,
        nombre: json['nombre'] as String,
        precio: (json['precio'] as num).toDouble(),
      );
}
