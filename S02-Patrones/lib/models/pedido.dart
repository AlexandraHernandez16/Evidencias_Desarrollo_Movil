class Pedido {
  Pedido({required this.id, required this.estado, required this.total});

  final int id;
  final String estado;
  final double total;

  factory Pedido.desdeJson(Map<String, dynamic> json) => Pedido(
        id: json['id'] as int,
        estado: json['estado'] as String,
        total: (json['total'] as num).toDouble(),
      );
}
