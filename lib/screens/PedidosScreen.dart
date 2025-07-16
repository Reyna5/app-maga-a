import 'package:flutter/material.dart';

class PedidosScreen extends StatefulWidget {
  final List<Map<String, dynamic>> pedidos; // Pasar aquí la lista de pedidos creados

  const PedidosScreen({super.key, required this.pedidos});

  @override
  State<PedidosScreen> createState() => _PedidosScreenState();
}

class _PedidosScreenState extends State<PedidosScreen> {
  // Filtros
  String? almacenFiltro;
  String? clienteFiltro;
  String? unidadFiltro;
  String textoBusqueda = '';

  List<String> get almacenes {
    final set = <String>{};
    for (var p in widget.pedidos) {
      if (p['almacen'] != null) set.add(p['almacen']);
    }
    return set.toList();
  }

  List<String> get clientes {
    final set = <String>{};
    for (var p in widget.pedidos) {
      if (p['cliente'] != null) set.add(p['cliente']);
    }
    return set.toList();
  }

  List<String> get unidades {
    final set = <String>{};
    for (var p in widget.pedidos) {
      if (p['unidad'] != null) set.add(p['unidad']);
    }
    return set.toList();
  }

  List<Map<String, dynamic>> get pedidosFiltrados {
    return widget.pedidos.where((pedido) {
      final matchAlmacen = almacenFiltro == null || almacenFiltro!.isEmpty || pedido['almacen'] == almacenFiltro;
      final matchCliente = clienteFiltro == null || clienteFiltro!.isEmpty || pedido['cliente'] == clienteFiltro;
      final matchUnidad = unidadFiltro == null || unidadFiltro!.isEmpty || pedido['unidad'] == unidadFiltro;
      final matchTexto = textoBusqueda.isEmpty ||
          pedido['id'].toString().toLowerCase().contains(textoBusqueda.toLowerCase()) ||
          (pedido['cliente']?.toLowerCase().contains(textoBusqueda.toLowerCase()) ?? false);
      return matchAlmacen && matchCliente && matchUnidad && matchTexto;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFECF0F1),
      body: SafeArea(
        child: Column(
          children: [
            // Filtros
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: almacenFiltro,
                          decoration: InputDecoration(
                            labelText: 'Almacén',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          items: almacenes.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                          onChanged: (v) => setState(() => almacenFiltro = v),
                          isExpanded: true,
                          hint: const Text('Todos'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: clienteFiltro,
                          decoration: InputDecoration(
                            labelText: 'Cliente',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          items: clientes.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                          onChanged: (v) => setState(() => clienteFiltro = v),
                          isExpanded: true,
                          hint: const Text('Todos'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: unidadFiltro,
                          decoration: InputDecoration(
                            labelText: 'Unidad',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          items: unidades.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                          onChanged: (v) => setState(() => unidadFiltro = v),
                          isExpanded: true,
                          hint: const Text('Todas'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        flex: 2,
                        child: SizedBox(
                          height: 48,
                          child: TextField(
                            decoration: InputDecoration(
                              labelText: 'Buscar Pedido',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                              suffixIcon: const Icon(Icons.search),
                            ),
                            onChanged: (v) => setState(() => textoBusqueda = v),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Tabla de pedidos
            Expanded(
              child: pedidosFiltrados.isEmpty
                  ? const Center(
                      child: Text('No hay pedidos registrados',
                          style: TextStyle(fontSize: 18, color: Colors.grey)),
                    )
                  : SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        headingRowColor: MaterialStateColor.resolveWith((states) => const Color(0xFFE0E0E0)),
                        columns: const [
                          DataColumn(label: Text('ID', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Cliente', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Almacén', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Unidad', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Fecha', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Estado', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Total', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Cantidad', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Producto', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Unidad', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('P. Unitario', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Stock', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Acciones', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Ver')),
                        ],
                        rows: pedidosFiltrados.map((pedido) {
                          return DataRow(
                            cells: [
                              DataCell(Text(pedido['id'].toString())),
                              DataCell(Text(pedido['cliente'] ?? '')),
                              DataCell(Text(pedido['almacen'] ?? '')),
                              DataCell(Text(pedido['unidad'] ?? '')),
                              DataCell(Text(pedido['fecha'] ?? '')),
                              DataCell(
                                Chip(
                                  label: Text(
                                    pedido['estado'] ?? '',
                                    style: TextStyle(
                                      color: pedido['estado'] == 'Completado'
                                          ? Colors.green[800]
                                          : Colors.orange[800],
                                    ),
                                  ),
                                  backgroundColor: pedido['estado'] == 'Completado'
                                      ? Colors.green[100]
                                      : Colors.orange[100],
                                ),
                              ),
                              DataCell(Text('\$${pedido['total']?.toStringAsFixed(2) ?? '0.00'}')),
                              // Nuevas celdas para productos
                              DataCell(Text(pedido['productos']?[0]['cantidad']?.toString() ?? '')),
                              DataCell(Text(pedido['productos']?[0]['nombre'] ?? '')),
                              DataCell(Text(pedido['unidad'] ?? '')),
                              DataCell(Text('\$${pedido['productos']?[0]['precio']?.toStringAsFixed(2) ?? '0.00'}')),
                              DataCell(Text(pedido['productos']?[0]['stock']?.toString() ?? '')),
                              DataCell(
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.blue),
                                  onPressed: () {
                                    // Acción de editar
                                  },
                                ),
                              ),
                              DataCell(
                                IconButton(
                                  icon: const Icon(Icons.remove_red_eye, color: Color(0xFF2C3E50)),
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: const Text('Detalle del Pedido'),
                                        content: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            ...((pedido['productos'] as List)
                                                .map((prod) => ListTile(
                                                      title: Text(prod['nombre']),
                                                      subtitle: Text('Cantidad: ${prod['cantidad']} - Unidad: ${pedido['unidad'] ?? ''}'),
                                                      trailing: Text('\$${prod['precio']?.toStringAsFixed(2) ?? '0.00'}'),
                                                    ))
                                                .toList()),
                                            const Divider(),
                                            Align(
                                              alignment: Alignment.centerRight,
                                              child: Text('Total: \$${pedido['total']?.toStringAsFixed(2) ?? '0.00'}',
                                                style: const TextStyle(fontWeight: FontWeight.bold)),
                                            ),
                                          ],
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.pop(context),
                                            child: const Text('Cerrar'),
                                          )
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}