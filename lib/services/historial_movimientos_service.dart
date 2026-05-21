import 'package:flutter/foundation.dart';
import '../models/movimiento_historial.dart';
import 'n8n_service.dart';

class HistorialMovimientosService {
  static final ValueNotifier<List<MovimientoHistorial>> historialNotifier =
      ValueNotifier<List<MovimientoHistorial>>([]);

  /// Carga el historial real desde n8n y actualiza el notifier.
  static Future<void> cargarDesdeN8n() async {
    final movimientos = await N8nService().obtenerHistorial();
    historialNotifier.value = movimientos;
  }

  /// Registro optimista local: agrega el movimiento al tope de la lista
  /// de forma inmediata, sin esperar a que n8n responda.
  /// Útil para dar feedback instantáneo al usuario en MovimientoScreen.
  static void registrarMovimiento({
    required String productoNombre,
    required String sku,
    required String accion,
    required int cantidad,
  }) {
    final movimiento = MovimientoHistorial(
      productoNombre: productoNombre,
      sku: sku,
      accion: accion,
      cantidad: cantidad,
      fecha: DateTime.now(),
    );
    historialNotifier.value = [movimiento, ...historialNotifier.value];
  }
}
