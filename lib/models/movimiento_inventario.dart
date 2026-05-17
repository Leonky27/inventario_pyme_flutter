class MovimientoInventario {
  int id;
  int productoId;
  int usuarioId;
  String tipo;
  int cantidad;
  DateTime fecha;

  MovimientoInventario({
    required this.id,
    required this.productoId,
    required this.usuarioId,
    required this.tipo,
    required this.cantidad,
    required this.fecha,
  });

  factory MovimientoInventario.fromJson(Map<String, dynamic> json) {
    return MovimientoInventario(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      productoId: json['producto_id'] is int ? json['producto_id'] : int.tryParse(json['producto_id'].toString()) ?? 0,
      usuarioId: json['Usuario_id'] is int ? json['Usuario_id'] : (json['usuario_id'] is int ? json['usuario_id'] : int.tryParse(json['Usuario_id']?.toString() ?? json['usuario_id']?.toString() ?? '0') ?? 0),
      tipo: json['tipo'] ?? '',
      cantidad: json['cantidad'] is int ? json['cantidad'] : int.tryParse(json['cantidad'].toString()) ?? 0,
      fecha: json['fecha'] != null ? DateTime.tryParse(json['fecha'].toString()) ?? DateTime.now() : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'producto_id': productoId,
      'Usuario_id': usuarioId,
      'tipo': tipo,
      'cantidad': cantidad,
      'fecha': fecha.toIso8601String(),
    };
  }
}
