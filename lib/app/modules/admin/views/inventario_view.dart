import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/models/product_model.dart';
import '../../../routes/app_pages.dart';
import '../controllers/admin_controller.dart';

enum _StatusFilter { all, active, paused, noStock, expired }

class InventarioView extends StatefulWidget {
  const InventarioView({Key? key}) : super(key: key);

  @override
  State<InventarioView> createState() => _InventarioViewState();
}

class _InventarioViewState extends State<InventarioView> {
  static const Color _purple = Color(0xFF7C3AED);
  static const Color _purpleLight = Color(0xFFEDE9FE);
  static const Color _bg = Color(0xFFF8F7FF);

  late final AdminController _ctrl;
  final _searchCtrl = TextEditingController();
  String? _filterCategory;
  _StatusFilter _statusFilter = _StatusFilter.all;
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
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: Row(
        children: [
          _sidebar(context),
          Expanded(child: _mainArea(context)),
        ],
      ),
    );
  }

  // ─── SIDEBAR ─────────────────────────────────────────────────────────────────

  Widget _sidebar(BuildContext context) {
    return Container(
      width: 240,
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 20),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF7C3AED), Color(0xFF9F67FA)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Center(
                    child: Text('AL',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 14)),
                  ),
                ),
                const SizedBox(width: 10),
                Obx(() {
                  _ctrl.storeId.value;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_ctrl.currentStore.name,
                          style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: _purple)),
                      const Text('Gestión de Tienda',
                          style: TextStyle(fontSize: 10, color: Colors.grey)),
                    ],
                  );
                }),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFF3F4F6)),
          const SizedBox(height: 8),
          _navItem(icon: Icons.home_outlined, label: 'Inicio', onTap: () => Get.offNamed(Routes.ADMIN)),
          _navItem(icon: Icons.grid_view_rounded, label: 'Inventario', selected: true),
          _navItem(icon: Icons.swap_horiz_rounded, label: 'Canjes', onTap: () => Get.offNamed(Routes.VOUCHER_HISTORY)),
          _navItem(icon: Icons.card_giftcard_outlined, label: 'Premios', onTap: () => Get.toNamed(Routes.PREMIOS)),
          _navItem(icon: Icons.history_outlined, label: 'Historial', onTap: () => Get.offNamed(Routes.VOUCHER_HISTORY)),
          _navItem(icon: Icons.bar_chart_outlined, label: 'Estadísticas', onTap: () => Get.offNamed(Routes.ANALYTICS)),
          const Spacer(),
          const Divider(height: 1, color: Color(0xFFF3F4F6)),
          _navItem(icon: Icons.settings_outlined, label: 'Configuración', onTap: () => Get.toNamed(Routes.ADMIN_SETTINGS)),
          _navItem(
            icon: Icons.logout,
            label: 'Cerrar Sesión',
            labelColor: Colors.red,
            iconColor: Colors.red,
            onTap: () => _confirmLogout(context),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _navItem({
    required IconData icon,
    required String label,
    bool selected = false,
    Color? labelColor,
    Color? iconColor,
    VoidCallback? onTap,
  }) {
    final fg = selected ? _purple : (iconColor ?? Colors.grey.shade600);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? _purpleLight : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: fg),
            const SizedBox(width: 10),
            Text(label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                  color: selected ? _purple : (labelColor ?? Colors.grey.shade700),
                )),
          ],
        ),
      ),
    );
  }

  // ─── MAIN AREA ───────────────────────────────────────────────────────────────

  Widget _mainArea(BuildContext context) {
    return Column(
      children: [
        _topBar(),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _titleRow(context),
                const SizedBox(height: 20),
                _statCards(),
                const SizedBox(height: 24),
                _productTable(context),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ─── TOP BAR ─────────────────────────────────────────────────────────────────

  Widget _topBar() {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 28),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFEEEEEE))),
      ),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 38,
              child: TextField(
                controller: _searchCtrl,
                onChanged: _onSearchChanged,
                onSubmitted: (_) => _search(),
                decoration: InputDecoration(
                  hintText: 'Buscar productos por SKU o nombre...',
                  hintStyle: TextStyle(fontSize: 13, color: Colors.grey.shade400),
                  prefixIcon: Icon(Icons.search, size: 18, color: Colors.grey.shade400),
                  suffixIcon: Obx(() {
                    if (_ctrl.isLoadingInventory.value) {
                      return const Padding(
                        padding: EdgeInsets.all(10),
                        child: SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      );
                    }
                    if (_searchCtrl.text.isNotEmpty) {
                      return IconButton(
                        icon: const Icon(Icons.close, size: 16),
                        onPressed: () {
                          _searchCtrl.clear();
                          _search();
                        },
                      );
                    }
                    return const SizedBox.shrink();
                  }),
                  filled: true,
                  fillColor: const Color(0xFFF5F5F5),
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(50),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 20),
          Stack(clipBehavior: Clip.none, children: [
            const Icon(Icons.notifications_outlined, size: 22, color: Color(0xFF374151)),
            Positioned(
              top: -2,
              right: -2,
              child: Obx(() => _ctrl.pendingCount > 0
                  ? Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                          color: Colors.orange, shape: BoxShape.circle),
                    )
                  : const SizedBox.shrink()),
            ),
          ]),
          const SizedBox(width: 20),
          const Icon(Icons.help_outline, size: 22, color: Color(0xFF374151)),
          const SizedBox(width: 20),
          Obx(() {
            _ctrl.storeId.value;
            return Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF7C3AED), Color(0xFF9F67FA)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(Icons.person, size: 16, color: Colors.white),
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(_ctrl.currentStore.name,
                        style: const TextStyle(
                            fontSize: 12, fontWeight: FontWeight.w700)),
                    // TODO(backend): role label should come from the user profile
                    const Text('SUPERUSER',
                        style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: _purple,
                            letterSpacing: 0.5)),
                  ],
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  // ─── TITLE ROW ────────────────────────────────────────────────────────────────

  Widget _titleRow(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Gestión de Inventario',
                style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF111827))),
            SizedBox(height: 4),
            Text('Administra el catálogo de recompensas y el stock disponible.',
                style: TextStyle(fontSize: 13, color: Colors.grey)),
          ],
        ),
        const Spacer(),
        Obx(() => OutlinedButton.icon(
          onPressed: _ctrl.isExportingCsv.value ? null : _exportCsv,
          icon: _ctrl.isExportingCsv.value
              ? const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(strokeWidth: 2))
              : const Icon(Icons.download_outlined,
                  size: 16, color: Color(0xFF374151)),
          label: const Text('Exportar CSV',
              style: TextStyle(fontSize: 13, color: Color(0xFF374151))),
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: Color(0xFFD1D5DB)),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)),
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        )),
        const SizedBox(width: 12),
        ElevatedButton.icon(
          onPressed: () => Get.toNamed(Routes.ADD_PRODUCT),
          icon: const Icon(Icons.add, size: 18, color: Colors.white),
          label: const Text('Añadir Producto',
              style: TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
          style: ElevatedButton.styleFrom(
            backgroundColor: _purple,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ],
    );
  }

  // ─── STAT CARDS ──────────────────────────────────────────────────────────────

  Widget _statCards() {
    return Obx(() => Row(
          children: [
            Expanded(
              child: _statCard(
                accent: _purple,
                icon: Icons.grid_view_rounded,
                iconBg: _purpleLight,
                iconColor: _purple,
                label: 'Total Productos',
                value: _fmtNum(_ctrl.inventoryMeta.value.total > 0
                    ? _ctrl.inventoryMeta.value.total
                    : _ctrl.products.length),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _statCard(
                accent: const Color(0xFFEA580C),
                icon: Icons.inventory_2_outlined,
                iconBg: const Color(0xFFFFF7ED),
                iconColor: const Color(0xFFEA580C),
                label: 'Stock Bajo',
                // HARDCODED: threshold < 10 units; should come from
                // GET /marketplace/stores/{id}/settings/ → low_stock_threshold
                value: _fmtNum(_ctrl.lowStockCount),
                valueColor: const Color(0xFFEA580C),
                subtitle: '< 10 unidades',
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _statCard(
                accent: const Color(0xFFD97706),
                icon: Icons.access_time_outlined,
                iconBg: const Color(0xFFFFFBEB),
                iconColor: const Color(0xFFD97706),
                label: 'Próximos a Vencer',
                // HARDCODED: "expiring soon" = within 30 days; should come from
                // GET /marketplace/stores/{id}/settings/ → expiry_warning_days
                value: _fmtNum(_ctrl.expiringSoonCount),
                valueColor: const Color(0xFFD97706),
                subtitle: 'en 30 días',
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _statCard(
                accent: const Color(0xFF059669),
                icon: Icons.category_outlined,
                iconBg: const Color(0xFFECFDF5),
                iconColor: const Color(0xFF059669),
                label: 'Categorías Activas',
                // NOTE: derived from loaded categories list; backend should expose
                // this as part of GET /marketplace/admin/inventory/stats/?store={id}
                value: _fmtNum(_ctrl.activeCategoriesCount),
              ),
            ),
          ],
        ));
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFEEEEEE)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 52,
            decoration: BoxDecoration(
              color: accent,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 14),
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: iconColor),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                const SizedBox(height: 2),
                Text(value,
                    style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: valueColor)),
                if (subtitle != null)
                  Text(subtitle,
                      style: TextStyle(
                          fontSize: 11,
                          color: valueColor.withValues(alpha: 0.65))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── PRODUCT TABLE ───────────────────────────────────────────────────────────

  Widget _productTable(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEEEEEE)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _tableToolbar(),
          _statusFilterChips(),
          _tableHeader(),
          Obx(() {
            if (_ctrl.isLoadingInventory.value) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 60),
                child: Center(child: CircularProgressIndicator()),
              );
            }
            final items = _filteredProducts();
            if (items.isEmpty) return _emptyState();
            return Column(
              children: [
                ...items.map((p) => _productRow(context, p)),
                _paginationBar(),
              ],
            );
          }),
        ],
      ),
    );
  }

  List<ProductModel> _filteredProducts() {
    final all = _ctrl.inventoryProducts.toList();
    switch (_statusFilter) {
      case _StatusFilter.active:
        return all.where((p) => p.isPublished && p.quantity > 0 && !p.isExpired).toList();
      case _StatusFilter.paused:
        return all.where((p) => !p.isPublished).toList();
      case _StatusFilter.noStock:
        return all.where((p) => p.quantity == 0).toList();
      case _StatusFilter.expired:
        return all.where((p) => p.isExpired).toList();
      case _StatusFilter.all:
        return all;
    }
  }

  Widget _tableToolbar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
      child: Row(
        children: [
          const Text('Lista de Productos',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF111827))),
          const Spacer(),
          // Category filter inline — no modal needed
          Obx(() {
            final cats = [
              'Todas',
              ..._ctrl.categories
                  .map((c) => c.title)
                  .where((t) => t.isNotEmpty),
            ];
            return DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _filterCategory ?? 'Todas',
                isDense: true,
                style: const TextStyle(fontSize: 13, color: Color(0xFF374151)),
                borderRadius: BorderRadius.circular(10),
                items: cats
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (v) {
                  setState(() => _filterCategory = v == 'Todas' ? null : v);
                  _search();
                },
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _statusFilterChips() {
    const filters = [
      (_StatusFilter.all, 'Todos', Color(0xFF7C3AED)),
      (_StatusFilter.active, 'Activos', Color(0xFF059669)),
      (_StatusFilter.paused, 'Pausados', Color(0xFFD97706)),
      (_StatusFilter.noStock, 'Sin Stock', Color(0xFFEA580C)),
      (_StatusFilter.expired, 'Vencidos', Color(0xFFDC2626)),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: filters.map((entry) {
            final (filter, label, color) = entry;
            final selected = _statusFilter == filter;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () => setState(() => _statusFilter = filter),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: selected ? color : Colors.transparent,
                    border: Border.all(
                        color: selected ? color : const Color(0xFFE5E7EB)),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(label,
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: selected
                              ? Colors.white
                              : const Color(0xFF6B7280))),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _tableHeader() {
    const style = TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: Colors.grey,
        letterSpacing: 0.5);
    return Container(
      margin: const EdgeInsets.only(top: 14),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: const BoxDecoration(
        color: Color(0xFFFAFAFA),
        border: Border(
          top: BorderSide(color: Color(0xFFF3F4F6)),
          bottom: BorderSide(color: Color(0xFFF3F4F6)),
        ),
      ),
      child: const Row(
        children: [
          SizedBox(width: 64, child: Text('FOTO', style: style)),
          Expanded(flex: 3, child: Text('NOMBRE / SKU', style: style)),
          Expanded(flex: 2, child: Text('CATEGORÍA', style: style)),
          Expanded(flex: 2, child: Text('ESTADO', style: style)),
          SizedBox(
              width: 100,
              child: Text('PTS', style: style, textAlign: TextAlign.right)),
          Expanded(flex: 2, child: Text('STOCK', style: style)),
          Expanded(flex: 2, child: Text('VENCIMIENTO', style: style)),
          SizedBox(
              width: 96,
              child: Text('ACCIONES', style: style, textAlign: TextAlign.center)),
        ],
      ),
    );
  }

  Widget _productRow(BuildContext context, ProductModel p) {
    final pts =
        p.pointsRequired > 0 ? p.pointsRequired : p.discountPrice.toInt();
    final stockColor = _stockColor(p.quantity);
    final stockPct = _stockPct(p.quantity);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFF3F4F6))),
      ),
      child: Row(
        children: [
          // Photo
          SizedBox(
            width: 64,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: p.image.startsWith('http')
                  ? Image.network(p.image,
                      width: 52,
                      height: 52,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _imgPlaceholder())
                  : _imgPlaceholder(),
            ),
          ),
          // Name + SKU
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(p.name,
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF111827)),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Text(
                  p.sku.isNotEmpty
                      ? p.sku
                      : p.id.length >= 8
                          ? p.id.substring(0, 8).toUpperCase()
                          : p.id.toUpperCase(),
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ],
            ),
          ),
          // Category
          Expanded(
            flex: 2,
            child: p.category.isNotEmpty
                ? Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _catColor(p.category).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(p.category,
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: _catColor(p.category)),
                        overflow: TextOverflow.ellipsis),
                  )
                : const Text('—', style: TextStyle(color: Colors.grey)),
          ),
          // Status badge
          Expanded(flex: 2, child: _statusBadge(p)),
          // Points
          SizedBox(
            width: 100,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(_fmtNum(pts),
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: _purple)),
                const SizedBox(width: 4),
                Container(
                  width: 16,
                  height: 16,
                  decoration: const BoxDecoration(
                      color: _purple, shape: BoxShape.circle),
                  child:
                      const Icon(Icons.star, size: 9, color: Colors.white),
                ),
              ],
            ),
          ),
          // Stock bar + count
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.only(left: 12),
              child: Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: stockPct,
                        backgroundColor: const Color(0xFFEEEEEE),
                        valueColor:
                            AlwaysStoppedAnimation<Color>(stockColor),
                        minHeight: 6,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text('${p.quantity}',
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: stockColor)),
                ],
              ),
            ),
          ),
          // Expiry
          Expanded(
            flex: 2,
            child: p.expiryDate == null
                ? Text('Sin vencimiento',
                    style: TextStyle(
                        fontSize: 11, color: Colors.grey.shade400))
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_fmtDate(p.expiryDate!),
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: p.isExpired
                                  ? Colors.red
                                  : p.isExpiringSoon
                                      ? Colors.orange
                                      : const Color(0xFF374151))),
                      if (p.isExpiringSoon && !p.isExpired)
                        const Text('Próximo a vencer',
                            style:
                                TextStyle(fontSize: 10, color: Colors.orange)),
                      if (p.isExpired)
                        const Text('Vencido',
                            style: TextStyle(fontSize: 10, color: Colors.red)),
                    ],
                  ),
          ),
          // Actions: edit | toggle publish | delete
          SizedBox(
            width: 96,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Tooltip(
                  message: 'Editar',
                  child: _actionBtn(
                    icon: Icons.edit_outlined,
                    onTap: () =>
                        Get.toNamed(Routes.ADD_PRODUCT, arguments: p),
                  ),
                ),
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
                    onTap: () => _ctrl.toggleProductPublished(p),
                  ),
                ),
                const SizedBox(width: 6),
                Tooltip(
                  message: 'Eliminar',
                  child: _actionBtn(
                    icon: Icons.delete_outline,
                    color: const Color(0xFFEF4444),
                    onTap: () => _confirmDelete(context, p),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration:
          BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(label,
          style: TextStyle(
              fontSize: 12, fontWeight: FontWeight.w600, color: fg)),
    );
  }

  Widget _emptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 20),
      child: Center(
        child: Column(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                  color: _purpleLight,
                  borderRadius: BorderRadius.circular(16)),
              child: const Icon(Icons.inventory_2_outlined,
                  size: 32, color: _purple),
            ),
            const SizedBox(height: 16),
            const Text('No se encontraron productos',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF374151))),
            const SizedBox(height: 6),
            Text(
              _searchCtrl.text.isNotEmpty
                  ? 'Sin resultados para "${_searchCtrl.text}"'
                  : 'Añade tu primer producto con el botón de arriba',
              style: const TextStyle(fontSize: 13, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _imgPlaceholder() {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
          color: _purpleLight, borderRadius: BorderRadius.circular(10)),
      child:
          const Icon(Icons.inventory_2_outlined, size: 22, color: _purple),
    );
  }

  Widget _actionBtn({
    required IconData icon,
    Color color = const Color(0xFF6B7280),
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 15, color: color),
      ),
    );
  }

  // ─── PAGINATION ──────────────────────────────────────────────────────────────

  Widget _paginationBar() {
    return Obx(() {
      final meta = _ctrl.inventoryMeta.value;
      final page = _ctrl.inventoryCurrentPage.value;
      final lastPage = meta.lastPage.clamp(1, 9999);
      final start = meta.total == 0 ? 0 : (page - 1) * 10 + 1;
      final end = (page * 10).clamp(0, meta.total);

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: Color(0xFFF3F4F6))),
        ),
        child: Row(
          children: [
            Text('Mostrando $start–$end de ${_fmtNum(meta.total)} productos',
                style: const TextStyle(fontSize: 13, color: Colors.grey)),
            const Spacer(),
            _pgBtn(
              icon: Icons.chevron_left,
              enabled: page > 1,
              onTap: () => _ctrl.loadInventoryPage(
                  page: page - 1,
                  search: _searchCtrl.text.trim(),
                  category: _filterCategory),
            ),
            const SizedBox(width: 4),
            ..._pageNums(page, lastPage).map((n) => n == -1
                ? const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4),
                    child: Text('…',
                        style: TextStyle(color: Colors.grey)))
                : _pgNum(
                    n,
                    n == page,
                    () => _ctrl.loadInventoryPage(
                        page: n,
                        search: _searchCtrl.text.trim(),
                        category: _filterCategory))),
            const SizedBox(width: 4),
            _pgBtn(
              icon: Icons.chevron_right,
              enabled: page < lastPage,
              onTap: () => _ctrl.loadInventoryPage(
                  page: page + 1,
                  search: _searchCtrl.text.trim(),
                  category: _filterCategory),
            ),
          ],
        ),
      );
    });
  }

  List<int> _pageNums(int page, int last) {
    if (last <= 5) return List.generate(last, (i) => i + 1);
    if (page <= 3) return [1, 2, 3, -1, last];
    if (page >= last - 2) return [1, -1, last - 2, last - 1, last];
    return [1, -1, page, -1, last];
  }

  Widget _pgBtn(
      {required IconData icon,
      required bool enabled,
      required VoidCallback onTap}) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFE5E7EB)),
          borderRadius: BorderRadius.circular(8),
          color: enabled ? Colors.white : const Color(0xFFF9FAFB),
        ),
        child: Icon(icon,
            size: 18,
            color: enabled
                ? const Color(0xFF374151)
                : Colors.grey.shade300),
      ),
    );
  }

  Widget _pgNum(int n, bool current, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 34,
        height: 34,
        margin: const EdgeInsets.symmetric(horizontal: 2),
        decoration: BoxDecoration(
          color: current ? _purple : Colors.transparent,
          border:
              Border.all(color: current ? _purple : const Color(0xFFE5E7EB)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text('$n',
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: current ? Colors.white : const Color(0xFF374151))),
        ),
      ),
    );
  }

  // ─── DIALOGS ─────────────────────────────────────────────────────────────────

  void _confirmDelete(BuildContext context, ProductModel p) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Eliminar producto'),
        content: Text(
            '¿Eliminar "${p.name}"? Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade400,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () async {
              Navigator.of(ctx).pop();
              await _ctrl.deleteProduct(p);
              _ctrl.loadInventoryPage(
                  page: _ctrl.inventoryCurrentPage.value,
                  search: _searchCtrl.text.trim(),
                  category: _filterCategory);
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Cerrar sesión'),
        content: const Text('¿Seguro que quieres cerrar sesión?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _purple,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () async {
              Navigator.of(ctx).pop();
              Get.offAllNamed(Routes.LOGIN);
            },
            child: const Text('Cerrar sesión'),
          ),
        ],
      ),
    );
  }

  void _exportCsv() => _ctrl.exportInventoryCsv();

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

  String _fmtDate(DateTime d) {
    const months = [
      'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
      'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic',
    ];
    return '${d.day} ${months[d.month - 1]}, ${d.year}';
  }

  // HARDCODED: thresholds 10 / 30 should come from store settings
  Color _stockColor(int qty) {
    if (qty <= 0) return Colors.grey;
    if (qty < 10) return const Color(0xFFDC2626);
    if (qty < 30) return const Color(0xFFD97706);
    return const Color(0xFF16A34A);
  }

  // HARDCODED: max=200 for progress bar; should use max stock from backend
  double _stockPct(int qty) {
    if (qty <= 0) return 0;
    if (qty >= 200) return 1.0;
    return (qty / 200).clamp(0.05, 1.0);
  }

  // HARDCODED: category → color mapping by keyword; categories should carry a
  // `color` field from GET /marketplace/categories/
  Color _catColor(String cat) {
    final lower = cat.toLowerCase();
    if (lower.contains('calzado') || lower.contains('zapato')) {
      return const Color(0xFFDC2626);
    }
    if (lower.contains('electr')) return const Color(0xFF2563EB);
    if (lower.contains('gadget')) return const Color(0xFF7C3AED);
    if (lower.contains('ropa') || lower.contains('moda')) {
      return const Color(0xFF9333EA);
    }
    if (lower.contains('beauty') || lower.contains('belleza')) {
      return const Color(0xFFDB2777);
    }
    if (lower.contains('food') || lower.contains('comida')) {
      return const Color(0xFF16A34A);
    }
    return const Color(0xFF6B7280);
  }
}
