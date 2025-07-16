import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class EmbarqueScreen extends StatefulWidget {
  const EmbarqueScreen({super.key});

  @override
  State<EmbarqueScreen> createState() => _EmbarqueScreenState();
}

class _EmbarqueScreenState extends State<EmbarqueScreen> {
  final List<Map<String, dynamic>> catalogoProductos = [
    {'nombre': 'Manzana', 'precio': 12.50, 'stock': 120},
    {'nombre': 'Banana', 'precio': 9.80, 'stock': 200},
    {'nombre': 'Sandía', 'precio': 30.00, 'stock': 15},
    {'nombre': 'Caja Fresa', 'precio': 50.00, 'stock': 12},
    {'nombre': 'Bulto Naranja', 'precio': 120.00, 'stock': 8},
  ];

  final List<String> almacenes = ['Almacén 1', 'Almacén 2'];
  final List<String> almacenistas = ['Almacenista 1', 'Almacenista 2'];
  final List<String> vendedores = ['Vendedor 1', 'Vendedor 2'];
  final List<String> clientes = ['Cliente 1', 'Cliente 2'];

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

  List<Map<String, dynamic>> productos = [];
  final TextEditingController cantidadController = TextEditingController(text: '1');
  bool isLoadingUnidades = false;

  @override
  void initState() {
    super.initState();
    _cargarUnidades();
  }

  Future<void> _cargarUnidades() async {
    setState(() {
      isLoadingUnidades = true;
    });

    try {
      final response = await http.get(
        Uri.parse('http://192.168.1.50/api_unidades.php'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          unidadesCompletas = List<Map<String, dynamic>>.from(data);
          unidades = data.map<String>((u) => u['unidad'].toString()).toList();
        });
      } else {
        _mostrarError('Error al cargar unidades (código: ${response.statusCode})');
      }
    } catch (e) {
      _mostrarError('Error de conexión: $e');
    } finally {
      setState(() {
        isLoadingUnidades = false;
      });
    }
  }

  void _mostrarError(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _onProductoSelected(String? producto) {
    final prod = catalogoProductos.firstWhere(
      (p) => p['nombre'] == producto,
      orElse: () => {},
    );
    setState(() {
      productoSeleccionado = producto;
      precioSeleccionado = prod['precio'] ?? 0.0;
      stockSeleccionado = prod['stock'] ?? 0;
      cantidadController.text = '1';
    });
  }



  void _agregarProducto() {
    if (productoSeleccionado == null || unidad == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona producto y unidad')),
      );
      return;
    }
    int cantidad = int.tryParse(cantidadController.text) ?? 1;
    if (cantidad < 1) cantidad = 1;

    // Obtener el idunidad correspondiente a la unidad seleccionada
    final unidadData = unidadesCompletas.firstWhere(
      (u) => u['unidad'] == unidad,
      orElse: () => {'idunidad': null},
    );

    productos.add({
      'nombre': productoSeleccionado,
      'unidad': unidad,
      'idunidad': unidadData['idunidad'], // Guardar también el ID para enviar al backend
      'precio': precioSeleccionado,
      'cantidad': cantidad,
      'stock': stockSeleccionado,
    });

    setState(() {
      productoSeleccionado = null;
      precioSeleccionado = null;
      stockSeleccionado = null;
      cantidadController.text = '1';
      unidad = null;
    });
  }

  void _cambiarCantidad(int index, int valor) {
    setState(() {
      productos[index]['cantidad'] += valor;
      if (productos[index]['cantidad'] < 1) {
        productos[index]['cantidad'] = 1;
      }
    });
  }

  void _eliminarProducto(int index) {
    setState(() {
      productos.removeAt(index);
    });
  }

  int get totalCantidad => productos.fold(0, (suma, item) => suma + (item['cantidad'] as int));
  double get sumaTotal => productos.fold(0.0, (suma, item) => suma + (item['cantidad'] * item['precio']));

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFECF0F1), Color(0xFFBDC3C7)],
        ),
      ),
      child: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.all(16),
          child: Card(
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Datos del Embarque',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C3E50)),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  
                  Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: [
                      _buildDropdown(
                        value: almacen,
                        items: almacenes,
                        label: 'Almacén',
                        onChanged: (v) => setState(() => almacen = v),
                        icon: Icons.store,
                      ),
                      _buildDropdown(
                        value: almacenista,
                        items: almacenistas,
                        label: 'Almacenista',
                        onChanged: (v) => setState(() => almacenista = v),
                        icon: Icons.person_outline,
                      ),
                      _buildDropdown(
                        value: vendedor,
                        items: vendedores,
                        label: 'Vendedor',
                        onChanged: (v) => setState(() => vendedor = v),
                        icon: Icons.people_outline,
                      ),
                      _buildDropdown(
                        value: cliente,
                        items: clientes,
                        label: 'Cliente',
                        onChanged: (v) => setState(() => cliente = v),
                        icon: Icons.person,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          const Text(
                            'Agregar Productos',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2C3E50)),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: isLoadingUnidades
                                    ? const Center(child: CircularProgressIndicator())
                                    : _buildDropdown(
                                        value: unidad,
                                        items: unidades,
                                        label: 'Unidad',
                                        onChanged: (v) => setState(() => unidad = v),
                                        icon: Icons.straighten,
                                      ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                flex: 3,
                                child: DropdownButtonFormField<String>(
                                  decoration: InputDecoration(
                                    labelText: 'Producto',
                                    prefixIcon: const Icon(Icons.shopping_basket),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  value: productoSeleccionado,
                                  items: catalogoProductos
                                      .map((prod) => DropdownMenuItem<String>(
                                          value: prod['nombre'], 
                                          child: Text(prod['nombre'])))
                                      .toList(),
                                  onChanged: _onProductoSelected,
                                  isExpanded: true,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: cantidadController,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    labelText: 'Cantidad',
                                    prefixIcon: const Icon(Icons.format_list_numbered),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  'Precio: \$${precioSeleccionado?.toStringAsFixed(2) ?? '0.00'}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF27AE60)),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  'Stock: ${stockSeleccionado ?? '0'}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFFE74C3C)),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              icon: const Icon(Icons.add_circle_outline),
                              label: const Text('AGREGAR PRODUCTO'),
                              onPressed: _agregarProducto,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF2C3E50),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 15),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        children: [
                          const Text(
                            'Productos Seleccionados',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2C3E50)),
                          ),
                          const SizedBox(height: 12),
                          productos.isEmpty
                              ? Container(
                                  padding: const EdgeInsets.all(20),
                                  child: const Column(
                                    children: [
                                      Icon(Icons.remove_shopping_cart,
                                          size: 50, color: Colors.grey),
                                      SizedBox(height: 10),
                                      Text('No hay productos agregados',
                                          style: TextStyle(color: Colors.grey)),
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
                                    rows: productos.asMap().entries.map((entry) {
                                      final i = entry.key;
                                      final item = entry.value;
                                      return DataRow(
                                        cells: [
                                          DataCell(
                                            Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                IconButton(
                                                  icon: const Icon(Icons.remove),
                                                  onPressed: () => _cambiarCantidad(i, -1),
                                                  iconSize: 18,
                                                  color: Colors.red,
                                                ),
                                                Text('${item['cantidad']}'),
                                                IconButton(
                                                  icon: const Icon(Icons.add),
                                                  onPressed: () => _cambiarCantidad(i, 1),
                                                  iconSize: 18,
                                                  color: Colors.green,
                                                ),
                                              ],
                                            ),
                                          ),
                                          DataCell(Text(item['nombre'].toString())),
                                          DataCell(Text(item['unidad'].toString())),
                                          DataCell(Text('\$${item['precio'].toStringAsFixed(2)}')),
                                          DataCell(Text(item['stock'].toString())),
                                          DataCell(
                                            IconButton(
                                              icon: const Icon(Icons.delete),
                                              color: Colors.red,
                                              onPressed: () => _eliminarProducto(i),
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
                  ),
                  const SizedBox(height: 20),
                  
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'TOTAL CANTIDAD:',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
                              ),
                              Text(
                                '$totalCantidad',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF3498DB)),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const Text(
                                'TOTAL IMPORTE:',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
                              ),
                              Text(
                                '\$${sumaTotal.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF27AE60)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  Row(
                    children: [
                      Expanded(
                        child: _buildActionButton(
                          icon: Icons.save,
                          text: 'GUARDAR LOCAL',
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
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildActionButton(
                          icon: Icons.cloud_upload,
                          text: 'GUARDAR',
                          color: const Color(0xFF2C3E50),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Guardado correctamente'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildActionButton(
                          icon: Icons.print,
                          text: 'IMPRIMIR',
                          color: const Color(0xFF16A085),
                          onPressed: () {},
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

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
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      items: items
          .map((item) => DropdownMenuItem(
                value: item,
                child: Text(item),
              ))
          .toList(),
      onChanged: onChanged,
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
        padding: const EdgeInsets.symmetric(vertical: 15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}