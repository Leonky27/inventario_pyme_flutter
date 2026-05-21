import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/producto.dart';
import '../models/movimiento_historial.dart';
import 'auth_service.dart';

class N8nService {
  // ─── URLs de webhooks n8n ───────────────────────────────────────────────────
  // Reemplaza cada URL con el webhook real de tu instancia n8n.
  final String addProductUrl =
      'https://n8n-services.app.n8n.cloud/webhook/crear-producto';
  final String updateProductUrl =
      'https://n8n-services.app.n8n.cloud/webhook/actualizar-producto';
  final String deleteProductUrl =
      'https://n8n-services.app.n8n.cloud/webhook/eliminar-producto';
  final String updateStockUrl =
      'https://n8n-services.app.n8n.cloud/webhook/movimientos';
  final String getProductsUrl =
      'https://n8n-services.app.n8n.cloud/webhook/obtener-datos';

  /// ⬇️  REEMPLAZA con tu webhook de n8n para consultar el historial.
  /// El workflow debe devolver una lista de movimientos con los campos:
  ///   productoNombre (o producto_nombre / nombre), sku, tipo (o accion),
  ///   cantidad, fecha
  final String getHistorialUrl =
      'https://n8n-services.app.n8n.cloud/webhook/historial-movimientos';

  Future<List<Producto>> obtenerProductos() async {
    try {
      final response = await http.get(Uri.parse(getProductsUrl));
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final List<dynamic> rows = _extractRows(body);
        return rows
            .map((json) => Producto.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('Error al obtener productos: ${response.statusCode}');
      }
    } catch (e) {
      // Fallback a datos simulados si falla
      await Future.delayed(Duration(seconds: 2));
      return [
        Producto(
          id: '1',
          nombre: 'Producto A',
          categoria: 'General',
          sku: 'SKU001',
          cantidad: 10,
          stockMinimo: 5,
          ultimaActualizacion: DateTime.now().toIso8601String(),
        ),
        Producto(
          id: '2',
          nombre: 'Producto B',
          categoria: 'General',
          sku: 'SKU002',
          cantidad: 5,
          stockMinimo: 2,
          ultimaActualizacion: DateTime.now().toIso8601String(),
        ),
      ];
    }
  }

  List<dynamic> _extractRows(dynamic body) {
    if (body is List) {
      return body;
    }
    if (body is Map<String, dynamic>) {
      if (body['data'] is List) return body['data'];
      if (body['rows'] is List) return body['rows'];
      if (body['products'] is List) return body['products'];
      for (final value in body.values) {
        if (value is List) return value;
      }
    }
    return [];
  }

  Future<void> actualizarProducto(Producto producto) async {
    try {
      final body = jsonEncode(producto.toJson(includeId: true));
      print('=================================');
      print('📤 ENVIANDO ACTUALIZACIÓN DE PRODUCTO');
      print('URL: $updateProductUrl');
      print('PAYLOAD: $body');
      print('=================================');

      final response = await http.put(
        Uri.parse(updateProductUrl),
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      print('=================================');
      print('📥 RESPUESTA');
      print('Status: ${response.statusCode}');
      print('Body: ${response.body}');
      print('=================================');

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('❌ ERROR EN ACTUALIZAR PRODUCTO: $e');
      rethrow;
    }
  }

  Future<void> actualizarStock({
    required String id,
    required int cantidad,
    required String tipo,
    int? usuarioId,
  }) async {
    try {
      final int actualUsuarioId = usuarioId ?? AuthService().currentUser?.id ?? 1;
      final payload = {'id': id, 'cantidad': cantidad, 'tipo': tipo, 'Usuario_id': actualUsuarioId};
      final body = jsonEncode(payload);
      print('=================================');
      print('📤 ENVIANDO MOVIMIENTO DE STOCK');
      print('URL: $updateStockUrl');
      print('PAYLOAD: $body');
      print('=================================');

      final response = await http.post(
        Uri.parse(updateStockUrl),
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      print('=================================');
      print('📥 RESPUESTA');
      print('Status: ${response.statusCode}');
      print('Body: ${response.body}');
      print('=================================');

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('❌ ERROR EN ACTUALIZAR STOCK: $e');
      rethrow;
    }
  }

  Future<void> agregarProducto(Producto producto) async {
    try {
      final body = jsonEncode(producto.toJson());
      print('📤 Enviando nuevo producto a n8n: $body');

      final response = await http.post(
        Uri.parse(addProductUrl),
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      print('📥 Respuesta de n8n (${response.statusCode}): ${response.body}');

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception(
          'Error al agregar producto: ${response.statusCode}\nRespuesta: ${response.body}',
        );
      }
    } catch (e) {
      print('❌ Error en agregarProducto: $e');
      rethrow;
    }
  }

  Future<void> eliminarProducto(String id) async {
    try {
      final url = '$deleteProductUrl?id=$id';
      print('=================================');
      print('📤 ENVIANDO ELIMINACIÓN DE PRODUCTO');
      print('URL: $url');
      print('=================================');

      final response = await http.delete(Uri.parse(url));

      print('=================================');
      print('📥 RESPUESTA');
      print('Status: ${response.statusCode}');
      print('Body: ${response.body}');
      print('=================================');

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('❌ ERROR EN ELIMINAR PRODUCTO: $e');
      rethrow;
    }
  }

  /// Obtiene el historial de movimientos desde n8n.
  Future<List<MovimientoHistorial>> obtenerHistorial() async {
    try {
      print('📤 OBTENIENDO HISTORIAL');
      print('URL: $getHistorialUrl');

      final response = await http.get(Uri.parse(getHistorialUrl));

      print('📥 RESPUESTA HISTORIAL (${response.statusCode}): ${response.body}');

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final List<dynamic> rows = _extractRows(body);
        return rows
            .map((json) =>
                MovimientoHistorial.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception(
            'Error al obtener historial: HTTP ${response.statusCode}');
      }
    } catch (e) {
      print('❌ ERROR EN OBTENER HISTORIAL: $e');
      rethrow;
    }
  }

  Future<List<String>> obtenerErrores() async {
    return ['Fila borrada en Sheets: Producto X'];
  }

  Future<void> resolverError(String error) async {}
}
