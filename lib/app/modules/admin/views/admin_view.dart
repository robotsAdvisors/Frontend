import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../utils/constants.dart';
import '../../../data/models/product_model.dart';
import '../../../data/services/auth_service.dart';
import '../../../routes/app_pages.dart';
import '../controllers/admin_controller.dart';

class AdminView extends GetView<AdminController> {
  const AdminView({Key? key}) : super(key: key);

  static const Color _purple = Color(0xFF7C3AED);
  static const Color _purpleLight = Color(0xFFEDE9FE);
  static const Color _bg = Color(0xFFF8F7FF);

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 900;
    return Scaffold(
      backgroundColor: _bg,
      body: isDesktop ? _desktopLayout(context) : _mobileLayout(context),
    );
  }

  // ─── DESKTOP ────────────────────────────────────────────────────────────────

  Widget _desktopLayout(BuildContext context) {
    return Row(
      children: [
        _sidebar(context),
        Expanded(child: _mainArea(context, desktop: true)),
      ],
    );
  }

  Widget _sidebar(BuildContext context) {
    final store = controller.currentStore;
    return Container(
      width: 220,
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Brand
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SvgPicture.asset(Constants.logo, height: 24),
                const SizedBox(height: 4),
                const Text('Shop Management',
                    style: TextStyle(fontSize: 11, color: Colors.grey)),
              ],
            ),
          ),
          const Divider(height: 1),
          const SizedBox(height: 12),
          _sideNavItem(icon: Icons.dashboard_outlined, label: 'Dashboard', selected: true),
          _sideNavItem(icon: Icons.inventory_2_outlined, label: 'Inventory', onTap: () {}),
          _sideNavItem(icon: Icons.receipt_long_outlined, label: 'Vouchers', onTap: () => Get.toNamed(Routes.VOUCHER_HISTORY)),
          _sideNavItem(icon: Icons.analytics_outlined, label: 'Analytics', onTap: () {}),
          _sideNavItem(icon: Icons.store_outlined, label: 'Datos tienda', onTap: () => _showStoreDetailsSheet(context)),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),
          if (AuthService.isStoreAdmin)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.add, size: 16, color: Colors.white),
                  label: const Text('Añadir producto',
                      style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
                  onPressed: () => _showCreateProductDialog(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _purple,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ),
          const Spacer(),
          const Divider(height: 1),
          // User profile footer
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: _purpleLight,
                  child: const Icon(Icons.person_outline, size: 16, color: _purple),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(store.name,
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                      Text(AuthService.isStoreAdmin ? 'Admin' : 'Viewer',
                          style: const TextStyle(fontSize: 11, color: Colors.grey)),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Cerrar sesión',
                  icon: const Icon(Icons.logout, size: 18, color: Colors.grey),
                  onPressed: () => _confirmLogout(context),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sideNavItem({
    required IconData icon,
    required String label,
    bool selected = false,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? _purpleLight : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: selected ? _purple : Colors.grey.shade500),
            const SizedBox(width: 10),
            Text(label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                  color: selected ? _purple : Colors.grey.shade700,
                )),
          ],
        ),
      ),
    );
  }

  Widget _mainArea(BuildContext context, {required bool desktop}) {
    return Column(
      children: [
        _topBar(context, desktop: desktop),
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(desktop ? 24 : 16),
            child: desktop
                ? _desktopContent(context)
                : _mobileContent(context),
          ),
        ),
      ],
    );
  }

  Widget _topBar(BuildContext context, {required bool desktop}) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFEEEEEE))),
      ),
      child: Row(
        children: [
          if (!desktop)
            IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          const Text('Overview',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1E1B4B))),
          const Spacer(),
          SizedBox(
            width: desktop ? 220 : 140,
            height: 36,
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Buscar...',
                hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                prefixIcon: Icon(Icons.search, size: 16, color: Colors.grey.shade400),
                filled: true,
                fillColor: const Color(0xFFF5F5F5),
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(50),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.notifications_outlined, size: 20),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.grid_view_outlined, size: 20),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _desktopContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _statCards(),
        const SizedBox(height: 24),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 3, child: _inventoryTable(context)),
            const SizedBox(width: 20),
            SizedBox(width: 280, child: _recentRedemptions(context)),
          ],
        ),
        const SizedBox(height: 20),
        _promoBanner(context),
      ],
    );
  }

  Widget _mobileContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _statCards(),
        const SizedBox(height: 20),
        _inventoryTable(context),
        const SizedBox(height: 20),
        _recentRedemptions(context),
        const SizedBox(height: 20),
        _promoBanner(context),
      ],
    );
  }

  Widget _statCards() {
    return Obx(() {
      final redemptions = controller.redeemedVouchers.length;
      final distributed = controller.vouchers.length;
      final skus = controller.totalProducts.value;
      return LayoutBuilder(builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 600;
        final cards = [
          _statCard(
            title: 'Redemptions (Mo)',
            value: redemptions.toString(),
            sub: '+12% vs last month',
            subColor: Colors.green,
            icon: Icons.redeem_outlined,
            iconBg: const Color(0xFFEDE9FE),
            iconColor: _purple,
          ),
          _statCard(
            title: 'Points Distributed',
            value: distributed.toString(),
            sub: 'Gold Tier',
            subColor: const Color(0xFFD97706),
            icon: Icons.stars_rounded,
            iconBg: const Color(0xFFFEF3C7),
            iconColor: const Color(0xFFD97706),
            badge: 'Gold',
          ),
          _statCard(
            title: 'Active Inventory',
            value: skus.toString(),
            sub: 'SKUs activos',
            subColor: Colors.grey,
            icon: Icons.inventory_2_outlined,
            iconBg: const Color(0xFFECFDF5),
            iconColor: Colors.green,
          ),
          _storeRatingCard(),
        ];
        if (isWide) {
          return Row(
            children: cards
                .map((c) => Expanded(child: Padding(padding: const EdgeInsets.only(right: 12), child: c)))
                .toList(),
          );
        }
        return Column(
          children: cards.map((c) => Padding(padding: const EdgeInsets.only(bottom: 12), child: c)).toList(),
        );
      });
    });
  }

  Widget _statCard({
    required String title,
    required String value,
    required String sub,
    required Color subColor,
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    String? badge,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEEEEEE)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(10)),
                child: Icon(icon, size: 18, color: iconColor),
              ),
              if (badge != null) ...[
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF3C7),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(badge,
                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFFD97706))),
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),
          Text(value,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Color(0xFF1E1B4B))),
          const SizedBox(height: 4),
          Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 4),
          Text(sub, style: TextStyle(fontSize: 11, color: subColor, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _storeRatingCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF7C3AED), Color(0xFF5B21B6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.star_outlined, size: 18, color: Colors.white),
          ),
          const SizedBox(height: 12),
          const Text('4.8',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white)),
          const SizedBox(height: 4),
          const Text('Store Rating', style: TextStyle(fontSize: 12, color: Colors.white70)),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () => showDialog<void>(
              context: Get.context!,
              builder: (ctx) => AlertDialog(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                title: const Text('Reseñas'),
                content: const Text('La sección de reseñas estará disponible próximamente.'),
                actions: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _purple,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () => Navigator.of(ctx).pop(),
                    child: const Text('Entendido'),
                  ),
                ],
              ),
            ),
            child: const Text('View Reviews →',
                style: TextStyle(
                    fontSize: 11, color: Colors.white, fontWeight: FontWeight.w600,
                    decoration: TextDecoration.underline, decorationColor: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _inventoryTable(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEEEEEE)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
            child: Row(
              children: [
                const Text('Active Inventory',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF1E1B4B))),
                const Spacer(),
                if (AuthService.isStoreAdmin)
                  TextButton(
                    onPressed: () => _showCreateProductDialog(context),
                    child: const Text('+ Añadir', style: TextStyle(fontSize: 12, color: _purple)),
                  ),
              ],
            ),
          ),
          // Header row
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: const BoxDecoration(
              color: Color(0xFFF9F9F9),
              border: Border(
                top: BorderSide(color: Color(0xFFEEEEEE)),
                bottom: BorderSide(color: Color(0xFFEEEEEE)),
              ),
            ),
            child: const Row(
              children: [
                Expanded(flex: 3, child: Text('Product Name', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.grey))),
                Expanded(flex: 2, child: Text('Points Cost', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.grey))),
                Expanded(flex: 2, child: Text('Stock Level', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.grey))),
                Expanded(flex: 2, child: Text('Status', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.grey))),
              ],
            ),
          ),
          Obx(() {
            if (controller.products.isEmpty) {
              return const Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: Text('No hay productos registrados.')),
              );
            }
            return Column(
              children: controller.products.map((item) => _inventoryRow(context, item)).toList(),
            );
          }),
        ],
      ),
    );
  }

  Widget _inventoryRow(BuildContext context, ProductModel item) {
    final stockRatio = item.quantity > 0 ? (item.quantity / 100).clamp(0.0, 1.0) : 0.0;
    final isLow = item.quantity < 10;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFF0F0F0))),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F3FF),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.inventory_2_outlined, size: 16, color: _purple),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.name,
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                          maxLines: 1, overflow: TextOverflow.ellipsis),
                      Text(item.sku,
                          style: const TextStyle(fontSize: 10, color: Colors.grey)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              '${item.discountPrice.toStringAsFixed(0)} pts',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: _purple),
            ),
          ),
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${item.quantity} units', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                const SizedBox(height: 4),
                LinearProgressIndicator(
                  value: stockRatio,
                  backgroundColor: const Color(0xFFEEEEEE),
                  color: isLow ? Colors.orange : _purple,
                  minHeight: 4,
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                    decoration: BoxDecoration(
                      color: isLow
                          ? Colors.orange.withValues(alpha: 0.12)
                          : Colors.green.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      isLow ? 'Low Stock' : 'Active',
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: isLow ? Colors.orange.shade700 : Colors.green.shade700,
                      ),
                    ),
                  ),
                ),
                if (AuthService.isStoreAdmin)
                  GestureDetector(
                    onTap: () => controller.deleteProduct(item),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 6),
                      child: Icon(Icons.delete_outline, size: 16, color: Colors.red.shade300),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _recentRedemptions(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEEEEEE)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 16, 20, 12),
            child: Text('Recent Redemptions',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF1E1B4B))),
          ),
          const Divider(height: 1),
          Obx(() {
            final redeemed = controller.redeemedVouchers;
            if (redeemed.isEmpty) {
              return const Padding(
                padding: EdgeInsets.all(20),
                child: Text('No hay canjes recientes.', style: TextStyle(color: Colors.grey, fontSize: 13)),
              );
            }
            return Column(
              children: redeemed.take(5).map((voucher) {
                final name = controller.customerNameFor(voucher);
                final date = voucher.createdAt.toLocal().toString().split(' ').first;
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: const BoxDecoration(
                    border: Border(bottom: BorderSide(color: Color(0xFFF0F0F0))),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: const Color(0xFFEDE9FE),
                        child: Text(
                          name.isNotEmpty ? name[0].toUpperCase() : 'U',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: _purple),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(name,
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                                maxLines: 1, overflow: TextOverflow.ellipsis),
                            Text(voucher.code,
                                style: const TextStyle(fontSize: 10, color: Colors.grey)),
                          ],
                        ),
                      ),
                      Text(date, style: const TextStyle(fontSize: 10, color: Colors.grey)),
                    ],
                  ),
                );
              }).toList(),
            );
          }),
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Get.toNamed(Routes.VOUCHER_HISTORY),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: _purple),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                ),
                child: const Text('View All History',
                    style: TextStyle(color: _purple, fontSize: 12, fontWeight: FontWeight.w600)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _promoBanner(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF7C3AED), Color(0xFF4F46E5)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.rocket_launch_outlined, color: Colors.white, size: 28),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Expand Your Reach',
                    style: TextStyle(
                        color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700)),
                SizedBox(height: 4),
                Text('Añade más productos y aumenta tus canjes mensuales.',
                    style: TextStyle(color: Colors.white70, fontSize: 12)),
              ],
            ),
          ),
          if (AuthService.isStoreAdmin)
            ElevatedButton(
              onPressed: () => _showCreateProductDialog(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: _purple,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Añadir producto',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
            ),
        ],
      ),
    );
  }

  // ─── MOBILE ─────────────────────────────────────────────────────────────────

  Widget _mobileLayout(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      drawer: Drawer(
        child: SafeArea(child: _sidebar(context)),
      ),
      body: _mainArea(context, desktop: false),
    );
  }

  // ─── LOGOUT ─────────────────────────────────────────────────────────────────

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
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _purple,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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

  // ─── STORE DETAILS SHEET ────────────────────────────────────────────────────

  void _showStoreDetailsSheet(BuildContext context) {
    final theme = context.theme;
    final store = controller.currentStore;
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
                      ? Image.asset(store.logoUrl, width: 80.w, height: 80.w, fit: BoxFit.cover)
                      : Image.network(store.logoUrl, width: 80.w, height: 80.w, fit: BoxFit.cover),
                ),
              ),
              16.verticalSpace,
              Center(child: Text(store.name, style: theme.textTheme.headlineSmall)),
              8.verticalSpace,
              Center(child: Text(store.description, style: theme.textTheme.bodyMedium, textAlign: TextAlign.center)),
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
                children: controller.storeUsers.map((user) => Container(
                  margin: EdgeInsets.only(bottom: 8.h),
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F3FF),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.person_outline, size: 16, color: _purple),
                      8.horizontalSpace,
                      Expanded(child: Text(user.email, style: theme.textTheme.bodySmall)),
                      Text(
                        user.role == AuthService.storeAdminRole ? 'Admin' : 'Viewer',
                        style: TextStyle(fontSize: 10.sp, color: _purple, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                )).toList(),
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
        Text(title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
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
          Expanded(flex: 2, child: Text('$label:', style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600))),
          Expanded(flex: 3, child: Text(value, style: theme.textTheme.bodySmall)),
        ],
      ),
    );
  }

  // ─── CREATE PRODUCT DIALOG ──────────────────────────────────────────────────

  void _showCreateProductDialog(BuildContext context) {
    final imageController = TextEditingController();
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    final categoryController = TextEditingController();
    final skuController = TextEditingController();
    final originalPriceController = TextEditingController();
    final discountPriceController = TextEditingController();
    final stockController = TextEditingController();

    Get.dialog(
      AlertDialog(
        title: const Text('Añadir producto'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: imageController, decoration: const InputDecoration(labelText: 'URL de imagen del producto')),
              TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Nombre del producto')),
              TextField(controller: descriptionController, decoration: const InputDecoration(labelText: 'Descripción completa'), maxLines: 3),
              TextField(controller: categoryController, decoration: const InputDecoration(labelText: 'Categoría')),
              TextField(controller: skuController, decoration: const InputDecoration(labelText: 'SKU')),
              TextField(controller: originalPriceController, decoration: const InputDecoration(labelText: 'Precio original'), keyboardType: const TextInputType.numberWithOptions(decimal: true)),
              TextField(controller: discountPriceController, decoration: const InputDecoration(labelText: 'Precio con descuento'), keyboardType: const TextInputType.numberWithOptions(decimal: true)),
              TextField(controller: stockController, decoration: const InputDecoration(labelText: 'Stock disponible'), keyboardType: TextInputType.number),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancelar')),
          TextButton(
            onPressed: () {
              final image = imageController.text.trim();
              final name = nameController.text.trim();
              final description = descriptionController.text.trim();
              final originalPrice = double.tryParse(originalPriceController.text.trim());
              final discountPrice = double.tryParse(discountPriceController.text.trim());
              final stock = int.tryParse(stockController.text.trim());

              if (name.isEmpty || description.isEmpty || categoryController.text.trim().isEmpty ||
                  skuController.text.trim().isEmpty || originalPrice == null ||
                  discountPrice == null || stock == null) {
                Get.snackbar('Error', 'Complete todos los campos obligatorios.');
                return;
              }

              controller.addProduct(ProductModel(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                image: image.isNotEmpty ? image : Constants.background,
                name: name,
                description: description,
                category: categoryController.text.trim(),
                sku: skuController.text.trim(),
                quantity: stock,
                originalPrice: originalPrice,
                discountPrice: discountPrice,
                storeId: controller.storeId.value.isNotEmpty ? controller.storeId.value : 'store_1',
              ));
              Get.back();
              Get.snackbar('Éxito', 'Producto agregado correctamente');
            },
            child: const Text('Agregar'),
          ),
        ],
      ),
    );
  }
}
