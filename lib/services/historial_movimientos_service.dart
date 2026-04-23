import 'package:flutter/foundation.dart';
import '../models/movimiento_historial.dart';

class HistorialMovimientosService {
  static final ValueNotifier<List<MovimientoHistorial>> historialNotifier =
      ValueNotifier<List<MovimientoHistorial>>([]);

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

  static void limpiarHistorial() {
    historialNotifier.value = [];
  }
}
