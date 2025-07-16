import 'package:distribuidora/screens/PedidosScreen.dart';
import 'package:flutter/material.dart';
import 'embarque_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Distribuidora Magaña',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 2,
          shadowColor: Colors.black26,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(10),
            ),
          ),
        ),
      ),
      home: const MainNavigationScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;
  final List<Widget> _screens = [
    const EmbarqueScreen(),
    const PedidosScreen(pedidos: []), // Aquí pasas tu lista real de pedidos
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Distribuidora Magaña',
            style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5)),
        backgroundColor: const Color(0xFF1A2C38),
        foregroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(15),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications, size: 26),
            onPressed: () {},
            tooltip: 'Notificaciones',
          ),
          const SizedBox(width: 8),
        ],
      ),
      drawer: _buildDrawer(context),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFF5F7FA), Color(0xFFE4E7EB)],
          ),
        ),
        child: _screens[_currentIndex],
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildBottomNavBar() {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
      child: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        backgroundColor: const Color(0xFF1A2C38),
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.local_shipping),
            label: 'Embarque',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Pedidos',
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      width: MediaQuery.of(context).size.width * 0.75,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(right: Radius.circular(20)),
      ),
      elevation: 10,
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1A2C38), Color(0xFF3A5668)],
          ),
          borderRadius: BorderRadius.horizontal(right: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _buildDrawerHeader(),
                  _buildDrawerItem(
                    context,
                    icon: Icons.local_shipping,
                    title: 'Embarque',
                    index: 0,
                  ),
                  _buildDrawerItem(
                    context,
                    icon: Icons.shopping_cart,
                    title: 'Pedidos',
                    index: 1,
                  ),
                  _buildDrawerItem(
                    context,
                    icon: Icons.assessment,
                    title: 'Reportes',
                    onTap: () {},
                  ),
                  _buildDrawerItem(
                    context,
                    icon: Icons.people,
                    title: 'Clientes',
                    onTap: () {},
                  ),
                  const Divider(color: Colors.white54, height: 20),
                  _buildDrawerItem(
                    context,
                    icon: Icons.settings,
                    title: 'Configuración',
                    onTap: () {},
                  ),
                  _buildDrawerItem(
                    context,
                    icon: Icons.help,
                    title: 'Ayuda',
                    onTap: () {},
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Versión 1.0.0',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerHeader() {
    return Container(
      height: 180,
      decoration: const BoxDecoration(
        color: Color(0xFF1A2C38),
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.1),
              border: Border.all(color: Colors.white54, width: 2),
            ),
            child: const Icon(Icons.inventory, size: 40, color: Colors.white),
          ),
          const SizedBox(height: 15),
          const Text(
            'Distribuidora Magaña',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            'Administración de distribución',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    int? index,
    VoidCallback? onTap,
  }) {
    final isSelected = index != null && _currentIndex == index;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: isSelected
            ? Colors.white.withOpacity(0.15)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        leading: Icon(icon,
            color: isSelected ? Colors.white : Colors.white.withOpacity(0.8)),
        title: Text(title,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.white.withOpacity(0.9),
              fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
            )),
        onTap: onTap ?? () {
          if (index != null) {
            setState(() => _currentIndex = index);
          }
          Navigator.pop(context);
        },
      ),
    );
  }
}