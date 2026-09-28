import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/pedido.dart';
import '../models/planta.dart';

class VentaApiService {
  VentaApiService(this.base);

  final String base;

  // Algoritmo común: pedir el recurso, validar, decodificar y mapear.
  // "crearElemento" es la fábrica que decide qué objeto concreto construir.
  Future<List<T>> _obtenerLista<T>(
    String recurso,
    T Function(Map<String, dynamic> json) crearElemento,
  ) async {
    final r = await http.get(Uri.parse('$base/$recurso'));
    if (r.statusCode != 200) {
      throw Exception('Error de red');
    }
    final lista = jsonDecode(r.body) as List;
    return lista.map((e) => crearElemento(e as Map<String, dynamic>)).toList();
  }

  Future<List<Planta>> obtenerPlantas() =>
      _obtenerLista('plantas', Planta.desdeJson);

  Future<List<Pedido>> obtenerPedidos() =>
      _obtenerLista('pedidos', Pedido.desdeJson);
}
