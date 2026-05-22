import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../../../utils/constants.dart';
import '../../../data/models/store_model.dart';
import '../../../data/models/store_user_model.dart';
import '../controllers/general_admin_controller.dart';

class GeneralAdminView extends GetView<GeneralAdminController> {
  const GeneralAdminView({Key? key}) : super(key: key);

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
    return Container(
      width: 220,
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 14,
                  backgroundColor: _purple,
                  child: Padding(
                    padding: const EdgeInsets.all(3),
                    child: SvgPicture.asset(Constants.logo),
                  ),
                ),
                const SizedBox(width: 8),
                const Text('Letdem',
                    style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: Color(0xFF1E1B4B))),
              ],
            ),
          ),
          const Divider(height: 1),
          const SizedBox(height: 12),
          _sideNavItem(icon: Icons.dashboard_outlined, label: 'Dashboard', selected: true),
          _sideNavItem(icon: Icons.store_outlined, label: 'Stores', onTap: () {}),
          _sideNavItem(icon: Icons.security_outlined, label: 'Permissions', onTap: () {}),
          _sideNavItem(icon: Icons.bar_chart_outlined, label: 'Global Metrics', onTap: () {}),
          _sideNavItem(icon: Icons.settings_outlined, label: 'Settings', onTap: () {}),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: _purpleLight,
                  child: const Icon(Icons.admin_panel_settings_outlined, size: 16, color: _purple),
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Super Admin',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                          maxLines: 1, overflow: TextOverflow.ellipsis),
                      Text('General Admin', style: TextStyle(fontSize: 11, color: Colors.grey)),
                    ],
                  ),
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
            child: desktop ? _desktopContent(context) : _mobileContent(context),
          ),
        ),
      ],
    );
  }

  Widget _topBar(BuildContext context, {required bool desktop}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFEEEEEE))),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (!desktop)
            IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Super Admin Dashboard',
                  style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF1E1B4B))),
              Text('Letdem Network Control Panel',
                  style: TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.notifications_outlined, size: 20),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
          ElevatedButton.icon(
            icon: const Icon(Icons.add, size: 16, color: Colors.white),
            label: const Text('Add New Store',
                style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
            onPressed: () => _showCreateStoreDialog(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: _purple,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
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
            Expanded(flex: 3, child: _storesTable(context)),
            const SizedBox(width: 20),
            SizedBox(width: 280, child: _permissionsPanel(context)),
          ],
        ),
        const SizedBox(height: 20),
        _networkGrowthCard(),
      ],
    );
  }

  Widget _mobileContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _statCards(),
        const SizedBox(height: 20),
        _storesTable(context),
        const SizedBox(height: 20),
        _permissionsPanel(context),
        const SizedBox(height: 20),
        _networkGrowthCard(),
      ],
    );
  }

  Widget _statCards() {
    return Obx(() {
      final totalStores = controller.totalStores.value;
      final activeUsers = controller.totalStoreUsers.value;
      final redemptions = 0; // placeholder — backend not yet exposing global redemptions
      return LayoutBuilder(builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 600;
        final cards = [
          _statCard(
            title: 'Total Stores',
            value: totalStores.toString(),
            sub: 'Registered networks',
            subColor: Colors.grey,
            icon: Icons.store_outlined,
            iconBg: const Color(0xFFEDE9FE),
            iconColor: _purple,
          ),
          _statCard(
            title: 'Active Users',
            value: activeUsers.toString(),
            sub: '+8% this month',
            subColor: Colors.green,
            icon: Icons.people_outline,
            iconBg: const Color(0xFFECFDF5),
            iconColor: Colors.green,
          ),
          _statCard(
            title: 'Total Redemptions',
            value: redemptions.toString(),
            sub: '0 pts distributed',
            subColor: Colors.grey,
            icon: Icons.redeem_outlined,
            iconBg: const Color(0xFFFEF3C7),
            iconColor: const Color(0xFFD97706),
          ),
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
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, size: 18, color: iconColor),
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

  Widget _storesTable(BuildContext context) {
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
                const Text('Active Stores',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF1E1B4B))),
                const Spacer(),
                TextButton(
                  onPressed: () => _showCreateUserDialog(context),
                  child: const Text('+ Usuario', style: TextStyle(fontSize: 12, color: _purple)),
                ),
              ],
            ),
          ),
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
                Expanded(flex: 3, child: Text('Store Name', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.grey))),
                Expanded(flex: 2, child: Text('Owner', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.grey))),
                Expanded(flex: 1, child: Text('Status', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.grey))),
                Expanded(flex: 1, child: Text('Admins', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.grey))),
                SizedBox(width: 60),
              ],
            ),
          ),
          Obx(() {
            if (controller.stores.isEmpty) {
              return const Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: Text('No hay tiendas registradas.')),
              );
            }
            return Column(
              children: controller.stores.map((store) => _storeRow(context, store)).toList(),
            );
          }),
        ],
      ),
    );
  }

  Widget _storeRow(BuildContext context, StoreModel store) {
    final initials = store.name.isNotEmpty
        ? store.name.trim().split(' ').take(2).map((w) => w[0].toUpperCase()).join()
        : '?';
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
                CircleAvatar(
                  radius: 16,
                  backgroundColor: _purpleLight,
                  child: Text(initials,
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: _purple)),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(store.name,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(store.ownerEmail,
                style: const TextStyle(fontSize: 11, color: Colors.grey),
                maxLines: 1, overflow: TextOverflow.ellipsis),
          ),
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text('Active',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.green),
                  textAlign: TextAlign.center),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text('${store.adminUserIds.length}',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
                textAlign: TextAlign.center),
          ),
          SizedBox(
            width: 60,
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {},
                  child: const Icon(Icons.edit_outlined, size: 16, color: _purple),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => _confirmDeleteStore(store.id),
                  child: Icon(Icons.delete_outline, size: 16, color: Colors.red.shade300),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _permissionsPanel(BuildContext context) {
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
            child: Text('System Permissions',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF1E1B4B))),
          ),
          const Divider(height: 1),
          _permissionRow(
            title: 'Super Admin',
            sub: '1 user',
            icon: Icons.admin_panel_settings_outlined,
            iconColor: _purple,
            iconBg: _purpleLight,
          ),
          Obx(() => _permissionRow(
            title: 'Store Managers',
            sub: '${controller.totalStoreUsers.value} users',
            icon: Icons.manage_accounts_outlined,
            iconColor: Colors.blue,
            iconBg: const Color(0xFFEFF6FF),
          )),
          _permissionRow(
            title: 'Support Team',
            sub: 'Read-only access',
            icon: Icons.support_agent_outlined,
            iconColor: Colors.green,
            iconBg: const Color(0xFFECFDF5),
          ),
          const Divider(height: 1),
          // Security compliance
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Text('Security Compliance',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF1E1B4B))),
                    Spacer(),
                    Text('98%', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: _purple)),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: const LinearProgressIndicator(
                    value: 0.98,
                    minHeight: 6,
                    backgroundColor: Color(0xFFEEEEEE),
                    valueColor: AlwaysStoppedAnimation<Color>(_purple),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: _purple),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                ),
                child: const Text('Manage Global Roles',
                    style: TextStyle(color: _purple, fontSize: 12, fontWeight: FontWeight.w600)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _permissionRow({
    required String title,
    required String sub,
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFF0F0F0))),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, size: 16, color: iconColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                Text(sub, style: const TextStyle(fontSize: 11, color: Colors.grey)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, size: 16, color: Colors.grey),
        ],
      ),
    );
  }

  Widget _networkGrowthCard() {
    final tabs = ['7D', '30D', '6M'];
    final selectedTab = 1.obs;
    return Obx(() {
      final sel = selectedTab.value;
      return Container(
        padding: const EdgeInsets.all(20),
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
                const Text('Network Growth',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF1E1B4B))),
                const Spacer(),
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: tabs.asMap().entries.map((entry) {
                      final i = entry.key;
                      final label = entry.value;
                      final isSelected = i == sel;
                      return GestureDetector(
                        onTap: () => selectedTab.value = i,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.white : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: isSelected ? [const BoxShadow(color: Color(0x1A000000), blurRadius: 4)] : [],
                          ),
                          child: Text(label,
                              style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.normal,
                                  color: isSelected ? _purple : Colors.grey)),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 80,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: List.generate(7, (i) {
                  final heightFactor = (0.3 + (i * 0.1)).clamp(0.0, 0.9);
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3),
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: Container(
                          height: 80 * heightFactor,
                          decoration: BoxDecoration(
                            color: i == 5 ? _purple : _purpleLight,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 8),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Mon', style: TextStyle(fontSize: 10, color: Colors.grey)),
                Text('Tue', style: TextStyle(fontSize: 10, color: Colors.grey)),
                Text('Wed', style: TextStyle(fontSize: 10, color: Colors.grey)),
                Text('Thu', style: TextStyle(fontSize: 10, color: Colors.grey)),
                Text('Fri', style: TextStyle(fontSize: 10, color: Colors.grey)),
                Text('Sat', style: TextStyle(fontSize: 10, color: Colors.grey)),
                Text('Sun', style: TextStyle(fontSize: 10, color: Colors.grey)),
              ],
            ),
          ],
        ),
      );
    });
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

  // ─── DIALOGS ─────────────────────────────────────────────────────────────────

  void _showCreateStoreDialog(BuildContext context) {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    final ownerEmailController = TextEditingController();

    Get.dialog(
      AlertDialog(
        title: const Text('Crear Nueva Tienda'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Nombre de la tienda')),
            TextField(controller: descriptionController, decoration: const InputDecoration(labelText: 'Descripción')),
            TextField(controller: ownerEmailController, decoration: const InputDecoration(labelText: 'Email del dueño')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancelar')),
          TextButton(
            onPressed: () {
              if (nameController.text.isNotEmpty &&
                  descriptionController.text.isNotEmpty &&
                  ownerEmailController.text.isNotEmpty) {
                controller.addStore(StoreModel(
                  id: 'store_${DateTime.now().millisecondsSinceEpoch}',
                  name: nameController.text,
                  description: descriptionController.text,
                  ownerId: 'owner_${DateTime.now().millisecondsSinceEpoch}',
                  ownerEmail: ownerEmailController.text,
                  adminUserIds: [],
                  fiscalId: 'FISCAL${DateTime.now().millisecondsSinceEpoch}',
                  address: 'Dirección por definir',
                  logoUrl: Constants.logo,
                  billingEmail: ownerEmailController.text,
                  billingPhone: '000 000 0000',
                  pin: '0000',
                  createdAt: DateTime.now(),
                ));
                Get.back();
                Get.snackbar('Éxito', 'Tienda creada correctamente');
              }
            },
            child: const Text('Crear'),
          ),
        ],
      ),
    );
  }

  void _showCreateUserDialog(BuildContext context) {
    final emailController = TextEditingController();
    final storeIdController = TextEditingController();

    Get.dialog(
      AlertDialog(
        title: const Text('Crear Usuario de Tienda'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: emailController, decoration: const InputDecoration(labelText: 'Email del usuario')),
            TextField(controller: storeIdController, decoration: const InputDecoration(labelText: 'ID de la tienda')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancelar')),
          TextButton(
            onPressed: () {
              if (emailController.text.isNotEmpty && storeIdController.text.isNotEmpty) {
                controller.addStoreUser(StoreUserModel(
                  id: 'admin_${DateTime.now().millisecondsSinceEpoch}',
                  email: emailController.text,
                  role: 'store_admin',
                  storeId: storeIdController.text,
                  createdAt: DateTime.now(),
                ));
                Get.back();
                Get.snackbar('Éxito', 'Usuario creado correctamente');
              }
            },
            child: const Text('Crear'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteStore(String storeId) {
    Get.dialog(
      AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: const Text('¿Estás seguro de que quieres eliminar esta tienda?'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancelar')),
          TextButton(
            onPressed: () {
              controller.removeStore(storeId);
              Get.back();
              Get.snackbar('Éxito', 'Tienda eliminada correctamente');
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}
