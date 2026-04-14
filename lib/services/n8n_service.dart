import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/producto.dart';

class N8nService {
  final String _postMovimientoUrl =
      'https://stevenpajarol1.app.n8n.cloud/webhook/inventario-pyme';
  final String _postProductoUrl =
      'https://stevenpajarol1.app.n8n.cloud/webhook/agregar-producto';
  final String _getUrl =
      'https://stevenpajarol1.app.n8n.cloud/webhook/obtener-datos';

  Future<bool> enviarMovimiento(InventarioMovimiento movimiento) async {
    try {
      final response = await http.post(
        Uri.parse(_postMovimientoUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(movimiento.toJson()),
      );

      return response.statusCode == 200;
    } catch (e) {
      print("Error conectando con n8n: $e");
      return false;
    }
  }

  Future<bool> agregarProducto(Map<String, dynamic> producto) async {
    try {
      final response = await http.post(
        Uri.parse(_postProductoUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(producto),
      );

      return response.statusCode == 200;
    } catch (e) {
      print("Error conectando con n8n: $e");
      return false;
    }
  }

  Future<List<dynamic>> fetchProductos() async {
    try {
      final response = await http.get(Uri.parse(_getUrl));

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);

        if (decoded is List) {
          return decoded;
        }

        if (decoded is Map<String, dynamic>) {
          return [decoded];
        }

        return [];
      } else {
        throw Exception('Error al cargar productos');
      }
    } catch (e) {
      print("Error: $e");
      return [];
    }
  }
}
