import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/models/category_model.dart';
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

  late final AdminController _ctrl;
  final _searchCtrl = TextEditingController();

  String? _filterCategory;
  // 'all' | 'active' | 'paused' | 'no_stock' | 'expired'
  String _statusFilter = 'all';
  // 'name' | '-name' | 'price' | '-price' | 'stock' | '-stock'
  // MISSING ENDPOINT: backend needs ?ordering= support on GET /marketplace/admin/products/
  String _sortOrder = 'name';

  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _ctrl = Get.find<AdminController>();
    _ctrl.loadInventoryPage(page: 1);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String _) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 420), _search);
  }

  void _search() => _ctrl.loadInventoryPage(
        page: 1,
        search: _searchCtrl.text.trim(),
        category: _filterCategory,
        ordering: _sortOrder,
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: Row(children: [
        _sidebar(context),
        Expanded(child: _mainArea(context)),
      ]),
    );
  }

  // ─── SIDEBAR ─────────────────────────────────────────────────────────────────

  Widget _sidebar(BuildContext context) {
    return Container(
      width: 220,
      color: Colors.white,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 20),
          child: Row(children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF7C3AED), Color(0xFF9F67FA)],
                  begin: Alignment.topLeft, end: Alignment.bottomRight),
                borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.store_outlined, color: Colors.white, size: 20)),
            const SizedBox(width: 10),
            Obx(() {
              _ctrl.storeId.value;
              return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(_ctrl.currentStore.name,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800,
                        color: Color(0xFF111827)),
                    maxLines: 1, overflow: TextOverflow.ellipsis),
                const Text('Admin Console',
                    style: TextStyle(fontSize: 10, color: Colors.grey)),
              ]);
            }),
          ]),
        ),
        const Divider(height: 1, color: Color(0xFFF3F4F6)),
        const SizedBox(height: 8),
        _navItem(icon: Icons.dashboard_outlined, label: 'Dashboard',
            onTap: () => Get.offNamed(Routes.ADMIN)),
        _navItem(icon: Icons.grid_view_rounded, label: 'Inventory', selected: true),
        _navItem(icon: Icons.receipt_long_outlined, label: 'Orders',
            onTap: () => Get.offNamed(Routes.VOUCHER_HISTORY)),
        _navItem(icon: Icons.bar_chart_outlined, label: 'Analytics',
            onTap: () => Get.offNamed(Routes.ANALYTICS)),
        _navItem(icon: Icons.card_giftcard_outlined, label: 'Vouchers',
            onTap: () => Get.offNamed(Routes.PREMIOS)),
        const Spacer(),
        const Divider(height: 1, color: Color(0xFFF3F4F6)),
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
          child: SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => Get.toNamed(Routes.ADD_PRODUCT),
              icon: const Icon(Icons.add, size: 16, color: _purple),
              label: const Text('+ Add New Product',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
                      color: _purple)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: _purple),
                padding: const EdgeInsets.symmetric(vertical: 11),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10))),
            ),
          ),
        ),
        ListTile(
          dense: true,
          leading: const Icon(Icons.logout, size: 18, color: Colors.grey),
          title: const Text('Cerrar Sesión',
              style: TextStyle(fontSize: 13, color: Colors.grey)),
          onTap: () => _confirmLogout(context),
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
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? _purpleLight : Colors.transparent,
          borderRadius: BorderRadius.circular(10)),
        child: Row(children: [
          Icon(icon, size: 18,
              color: selected ? _purple : Colors.grey.shade600),
          const SizedBox(width: 10),
          Text(label, style: TextStyle(
            fontSize: 13,
            fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
            color: selected ? _purple : Colors.grey.shade700)),
        ]),
      ),
    );
  }

  // ─── MAIN AREA ───────────────────────────────────────────────────────────────

  Widget _mainArea(BuildContext context) {
    return Column(children: [
      _topBar(),
      Expanded(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(28),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _titleRow(context),
            const SizedBox(height: 20),
            _statCards(),
            const SizedBox(height: 24),
            _productTable(context),
            const SizedBox(height: 16),
            _complianceFooter(),
            const SizedBox(height: 8),
          ]),
        ),
      ),
    ]);
  }

  // ─── TOP BAR ─────────────────────────────────────────────────────────────────

  Widget _topBar() {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 28),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFEEEEEE)))),
      child: Row(children: [
        Expanded(
          child: SizedBox(
            height: 38,
            child: TextField(
              controller: _searchCtrl,
              onChanged: _onSearchChanged,
              onSubmitted: (_) => _search(),
              decoration: InputDecoration(
                hintText: 'Buscar en el inventario...',
                hintStyle: TextStyle(fontSize: 13, color: Colors.grey.shade400),
                prefixIcon: Icon(Icons.search, size: 18, color: Colors.grey.shade400),
                suffixIcon: Obx(() {
                  if (_ctrl.isLoadingInventory.value) {
                    return const Padding(padding: EdgeInsets.all(10),
                        child: SizedBox(width: 16, height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2)));
                  }
                  if (_searchCtrl.text.isNotEmpty) {
                    return IconButton(
                        icon: const Icon(Icons.close, size: 16),
                        onPressed: () { _searchCtrl.clear(); _search(); });
                  }
                  return const SizedBox.shrink();
                }),
                filled: true, fillColor: const Color(0xFFF5F5F5), isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(50),
                    borderSide: BorderSide.none)),
            ),
          ),
        ),
        const SizedBox(width: 20),
        Stack(clipBehavior: Clip.none, children: [
          const Icon(Icons.notifications_outlined, size: 22,
              color: Color(0xFF374151)),
          Positioned(top: -2, right: -2,
              child: Obx(() => _ctrl.pendingCount > 0
                  ? Container(width: 8, height: 8,
                      decoration: const BoxDecoration(
                          color: Colors.orange, shape: BoxShape.circle))
                  : const SizedBox.shrink())),
        ]),
        const SizedBox(width: 16),
        const Icon(Icons.settings_outlined, size: 22, color: Color(0xFF374151)),
        const SizedBox(width: 20),
        Obx(() {
          _ctrl.storeId.value;
          // TODO(backend): use GET /v1/users/me/ → { name, role } instead of store owner
          final name = _ctrl.currentStore.ownerName.isNotEmpty
              ? _ctrl.currentStore.ownerName
              : _ctrl.currentStore.name;
          final initials = name.trim().split(' ')
              .where((w) => w.isNotEmpty).take(2)
              .map((w) => w[0]).join().toUpperCase();
          return Row(children: [
            CircleAvatar(
              radius: 16, backgroundColor: _purpleLight,
              child: Text(initials.isEmpty ? 'A' : initials,
                  style: const TextStyle(fontSize: 11,
                      fontWeight: FontWeight.w700, color: _purple))),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(name.isEmpty ? 'Admin LetDem' : name,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                Text(_formatRole(AuthService.currentUserRole),
                    style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w700,
                        color: _purple, letterSpacing: 0.5)),
              ],
            ),
          ]);
        }),
      ]),
    );
  }

  // ─── TITLE ROW ────────────────────────────────────────────────────────────────

  Widget _titleRow(BuildContext context) {
    return Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
      const Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Gestión de Inventario',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800,
                  color: Color(0xFF111827))),
          SizedBox(height: 4),
          Text(
            'Administra tus productos, controla el stock y define estrategias de canje por puntos o venta directa.',
            style: TextStyle(fontSize: 13, color: Colors.grey)),
        ]),
      ),
      const SizedBox(width: 16),
      Obx(() => OutlinedButton.icon(
        onPressed: _ctrl.isExportingCsv.value ? null : _ctrl.exportInventoryCsv,
        icon: _ctrl.isExportingCsv.value
            ? const SizedBox(width: 14, height: 14,
                child: CircularProgressIndicator(strokeWidth: 2))
            : const Icon(Icons.download_outlined, size: 16,
                color: Color(0xFF374151)),
        label: const Text('Exportar',
            style: TextStyle(fontSize: 13, color: Color(0xFF374151))),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Color(0xFFD1D5DB)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12)),
      )),
      const SizedBox(width: 12),
      ElevatedButton.icon(
        onPressed: () => Get.toNamed(Routes.ADD_PRODUCT),
        icon: const Icon(Icons.add_circle_outline, size: 16, color: Colors.white),
        label: const Text('Nuevo Producto/Canje',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
                color: Colors.white)),
        style: ElevatedButton.styleFrom(
          backgroundColor: _purple, elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
      ),
    ]);
  }

  // ─── STAT CARDS ──────────────────────────────────────────────────────────────

  Widget _statCards() {
    return Obx(() => Row(children: [
      Expanded(child: _statCard(
        accent: _purple, icon: Icons.grid_view_rounded,
        iconBg: _purpleLight, iconColor: _purple,
        label: 'Total Productos',
        value: _fmtNum(() {
          final stats = _ctrl.inventoryStats.value;
          if (stats['total_products'] is int) return stats['total_products'] as int;
          return _ctrl.inventoryMeta.value.total > 0
              ? _ctrl.inventoryMeta.value.total
              : _ctrl.products.length;
        }()),
      )),
      const SizedBox(width: 16),
      Expanded(child: _statCard(
        accent: const Color(0xFFEA580C), icon: Icons.inventory_2_outlined,
        iconBg: const Color(0xFFFFF7ED), iconColor: const Color(0xFFEA580C),
        label: 'Stock Bajo',
        value: _fmtNum(() {
          final stats = _ctrl.inventoryStats.value;
          if (stats['low_stock'] is int) return stats['low_stock'] as int;
          return _ctrl.lowStockCount;
        }()),
        valueColor: const Color(0xFFEA580C),
        subtitle: '< ${_ctrl.lowStockThreshold.value} unidades',
      )),
      const SizedBox(width: 16),
      Expanded(child: _statCard(
        accent: const Color(0xFFD97706), icon: Icons.access_time_outlined,
        iconBg: const Color(0xFFFFFBEB), iconColor: const Color(0xFFD97706),
        label: 'Próximos a Vencer',
        value: _fmtNum(_ctrl.expiringSoonCount),
        valueColor: const Color(0xFFD97706),
        subtitle: 'en ${_ctrl.expiryWarningDays.value} días',
      )),
      const SizedBox(width: 16),
      Expanded(child: _statCard(
        accent: const Color(0xFF059669), icon: Icons.category_outlined,
        iconBg: const Color(0xFFECFDF5), iconColor: const Color(0xFF059669),
        label: 'Categorías Activas',
        value: _fmtNum(_ctrl.activeCategoriesCount),
      )),
    ]));
  }

  Widget _statCard({
    required Color accent,
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String label,
    required String value,
    Color valueColor = const Color(0xFF111827),
    String? subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFEEEEEE)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8, offset: const Offset(0, 2))]),
      child: Row(children: [
        Container(width: 4, height: 52,
            decoration: BoxDecoration(color: accent, borderRadius: BorderRadius.circular(4))),
        const SizedBox(width: 14),
        Container(width: 44, height: 44,
            decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, size: 20, color: iconColor)),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 2),
          Text(value, style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: valueColor)),
          if (subtitle != null)
            Text(subtitle, style: TextStyle(fontSize: 11,
                color: valueColor.withValues(alpha: 0.65))),
        ])),
      ]),
    );
  }

  // ─── PRODUCT TABLE ───────────────────────────────────────────────────────────

  Widget _productTable(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEEEEEE)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10, offset: const Offset(0, 2))]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _tableToolbar(),
        _tableHeader(),
        Obx(() {
          if (_ctrl.isLoadingInventory.value) {
            return const Padding(padding: EdgeInsets.symmetric(vertical: 60),
                child: Center(child: CircularProgressIndicator()));
          }
          final items = _filteredProducts();
          if (items.isEmpty) return _emptyState();
          return Column(children: [
            ...items.map((p) => _productRow(context, p)),
            _paginationBar(),
          ]);
        }),
      ]),
    );
  }

  List<ProductModel> _filteredProducts() {
    final all = _ctrl.inventoryProducts.toList();
    switch (_statusFilter) {
      case 'active':
        return all.where((p) => p.isPublished && p.quantity > 0 && !p.isExpired).toList();
      case 'paused':
        return all.where((p) => !p.isPublished).toList();
      case 'no_stock':
        return all.where((p) => p.quantity == 0).toList();
      case 'expired':
        return all.where((p) => p.isExpired).toList();
      default:
        return all;
    }
  }

  // ─── TABLE TOOLBAR (título + 3 dropdowns) ────────────────────────────────────

  Widget _tableToolbar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Text('Gestión de Inventario',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700,
                  color: Color(0xFF111827))),
          const Spacer(),
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFE5E7EB)),
                borderRadius: BorderRadius.circular(8)),
            child: const Icon(Icons.filter_list, size: 18, color: Color(0xFF6B7280))),
        ]),
        const SizedBox(height: 14),
        Row(children: [
          // Categoría
          Obx(() {
            final cats = {
              'all': 'Todos los Categorías',
              for (final c in _ctrl.categories.where((c) => c.title.isNotEmpty))
                c.title: c.title,
            };
            return _filterDropdown<String>(
              value: _filterCategory ?? 'all',
              items: cats,
              onChanged: (v) {
                setState(() => _filterCategory = v == 'all' ? null : v);
                _search();
              },
            );
          }),
          const SizedBox(width: 10),
          // Estado
          _filterDropdown<String>(
            value: _statusFilter,
            items: const {
              'all':      'Todos los Estados',
              'active':   'Activo',
              'paused':   'Pausado',
              'no_stock': 'Sin Stock',
              'expired':  'Vencido',
            },
            onChanged: (v) => setState(() => _statusFilter = v ?? 'all'),
          ),
          const SizedBox(width: 10),
          // Ordenar por — MISSING ENDPOINT: needs ordering support on backend
          _filterDropdown<String>(
            value: _sortOrder,
            items: const {
              'name':   'Ninguno (A-Z)',
              '-name':  'Nombre (Z-A)',
              'price':  'Precio (Menor)',
              '-price': 'Precio (Mayor)',
              'stock':  'Stock (Menor)',
              '-stock': 'Stock (Mayor)',
            },
            onChanged: (v) {
              setState(() => _sortOrder = v ?? 'name');
              _search();
            },
          ),
        ]),
        const SizedBox(height: 4),
      ]),
    );
  }

  Widget _filterDropdown<T>({
    required T value,
    required Map<T, String> items,
    required ValueChanged<T?> onChanged,
  }) {
    return Container(
      height: 38,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE5E7EB)),
        borderRadius: BorderRadius.circular(8)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value, isDense: true,
          style: const TextStyle(fontSize: 13, color: Color(0xFF374151)),
          borderRadius: BorderRadius.circular(10),
          icon: const Icon(Icons.keyboard_arrow_down, size: 16,
              color: Color(0xFF6B7280)),
          items: items.entries
              .map((e) => DropdownMenuItem<T>(value: e.key, child: Text(e.value)))
              .toList(),
          onChanged: onChanged),
      ),
    );
  }

  // ─── TABLE HEADER ─────────────────────────────────────────────────────────────

  Widget _tableHeader() {
    const style = TextStyle(fontSize: 10, fontWeight: FontWeight.w700,
        color: Colors.grey, letterSpacing: 0.6);
    return Container(
      margin: const EdgeInsets.only(top: 14),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 11),
      decoration: const BoxDecoration(
        color: Color(0xFFFAFAFA),
        border: Border(
          top: BorderSide(color: Color(0xFFF3F4F6)),
          bottom: BorderSide(color: Color(0xFFF3F4F6)))),
      child: const Row(children: [
        SizedBox(width: 52),
        SizedBox(width: 12),
        Expanded(flex: 3, child: Text('PRODUCTO', style: style)),
        Expanded(flex: 2, child: Text('CATEGORÍA / SKU', style: style)),
        SizedBox(width: 120, child: Text('STOCK', style: style)),
        SizedBox(width: 140, child: Text('PRECIO / COSTE (PTS)', style: style)),
        SizedBox(width: 100, child: Text('ESTADO', style: style)),
        SizedBox(width: 80, child: Text('ACCIONES', style: style,
            textAlign: TextAlign.center)),
      ]),
    );
  }

  // ─── PRODUCT ROW ──────────────────────────────────────────────────────────────

  Widget _productRow(BuildContext context, ProductModel p) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: Color(0xFFF3F4F6)))),
      child: Row(children: [
        // Imagen
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: p.image.startsWith('http')
              ? Image.network(p.image, width: 52, height: 52, fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _imgPlaceholder())
              : _imgPlaceholder()),
        const SizedBox(width: 12),

        // Nombre + descripción
        Expanded(
          flex: 3,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(p.name,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700,
                    color: Color(0xFF111827)),
                maxLines: 1, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 2),
            Text(
              p.description.isNotEmpty
                  ? p.description
                  : (p.category.isNotEmpty ? p.category : '—'),
              style: const TextStyle(fontSize: 11, color: Colors.grey),
              maxLines: 1, overflow: TextOverflow.ellipsis),
          ]),
        ),

        // Categoría / SKU
        Expanded(
          flex: 2,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            if (p.category.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  // HARDCODED: keyword color mapping — categories should expose
                  // a `color` field from GET /marketplace/categories/
                  color: _catColor(p.category).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20)),
                child: Text(p.category,
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
                        color: _catColor(p.category)),
                    overflow: TextOverflow.ellipsis))
            else
              const Text('—', style: TextStyle(color: Colors.grey, fontSize: 12)),
            const SizedBox(height: 4),
            Text(
              p.sku.isNotEmpty
                  ? p.sku
                  : (p.id.length >= 8
                      ? p.id.substring(0, 8).toUpperCase()
                      : p.id.toUpperCase()),
              style: const TextStyle(fontSize: 10, color: Colors.grey)),
          ]),
        ),

        // Stock
        SizedBox(width: 120, child: _stockPill(p.quantity)),

        // Precio / Coste (Pts)
        SizedBox(width: 140, child: _pricePtsBadge(p)),

        // Estado
        SizedBox(width: 100, child: _statusBadge(p)),

        // Acciones
        SizedBox(
          width: 80,
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Tooltip(message: 'Editar',
                child: _actionBtn(icon: Icons.edit_outlined,
                    onTap: () => Get.toNamed(Routes.ADD_PRODUCT, arguments: p))),
            const SizedBox(width: 6),
            Tooltip(
              message: p.isPublished ? 'Pausar' : 'Activar',
              child: _actionBtn(
                icon: p.isPublished
                    ? Icons.pause_circle_outline
                    : Icons.play_circle_outline,
                color: p.isPublished
                    ? const Color(0xFFD97706)
                    : const Color(0xFF059669),
                onTap: () => _ctrl.toggleProductPublished(p))),
            const SizedBox(width: 6),
            Tooltip(message: 'Eliminar',
                child: _actionBtn(icon: Icons.delete_outline,
                    color: const Color(0xFFEF4444),
                    onTap: () => _confirmDelete(context, p))),
          ]),
        ),
      ]),
    );
  }

  Widget _stockPill(int qty) {
    final Color bg;
    final Color fg;
    final int threshold = _ctrl.lowStockThreshold.value;
    if (qty <= 0) {
      bg = const Color(0xFFF3F4F6);
      fg = const Color(0xFF6B7280);
    } else if (qty < threshold) {
      bg = const Color(0xFFFEE2E2);
      fg = const Color(0xFFDC2626);
    } else if (qty < threshold * 3) {
      bg = const Color(0xFFFFF7ED);
      fg = const Color(0xFFD97706);
    } else {
      bg = const Color(0xFFECFDF5);
      fg = const Color(0xFF059669);
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text('$qty unidades',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: fg)));
  }

  Widget _pricePtsBadge(ProductModel p) {
    final monetary = p.monetaryPrice > 0 ? p.monetaryPrice : p.originalPrice;
    final pts = p.pointsRequired > 0
        ? p.pointsRequired
        : (p.discountPrice > 0 ? p.discountPrice.toInt() : 0);

    if (monetary > 0 && p.pointsRequired == 0) {
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('\$${monetary.toStringAsFixed(2)}',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800,
                color: Color(0xFF111827))),
        if (p.discountPercent > 0)
          Text('${p.discountPercent.toInt()}% desc.',
              style: const TextStyle(fontSize: 10, color: Colors.grey)),
      ]);
    }
    if (pts > 0) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
            color: _purpleLight, borderRadius: BorderRadius.circular(20)),
        child: Text('${_fmtNum(pts)} Pts',
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700,
                color: _purple)));
    }
    return const Text('—', style: TextStyle(color: Colors.grey));
  }

  Widget _statusBadge(ProductModel p) {
    final Color bg;
    final Color fg;
    final String label;
    if (p.isExpired) {
      label = 'Vencido';
      bg = const Color(0xFFFEE2E2);
      fg = const Color(0xFFDC2626);
    } else if (p.quantity == 0) {
      label = 'Sin Stock';
      bg = const Color(0xFFF3F4F6);
      fg = const Color(0xFF6B7280);
    } else if (!p.isPublished) {
      label = 'Pausado';
      bg = const Color(0xFFFFFBEB);
      fg = const Color(0xFFD97706);
    } else {
      label = 'Activo';
      bg = const Color(0xFFECFDF5);
      fg = const Color(0xFF059669);
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(label,
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: fg)));
  }

  // ─── COMPLIANCE FOOTER ────────────────────────────────────────────────────────

  Widget _complianceFooter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFFDE68A))),
      child: const Row(children: [
        Icon(Icons.info_outline, size: 16, color: Color(0xFFD97706)),
        SizedBox(width: 10),
        Expanded(child: Text(
          'Cumplimiento: El historial de campos completados no puede ser alterado bajo ninguna circunstancia por razones de auditoría fiscal.',
          style: TextStyle(fontSize: 12, color: Color(0xFF92400E)))),
      ]),
    );
  }

  // ─── EMPTY STATE ──────────────────────────────────────────────────────────────

  Widget _emptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 20),
      child: Center(child: Column(children: [
        Container(width: 64, height: 64,
            decoration: BoxDecoration(color: _purpleLight,
                borderRadius: BorderRadius.circular(16)),
            child: const Icon(Icons.inventory_2_outlined, size: 32, color: _purple)),
        const SizedBox(height: 16),
        const Text('No se encontraron productos',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700,
                color: Color(0xFF374151))),
        const SizedBox(height: 6),
        Text(
          _searchCtrl.text.isNotEmpty
              ? 'Sin resultados para "${_searchCtrl.text}"'
              : 'Añade tu primer producto con el botón de arriba',
          style: const TextStyle(fontSize: 13, color: Colors.grey),
          textAlign: TextAlign.center),
      ])),
    );
  }

  Widget _imgPlaceholder() {
    return Container(width: 52, height: 52,
        decoration: BoxDecoration(color: _purpleLight, borderRadius: BorderRadius.circular(8)),
        child: const Icon(Icons.inventory_2_outlined, size: 22, color: _purple));
  }

  Widget _actionBtn({
    required IconData icon,
    Color color = const Color(0xFF6B7280),
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(width: 28, height: 28,
          decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, size: 15, color: color)));
  }

  // ─── PAGINATION ──────────────────────────────────────────────────────────────

  Widget _paginationBar() {
    return Obx(() {
      final meta     = _ctrl.inventoryMeta.value;
      final page     = _ctrl.inventoryCurrentPage.value;
      final lastPage = meta.lastPage.clamp(1, 9999);
      final start    = meta.total == 0 ? 0 : (page - 1) * 10 + 1;
      final end      = (page * 10).clamp(0, meta.total);

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: const BoxDecoration(
            border: Border(top: BorderSide(color: Color(0xFFF3F4F6)))),
        child: Row(children: [
          Text('Mostrando $start–$end de ${_fmtNum(meta.total)} productos registrados',
              style: const TextStyle(fontSize: 13, color: Colors.grey)),
          const Spacer(),
          _pgBtn(icon: Icons.chevron_left, enabled: page > 1,
              onTap: () => _ctrl.loadInventoryPage(page: page - 1,
                  search: _searchCtrl.text.trim(),
                  category: _filterCategory, ordering: _sortOrder)),
          const SizedBox(width: 4),
          ..._pageNums(page, lastPage).map((n) => n == -1
              ? const Padding(padding: EdgeInsets.symmetric(horizontal: 4),
                  child: Text('…', style: TextStyle(color: Colors.grey)))
              : _pgNum(n, n == page, () => _ctrl.loadInventoryPage(page: n,
                  search: _searchCtrl.text.trim(),
                  category: _filterCategory, ordering: _sortOrder))),
          const SizedBox(width: 4),
          _pgBtn(icon: Icons.chevron_right, enabled: page < lastPage,
              onTap: () => _ctrl.loadInventoryPage(page: page + 1,
                  search: _searchCtrl.text.trim(),
                  category: _filterCategory, ordering: _sortOrder)),
        ]),
      );
    });
  }

  List<int> _pageNums(int page, int last) {
    if (last <= 5) return List.generate(last, (i) => i + 1);
    if (page <= 3) return [1, 2, 3, -1, last];
    if (page >= last - 2) return [1, -1, last - 2, last - 1, last];
    return [1, -1, page, -1, last];
  }

  Widget _pgBtn({required IconData icon, required bool enabled, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(width: 34, height: 34,
          decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFE5E7EB)),
              borderRadius: BorderRadius.circular(8),
              color: enabled ? Colors.white : const Color(0xFFF9FAFB)),
          child: Icon(icon, size: 18,
              color: enabled ? const Color(0xFF374151) : Colors.grey.shade300)));
  }

  Widget _pgNum(int n, bool current, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 34, height: 34,
        margin: const EdgeInsets.symmetric(horizontal: 2),
        decoration: BoxDecoration(
          color: current ? _purple : Colors.transparent,
          border: Border.all(color: current ? _purple : const Color(0xFFE5E7EB)),
          borderRadius: BorderRadius.circular(8)),
        child: Center(child: Text('$n',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
                color: current ? Colors.white : const Color(0xFF374151))))),
    );
  }

  // ─── DIALOGS ─────────────────────────────────────────────────────────────────

  void _confirmDelete(BuildContext context, ProductModel p) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Eliminar producto'),
        content: Text('¿Eliminar "${p.name}"? Esta acción no se puede deshacer.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade400, foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            onPressed: () async {
              Navigator.of(ctx).pop();
              await _ctrl.deleteProduct(p);
              _ctrl.loadInventoryPage(
                  page: _ctrl.inventoryCurrentPage.value,
                  search: _searchCtrl.text.trim(),
                  category: _filterCategory, ordering: _sortOrder);
            },
            child: const Text('Eliminar')),
        ],
      ),
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Cerrar sesión'),
        content: const Text('¿Seguro que quieres cerrar sesión?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _purple, foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            onPressed: () async {
              Navigator.of(ctx).pop();
              await AuthService.signOut();
              Get.offAllNamed(Routes.LOGIN);
            },
            child: const Text('Cerrar sesión')),
        ],
      ),
    );
  }

  // ─── HELPERS ──────────────────────────────────────────────────────────────────

  String _fmtNum(int n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 1000) {
      final s = n.toString();
      final buf = StringBuffer();
      for (int i = 0; i < s.length; i++) {
        if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
        buf.write(s[i]);
      }
      return buf.toString();
    }
    return '$n';
  }

  Color _catColor(String cat) {
    // Use the hex color from the backend category (GET /marketplace/categories/ → color field).
    final match = _ctrl.categories.cast<CategoryModel?>().firstWhere(
        (c) => c?.title == cat, orElse: () => null);
    if (match != null && match.color.isNotEmpty) {
      final hex = match.color.replaceAll('#', '');
      final value = int.tryParse(
          hex.length == 6 ? 'FF$hex' : hex.length == 8 ? hex : '', radix: 16);
      if (value != null) return Color(value);
    }
    // Fallback palette when backend returns no color.
    final lower = cat.toLowerCase();
    if (lower.contains('electr'))                              return const Color(0xFF2563EB);
    if (lower.contains('calzado') || lower.contains('zapato')) return const Color(0xFFDC2626);
    if (lower.contains('indumentaria') || lower.contains('ropa')) return const Color(0xFF9333EA);
    if (lower.contains('hogar'))                               return const Color(0xFF0891B2);
    if (lower.contains('belleza') || lower.contains('beauty')) return const Color(0xFFDB2777);
    if (lower.contains('gadget'))                              return const Color(0xFF7C3AED);
    if (lower.contains('comida') || lower.contains('food'))    return const Color(0xFF16A34A);
    return const Color(0xFF6B7280);
  }

  String _formatRole(String role) {
    switch (role.toUpperCase()) {
      case 'STORE_ADMIN':   return 'Store Admin';
      case 'STORE_VIEWER':  return 'Store Viewer';
      case 'ADMIN':         return 'General Admin';
      case 'SUPERUSER':     return 'Super Admin';
      case 'MEMBER':        return 'Miembro';
      default:
        if (role.isEmpty) return 'Admin Console';
        return role[0].toUpperCase() + role.substring(1).toLowerCase();
    }
  }
}
