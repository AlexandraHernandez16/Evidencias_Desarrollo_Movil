# Hallazgos — Duplicación en la capa de datos (vivero)

## 2.1 Fragmentos duplicados

**Archivo:** `lib/data/vivero_api_service.dart`

**Funciones:** `obtenerPlantas()` y `obtenerPedidos()`

Ambas funciones repiten exactamente la misma estructura (el "esqueleto" del algoritmo es idéntico), y solo cambian dos detalles: el endpoint consultado y la clase concreta usada para convertir el JSON en objeto. Concretamente se repite:

1. La construcción y ejecución de la petición HTTP:
   ```dart
   final r = await http.get(Uri.parse('$base/...'));
   ```
2. La validación del código de estado y el manejo de error:
   ```dart
   if (r.statusCode != 200) { throw Exception('Error de red'); }
   ```
3. La decodificación del cuerpo de la respuesta como lista:
   ```dart
   final lista = jsonDecode(r.body) as List;
   ```
4. El recorrido de la lista para mapear cada elemento a un modelo:
   ```dart
   return lista.map((e) => X.desdeJson(e)).toList();
   ```

Lo único que difiere entre `obtenerPlantas()` y `obtenerPedidos()` es el string `'plantas'` / `'pedidos'` y la referencia `Planta.desdeJson` / `Pedido.desdeJson`. Si mañana cambia la forma de validar la respuesta (por ejemplo, aceptar también 201, o registrar el error en un log), habría que editar ese mismo bloque en **N** funciones distintas — hoy dos, pero el patrón crece con cada nuevo recurso (categorías, clientes, etc.).

## 2.2 Patrón aplicado y justificación

**Patrón:** **Factory Method** (aplicado mediante un parámetro de tipo función que actúa como "fábrica" de objetos).

Se extrae un método privado genérico `_obtenerLista<T>(recurso, crearElemento)` que concentra el algoritmo común (petición HTTP, validación de estado, decodificación JSON, mapeo a lista). El único paso que varía entre casos —qué clase concreta se construye a partir del JSON— se delega a un parámetro `T Function(Map<String, dynamic>) crearElemento`, que cada método público (`obtenerPlantas`, `obtenerPedidos`) provee (`Planta.desdeJson`, `Pedido.desdeJson`).

**Por qué Factory Method y no otro patrón:**

- **Adapter** no aplica: no hay dos interfaces incompatibles que conciliar; ambos métodos ya usan la misma interfaz (`http`, `jsonDecode`).
- **Strategy** no aplica: el *algoritmo* de obtención de datos (GET → validar → decodificar → mapear) es idéntico en ambos casos; lo que cambia no es el algoritmo sino el *objeto concreto construido*, que es justo lo que resuelve Factory Method.
- **Observer** no aplica: no hay notificación a múltiples interesados ante un cambio de estado.
- **Repository** resuelve otro problema (desacoplar la pantalla de la fuente de datos para poder probarla sin servidor); aquí la duplicación vive *dentro* de la propia capa de datos, entre dos funciones que ya pertenecen al mismo repositorio/servicio, así que no elimina la repetición del bloque HTTP+parseo.

Por eso Factory Method es el más directo: mantiene un único punto de verdad para la lógica de red y parseo, y cada recurso solo declara "qué construir", sin duplicar "cómo obtenerlo".

## 2.3 Código refactorizado

Ver [lib/data/vivero_api_service.dart](lib/data/vivero_api_service.dart). El comportamiento se mantiene intacto: mismos endpoints, misma excepción (`Exception('Error de red')`) ante código de estado distinto de 200, mismos tipos de retorno (`Future<List<Planta>>`, `Future<List<Pedido>>`).
