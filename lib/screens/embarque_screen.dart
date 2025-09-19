import 'package:flutter/material.dart';

class EmbarqueScreen extends StatefulWidget {
  const EmbarqueScreen({super.key});

  @override
  State<EmbarqueScreen> createState() => _EmbarqueScreenState();
}

class _EmbarqueScreenState extends State<EmbarqueScreen> {
  // --- Catálogos (mock). Puedes sustituir por tus fuentes reales ---
  final List<String> almacenes = const ['Almacén Central', 'Almacén Norte'];
  final List<String> almacenistas = const ['Arturo Gómez', 'María Pérez'];
  final List<Map<String, dynamic>> unidadesCompletas = const [
    {'idunidad': 1, 'unidad': 'kg'},
    {'idunidad': 2, 'unidad': 'm'},
    {'idunidad': 3, 'unidad': 'lb'},
    {'idunidad': 4, 'unidad': 'pz'},
    {'idunidad': 5, 'unidad': 'caja'},
  ];

  // Clientes "verdaderos"
  final List<String> clientes = const [
    'Walmart',
    'OXXO',
    'Chedraui',
    'Soriana',
    'Bodega Aurrera',
  ];

  // --- Estado de filtros/encabezado ---
  String? almacen;
  String? almacenista;
  String? unidad; // para el alta de producto
  String? cliente;

  // --- Controles para agregar producto ---
  final TextEditingController productoCtrl = TextEditingController();
  final TextEditingController precioCtrl = TextEditingController(text: '0.00');
  final TextEditingController cantidadCtrl = TextEditingController(text: '1');

  // --- Lista de renglones en la tabla ---
  final List<Map<String, dynamic>> filas = []; // {cod, cantidad, unidad, producto, precio}

  // Helpers
  List<String> get unidades => unidadesCompletas.map((e) => e['unidad'] as String).toList();

  void _snack(String msg, {Color color = Colors.black87}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: color),
    );
  }

  String _nextCodigo() {
    final next = filas.length + 1;
    return next.toString().padLeft(3, '0'); // 001, 002, ...
  }

  void _agregarFila() {
    if (almacen == null || almacenista == null || unidad == null || cliente == null) {
      _snack('Completa: Almacén, Almacenista, Unidad y Cliente.', color: Colors.red);
      return;
    }
    final nombre = productoCtrl.text.trim();
    if (nombre.isEmpty) {
      _snack('Escribe el nombre del producto.', color: Colors.red);
      return;
    }
    final precio = double.tryParse(precioCtrl.text.replaceAll(',', '.')) ?? 0.0;
    int cantidad = int.tryParse(cantidadCtrl.text) ?? 1;
    if (cantidad < 1) cantidad = 1;

    setState(() {
      filas.add({
        'cod': _nextCodigo(),
        'cantidad': cantidad,
        'unidad': unidad,
        'producto': nombre,
        'precio': precio,
      });
      // limpiar campos de captura
      productoCtrl.clear();
      precioCtrl.text = '0.00';
      cantidadCtrl.text = '1';
    });
  }

  void _cambiarCantidad(int index, int delta) {
    setState(() {
      final nueva = (filas[index]['cantidad'] as int) + delta;
      filas[index]['cantidad'] = nueva < 1 ? 1 : nueva;
    });
  }

  void _eliminar(int index) {
    setState(() {
      filas.removeAt(index);
      // reenumerar códigos para que sigan consecutivos
      for (int i = 0; i < filas.length; i++) {
        filas[i]['cod'] = (i + 1).toString().padLeft(3, '0');
      }
    });
  }

  double get total => filas.fold<double>(
        0.0,
        (sum, f) => sum + (f['cantidad'] as int) * (f['precio'] as double),
      );

  // UI ----------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE9EDF3),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _Header(),
              const SizedBox(height: 16),

              // Encabezado (4 selects) -> 2 por fila en móvil/tablet, 4 en desktop
              _CardWrap(
                child: LayoutBuilder(
                  builder: (context, c) {
                    final w = c.maxWidth;
                    final isPhoneOrTablet = w < 1000; // breakpoint
                    final cols = isPhoneOrTablet ? 2 : 4;

                    return GridView.count(
                      crossAxisCount: cols,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 3.2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        _dropdown(
                          label: 'Almacén',
                          icon: Icons.store_mall_directory_outlined,
                          value: almacen,
                          items: almacenes,
                          onChanged: (v) => setState(() => almacen = v),
                        ),
                        _dropdown(
                          label: 'Almacenista',
                          icon: Icons.badge_outlined,
                          value: almacenista,
                          items: almacenistas,
                          onChanged: (v) => setState(() => almacenista = v),
                        ),
                        _dropdown(
                          label: 'Unidad',
                          icon: Icons.straighten,
                          value: unidad,
                          items: unidades,
                          onChanged: (v) => setState(() => unidad = v),
                        ),
                        _dropdown(
                          label: 'Cliente',
                          icon: Icons.person_outline,
                          value: cliente,
                          items: clientes,
                          onChanged: (v) => setState(() => cliente = v),
                        ),
                      ],
                    );
                  },
                ),
              ),

              const SizedBox(height: 16),

              // Captura (Producto + Precio + Cantidad en fila de 3) + botón Agregar debajo
              _CardWrap(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const _SectionTitle('Producto'),
                    const SizedBox(height: 12),

                    // Fila de 3 SIEMPRE (producto, precio, cantidad)
                    LayoutBuilder(builder: (context, c) {
                      return GridView.count(
                        crossAxisCount: 3,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 12,
                        childAspectRatio: 4.0,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        children: [
                          TextField(
                            controller: productoCtrl,
                            decoration: _inputDeco(
                              label: 'Producto',
                              icon: Icons.shopping_basket_outlined,
                              trailing: IconButton(
                                onPressed: () => productoCtrl.clear(),
                                icon: const Icon(Icons.close),
                              ),
                            ),
                          ),
                          TextField(
                            controller: precioCtrl,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            decoration: _inputDeco(
                              label: 'Precio (P/U)',
                              icon: Icons.attach_money,
                            ),
                          ),
                          TextField(
                            controller: cantidadCtrl,
                            keyboardType: TextInputType.number,
                            decoration: _inputDeco(
                              label: 'Cantidad',
                              icon: Icons.format_list_numbered,
                            ),
                          ),
                        ],
                      );
                    }),

                    const SizedBox(height: 12),

                    // Botón Agregar ancho completo (se mantiene en su posición)
                    SizedBox(
                      width: double.infinity,
                      child: _primaryButton(
                        icon: Icons.add_circle_outline,
                        text: 'Agregar',
                        background: const Color(0xFF1E3A8A), // Indigo 900
                        onPressed: _agregarFila,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Tabla
              _CardWrap(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const _SectionTitle('Detalle'),
                    const SizedBox(height: 12),
                    filas.isEmpty
                        ? const Padding(
                            padding: EdgeInsets.all(24.0),
                            child: Center(
                              child: Text('Sin productos agregados', style: TextStyle(color: Colors.grey)),
                            ),
                          )
                        : SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: DataTable(
                              columns: const [
                                DataColumn(label: Text('cod.')),
                                DataColumn(label: Text('Cantidad')),
                                DataColumn(label: Text('Unidad')),
                                DataColumn(label: Text('Producto')),
                                DataColumn(label: Text('P/U')),
                                DataColumn(label: Text('Acciones')),
                              ],
                              rows: [
                                for (int i = 0; i < filas.length; i++)
                                  DataRow(
                                    cells: [
                                      DataCell(Text(filas[i]['cod'] as String)),
                                      DataCell(Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.remove),
                                            color: Colors.red,
                                            iconSize: 18,
                                            onPressed: () => _cambiarCantidad(i, -1),
                                          ),
                                          Text('${filas[i]['cantidad']}'),
                                          IconButton(
                                            icon: const Icon(Icons.add),
                                            color: Colors.green,
                                            iconSize: 18,
                                            onPressed: () => _cambiarCantidad(i, 1),
                                          ),
                                        ],
                                      )),
                                      DataCell(Text(filas[i]['unidad'].toString())),
                                      DataCell(Text(filas[i]['producto'].toString())),
                                      DataCell(Text('\$${(filas[i]['precio'] as double).toStringAsFixed(2)}')),
                                      DataCell(
                                        IconButton(
                                          icon: const Icon(Icons.delete),
                                          color: Colors.red,
                                          onPressed: () => _eliminar(i),
                                        ),
                                      ),
                                    ],
                                  )
                              ],
                            ),
                          ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Total
              _CardWrap(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('TOTAL', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F766E), // teal 700
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '\$${total.toStringAsFixed(2)}',
                        style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Botones de acción (SIEMPRE en fila de 3 horizontal, responsivo)
              LayoutBuilder(
                builder: (context, c) {
                  return GridView.count(
                    crossAxisCount: 3, // siempre tres por fila
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 3.6,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      _actionBtnModern(
                        icon: Icons.save_outlined,
                        text: 'GUARDAR LOCALMENTE',
                        background: const Color(0xFF6C757D), // gris moderno
                        border: const Color(0xFF495057),
                        onPressed: () => _snack('Guardado localmente', color: Colors.green),
                      ),
                      _actionBtnModern(
                        icon: Icons.cloud_upload_outlined,
                        text: 'GUARDAR',
                        background: const Color(0xFF1E3A8A), // indigo 900
                        border: const Color(0xFF1D4ED8), // indigo 700
                        onPressed: () => _snack('Guardado en servidor (demo)', color: Colors.blueGrey),
                      ),
                      _actionBtnModern(
                        icon: Icons.print_outlined,
                        text: 'IMPRIMIR',
                        background: const Color(0xFF0F766E), // teal 700
                        border: const Color(0xFF115E59), // teal 800
                        onPressed: () => _snack('Enviando a impresión (demo)', color: Colors.teal),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ------- Widgets auxiliares -------

  InputDecoration _inputDeco({
    required String label,
    required IconData icon,
    Widget? trailing,
  }) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      suffixIcon: trailing,
      filled: true,
      fillColor: const Color(0xFFF6F7FB),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFD8DFEA)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF1E3A8A), width: 1.6),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    );
  }

  Widget _dropdown({
    required String label,
    required IconData icon,
    required String? value,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: const Color(0xFFF6F7FB),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFD8DFEA)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF1E3A8A), width: 1.6),
        ),
      ),
      isExpanded: true,
      items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
      onChanged: onChanged,
    );
  }

  // Botón primario (para "Agregar")
  Widget _primaryButton({
    required IconData icon,
    required String text,
    required Color background,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 20),
      label: Text(text),
      style: ElevatedButton.styleFrom(
        backgroundColor: background,
        foregroundColor: Colors.white,
        elevation: 3,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        shadowColor: Colors.black.withOpacity(0.25),
      ),
    );
  }

  // Botones de acción con diseño moderno (fila de 3)
  Widget _actionBtnModern({
    required IconData icon,
    required String text,
    required Color background,
    required Color border,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: background,
        foregroundColor: Colors.white,
        elevation: 4,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: border, width: 1.2),
        ),
        shadowColor: Colors.black.withOpacity(0.25),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w700, letterSpacing: 0.3),
            ),
          ),
        ],
      ),
    );
  }
}

// --------- Secciones visuales ---------

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final Color a = const Color(0xFF0D1B2A);
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: a,
          ),
          child: const Icon(Icons.local_shipping_rounded, color: Colors.white, size: 26),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Text(
            'Embarques',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
          ),
        ),
        const CircleAvatar(
          radius: 18,
          child: Icon(Icons.person_outline),
        ),
        const SizedBox(width: 8),
        const Text('Hola Arturo', style: TextStyle(fontWeight: FontWeight.w600)),
      ],
    );
  }
}

class _CardWrap extends StatelessWidget {
  final Widget child;
  const _CardWrap({required this.child});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(padding: const EdgeInsets.all(16), child: child),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(text, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700));
  }
}
