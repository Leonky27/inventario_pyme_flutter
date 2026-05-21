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

  /// Parsea la respuesta de n8n. Acepta distintos nombres de campo
  /// según cómo el workflow devuelva el JOIN de movimientos + productos.
  factory MovimientoHistorial.fromJson(Map<String, dynamic> json) {
    return MovimientoHistorial(
      productoNombre:
          json['productoNombre'] ??
          json['producto_nombre'] ??
          json['nombre'] ??
          '',
      sku: json['sku'] ?? '',
      accion: json['accion'] ?? json['tipo'] ?? '',
      cantidad: json['cantidad'] is int
          ? json['cantidad']
          : int.tryParse(json['cantidad']?.toString() ?? '0') ?? 0,
      fecha: json['fecha'] != null
          ? DateTime.tryParse(json['fecha'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
