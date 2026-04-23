class MovimientoHistorial {
  final String productoNombre;
  final String sku;
  final String accion;
  final int cantidad;
  final DateTime fecha;

  MovimientoHistorial({
    required this.productoNombre,
    required this.sku,
    required this.accion,
    required this.cantidad,
    required this.fecha,
  });
}
