import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../utils/constants.dart';
import '../../../data/models/product_model.dart';
import '../../../data/models/store_user_model.dart';
import '../../../data/services/auth_service.dart';
import '../../../routes/app_pages.dart';
import '../controllers/admin_controller.dart';

class AdminView extends StatefulWidget {
  const AdminView({Key? key}) : super(key: key);

  @override
  State<AdminView> createState() => _AdminViewState();
}

class _AdminViewState extends State<AdminView> {
  static const Color _purple = Color(0xFF7C3AED);
  static const Color _purpleLight = Color(0xFFEDE9FE);
  static const Color _bg = Color(0xFFF8F7FF);

  late final AdminController _ctrl;

  final _searchCtrl = TextEditingController();
  String? _catFilter;
  String? _statusFilter;
  int _page = 1;
  static const int _pageSize = 10;

  @override
  void initState() {
    super.initState();
    _ctrl = Get.find<AdminController>();
    _searchCtrl.addListener(() => setState(() => _page = 1));
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<ProductModel> _filtered(List<ProductModel> all) {
    final q = _searchCtrl.text.toLowerCase();
    return all.where((p) {
      if (q.isNotEmpty &&
          !p.name.toLowerCase().contains(q) &&
          !p.sku.toLowerCase().contains(q)) return false;
      if (_catFilter != null && _catFilter!.isNotEmpty && p.category != _catFilter) return false;
      if (_statusFilter == 'active' && p.quantity < 5) return false;
      if (_statusFilter == 'inactive' && p.quantity >= 5) return false;
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 900;
    return Scaffold(
      backgroundColor: _bg,
      body: isDesktop ? _desktopLayout(context) : _mobileLayout(context),
    );
  }

  // ─── LAYOUTS ─────────────────────────────────────────────────────────────────

  Widget _desktopLayout(BuildContext context) {
    return Row(
      children: [
        _sidebar(context),
        Expanded(child: _mainArea(context)),
      ],
    );
  }

  Widget _mobileLayout(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      drawer: Drawer(child: SafeArea(child: _sidebar(context))),
      body: _mainArea(context),
    );
  }

  // ─── SIDEBAR ─────────────────────────────────────────────────────────────────

  Widget _sidebar(BuildContext context) {
    return Container(
      width: 220,
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('Lentem',
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: _purple,
                        height: 1.1)),
                Text('Admin',
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: _purple,
                        height: 1.1)),
                SizedBox(height: 4),
                Text('Shop Management',
                    style: TextStyle(fontSize: 11, color: Colors.grey)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _navItem(icon: Icons.dashboard_outlined, label: 'Dashboard',
              onTap: () {}),
          _navItem(icon: Icons.inventory_2_outlined, label: 'Inventory',
              selected: true, onTap: () {}),
          _navItem(icon: Icons.shopping_cart_outlined, label: 'Orders',
              onTap: () => Get.toNamed(Routes.VOUCHER_HISTORY)),
          _navItem(icon: Icons.analytics_outlined, label: 'Analytics',
              onTap: () => Get.toNamed(Routes.ANALYTICS)),
          _navItem(icon: Icons.settings_outlined, label: 'Settings',
              onTap: () => _showStoreDetailsSheet(context)),
          const Spacer(),
          const Divider(height: 1),
          // Profile row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: _purpleLight,
                  child: const Icon(Icons.person, size: 18, color: _purple),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                  _ctrl.currentStore.name,
                  style: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w700),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                      Text(
                        AuthService.isStoreAdmin ? 'Lead Manager' : 'Viewer',
                        style: const TextStyle(fontSize: 10, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => _confirmLogout(context),
                  child: const Icon(Icons.logout, size: 16, color: Colors.grey),
                ),
              ],
            ),
          ),
          // Add New Product button
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 20),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Get.toNamed(Routes.ADD_PRODUCT),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E1B4B),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Add New Product',
                    style:
                        TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
              ),
            ),
          ),
        ],
      ),
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
          color: selected ? _purple : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(icon,
                size: 18,
                color: selected ? Colors.white : Colors.grey.shade500),
            const SizedBox(width: 10),
            Text(label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight:
                      selected ? FontWeight.w600 : FontWeight.normal,
                  color: selected ? Colors.white : Colors.grey.shade700,
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
        _topBar(context),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _titleRow(),
                const SizedBox(height: 24),
                _statCards(),
                const SizedBox(height: 24),
                _inventoryPanel(context),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ─── TOP BAR ─────────────────────────────────────────────────────────────────

  Widget _topBar(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFEEEEEE))),
      ),
      child: Row(
        children: [
          // Search
          SizedBox(
            width: 260,
            height: 38,
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search inventory...',
                hintStyle:
                    TextStyle(fontSize: 13, color: Colors.grey.shade400),
                prefixIcon:
                    Icon(Icons.search, size: 18, color: Colors.grey.shade400),
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
          const Spacer(),
          // Nav tabs
          _tabLink('Marketplace'),
          const SizedBox(width: 24),
          _tabLink('Earning'),
          const SizedBox(width: 24),
          _tabLink('Rewards'),
          const SizedBox(width: 24),
          // Bell
          Stack(
            clipBehavior: Clip.none,
            children: [
              const Icon(Icons.notifications_outlined,
                  size: 22, color: Color(0xFF374151)),
              Positioned(
                top: -2,
                right: -2,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                      color: Colors.orange, shape: BoxShape.circle),
                ),
              ),
            ],
          ),
          const SizedBox(width: 20),
          // Points badge
          Obx(() {
            final pts = _ctrl.totalStock.value * 10;
            return Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF3C7),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.local_offer_outlined,
                      size: 14, color: Color(0xFFD97706)),
                  const SizedBox(width: 5),
                  Text(
                    '${_formatNum(pts)} pts',
                    style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFD97706)),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _tabLink(String label) {
    return Text(label,
        style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Color(0xFF374151)));
  }

  // ─── TITLE ROW ───────────────────────────────────────────────────────────────

  Widget _titleRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Product Inventory',
                  style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF111827))),
              SizedBox(height: 4),
              Text('Manage your shop items and point redemption values.',
                  style: TextStyle(fontSize: 13, color: Colors.grey)),
            ],
          ),
        ),
        if (AuthService.isStoreAdmin)
          ElevatedButton.icon(
            onPressed: () => Get.toNamed(Routes.ADD_PRODUCT),
            icon: const Icon(Icons.add, size: 16, color: Colors.white),
            label: const Text('Add New Product',
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor: _purple,
              elevation: 0,
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
      ],
    );
  }

  // ─── STAT CARDS ──────────────────────────────────────────────────────────────

  Widget _statCards() {
    return Obx(() {
      final total = _ctrl.products.length;
      final lowStock = _ctrl.products.where((p) => p.quantity < 10).length;
      final activeCount =
          _ctrl.products.where((p) => p.quantity >= 5).length;
      final activePct =
          total > 0 ? (activeCount / total * 100).round() : 0;

      return Row(
        children: [
          Expanded(
            child: _statCard(
              iconBg: _purpleLight,
              iconColor: _purple,
              icon: Icons.inventory_2_outlined,
              label: 'Total Products',
              value: _formatNum(total),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _statCard(
              iconBg: const Color(0xFFFFF7ED),
              iconColor: const Color(0xFFF97316),
              icon: Icons.warning_amber_rounded,
              label: 'Low Stock Alerts',
              value: '$lowStock Items',
              valueColor: lowStock > 0
                  ? const Color(0xFFF97316)
                  : const Color(0xFF111827),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _statCard(
              iconBg: _purpleLight,
              iconColor: _purple,
              icon: Icons.stars_rounded,
              label: 'Active Rewards',
              value: '$activePct%',
            ),
          ),
        ],
      );
    });
  }

  Widget _statCard({
    required Color iconBg,
    required Color iconColor,
    required IconData icon,
    required String label,
    required String value,
    Color valueColor = const Color(0xFF111827),
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEEEEEE)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: iconBg,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 22, color: iconColor),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(fontSize: 12, color: Colors.grey)),
              const SizedBox(height: 4),
              Text(value,
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: valueColor)),
            ],
          ),
        ],
      ),
    );
  }

  // ─── INVENTORY PANEL ─────────────────────────────────────────────────────────

  Widget _inventoryPanel(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEEEEEE)),
      ),
      child: Column(
        children: [
          _filterBar(),
          _tableHeader(),
          Obx(() {
            final filtered = _filtered(_ctrl.products.toList());
            if (filtered.isEmpty) {
              return const Padding(
                padding: EdgeInsets.all(32),
                child: Center(
                  child: Text('No se encontraron productos.',
                      style: TextStyle(color: Colors.grey)),
                ),
              );
            }
            final total = filtered.length;
            final lastPage = (total / _pageSize).ceil().clamp(1, 9999);
            if (_page > lastPage) {
              WidgetsBinding.instance
                  .addPostFrameCallback((_) => setState(() => _page = 1));
            }
            final start = (_page - 1) * _pageSize;
            final end = math.min(start + _pageSize, total);
            final pageItems = filtered.sublist(start, end);
            return Column(
              children: [
                ...pageItems.map((p) => _productRow(context, p)),
                _paginationBar(total, lastPage),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _filterBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Row(
        children: [
          // Filter text field
          Expanded(
            child: SizedBox(
              height: 42,
              child: TextField(
                controller: _searchCtrl,
                decoration: InputDecoration(
                  hintText: 'Filter by product name...',
                  hintStyle:
                      TextStyle(fontSize: 13, color: Colors.grey.shade400),
                  prefixIcon: Icon(Icons.filter_list,
                      size: 18, color: Colors.grey.shade400),
                  filled: true,
                  fillColor: const Color(0xFFF9F9F9),
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 11),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide:
                        const BorderSide(color: _purple, width: 1.5),
                  ),
                ),
                style: const TextStyle(fontSize: 13),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Category dropdown
          Obx(() {
            final cats = ['All Categories',
              ..._ctrl.categories.map((c) => c.title).where((t) => t.isNotEmpty)
            ];
            return _filterDropdown(
              value: _catFilter ?? 'All Categories',
              items: cats,
              onChanged: (v) => setState(() {
                _catFilter = v == 'All Categories' ? null : v;
                _page = 1;
              }),
            );
          }),
          const SizedBox(width: 12),
          // Status dropdown
          _filterDropdown(
            value: _statusFilter == 'active'
                ? 'Active'
                : _statusFilter == 'inactive'
                    ? 'Inactive'
                    : 'All Status',
            items: const ['All Status', 'Active', 'Inactive'],
            onChanged: (v) => setState(() {
              if (v == 'Active') {
                _statusFilter = 'active';
              } else if (v == 'Inactive') {
                _statusFilter = 'inactive';
              } else {
                _statusFilter = null;
              }
              _page = 1;
            }),
          ),
        ],
      ),
    );
  }

  Widget _filterDropdown({
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      height: 42,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F9F9),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          items: items
              .map((e) => DropdownMenuItem(
                    value: e,
                    child: Text(e,
                        style: const TextStyle(
                            fontSize: 13, color: Color(0xFF374151))),
                  ))
              .toList(),
          onChanged: onChanged,
          icon: const Icon(Icons.keyboard_arrow_down,
              size: 18, color: Colors.grey),
          style: const TextStyle(fontSize: 13, color: Color(0xFF374151)),
        ),
      ),
    );
  }

  Widget _tableHeader() {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: Color(0xFFF0F0F0)),
          bottom: BorderSide(color: Color(0xFFF0F0F0)),
        ),
      ),
      child: const Row(
        children: [
          Expanded(flex: 3, child: _ColHeader('Product')),
          Expanded(flex: 2, child: _ColHeader('Category')),
          Expanded(flex: 2, child: _ColHeader('Value')),
          Expanded(flex: 2, child: _ColHeader('Stock Level')),
          Expanded(flex: 2, child: _ColHeader('Status')),
          SizedBox(width: 80, child: _ColHeader('Actions')),
        ],
      ),
    );
  }

  Widget _productRow(BuildContext context, ProductModel item) {
    final maxQty = _ctrl.products.isEmpty
        ? 1
        : _ctrl.products.map((p) => p.quantity).reduce(math.max);
    final stockPct =
        maxQty > 0 ? (item.quantity / maxQty).clamp(0.0, 1.0) : 0.0;
    final isLow = item.quantity < 10;
    final isActive = item.quantity >= 5;
    final pointsValue = item.pointsRequired > 0
        ? item.pointsRequired
        : item.discountPrice.toInt();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFF5F5F5))),
      ),
      child: Row(
        children: [
          // Product
          Expanded(
            flex: 3,
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: item.image.startsWith('http')
                      ? Image.network(
                          item.image,
                          width: 40,
                          height: 40,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _imgPlaceholder(),
                        )
                      : _imgPlaceholder(),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.name,
                          style: const TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w600,
                              color: Color(0xFF111827)),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                      Text('SKU: ${item.sku.isNotEmpty ? item.sku : item.id.substring(0, math.min(6, item.id.length)).toUpperCase()}',
                          style: const TextStyle(
                              fontSize: 11, color: Colors.grey)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Category
          Expanded(
            flex: 2,
            child: item.category.isNotEmpty
                ? Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _catColor(item.category).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      item.category,
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: _catColor(item.category)),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  )
                : const Text('—',
                    style: TextStyle(fontSize: 12, color: Colors.grey)),
          ),
          // Value
          Expanded(
            flex: 2,
            child: Row(
              children: [
                const Icon(Icons.star_rounded,
                    size: 14, color: Color(0xFFD97706)),
                const SizedBox(width: 4),
                Text(
                  '${_formatNum(pointsValue)} pts',
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF111827)),
                ),
              ],
            ),
          ),
          // Stock Level
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${item.quantity} / ${item.stock > 0 ? item.stock : item.quantity + 50}',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isLow
                          ? const Color(0xFFDC2626)
                          : const Color(0xFF374151)),
                ),
                const SizedBox(height: 4),
                LinearProgressIndicator(
                  value: stockPct,
                  backgroundColor: const Color(0xFFEEEEEE),
                  valueColor: AlwaysStoppedAnimation<Color>(
                      isLow ? const Color(0xFFDC2626) : _purple),
                  minHeight: 5,
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            ),
          ),
          // Status
          Expanded(
            flex: 2,
            child: Row(
              children: [
                Transform.scale(
                  scale: 0.8,
                  child: Switch(
                    value: isActive,
                    onChanged: null,
                    activeColor: _purple,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
                Text(
                  isActive ? 'Active' : 'Inactive',
                  style: TextStyle(
                      fontSize: 12,
                      color: isActive
                          ? const Color(0xFF374151)
                          : Colors.grey),
                ),
              ],
            ),
          ),
          // Actions
          SizedBox(
            width: 80,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (AuthService.isStoreAdmin) ...[
                  GestureDetector(
                    onTap: () =>
                        Get.toNamed(Routes.ADD_PRODUCT, arguments: item),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.edit_outlined,
                          size: 14, color: Color(0xFF3B82F6)),
                    ),
                  ),
                  const SizedBox(width: 6),
                  GestureDetector(
                    onTap: () => _confirmDelete(context, item),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF2F2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.delete_outline,
                          size: 14, color: Color(0xFFEF4444)),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _imgPlaceholder() {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: _purpleLight,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(Icons.inventory_2_outlined, size: 18, color: _purple),
    );
  }

  Color _catColor(String cat) {
    final lower = cat.toLowerCase();
    if (lower.contains('food') || lower.contains('bever')) {
      return const Color(0xFF16A34A);
    }
    if (lower.contains('electr')) return const Color(0xFF2563EB);
    if (lower.contains('apparel') || lower.contains('cloth')) {
      return const Color(0xFF9333EA);
    }
    if (lower.contains('beauty') || lower.contains('health')) {
      return const Color(0xFFDB2777);
    }
    return const Color(0xFF6B7280);
  }

  // ─── PAGINATION ──────────────────────────────────────────────────────────────

  Widget _paginationBar(int total, int lastPage) {
    final start = (_page - 1) * _pageSize + 1;
    final end = math.min(_page * _pageSize, total);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        children: [
          Text('Showing $start to $end of $total entries',
              style: const TextStyle(fontSize: 12, color: Colors.grey)),
          const Spacer(),
          _pgBtn(
            icon: Icons.chevron_left,
            enabled: _page > 1,
            onTap: () => setState(() => _page--),
          ),
          ..._pageNums(lastPage)
              .map((n) => n == -1 ? _pgDots() : _pgNum(n)),
          _pgBtn(
            icon: Icons.chevron_right,
            enabled: _page < lastPage,
            onTap: () => setState(() => _page++),
          ),
        ],
      ),
    );
  }

  String _formatNum(int n) {
    if (n >= 1000) {
      return '${(n / 1000).toStringAsFixed(n % 1000 == 0 ? 0 : 1)}k';
    }
    return '$n';
  }

  List<int> _pageNums(int last) {
    if (last <= 5) return List.generate(last, (i) => i + 1);
    if (_page <= 3) return [1, 2, 3, -1, last];
    if (_page >= last - 2) return [1, -1, last - 2, last - 1, last];
    return [1, -1, _page, -1, last];
  }

  Widget _pgNum(int n) {
    final sel = n == _page;
    return GestureDetector(
      onTap: () => setState(() => _page = n),
      child: Container(
        width: 32,
        height: 32,
        margin: const EdgeInsets.symmetric(horizontal: 2),
        decoration: BoxDecoration(
          color: sel ? _purple : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        alignment: Alignment.center,
        child: Text('$n',
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: sel ? Colors.white : const Color(0xFF374151))),
      ),
    );
  }

  Widget _pgDots() {
    return const SizedBox(
      width: 28,
      child: Center(
          child:
              Text('...', style: TextStyle(fontSize: 13, color: Colors.grey))),
    );
  }

  Widget _pgBtn(
      {required IconData icon,
      required bool enabled,
      required VoidCallback onTap}) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: 32,
        height: 32,
        margin: const EdgeInsets.symmetric(horizontal: 2),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon,
            size: 18,
            color: enabled ? const Color(0xFF374151) : Colors.grey.shade300),
      ),
    );
  }

  // ─── DELETE CONFIRM ──────────────────────────────────────────────────────────

  void _confirmDelete(BuildContext context, ProductModel item) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Eliminar producto'),
        content: Text(
            '¿Eliminar "${item.name}"? Esta acción no se puede deshacer.'),
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
            onPressed: () {
              Navigator.of(ctx).pop();
              _ctrl.deleteProduct(item);
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  // ─── LOGOUT ──────────────────────────────────────────────────────────────────

  void _confirmLogout(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
              await AuthService.signOut();
              Get.offAllNamed(Routes.LOGIN);
            },
            child: const Text('Cerrar sesión'),
          ),
        ],
      ),
    );
  }

  // ─── STORE DETAILS SHEET ─────────────────────────────────────────────────────

  void _showStoreDetailsSheet(BuildContext context) {
    final theme = context.theme;
    final store = _ctrl.currentStore;
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(24.w),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16.r),
                  child: store.logoUrl.startsWith('assets/')
                      ? Image.asset(store.logoUrl,
                          width: 80.w, height: 80.w, fit: BoxFit.cover)
                      : Image.network(store.logoUrl,
                          width: 80.w, height: 80.w, fit: BoxFit.cover),
                ),
              ),
              16.verticalSpace,
              Center(
                  child: Text(store.name,
                      style: theme.textTheme.headlineSmall)),
              8.verticalSpace,
              Center(
                  child: Text(store.description,
                      style: theme.textTheme.bodyMedium,
                      textAlign: TextAlign.center)),
              24.verticalSpace,
              _sheetSection(theme, 'Datos fiscales', [
                _sheetRow(theme, 'ID fiscal', store.fiscalId),
                _sheetRow(theme, 'Email facturación', store.billingEmail),
                _sheetRow(theme, 'Teléfono', store.billingPhone),
              ]),
              _sheetSection(theme, 'Dirección', [
                _sheetRow(theme, 'Dirección', store.address),
                _sheetRow(theme, 'Email dueño', store.ownerEmail),
                _sheetRow(theme, 'PIN', store.pin),
              ]),
              _sheetSection(theme, 'Usuarios', []),
              Obx(() => Column(
                    children: _ctrl.storeUsers
                        .map((user) => Container(
                              margin: EdgeInsets.only(bottom: 8.h),
                              padding: EdgeInsets.all(12.w),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF5F3FF),
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.person_outline,
                                      size: 16, color: _purple),
                                  8.horizontalSpace,
                                  Expanded(
                                      child: Text(user.email,
                                          style: theme.textTheme.bodySmall)),
                                  Text(
                                    user.role ==
                                            AuthService.storeAdminRole
                                        ? 'Admin'
                                        : 'Viewer',
                                    style: TextStyle(
                                        fontSize: 10.sp,
                                        color: _purple,
                                        fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                            ))
                        .toList(),
                  )),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _sheetSection(ThemeData theme, String title, List<Widget> rows) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: theme.textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.w700)),
        8.verticalSpace,
        ...rows,
        16.verticalSpace,
      ],
    );
  }

  Widget _sheetRow(ThemeData theme, String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 6.h),
      child: Row(
        children: [
          Expanded(
              flex: 2,
              child: Text('$label:',
                  style: theme.textTheme.bodySmall
                      ?.copyWith(fontWeight: FontWeight.w600))),
          Expanded(
              flex: 3,
              child: Text(value, style: theme.textTheme.bodySmall)),
        ],
      ),
    );
  }
}

// ─── HELPERS ─────────────────────────────────────────────────────────────────

class _ColHeader extends StatelessWidget {
  final String text;
  const _ColHeader(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(text,
        style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: Colors.grey,
            letterSpacing: 0.3));
  }
}
