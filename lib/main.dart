import 'package:flutter/material.dart';
import 'screens/inventario_screen.dart';
import 'screens/movimiento_screen.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Inventario SEGED',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<({String title, Widget screen})> _screens = const [
    (title: 'Inventario', screen: InventarioScreen()),
    (title: 'Movimientos', screen: MovimientoScreen()),
  ];

  void _navigateToScreen(int index) {
    setState(() => _selectedIndex = index);
    Navigator.pop(context); // Cierra el drawer después de seleccionar
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_screens[_selectedIndex].title),
      ),
      body: SafeArea(child: _screens[_selectedIndex].screen),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: Colors.blue),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: const [
                  Text(
                    'SEGED',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'Sistema de Inventario',
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
            ..._screens.asMap().entries.map((entry) {
              int index = entry.key;
              String title = entry.value.title;
              bool isSelected = _selectedIndex == index;

              return ListTile(
                title: Text(title),
                leading: Icon(
                  index == 0 ? Icons.inventory_2 : Icons.swap_horiz,
                  color: isSelected ? Colors.blue : Colors.grey,
                ),
                selected: isSelected,
                selectedTileColor: Colors.blue.withOpacity(0.1),
                onTap: () => _navigateToScreen(index),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}
