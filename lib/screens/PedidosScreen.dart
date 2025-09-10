import 'package:flutter/material.dart';

class PedidosScreen extends StatefulWidget {
  final List<Map<String, dynamic>> pedidos;

  const PedidosScreen({Key? key, required this.pedidos}) : super(key: key);

  @override
  State<PedidosScreen> createState() => _PedidosScreenState();
}

class _PedidosScreenState extends State<PedidosScreen> {
  String? almacenFiltro = '';
  String? clienteFiltro = '';
  String? unidadFiltro = '';
  String textoBusqueda = '';

  List<String> get almacenes => {
        for (var p in widget.pedidos)
          if (p['almacen'] != null) p['almacen'].toString()
      }.toList();

  List<String> get clientes => {
        for (var p in widget.pedidos)
          if (p['cliente'] != null) p['cliente'].toString()
      }.toList();

  List<String> get unidades => {
        for (var p in widget.pedidos)
          if (p['unidad'] != null) p['unidad'].toString()
      }.toList();

  List<Map<String, dynamic>> get pedidosFiltrados {
    return widget.pedidos.where((pedido) {
      final matchAlmacen = almacenFiltro == null || almacenFiltro!.isEmpty || pedido['almacen'] == almacenFiltro;
      final matchCliente = clienteFiltro == null || clienteFiltro!.isEmpty || pedido['cliente'] == clienteFiltro;
      final matchUnidad = unidadFiltro == null || unidadFiltro!.isEmpty || pedido['unidad'] == unidadFiltro;
      final matchTexto = textoBusqueda.isEmpty ||
          pedido['id'].toString().toLowerCase().contains(textoBusqueda.toLowerCase()) ||
          (pedido['cliente']?.toString().toLowerCase().contains(textoBusqueda.toLowerCase()) ?? false);
      return matchAlmacen && matchCliente && matchUnidad && matchTexto;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFECF0F1),
      appBar: AppBar(
        title: const Text('📦 Lista de Pedidos'),
        backgroundColor: const Color(0xFF2C3E50),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: almacenFiltro,
                          decoration: _inputDeco('Almacén'),
                          items: [
                            const DropdownMenuItem(value: '', child: Text('Todos')),
                            ...almacenes.map((e) => DropdownMenuItem(value: e, child: Text(e))),
                          ],
                          onChanged: (v) => setState(() => almacenFiltro = v),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: clienteFiltro,
                          decoration: _inputDeco('Cliente'),
                          items: [
                            const DropdownMenuItem(value: '', child: Text('Todos')),
                            ...clientes.map((e) => DropdownMenuItem(value: e, child: Text(e))),
                          ],
                          onChanged: (v) => setState(() => clienteFiltro = v),
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
                          decoration: _inputDeco('Unidad'),
                          items: [
                            const DropdownMenuItem(value: '', child: Text('Todas')),
                            ...unidades.map((e) => DropdownMenuItem(value: e, child: Text(e))),
                          ],
                          onChanged: (v) => setState(() => unidadFiltro = v),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        flex: 2,
                        child: TextField(
                          decoration: InputDecoration(
                            labelText: 'Buscar pedido',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            suffixIcon: const Icon(Icons.search),
                          ),
                          onChanged: (v) => setState(() => textoBusqueda = v),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: pedidosFiltrados.isEmpty
                  ? const Center(child: Text('No se encontraron pedidos', style: TextStyle(fontSize: 18, color: Colors.grey)))
                  : SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        columnSpacing: 20,
                        dataRowMinHeight: 60,
                        headingRowColor: MaterialStateColor.resolveWith((states) => const Color(0xFF2C3E50)),
                        headingTextStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        columns: const [
                          DataColumn(label: Text('ID')),
                          DataColumn(label: Text('Cliente')),
                          DataColumn(label: Text('Almacén')),
                          DataColumn(label: Text('Unidad')),
                          DataColumn(label: Text('Fecha')),
                          DataColumn(label: Text('Estado')),
                          DataColumn(label: Text('Total')),
                          DataColumn(label: Text('Productos')),
                          DataColumn(label: Text('Acciones')),
                        ],
                        rows: pedidosFiltrados.map((pedido) {
                          return DataRow(cells: [
                            DataCell(Center(child: Text(pedido['id'].toString()))),
                            DataCell(Text(pedido['cliente'] ?? 'N/A')),
                            DataCell(Text(pedido['almacen'] ?? 'N/A')),
                            DataCell(Text(pedido['unidad'] ?? 'N/A')),
                            DataCell(Text(pedido['fecha'] ?? 'N/A')),
                            DataCell(
                              Chip(
                                label: Text(
                                  pedido['estado'] ?? 'N/A',
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
                            DataCell(Text('${(pedido['productos'] as List?)?.length ?? 0} productos',
                                style: const TextStyle(color: Colors.blue))),
                            DataCell(
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit, color: Colors.blue),
                                    onPressed: () {},
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.remove_red_eye, color: Colors.green),
                                    onPressed: () => _mostrarDetallePedido(context, pedido),
                                  ),
                                ],
                              ),
                            ),
                          ]);
                        }).toList(),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDeco(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
    );
  }

  void _mostrarDetallePedido(BuildContext context, Map<String, dynamic> pedido) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Pedido #${pedido['id']}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoRow('Cliente:', pedido['cliente']),
              _buildInfoRow('Almacén:', pedido['almacen']),
              _buildInfoRow('Unidad:', pedido['unidad']),
              _buildInfoRow('Fecha:', pedido['fecha']),
              _buildInfoRow('Estado:', pedido['estado']),
              const SizedBox(height: 10),
              const Text('Productos:', style: TextStyle(fontWeight: FontWeight.bold)),
              const Divider(),
              ...(pedido['productos'] as List? ?? []).map((p) {
                final total = (p['cantidad'] ?? 0) * (p['precio'] ?? 0);
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Expanded(flex: 3, child: Text(p['nombre'] ?? 'Producto')),
                      Expanded(child: Text('${p['cantidad']} x')),
                      Expanded(child: Text('\$${(p['precio'] ?? 0).toStringAsFixed(2)}')),
                      Expanded(child: Text('\$${total.toStringAsFixed(2)}', textAlign: TextAlign.end)),
                    ],
                  ),
                );
              }),
              const Divider(),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'Total: \$${pedido['total']?.toStringAsFixed(2) ?? '0.00'}',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cerrar')),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(width: 8),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
