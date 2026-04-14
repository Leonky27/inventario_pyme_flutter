import 'package:flutter/material.dart';
import '../services/n8n_service.dart';

class InventarioScreen extends StatefulWidget {
  const InventarioScreen({super.key});

  @override
  _InventarioScreenState createState() => _InventarioScreenState();
}

class _InventarioScreenState extends State<InventarioScreen> {
  final N8nService service = N8nService();
  late Future<List<dynamic>> _productosFuture;

  @override
  void initState() {
    super.initState();
    _productosFuture = service.fetchProductos();
  }

  void _refreshProductos() {
    setState(() {
      _productosFuture = service.fetchProductos();
    });
  }

  Future<void> _showAddProductDialog() async {
    final _formKey = GlobalKey<FormState>();
    final _idController = TextEditingController();
    final _nombreController = TextEditingController();
    final _categoriaController = TextEditingController();
    final _stockActualController = TextEditingController();
    final _stockMinimoController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Agregar nuevo producto'),
          content: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _idController,
                    decoration: const InputDecoration(labelText: 'ID del producto'),
                    validator: (value) => value == null || value.isEmpty ? 'Ingresa el ID' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _nombreController,
                    decoration: const InputDecoration(labelText: 'Nombre'),
                    validator: (value) => value == null || value.isEmpty ? 'Ingresa el nombre' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _categoriaController,
                    decoration: const InputDecoration(labelText: 'Categoría'),
                    validator: (value) => value == null || value.isEmpty ? 'Ingresa la categoría' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _stockActualController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Stock actual'),
                    validator: (value) => value == null || value.isEmpty ? 'Ingresa el stock actual' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _stockMinimoController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Stock mínimo'),
                    validator: (value) => value == null || value.isEmpty ? 'Ingresa el stock mínimo' : null,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (!_formKey.currentState!.validate()) return;

                final nuevoProducto = {
                  'id_producto': _idController.text.trim(),
                  'nombre': _nombreController.text.trim(),
                  'categoria': _categoriaController.text.trim(),
                  'stock_actual': int.tryParse(_stockActualController.text.trim()) ?? 0,
                  'stock_minimo': int.tryParse(_stockMinimoController.text.trim()) ?? 0,
                  'ultima_actualizacion': DateTime.now().toIso8601String(),
                };

                final success = await service.agregarProducto(nuevoProducto);
                Navigator.of(context).pop(success);
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );

    if (result == true) {
      _refreshProductos();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Producto agregado correctamente')),
      );
    } else if (result == false) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo agregar el producto')), 
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: _productosFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return const Center(child: Text("Error al conectar con el servidor"));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text("No hay productos registrados"));
        }

        return Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 8,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Expanded(
                            child: Text(
                              'Inventario de productos',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: _showAddProductDialog,
                            icon: const Icon(Icons.add),
                            label: const Text('Agregar producto'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Divider(),
                      const SizedBox(height: 12),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          child: DataTable(
                            headingRowColor: MaterialStateProperty.resolveWith(
                              (states) => Colors.blue.shade50,
                            ),
                            columns: const [
                              DataColumn(label: Text('ID')),
                              DataColumn(label: Text('Nombre')),
                              DataColumn(label: Text('Categoría')),
                              DataColumn(label: Text('Stock Actual')),
                              DataColumn(label: Text('Stock Mínimo')),
                              DataColumn(label: Text('Última Actualización')),
                            ],
                            rows: snapshot.data!.map((producto) {
                              return DataRow(
                                cells: [
                                  DataCell(Text(producto['id_producto'].toString())),
                                  DataCell(Text(producto['nombre'].toString())),
                                  DataCell(Text(producto['categoria'].toString())),
                                  DataCell(Text(producto['stock_actual'].toString())),
                                  DataCell(Text(producto['stock_minimo'].toString())),
                                  DataCell(Text(producto['ultima_actualizacion'].toString())),
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}