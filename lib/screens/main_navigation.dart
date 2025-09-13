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
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
          brightness: Brightness.light,
        ),
        textTheme: const TextTheme(
          headlineSmall: TextStyle(fontWeight: FontWeight.bold),
          titleMedium: TextStyle(fontWeight: FontWeight.w600),
          bodyMedium: TextStyle(fontSize: 14),
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

  final List<Widget> _screens = const [
    DashboardScreen(),
    EmbarqueScreen(),
    PedidosScreen(pedidos: []),
  ];

  final List<String> _titles = const [
    "Inicio",
    "Embarque",
    "Pedidos",
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isLargeScreen = constraints.maxWidth >= 1000; // escritorio
        return Scaffold(
          appBar: AppBar(
            title: Text(_titles[_currentIndex]),
            centerTitle: true,
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Colors.white,
          ),
          drawer: isLargeScreen ? null : _buildDrawer(),
          body: SafeArea(
            child: Row(
              children: [
                if (isLargeScreen) _buildNavigationRail(),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: _screens[_currentIndex],
                  ),
                ),
              ],
            ),
          ),
          bottomNavigationBar:
              isLargeScreen ? null : _buildBottomNavigationBar(),
        );
      },
    );
  }

  Widget _buildBottomNavigationBar() {
    return NavigationBar(
      selectedIndex: _currentIndex,
      onDestinationSelected: (i) => setState(() => _currentIndex = i),
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.dashboard_outlined),
          selectedIcon: Icon(Icons.dashboard, color: Colors.indigo),
          label: "Inicio",
        ),
        NavigationDestination(
          icon: Icon(Icons.local_shipping_outlined),
          selectedIcon: Icon(Icons.local_shipping, color: Colors.indigo),
          label: "Embarque",
        ),
        NavigationDestination(
          icon: Icon(Icons.shopping_cart_outlined),
          selectedIcon: Icon(Icons.shopping_cart, color: Colors.indigo),
          label: "Pedidos",
        ),
      ],
    );
  }

  Widget _buildNavigationRail() {
    return NavigationRail(
      selectedIndex: _currentIndex,
      onDestinationSelected: (i) => setState(() => _currentIndex = i),
      labelType: NavigationRailLabelType.all,
      backgroundColor: Colors.grey.shade100,
      destinations: const [
        NavigationRailDestination(
          icon: Icon(Icons.dashboard_outlined),
          selectedIcon: Icon(Icons.dashboard, color: Colors.indigo),
          label: Text("Inicio"),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.local_shipping_outlined),
          selectedIcon: Icon(Icons.local_shipping, color: Colors.indigo),
          label: Text("Embarque"),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.shopping_cart_outlined),
          selectedIcon: Icon(Icons.shopping_cart, color: Colors.indigo),
          label: Text("Pedidos"),
        ),
      ],
    );
  }

  Drawer _buildDrawer() {
    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(
              color: Colors.indigo.shade700,
            ),
            currentAccountPicture: const CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.business, color: Colors.indigo, size: 36),
            ),
            accountName: const Text(
              "Distribuidora Magaña",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            accountEmail: const Text("Administración de distribución"),
          ),
          ListTile(
            leading: const Icon(Icons.dashboard_outlined),
            title: const Text("Inicio"),
            selected: _currentIndex == 0,
            onTap: () {
              setState(() => _currentIndex = 0);
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.local_shipping_outlined),
            title: const Text("Embarque"),
            selected: _currentIndex == 1,
            onTap: () {
              setState(() => _currentIndex = 1);
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.shopping_cart_outlined),
            title: const Text("Pedidos"),
            selected: _currentIndex == 2,
            onTap: () {
              setState(() => _currentIndex = 2);
              Navigator.pop(context);
            },
          ),
          const Spacer(),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text("Configuración"),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.help_outline),
            title: const Text("Ayuda"),
            onTap: () {},
          ),
          const SizedBox(height: 10),
          Text(
            "Versión 1.0.0",
            style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}

/// DASHBOARD 100% RESPONSIVO
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final double w = MediaQuery.of(context).size.width;
    // Escala suave para tipografías/íconos según ancho
    final double scale = (w / 390).clamp(0.85, 1.25);

    final cards = [
      _DashboardCard(
        title: "Pedidos",
        value: "128",
        icon: Icons.shopping_cart,
        color: Colors.indigo,
        scale: scale,
      ),
      _DashboardCard(
        title: "Embarques",
        value: "42",
        icon: Icons.local_shipping,
        color: Colors.green,
        scale: scale,
      ),
      _DashboardCard(
        title: "Clientes",
        value: "87",
        icon: Icons.people,
        color: Colors.orange,
        scale: scale,
      ),
    ];

    return Padding(
      padding: const EdgeInsets.all(16),
      // Grid adaptable por ANCHO: agrega/quita columnas automáticamente
      child: GridView.builder(
        itemCount: cards.length,
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 280,      // ancho máximo por tarjeta
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.05,       // ↑ más alto para evitar overflow
        ),
        itemBuilder: (_, i) => cards[i],
      ),
    );
  }
}

class _DashboardCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final double scale;

  const _DashboardCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.scale,
  });

  @override
  Widget build(BuildContext context) {
    final TextStyle valueStyle = Theme.of(context)
        .textTheme
        .headlineSmall!
        .copyWith(color: color, fontSize: 24 * scale);

    final TextStyle titleStyle =
        Theme.of(context).textTheme.titleMedium!.copyWith(fontSize: 15 * scale);

    final double avatarRadius = 28 * scale;
    final double iconSize = 28 * scale;

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly, // reparte altura
          mainAxisSize: MainAxisSize.max,
          children: [
            CircleAvatar(
              backgroundColor: color.withOpacity(0.15),
              radius: avatarRadius,
              child: Icon(icon, color: color, size: iconSize),
            ),
            Text(value, style: valueStyle, maxLines: 1),
            Text(title, style: titleStyle, maxLines: 1, overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }
}
