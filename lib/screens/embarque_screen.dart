import 'package:distribuidora/screens/PedidosScreen.dart';
import 'package:flutter/material.dart';

class EmbarqueScreen extends StatefulWidget {
  const EmbarqueScreen({super.key});

  @override
  State<EmbarqueScreen> createState() => _EmbarqueScreenState();
}

class _EmbarqueScreenState extends State<EmbarqueScreen> {
  // Catálogo de productos de ejemplo (local)
  final List<Map<String, dynamic>> catalogoProductos = const [
    {'nombre': 'Manzana', 'precio': 12.50, 'stock': 120},
    {'nombre': 'Banana', 'precio': 9.80, 'stock': 200},
    {'nombre': 'Sandía', 'precio': 30.00, 'stock': 15},
    {'nombre': 'Caja Fresa', 'precio': 50.00, 'stock': 12},
    {'nombre': 'Bulto Naranja', 'precio': 120.00, 'stock': 8},
  ];

  // Datos de ejemplo (locales)
  final List<String> almacenes = const ['Almacén 1', 'Almacén 2'];
  final List<String> almacenistas = const ['Almacenista 1', 'Almacenista 2'];
  final List<String> vendedores = const ['Vendedor 1', 'Vendedor 2'];
  final List<String> clientes = const ['Cliente 1', 'Cliente 2'];

  // Unidades locales (sin conexión) con su idunidad
  final List<Map<String, dynamic>> unidadesCompletasMock = const [
    {'idunidad': 1, 'unidad': 'PZA'},
    {'idunidad': 2, 'unidad': 'KG'},
    {'idunidad': 3, 'unidad': 'CAJA'},
    {'idunidad': 4, 'unidad': 'BULTO'},
  ];

  // Estas se llenan a partir del mock anterior
  List<String> unidades = [];
  List<Map<String, dynamic>> unidadesCompletas = [];

  String? almacen;
  String? almacenista;
  String? vendedor;
  String? cliente;
  String? unidad;

  String? productoSeleccionado;
  double? precioSeleccionado;
  int? stockSeleccionado;

  final List<Map<String, dynamic>> productos = [];
  final TextEditingController cantidadController =
      TextEditingController(text: '1');

  @override
  void initState() {
    super.initState();
    unidadesCompletas =
        List<Map<String, dynamic>>.from(unidadesCompletasMock);
    unidades = unidadesCompletas.map((u) => u['unidad'].toString()).toList();
  }

  void _mostrarError(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensaje), backgroundColor: Colors.red),
    );
  }

  void _onProductoSelected(String? producto) {
    final prod = catalogoProductos.firstWhere(
      (p) => p['nombre'] == producto,
      orElse: () => <String, dynamic>{},
    );
    setState(() {
      productoSeleccionado = producto;
      precioSeleccionado = (prod['precio'] as num?)?.toDouble() ?? 0.0;
      stockSeleccionado = (prod['stock'] as int?) ?? 0;
      cantidadController.text = '1';
    });
  }

  void _agregarProducto() {
    if (productoSeleccionado == null || unidad == null) {
      _mostrarError('Selecciona producto y unidad');
      return;
    }
    int cantidad = int.tryParse(cantidadController.text) ?? 1;
    if (cantidad < 1) cantidad = 1;

    final unidadData = unidadesCompletas.firstWhere(
      (u) => u['unidad'] == unidad,
      orElse: () => {'idunidad': null},
    );

    setState(() {
      productos.add({
        'nombre': productoSeleccionado,
        'unidad': unidad,
        'idunidad': unidadData['idunidad'],
        'precio': precioSeleccionado ?? 0.0,
        'cantidad': cantidad,
        'stock': stockSeleccionado ?? 0,
      });

      // reset selección
      productoSeleccionado = null;
      precioSeleccionado = null;
      stockSeleccionado = null;
      cantidadController.text = '1';
      unidad = null;
    });
  }

  void _cambiarCantidad(int index, int valor) {
    setState(() {
      productos[index]['cantidad'] =
          (productos[index]['cantidad'] as int) + valor;
      if (productos[index]['cantidad'] < 1) {
        productos[index]['cantidad'] = 1; // <-- corregido (antes 'Cantidad')
      }
    });
  }

  void _eliminarProducto(int index) {
    setState(() => productos.removeAt(index));
  }

  int get totalCantidad =>
      productos.fold<int>(0, (suma, item) => suma + (item['cantidad'] as int));

  double get sumaTotal => productos.fold<double>(
        0.0,
        (suma, item) =>
            suma +
            ((item['cantidad'] as int) *
                    ((item['precio'] as num?)?.toDouble() ?? 0.0))
                .toDouble(),
      );

  // ===== Guardar y navegar a Pedidos =====
  void _guardarYMandarAPedidos() {
    if (almacen == null ||
        almacenista == null ||
        vendedor == null ||
        cliente == null) {
      _mostrarError('Completa: Almacén, Almacenista, Vendedor y Cliente.');
      return;
    }
    if (productos.isEmpty) {
      _mostrarError('Agrega al menos un producto.');
      return;
    }

    final unidadesPedido =
        productos.map((p) => p['unidad']).toSet().toList();
    final unidadGlobal = unidadesPedido.length == 1
        ? (unidadesPedido.first ?? 'N/A')
        : 'Mixto';

    final now = DateTime.now();
    final fecha =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    final id = now.millisecondsSinceEpoch % 1000000;

    final pedido = {
      'id': id,
      'cliente': cliente,
      'almacen': almacen,
      'unidad': unidadGlobal,
      'fecha': fecha,
      'estado': 'Pendiente',
      'total': sumaTotal,
      'productos':
          productos.map((p) => Map<String, dynamic>.from(p)).toList(),
    };

    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => PedidosScreen(pedidos: [pedido])),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // SIN AppBar con franja; header moderno dentro del body
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF6F8FB), Color(0xFFE9EDF3)],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final double w = constraints.maxWidth;
              final bool isSmall = w < 600;
              final bool isMedium = w >= 600 && w < 1000;
              final double fieldWidth =
                  isSmall ? w : (isMedium ? (w - 64) / 2 : (w - 96) / 3);

              return SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _HeaderTitle(), // TÍTULO moderno
                    const SizedBox(height: 16),

                    // === Filtros / Encabezado ===
                    _CardWrap(
                      child: Wrap(
                        spacing: 16,
                        runSpacing: 16,
                        children: [
                          SizedBox(
                            width: fieldWidth,
                            child: _buildDropdown(
                              value: almacen,
                              items: almacenes,
                              label: 'Almacén',
                              onChanged: (v) =>
                                  setState(() => almacen = v),
                              icon: Icons.store_mall_directory_outlined,
                            ),
                          ),
                          SizedBox(
                            width: fieldWidth,
                            child: _buildDropdown(
                              value: almacenista,
                              items: almacenistas,
                              label: 'Almacenista',
                              onChanged: (v) =>
                                  setState(() => almacenista = v),
                              icon: Icons.badge_outlined,
                            ),
                          ),
                          SizedBox(
                            width: fieldWidth,
                            child: _buildDropdown(
                              value: vendedor,
                              items: vendedores,
                              label: 'Vendedor',
                              onChanged: (v) =>
                                  setState(() => vendedor = v),
                              icon: Icons.sell_outlined,
                            ),
                          ),
                          SizedBox(
                            width: fieldWidth,
                            child: _buildDropdown(
                              value: cliente,
                              items: clientes,
                              label: 'Cliente',
                              onChanged: (v) =>
                                  setState(() => cliente = v),
                              icon: Icons.person_outline,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // === Agregar productos ===
                    _CardWrap(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _SectionTitle('Agregar productos'),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 16,
                            runSpacing: 12,
                            children: [
                              SizedBox(
                                width: isSmall ? w : (isMedium ? fieldWidth : fieldWidth),
                                child: _buildDropdown(
                                  value: unidad,
                                  items: unidades,
                                  label: 'Unidad',
                                  onChanged: (v) =>
                                      setState(() => unidad = v),
                                  icon: Icons.straighten,
                                ),
                              ),
                              SizedBox(
                                width: isSmall ? w : (isMedium ? fieldWidth : fieldWidth * 2 + 16),
                                child: DropdownButtonFormField<String>(
                                  decoration: InputDecoration(
                                    labelText: 'Producto',
                                    prefixIcon:
                                        const Icon(Icons.shopping_basket_outlined),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  value: productoSeleccionado,
                                  items: catalogoProductos
                                      .map(
                                        (prod) => DropdownMenuItem<String>(
                                          value: prod['nombre'] as String,
                                          child: Text(prod['nombre'] as String),
                                        ),
                                      )
                                      .toList(),
                                  onChanged: _onProductoSelected,
                                  isExpanded: true,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 16,
                            runSpacing: 12,
                            children: [
                              SizedBox(
                                width: isSmall ? w : fieldWidth,
                                child: TextField(
                                  controller: cantidadController,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    labelText: 'Cantidad',
                                    prefixIcon: const Icon(
                                        Icons.format_list_numbered),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                ),
                              ),
                              _InfoPill(
                                label: 'Precio',
                                value:
                                    '\$${(precioSeleccionado ?? 0.0).toStringAsFixed(2)}',
                                color: const Color(0xFF27AE60),
                                width: isSmall ? w : fieldWidth,
                              ),
                              _InfoPill(
                                label: 'Stock',
                                value: '${stockSeleccionado ?? 0}',
                                color: const Color(0xFFE74C3C),
                                width: isSmall ? w : fieldWidth,
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              icon: const Icon(Icons.add_circle_outline),
                              label: const Text('Agregar producto'),
                              onPressed: _agregarProducto,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF2C3E50),
                                foregroundColor: Colors.white,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // === Tabla productos ===
                    _CardWrap(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _SectionTitle('Productos seleccionados'),
                          const SizedBox(height: 12),
                          productos.isEmpty
                              ? const Padding(
                                  padding: EdgeInsets.all(20),
                                  child: Column(
                                    children: [
                                      Icon(Icons.remove_shopping_cart_outlined,
                                          size: 46, color: Colors.grey),
                                      SizedBox(height: 8),
                                      Text('No hay productos agregados',
                                          style:
                                              TextStyle(color: Colors.grey)),
                                    ],
                                  ),
                                )
                              : SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: DataTable(
                                    columns: const [
                                      DataColumn(label: Text('Cantidad')),
                                      DataColumn(label: Text('Producto')),
                                      DataColumn(label: Text('Unidad')),
                                      DataColumn(label: Text('P. Unitario')),
                                      DataColumn(label: Text('Stock')),
                                      DataColumn(label: Text('Acciones')),
                                    ],
                                    rows: productos
                                        .asMap()
                                        .entries
                                        .map((entry) {
                                      final i = entry.key;
                                      final item = entry.value;
                                      final precio = (item['precio'] as num?)
                                              ?.toDouble() ??
                                          0.0;
                                      return DataRow(
                                        cells: [
                                          DataCell(
                                            Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                IconButton(
                                                  icon:
                                                      const Icon(Icons.remove),
                                                  onPressed: () =>
                                                      _cambiarCantidad(
                                                          i, -1),
                                                  iconSize: 18,
                                                  color: Colors.red,
                                                ),
                                                Text(
                                                    '${item['cantidad'] as int}'),
                                                IconButton(
                                                  icon: const Icon(Icons.add),
                                                  onPressed: () =>
                                                      _cambiarCantidad(i, 1),
                                                  iconSize: 18,
                                                  color: Colors.green,
                                                ),
                                              ],
                                            ),
                                          ),
                                          DataCell(
                                              Text(item['nombre'].toString())),
                                          DataCell(
                                              Text(item['unidad'].toString())),
                                          DataCell(Text(
                                              '\$${precio.toStringAsFixed(2)}')),
                                          DataCell(
                                              Text(item['stock'].toString())),
                                          DataCell(
                                            IconButton(
                                              icon: const Icon(Icons.delete),
                                              color: Colors.red,
                                              onPressed: () =>
                                                  _eliminarProducto(i),
                                            ),
                                          ),
                                        ],
                                      );
                                    }).toList(),
                                  ),
                                ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // === Totales ===
                    _CardWrap(
                      child: LayoutBuilder(
                        builder: (_, c) {
                          final bool stack = c.maxWidth < 520;
                          return stack
                              ? Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    _TotalTile(
                                      title: 'Total cantidad',
                                      value: '$totalCantidad',
                                      color: const Color(0xFF3498DB),
                                      alignEnd: false,
                                    ),
                                    const SizedBox(height: 12),
                                    _TotalTile(
                                      title: 'Total importe',
                                      value:
                                          '\$${sumaTotal.toStringAsFixed(2)}',
                                      color: const Color(0xFF27AE60),
                                      alignEnd: true,
                                    ),
                                  ],
                                )
                              : Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    _TotalTile(
                                      title: 'Total cantidad',
                                      value: '$totalCantidad',
                                      color: const Color(0xFF3498DB),
                                      alignEnd: false,
                                    ),
                                    _TotalTile(
                                      title: 'Total importe',
                                      value:
                                          '\$${sumaTotal.toStringAsFixed(2)}',
                                      color: const Color(0xFF27AE60),
                                      alignEnd: true,
                                    ),
                                  ],
                                );
                        },
                      ),
                    ),

                    const SizedBox(height: 16),

                    // === Botones ===
                    LayoutBuilder(
                      builder: (_, c) {
                        final bool stack = c.maxWidth < 700;
                        final children = [
                          _buildActionButton(
                            icon: Icons.save_outlined,
                            text: 'Guardar local',
                            color: const Color(0xFF7F8C8D),
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Guardado localmente'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            },
                          ),
                          _buildActionButton(
                            icon: Icons.cloud_upload_outlined,
                            text: 'Guardar',
                            color: const Color(0xFF2C3E50),
                            onPressed: _guardarYMandarAPedidos,
                          ),
                          _buildActionButton(
                            icon: Icons.print_outlined,
                            text: 'Imprimir',
                            color: const Color(0xFF16A085),
                            onPressed: () {},
                          ),
                        ];

                        if (stack) {
                          return Column(
                            children: [
                              for (int i = 0; i < children.length; i++) ...[
                                SizedBox(
                                    width: double.infinity,
                                    child: children[i]),
                                if (i < children.length - 1)
                                  const SizedBox(height: 10),
                              ]
                            ],
                          );
                        }
                        return Row(
                          children: [
                            for (int i = 0; i < children.length; i++) ...[
                              Expanded(child: children[i]),
                              if (i < children.length - 1)
                                const SizedBox(width: 10),
                            ]
                          ],
                        );
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  // ---------- Widgets de apoyo ----------

  Widget _buildDropdown({
    required String? value,
    required List<String> items,
    required String label,
    required void Function(String?) onChanged,
    required IconData icon,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
      items: items
          .map((item) => DropdownMenuItem(value: item, child: Text(item)))
          .toList(),
      onChanged: onChanged,
      isExpanded: true,
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String text,
    required Color color,
    required void Function() onPressed,
  }) {
    return ElevatedButton.icon(
      icon: Icon(icon, size: 20),
      label: Text(text),
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

// ======= Sección: encabezado moderno =======

class _HeaderTitle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final Color a = const Color(0xFF4C6FFF);
    final Color b = const Color(0xFF22C1C3);

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(colors: [a, b]),
            boxShadow: [
              BoxShadow(
                color: a.withOpacity(0.35),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: const Icon(Icons.local_shipping_rounded,
              color: Colors.white, size: 28),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _GradientText(
                'Embarque',
                gradient: LinearGradient(colors: [a, b]),
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.2,
                ),
              ),
              Text(
                'Captura y prepara los pedidos para envío',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 13.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _GradientText extends StatelessWidget {
  final String text;
  final TextStyle style;
  final Gradient gradient;

  const _GradientText(this.text,
      {required this.gradient, required this.style, super.key});

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) =>
          gradient.createShader(Offset.zero & bounds.size),
      child: Text(text, style: style.copyWith(color: Colors.white)),
    );
  }
}

// ======= Sección: tarjetas contenedoras =======

class _CardWrap extends StatelessWidget {
  final Widget child;
  const _CardWrap({required this.child});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: child,
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style:
          const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
    );
  }
}

class _InfoPill extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final double width;

  const _InfoPill({
    required this.label,
    required this.value,
    required this.color,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: color.withOpacity(.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(.25)),
        ),
        child: Row(
          children: [
            Icon(Icons.info_outline, color: color),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                '$label: $value',
                style: TextStyle(
                  color: color.darken(0.1),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TotalTile extends StatelessWidget {
  final String title;
  final String value;
  final Color color;
  final bool alignEnd;
  const _TotalTile({
    required this.title,
    required this.value,
    required this.color,
    required this.alignEnd,
  });

  @override
  Widget build(BuildContext context) {
    final column = Column(
      crossAxisAlignment:
          alignEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(color: Colors.grey, fontSize: 15)),
        Text(
          value,
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
      ],
    );
    return column;
  }
}

// ======= Helpers =======

extension _ColorX on Color {
  Color darken([double amount = .1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(this);
    final hslDark =
        hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
    return hslDark.toColor();
  }
}
