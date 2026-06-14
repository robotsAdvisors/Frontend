import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/models/product_model.dart';
import '../../../data/services/auth_service.dart';
import '../../../routes/app_pages.dart';
import '../controllers/admin_controller.dart';

class InventarioView extends StatefulWidget {
  const InventarioView({super.key});

  @override
  State<InventarioView> createState() => _InventarioViewState();
}

class _InventarioViewState extends State<InventarioView> {
  static const Color _purple      = Color(0xFF7C3AED);
  static const Color _purpleLight = Color(0xFFEDE9FE);
  static const Color _bg          = Color(0xFFF8F7FF);
  static const Color _dark        = Color(0xFF1E1B4B);
  static const Color _border      = Color(0xFFEEEEEE);
  static const Color _green       = Color(0xFF10B981);
  static const Color _amber       = Color(0xFFF59E0B);
  static const Color _red         = Color(0xFFEF4444);
  static const Color _blue        = Color(0xFF3B82F6);

  static const TextStyle _hdrStyle = TextStyle(
      fontSize: 10, fontWeight: FontWeight.w700,
      color: Colors.grey, letterSpacing: 0.5);

  late final AdminController _ctrl;
  final _searchCtrl = TextEditingController();
  Timer? _searchDebounce;

  String _statusFilter = 'all';
  String _sortOrder    = 'name';

  @override
  void initState() {
    super.initState();
    _ctrl = Get.find<AdminController>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _ctrl.loadInventoryPage(page: 1);
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _searchDebounce?.cancel();
    super.dispose();
  }

  void _onSearch(String q) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 400), () {
      _ctrl.loadInventoryPage(page: 1, search: q, ordering: _sortOrder);
    });
  }

  void _reload() {
    _ctrl.loadInventoryPage(
        page: 1,
        search: _searchCtrl.text.trim(),
        ordering: _sortOrder);
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 900;
    if (isDesktop) {
      return Scaffold(
        backgroundColor: _bg,
        body: Row(children: [
          _sidebar(context),
          Expanded(child: _body(context)),
        ]),
      );
    }
    return Scaffold(
      backgroundColor: _bg,
      drawer: Drawer(child: SafeArea(child: _sidebar(context))),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: _dark),
        title: const Text('Productos', style: TextStyle(color: _dark, fontSize: 16, fontWeight: FontWeight.w700)),
      ),
      body: _body(context),
    );
  }

  // ─── SIDEBAR ──────────────────────────────────────────────────────────────

  Widget _sidebar(BuildContext context) {
    return Container(
      width: 220,
      color: Colors.white,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
          child: Row(children: [
            Container(
              width: 32, height: 32,
              decoration: BoxDecoration(
                  color: _purple, borderRadius: BorderRadius.circular(8)),
              child: const Icon(Icons.shield_outlined, size: 17, color: Colors.white),
            ),
            const SizedBox(width: 10),
            const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('LetDem', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: _dark)),
              Text('Admin Tienda', style: TextStyle(fontSize: 10, color: Colors.grey)),
            ]),
          ]),
        ),
        Container(height: 1, color: _border),
        const SizedBox(height: 8),
        _navItem(icon: Icons.grid_view_outlined,    label: 'Inicio',
            onTap: () => Get.offAllNamed(Routes.ADMIN)),
        _navItem(icon: Icons.group_outlined,         label: 'Equipo',
            onTap: () => Get.toNamed(Routes.EMPLEADOS)),
        _navItem(icon: Icons.receipt_outlined,       label: 'Pedidos',
            onTap: () => Get.toNamed(Routes.CONFIRMAR_ENTREGA)),
        _navItem(icon: Icons.inventory_2_outlined,   label: 'Productos', selected: true),
        _navItem(icon: Icons.badge_outlined,         label: 'Empleados',
            onTap: () => Get.toNamed(Routes.EMPLEADOS)),
        _navItem(icon: Icons.security_outlined,      label: 'Seguridad',
            onTap: () => Get.toNamed(Routes.SEGURIDAD)),
        _navItem(icon: Icons.settings_outlined,      label: 'Configuraciones',
            onTap: () => Get.toNamed(Routes.ADMIN_SETTINGS)),
        const Spacer(),
        Container(height: 1, color: _border),
        ListTile(
          dense: true,
          leading: const Icon(Icons.logout, size: 18, color: Colors.grey),
          title: const Text('Cerrar Sesión', style: TextStyle(fontSize: 13, color: Colors.grey)),
          onTap: () async {
            await AuthService.signOut();
            Get.offAllNamed(Routes.LOGIN);
          },
        ),
        const SizedBox(height: 8),
      ]),
    );
  }

  Widget _navItem({
    required IconData icon,
    required String label,
    bool selected = false,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.fromLTRB(12, 2, 12, 2),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        decoration: BoxDecoration(
          color: selected ? _purpleLight : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(children: [
          Icon(icon, size: 17, color: selected ? _purple : Colors.grey.shade500),
          const SizedBox(width: 10),
          Text(label, style: TextStyle(
            fontSize: 13,
            fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
            color: selected ? _purple : Colors.grey.shade700,
          )),
        ]),
      ),
    );
  }

  // ─── BODY ─────────────────────────────────────────────────────────────────

  Widget _body(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(28, 28, 28, 28),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _header(context),
        const SizedBox(height: 24),
        _statsRow(),
        const SizedBox(height: 20),
        _filters(),
        const SizedBox(height: 16),
        _productsTable(context),
        const SizedBox(height: 20),
        _pagination(),
      ]),
    );
  }

  // ─── HEADER ───────────────────────────────────────────────────────────────

  Widget _header(BuildContext context) {
    return Row(children: [
      Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Text('Gestión de productos y estados',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: _dark)),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                  color: _purpleLight, borderRadius: BorderRadius.circular(20)),
              child: const Text('ADMIN TIENDA',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: _purple)),
            ),
          ]),
          const SizedBox(height: 4),
          const Text(
              'Escanea y controla, crea y publica usando el panel de productos de la tienda',
              style: TextStyle(fontSize: 13, color: Colors.grey)),
        ]),
      ),
      const SizedBox(width: 16),
      ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: _purple, foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        icon: const Icon(Icons.add, size: 18),
        label: const Text('Añadir producto',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        onPressed: () => Get.toNamed(Routes.ADD_PRODUCT),
      ),
    ]);
  }

  // ─── STATS ────────────────────────────────────────────────────────────────

  Widget _statsRow() {
    return Obx(() {
      final stats = _ctrl.inventoryStats.value;
      final total      = stats['total']      ?? _ctrl.totalProducts.value;
      final inStock    = stats['in_stock']   ?? _ctrl.totalStock.value;
      final pending    = stats['pending']    ?? 0;
      final categories = _ctrl.categories.length;
      return Row(children: [
        Expanded(child: _statCard(
          icon: Icons.inventory_2_outlined, color: _purple, iconBg: _purpleLight,
          label: 'Productos', value: '$total',
        )),
        const SizedBox(width: 12),
        Expanded(child: _statCard(
          icon: Icons.check_circle_outline, color: _blue, iconBg: const Color(0xFFEFF6FF),
          label: 'En stock', value: '$inStock',
        )),
        const SizedBox(width: 12),
        Expanded(child: _statCard(
          icon: Icons.schedule_outlined, color: _amber, iconBg: const Color(0xFFFFFBEB),
          label: 'Pendientes', value: '$pending',
        )),
        const SizedBox(width: 12),
        Expanded(child: _statCard(
          icon: Icons.category_outlined, color: _green, iconBg: const Color(0xFFECFDF5),
          label: 'Categorías', value: '$categories',
        )),
      ]);
    });
  }

  Widget _statCard({
    required IconData icon, required Color color, required Color iconBg,
    required String label, required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _border),
      ),
      child: Row(children: [
        Container(
          width: 38, height: 38,
          decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, size: 18, color: color),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: color)),
            Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
          ],
        )),
      ]),
    );
  }

  // ─── FILTERS ──────────────────────────────────────────────────────────────

  Widget _filters() {
    return Row(children: [
      Expanded(
        child: TextField(
          controller: _searchCtrl,
          onChanged: _onSearch,
          decoration: InputDecoration(
            hintText: 'Buscar producto...',
            hintStyle: const TextStyle(fontSize: 13, color: Colors.grey),
            prefixIcon: const Icon(Icons.search, size: 18, color: Colors.grey),
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(vertical: 10),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: _border)),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: _border)),
          ),
        ),
      ),
      const SizedBox(width: 12),
      _filterChip('Todos',     'all'),
      const SizedBox(width: 6),
      _filterChip('Activos',   'active'),
      const SizedBox(width: 6),
      _filterChip('Pausados',  'paused'),
      const SizedBox(width: 6),
      _filterChip('Sin stock', 'no_stock'),
      const SizedBox(width: 12),
      _sortDropdown(),
    ]);
  }

  Widget _filterChip(String label, String value) {
    final selected = _statusFilter == value;
    return GestureDetector(
      onTap: () {
        setState(() => _statusFilter = value);
        _reload();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? _purple : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: selected ? _purple : _border),
        ),
        child: Text(label, style: TextStyle(
            fontSize: 12,
            fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
            color: selected ? Colors.white : Colors.grey.shade700)),
      ),
    );
  }

  Widget _sortDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _sortOrder,
          isDense: true,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
          items: const [
            DropdownMenuItem(value: 'name',   child: Text('Nombre A-Z')),
            DropdownMenuItem(value: '-name',  child: Text('Nombre Z-A')),
            DropdownMenuItem(value: 'stock',  child: Text('Stock ↑')),
            DropdownMenuItem(value: '-stock', child: Text('Stock ↓')),
            DropdownMenuItem(value: 'price',  child: Text('Precio ↑')),
            DropdownMenuItem(value: '-price', child: Text('Precio ↓')),
          ],
          onChanged: (v) {
            if (v == null) return;
            setState(() => _sortOrder = v);
            _reload();
          },
        ),
      ),
    );
  }

  // ─── TABLE ────────────────────────────────────────────────────────────────

  Widget _productsTable(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _border),
      ),
      child: Column(children: [
        // Table header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: const BoxDecoration(
            color: Color(0xFFFAFAFB),
            borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
          ),
          child: const Row(children: [
            SizedBox(width: 48),
            SizedBox(width: 12),
            Expanded(flex: 4, child: Text('PRODUCTO', style: _hdrStyle)),
            Expanded(flex: 2, child: Text('TIPO',     style: _hdrStyle)),
            Expanded(flex: 2, child: Text('STOCK',    style: _hdrStyle)),
            Expanded(flex: 2, child: Text('VENTAS',   style: _hdrStyle)),
            Expanded(flex: 2, child: Text('ESTADO',   style: _hdrStyle)),
            SizedBox(width: 80, child: Text('ACCIÓN',  style: _hdrStyle, textAlign: TextAlign.center)),
          ]),
        ),
        Container(height: 1, color: _border),
        Obx(() {
          if (_ctrl.isLoadingInventory.value) {
            return const Padding(
              padding: EdgeInsets.all(40),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          final all = _ctrl.inventoryProducts;
          final products = _statusFilter == 'all'
              ? all
              : all.where((p) {
                  return switch (_statusFilter) {
                    'active'   => p.isPublished && p.stock > 0,
                    'paused'   => !p.isPublished,
                    'no_stock' => p.stock == 0,
                    _          => true,
                  };
                }).toList();
          if (products.isEmpty) {
            return const Padding(
              padding: EdgeInsets.all(40),
              child: Center(child: Text('Sin productos',
                  style: TextStyle(fontSize: 13, color: Colors.grey))),
            );
          }
          return Column(
            children: products.asMap().entries
                .map((e) => _productRow(context, e.value, e.key.isEven))
                .toList(),
          );
        }),
      ]),
    );
  }

  Widget _productRow(BuildContext context, ProductModel p, bool even) {
    final statusData = _statusBadge(p);
    return Container(
      color: even ? Colors.white : const Color(0xFFFAFAFB),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(children: [
        // Thumbnail
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: p.image.isNotEmpty
              ? Image.network(p.image, width: 48, height: 48, fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _imgPlaceholder())
              : _imgPlaceholder(),
        ),
        const SizedBox(width: 12),
        // Producto
        Expanded(flex: 4, child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(p.name,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                overflow: TextOverflow.ellipsis),
            if (p.sku.isNotEmpty)
              Text(p.sku, style: const TextStyle(fontSize: 10, color: Colors.grey)),
          ],
        )),
        // TIPO — campo `type` del backend
        Expanded(flex: 2, child: _typeBadge(p.type)),
        // STOCK
        Expanded(flex: 2, child: _stockBadge(p.stock)),
        // VENTAS — campo `sales_count` anotado por el backend
        Expanded(flex: 2, child: Text('${p.salesCount}',
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600))),
        // ESTADO
        Expanded(flex: 2, child: _badge(
            statusData.$1, statusData.$2, statusData.$3)),
        // ACCIÓN
        SizedBox(
          width: 80,
          child: Center(child: _actionBtn(
            'Editar',
            () => Get.toNamed(Routes.ADD_PRODUCT, arguments: p),
          )),
        ),
      ]),
    );
  }

  Widget _imgPlaceholder() {
    return Container(
      width: 48, height: 48,
      decoration: BoxDecoration(
          color: _purpleLight, borderRadius: BorderRadius.circular(8)),
      child: const Icon(Icons.image_outlined, size: 20, color: _purple),
    );
  }

  Widget _typeBadge(String type) {
    final (label, color, bg) = switch (type.toLowerCase()) {
      'beneficio' => ('Beneficio', _purple, _purpleLight),
      'carta'     => ('Carta',     _blue,   const Color(0xFFEFF6FF)),
      _           => ('Descuento', _amber,  const Color(0xFFFFFBEB)),
    };
    return _badge(label, color, bg);
  }

  Widget _stockBadge(int stock) {
    Color color;
    Color bg;
    if (stock == 0) {
      color = Colors.grey.shade600; bg = const Color(0xFFF5F5F5);
    } else if (stock < 5) {
      color = _red; bg = const Color(0xFFFEF2F2);
    } else if (stock < 20) {
      color = _amber; bg = const Color(0xFFFFFBEB);
    } else {
      color = _green; bg = const Color(0xFFECFDF5);
    }
    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
        child: Text('$stock uds',
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: color)),
      ),
    );
  }

  (String, Color, Color) _statusBadge(ProductModel p) {
    if (p.stock == 0) return ('Sin stock', Colors.grey.shade600, const Color(0xFFF5F5F5));
    if (!p.isPublished) return ('Pausado', _amber, const Color(0xFFFFFBEB));
    return ('Activo', _green, const Color(0xFFECFDF5));
  }

  Widget _badge(String label, Color color, Color bg) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
        child: Text(label,
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: color)),
      ),
    );
  }

  Widget _actionBtn(String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: _purpleLight,
          borderRadius: BorderRadius.circular(7),
          border: Border.all(color: _purple.withValues(alpha: 0.3)),
        ),
        child: Text(label,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: _purple)),
      ),
    );
  }

  // ─── PAGINATION ───────────────────────────────────────────────────────────

  Widget _pagination() {
    return Obx(() {
      final meta = _ctrl.inventoryMeta.value;
      if (meta.lastPage <= 1) return const SizedBox.shrink();
      final current = _ctrl.inventoryCurrentPage.value;
      return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: current > 1
              ? () => _ctrl.loadInventoryPage(page: current - 1, ordering: _sortOrder)
              : null,
        ),
        Text('Página $current de ${meta.lastPage}',
            style: const TextStyle(fontSize: 13, color: Colors.grey)),
        IconButton(
          icon: const Icon(Icons.chevron_right),
          onPressed: current < meta.lastPage
              ? () => _ctrl.loadInventoryPage(page: current + 1, ordering: _sortOrder)
              : null,
        ),
      ]);
    });
  }
}
