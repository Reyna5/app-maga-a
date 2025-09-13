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

  // Controladores para scroll responsivo
  final ScrollController _tableHCtrl = ScrollController();
  final ScrollController _dialogTableHCtrl = ScrollController();

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
      final matchAlmacen =
          almacenFiltro == null || almacenFiltro!.isEmpty || pedido['almacen'] == almacenFiltro;
      final matchCliente =
          clienteFiltro == null || clienteFiltro!.isEmpty || pedido['cliente'] == clienteFiltro;
      final matchUnidad =
          unidadFiltro == null || unidadFiltro!.isEmpty || pedido['unidad'] == unidadFiltro;
      final matchTexto = textoBusqueda.isEmpty ||
          pedido['id'].toString().toLowerCase().contains(textoBusqueda.toLowerCase()) ||
          (pedido['cliente']?.toString().toLowerCase().contains(textoBusqueda.toLowerCase()) ?? false);
      return matchAlmacen && matchCliente && matchUnidad && matchTexto;
    }).toList();
  }

  @override
  void dispose() {
    _tableHCtrl.dispose();
    _dialogTableHCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter, end: Alignment.bottomCenter,
            colors: [Color(0xFFF6F8FB), Color(0xFFE9EDF3)],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final double w = constraints.maxWidth;
              final bool isSmall = w < 700;
              final bool isMedium = w >= 700 && w < 1100;
              final double fieldWidth =
                  isSmall ? w : (isMedium ? (w - 64) / 2 : (w - 96) / 3);

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Título moderno (igual al de Embarque)
                  const Padding(
                    padding: EdgeInsets.fromLTRB(16, 12, 16, 0),
                    child: _HeaderTitlePedidos(),
                  ),
                  const SizedBox(height: 12),

                  // FILTROS + BÚSQUEDA
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _CardWrap(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Wrap(
                            spacing: 16,
                            runSpacing: 12,
                            children: [
                              SizedBox(
                                width: fieldWidth,
                                child: _buildFilterDropdown(
                                  value: almacenFiltro,
                                  items: almacenes,
                                  hint: 'Todos los almacenes',
                                  label: 'Almacén',
                                  icon: Icons.store_mall_directory_outlined,
                                  onChanged: (v) => setState(() => almacenFiltro = v),
                                ),
                              ),
                              SizedBox(
                                width: fieldWidth,
                                child: _buildFilterDropdown(
                                  value: clienteFiltro,
                                  items: clientes,
                                  hint: 'Todos los clientes',
                                  label: 'Cliente',
                                  icon: Icons.person_outline,
                                  onChanged: (v) => setState(() => clienteFiltro = v),
                                ),
                              ),
                              SizedBox(
                                width: fieldWidth,
                                child: _buildFilterDropdown(
                                  value: unidadFiltro,
                                  items: unidades,
                                  hint: 'Todas las unidades',
                                  label: 'Unidad',
                                  icon: Icons.local_shipping_outlined,
                                  onChanged: (v) => setState(() => unidadFiltro = v),
                                ),
                              ),
                              SizedBox(
                                width: isSmall ? w : (isMedium ? fieldWidth * 2 + 16 : fieldWidth * 3 + 32),
                                child: TextField(
                                  decoration: InputDecoration(
                                    labelText: 'Buscar pedido',
                                    hintText: 'ID o nombre de cliente...',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: const BorderSide(color: Color(0xFF3B82F6)),
                                    ),
                                    filled: true,
                                    fillColor: const Color(0xFFF8FAFC),
                                    prefixIcon: const Icon(Icons.search, color: Color(0xFF64748B)),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                  ),
                                  onChanged: (v) => setState(() => textoBusqueda = v),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  // RESUMEN + LIMPIAR
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            '${pedidosFiltrados.length} pedido${pedidosFiltrados.length != 1 ? 's' : ''} encontrado${pedidosFiltrados.length != 1 ? 's' : ''}',
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Color(0xFF64748B),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        if ((almacenFiltro ?? '').isNotEmpty ||
                            (clienteFiltro ?? '').isNotEmpty ||
                            (unidadFiltro ?? '').isNotEmpty ||
                            textoBusqueda.isNotEmpty)
                          TextButton.icon(
                            onPressed: () {
                              setState(() {
                                almacenFiltro = '';
                                clienteFiltro = '';
                                unidadFiltro = '';
                                textoBusqueda = '';
                              });
                            },
                            icon: const Icon(Icons.clear, size: 16),
                            label: const Text('Limpiar filtros'),
                            style: TextButton.styleFrom(
                              foregroundColor: const Color(0xFF64748B),
                            ),
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 8),

                  // TABLA
                  Expanded(
                    child: pedidosFiltrados.isEmpty
                        ? _buildEmptyState()
                        : Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            child: _CardWrap(
                              child: Scrollbar(
                                controller: _tableHCtrl,
                                thumbVisibility: true,
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  controller: _tableHCtrl,
                                  child: ConstrainedBox(
                                    constraints: BoxConstraints(minWidth: w),
                                    child: DataTable(
                                      columnSpacing: 24,
                                      horizontalMargin: 16,
                                      dataRowMinHeight: 60,
                                      dataRowMaxHeight: 72,
                                      headingRowHeight: 56,
                                      headingRowColor: MaterialStateProperty.resolveWith(
                                          (states) => const Color(0xFFF1F5F9)),
                                      headingTextStyle: const TextStyle(
                                        color: Color(0xFF334155),
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                      ),
                                      columns: const [
                                        DataColumn(label: Text('ID')),
                                        DataColumn(label: Text('Cliente')),
                                        DataColumn(label: Text('Almacén')),
                                        DataColumn(label: Text('Unidad')),
                                        DataColumn(label: Text('Fecha')),
                                        DataColumn(label: Text('Estado')),
                                        DataColumn(label: Text('Total', textAlign: TextAlign.end)),
                                        DataColumn(label: Text('Productos')),
                                        DataColumn(label: Text('Acciones')),
                                      ],
                                      rows: pedidosFiltrados.map((pedido) {
                                        return DataRow(
                                          cells: [
                                            DataCell(
                                              Text(
                                                '#${pedido['id'].toString()}',
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  color: Color(0xFF1E293B),
                                                ),
                                              ),
                                            ),
                                            DataCell(Text(pedido['cliente'] ?? 'N/A')),
                                            DataCell(Text(pedido['almacen'] ?? 'N/A')),
                                            DataCell(Text(pedido['unidad'] ?? 'N/A')),
                                            DataCell(Text(pedido['fecha'] ?? 'N/A')),
                                            DataCell(
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                                decoration: BoxDecoration(
                                                  color: _getEstadoColor(pedido['estado']).withOpacity(0.1),
                                                  borderRadius: BorderRadius.circular(16),
                                                ),
                                                child: Text(
                                                  pedido['estado'] ?? 'N/A',
                                                  style: TextStyle(
                                                    color: _getEstadoColor(pedido['estado']),
                                                    fontWeight: FontWeight.w500,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            DataCell(
                                              Align(
                                                alignment: Alignment.centerRight,
                                                child: Text(
                                                  '\$${(pedido['total'] is num) ? (pedido['total'] as num).toStringAsFixed(2) : '0.00'}',
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                    color: Color(0xFF059669),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            DataCell(
                                              Tooltip(
                                                message: 'Ver productos',
                                                child: Row(
                                                  children: [
                                                    const Icon(Icons.inventory_2, size: 16, color: Color(0xFF3B82F6)),
                                                    const SizedBox(width: 4),
                                                    Text(
                                                      '${(pedido['productos'] as List?)?.length ?? 0}',
                                                      style: const TextStyle(color: Color(0xFF3B82F6)),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            DataCell(
                                              Row(
                                                children: [
                                                  IconButton(
                                                    icon: const Icon(Icons.remove_red_eye, size: 20),
                                                    color: const Color(0xFF3B82F6),
                                                    onPressed: () => _mostrarDetallePedido(context, pedido),
                                                  ),
                                                  IconButton(
                                                    icon: const Icon(Icons.edit, size: 20),
                                                    color: const Color(0xFF059669),
                                                    onPressed: () {},
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
      backgroundColor: const Color(0xFFF8FAFC),
    );
  }

  // ------- Widgets auxiliares -------
  Widget _buildFilterDropdown({
    required String? value,
    required List<String> items,
    required String hint,
    required String label,
    required IconData icon,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Color(0xFF64748B),
          ),
        ),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          value: value,
          isExpanded: true,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            prefixIcon: Icon(icon, size: 20, color: const Color(0xFF64748B)),
          ),
          items: [
            DropdownMenuItem(value: '', child: Text(hint)),
            ...items.map((e) => DropdownMenuItem(value: e, child: Text(e))),
          ],
          onChanged: onChanged,
          style: const TextStyle(fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.inbox, size: 64, color: Color(0xFFCBD5E1)),
            const SizedBox(height: 16),
            const Text(
              'No se encontraron pedidos',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Color(0xFF64748B)),
            ),
            const SizedBox(height: 8),
            const Text(
              'Intenta ajustar los filtros o términos de búsqueda',
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFF94A3B8)),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  almacenFiltro = '';
                  clienteFiltro = '';
                  unidadFiltro = '';
                  textoBusqueda = '';
                });
              },
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Restablecer filtros'),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: const Color(0xFF3B82F6),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getEstadoColor(String? estado) {
    switch (estado) {
      case 'Completado':
        return const Color(0xFF059669);
      case 'Pendiente':
        return const Color(0xFFF59E0B);
      case 'Cancelado':
        return const Color(0xFFEF4444);
      default:
        return const Color(0xFF64748B);
    }
  }

  void _mostrarDetallePedido(BuildContext context, Map<String, dynamic> pedido) {
    final size = MediaQuery.of(context).size;
    showDialog(
      context: context,
      builder: (_) => Dialog(
        insetPadding: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: 720,
            maxHeight: size.height * 0.9,
          ),
          child: Container(
            padding: const EdgeInsets.all(24),
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          'Pedido #${pedido['id']}',
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(height: 1),
                  const SizedBox(height: 16),

                  const Text('INFORMACIÓN DEL PEDIDO',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF64748B))),
                  const SizedBox(height: 12),
                  _buildDetailRow('Cliente:', pedido['cliente'] ?? 'N/A'),
                  _buildDetailRow('Almacén:', pedido['almacen'] ?? 'N/A'),
                  _buildDetailRow('Unidad:', pedido['unidad'] ?? 'N/A'),
                  _buildDetailRow('Fecha:', pedido['fecha'] ?? 'N/A'),
                  _buildDetailRow('Estado:', pedido['estado'] ?? 'N/A',
                      valueStyle: TextStyle(color: _getEstadoColor(pedido['estado']), fontWeight: FontWeight.w500)),

                  const SizedBox(height: 24),
                  const Divider(height: 1),
                  const SizedBox(height: 16),

                  const Text('PRODUCTOS',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF64748B))),
                  const SizedBox(height: 12),

                  // Scroll horizontal para la tabla del diálogo (responsivo)
                  Scrollbar(
                    controller: _dialogTableHCtrl,
                    thumbVisibility: true,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      controller: _dialogTableHCtrl,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(minWidth: 480),
                        child: Table(
                          columnWidths: const {
                            0: FlexColumnWidth(3),
                            1: FlexColumnWidth(1),
                            2: FlexColumnWidth(1.2),
                            3: FlexColumnWidth(1.2),
                          },
                          children: [
                            TableRow(
                              decoration: BoxDecoration(
                                border: Border(bottom: BorderSide(color: Colors.grey)),
                              ),
                              children: const [
                                Padding(
                                  padding: EdgeInsets.only(bottom: 8),
                                  child: Text('Producto', style: TextStyle(fontWeight: FontWeight.w600)),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(bottom: 8),
                                  child: Text('Cantidad', style: TextStyle(fontWeight: FontWeight.w600)),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(bottom: 8),
                                  child: Text('Precio', style: TextStyle(fontWeight: FontWeight.w600)),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(bottom: 8),
                                  child: Text('Total', style: TextStyle(fontWeight: FontWeight.w600), textAlign: TextAlign.right),
                                ),
                              ],
                            ),
                            ...(pedido['productos'] as List? ?? []).map((p) {
                              final cantidad = (p['cantidad'] ?? 0) as num;
                              final precio = (p['precio'] ?? 0) as num;
                              final total = cantidad * precio;
                              return TableRow(
                                decoration: BoxDecoration(
                                  border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
                                ),
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 8),
                                    child: Text(p['nombre']?.toString() ?? 'Producto'),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 8),
                                    child: Text(cantidad.toString()),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 8),
                                    child: Text('\$${precio.toStringAsFixed(2)}'),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 8),
                                    child: Text(
                                      '\$${total.toStringAsFixed(2)}',
                                      textAlign: TextAlign.right,
                                      style: const TextStyle(fontWeight: FontWeight.w500),
                                    ),
                                  ),
                                ],
                              );
                            }).toList(),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),
                  const Divider(height: 1),
                  const SizedBox(height: 16),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('TOTAL:', style: TextStyle(fontWeight: FontWeight.w600)),
                      Text(
                        '\$${(pedido['total'] as num?)?.toStringAsFixed(2) ?? '0.00'}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF059669),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: const Color(0xFF3B82F6),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text('Cerrar', style: TextStyle(fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {TextStyle? valueStyle}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500, color: Color(0xFF64748B)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              style: valueStyle ?? const TextStyle(color: Color(0xFF1E293B)),
            ),
          ),
        ],
      ),
    );
  }
}

// ======= Título moderno (igual estilo que Embarque) =======

class _HeaderTitlePedidos extends StatelessWidget {
  const _HeaderTitlePedidos();

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
          child: const Icon(Icons.assignment_turned_in_rounded,
              color: Colors.white, size: 28),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _GradientText(
                'Pedidos',
                gradient: LinearGradient(colors: [a, b]),
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.2,
                ),
              ),
              Text(
                'Consulta, filtra y gestiona tus pedidos',
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

// ======= Contenedor de tarjeta reutilizable =======

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
