import 'package:flutter/material.dart';
import '../models/movimiento_historial.dart';
import '../services/historial_movimientos_service.dart';

class HistorialMovimientosScreen extends StatefulWidget {
  const HistorialMovimientosScreen({super.key});

  @override
  State<HistorialMovimientosScreen> createState() =>
      _HistorialMovimientosScreenState();
}

class _HistorialMovimientosScreenState
    extends State<HistorialMovimientosScreen> {
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _cargarHistorial();
  }

  Future<void> _cargarHistorial() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      await HistorialMovimientosService.cargarDesdeN8n();
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _formatearFecha(DateTime fecha) {
    final day = fecha.day.toString().padLeft(2, '0');
    final month = fecha.month.toString().padLeft(2, '0');
    final year = fecha.year.toString();
    final hour = fecha.hour.toString().padLeft(2, '0');
    final minute = fecha.minute.toString().padLeft(2, '0');
    return '$day/$month/$year $hour:$minute';
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.cloud_off, color: Colors.red[300], size: 56),
            const SizedBox(height: 16),
            const Text(
              'No se pudo cargar el historial',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              _error ?? '',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _cargarHistorial,
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history_toggle_off, size: 56, color: Colors.grey),
          SizedBox(height: 12),
          Text(
            'Aún no hay movimientos registrados',
            style: TextStyle(fontSize: 16, color: Colors.black54),
          ),
        ],
      ),
    );
  }

  Widget _buildListItem(MovimientoHistorial movimiento) {
    final esEntrada = movimiento.accion == 'entrada';
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: esEntrada ? Colors.green[100] : Colors.red[100],
        child: Icon(
          esEntrada ? Icons.arrow_downward : Icons.arrow_upward,
          color: esEntrada ? Colors.green[700] : Colors.red[700],
        ),
      ),
      title: Text(
        movimiento.productoNombre,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        'SKU: ${movimiento.sku}\n${_formatearFecha(movimiento.fecha)}',
      ),
      isThreeLine: true,
      trailing: Text(
        '${esEntrada ? '+' : '-'}${movimiento.cantidad}',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: esEntrada ? Colors.green[700] : Colors.red[700],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial de Movimientos'),
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: 'Actualizar historial',
              onPressed: _cargarHistorial,
            ),
        ],
      ),
      body: _error != null
          ? _buildError()
          : RefreshIndicator(
              onRefresh: _cargarHistorial,
              child: ValueListenableBuilder<List<MovimientoHistorial>>(
                valueListenable:
                    HistorialMovimientosService.historialNotifier,
                builder: (context, historial, _) {
                  if (_isLoading && historial.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (historial.isEmpty) return _buildEmpty();

                  return ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: historial.length,
                    separatorBuilder: (_, __) =>
                        const Divider(height: 1),
                    itemBuilder: (context, index) =>
                        _buildListItem(historial[index]),
                  );
                },
              ),
            ),
    );
  }
}
