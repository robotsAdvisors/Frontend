import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/models/store_user_model.dart';
import '../../../data/services/auth_service.dart';
import '../../../routes/app_pages.dart';
import '../controllers/admin_controller.dart';

class AdminSettingsView extends StatefulWidget {
  const AdminSettingsView({Key? key}) : super(key: key);

  @override
  State<AdminSettingsView> createState() => _AdminSettingsViewState();
}

class _AdminSettingsViewState extends State<AdminSettingsView> {
  static const Color _purple = Color(0xFF7C3AED);
  static const Color _purpleLight = Color(0xFFEDE9FE);
  static const Color _bg = Color(0xFFF5F3FF);

  late final AdminController _ctrl;

  // Form controllers
  final _nameCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _billingAddressCtrl = TextEditingController();
  final _fiscalIdCtrl = TextEditingController();
  String? _selectedCategory;
  bool _sameAddressForBilling = false;
  bool _twoFactorEnabled = false;

  @override
  void initState() {
    super.initState();
    _ctrl = Get.find<AdminController>();
    _populateFromStore();
    _ctrl.reloadStoreUsers();
  }

  void _populateFromStore() {
    final s = _ctrl.currentStore;
    _nameCtrl.text = s.name;
    _addressCtrl.text = s.address;
    _billingAddressCtrl.text = s.billingAddress.isNotEmpty ? s.billingAddress : s.address;
    _fiscalIdCtrl.text = s.fiscalId;
    _selectedCategory = s.categories.isNotEmpty ? s.categories.first : null;
    _twoFactorEnabled = s.twoFactorEnabled;
    _sameAddressForBilling = s.billingAddress.isEmpty || s.billingAddress == s.address;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _addressCtrl.dispose();
    _billingAddressCtrl.dispose();
    _fiscalIdCtrl.dispose();
    super.dispose();
  }

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
      width: 220,
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Admin LetDem',
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: _purple)),
                const Text('Gestión de Tienda',
                    style: TextStyle(fontSize: 10, color: Colors.grey)),
              ],
            ),
          ),
          const Divider(height: 1),
          const SizedBox(height: 8),
          _navItem(icon: Icons.home_outlined, label: 'Inicio',
              onTap: () => Get.offNamed(Routes.ADMIN)),
          _navItem(icon: Icons.swap_horiz_rounded, label: 'Canjes',
              onTap: () => Get.offNamed(Routes.VOUCHER_HISTORY)),
          _navItem(icon: Icons.card_giftcard_outlined, label: 'Premios',
              onTap: () => Get.toNamed(Routes.PREMIOS)),
          _navItem(icon: Icons.history_outlined, label: 'Historial',
              onTap: () => Get.offNamed(Routes.VOUCHER_HISTORY)),
          _navItem(icon: Icons.bar_chart_outlined, label: 'Estadísticas',
              onTap: () => Get.offNamed(Routes.ANALYTICS)),
          _navItem(icon: Icons.lock_outline, label: 'PIN',
              onTap: () => _showChangePinDialog(context)),
          _navItem(icon: Icons.shield_outlined, label: 'Seguridad',
              selected: true),
          const Spacer(),
          const Divider(height: 1),
          ListTile(
            dense: true,
            leading: const Icon(Icons.logout, size: 18, color: Colors.grey),
            title: const Text('Cerrar Sesión',
                style: TextStyle(fontSize: 13, color: Colors.grey)),
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
    VoidCallback? onTap,
  }) {
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
            Icon(icon,
                size: 18,
                color: selected ? _purple : Colors.grey.shade500),
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

  // ─── MAIN AREA ───────────────────────────────────────────────────────────────

  Widget _mainArea(BuildContext context) {
    return Column(
      children: [
        _topBar(),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(32, 24, 32, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sectionHeader(Icons.store_outlined, 'Información de la Tienda'),
                const SizedBox(height: 16),
                _storeInfoSection(context),
                const SizedBox(height: 32),
                _rolesSection(context),
                const SizedBox(height: 32),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _securitySection(context)),
                    const SizedBox(width: 24),
                    Expanded(child: _fiscalSection()),
                  ],
                ),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
        _bottomBar(context),
      ],
    );
  }

  // ─── TOP BAR ─────────────────────────────────────────────────────────────────

  Widget _topBar() {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 32),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFEEEEEE))),
      ),
      child: Row(
        children: [
          const Text('Configuración',
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: _purple)),
          const Spacer(),
          SizedBox(
            width: 220,
            height: 36,
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Buscar ajuste...',
                hintStyle:
                    TextStyle(fontSize: 13, color: Colors.grey.shade400),
                prefixIcon: Icon(Icons.search,
                    size: 18, color: Colors.grey.shade400),
                filled: true,
                fillColor: const Color(0xFFF5F5F5),
                isDense: true,
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 9),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(50),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          const Icon(Icons.settings_outlined,
              size: 22, color: Color(0xFF374151)),
          const SizedBox(width: 16),
          Stack(
            clipBehavior: Clip.none,
            children: [
              const Icon(Icons.notifications_outlined,
                  size: 22, color: Color(0xFF374151)),
              Positioned(
                top: -2,
                right: -2,
                child: Obx(() => _ctrl.pendingCount > 0
                    ? Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                            color: Colors.orange,
                            shape: BoxShape.circle),
                      )
                    : const SizedBox.shrink()),
              ),
            ],
          ),
          const SizedBox(width: 16),
          CircleAvatar(
            radius: 16,
            backgroundColor: _purpleLight,
            child: _ctrl.currentStore.logoUrl.startsWith('http')
                ? ClipOval(
                    child: Image.network(
                      _ctrl.currentStore.logoUrl,
                      width: 32,
                      height: 32,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          const Icon(Icons.person, size: 16, color: _purple),
                    ),
                  )
                : const Icon(Icons.person, size: 16, color: _purple),
          ),
        ],
      ),
    );
  }

  // ─── SECTION HEADER ───────────────────────────────────────────────────────────

  Widget _sectionHeader(IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, size: 20, color: _purple),
        const SizedBox(width: 10),
        Text(title,
            style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Color(0xFF111827))),
      ],
    );
  }

  // ─── STORE INFO SECTION ───────────────────────────────────────────────────────

  Widget _storeInfoSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left: banner + logo
          SizedBox(width: 220, child: _bannerLogoColumn()),
          const SizedBox(width: 32),
          // Right: form fields
          Expanded(child: _storeFormFields(context)),
        ],
      ),
    );
  }

  Widget _bannerLogoColumn() {
    return Column(
      children: [
        // Banner
        GestureDetector(
          onTap: () => _showImagePickerPlaceholder('banner'),
          child: Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: _ctrl.currentStore.banner.startsWith('http')
                    ? Image.network(
                        _ctrl.currentStore.banner,
                        width: 220,
                        height: 140,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _bannerPlaceholder(),
                      )
                    : _bannerPlaceholder(),
              ),
              Positioned(
                top: 8,
                left: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _purple,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text('Portada',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        // Logo
        GestureDetector(
          onTap: () => _showImagePickerPlaceholder('logo'),
          child: Column(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: _purpleLight,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 8,
                        offset: const Offset(0, 2))
                  ],
                ),
                child: _ctrl.currentStore.logoUrl.startsWith('http')
                    ? ClipOval(
                        child: Image.network(
                          _ctrl.currentStore.logoUrl,
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _logoFallback(),
                        ),
                      )
                    : _logoFallback(),
              ),
              const SizedBox(height: 10),
              const Text('Logo de Tienda',
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: _purple)),
              const Text('Formato PNG o SVG\n(200×200px)',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 11, color: Colors.grey)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _bannerPlaceholder() {
    return Container(
      width: 220,
      height: 140,
      color: const Color(0xFFE8D5FF),
      child: const Center(
          child: Icon(Icons.store, size: 48, color: _purple)),
    );
  }

  Widget _logoFallback() {
    final initials = _ctrl.currentStore.name.isNotEmpty
        ? _ctrl.currentStore.name
            .split(' ')
            .take(2)
            .map((w) => w.isNotEmpty ? w[0] : '')
            .join()
            .toUpperCase()
        : 'LD';
    return Center(
      child: Text(initials,
          style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: _purple)),
    );
  }

  Widget _storeFormFields(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: _labeledField(
                label: 'Nombre Comercial',
                child: _textField(_nameCtrl),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _labeledField(
                label: 'Categoría',
                child: Obx(() {
                  final cats = [
                    ..._ctrl.categories.map((c) => c.title).where((t) => t.isNotEmpty)
                  ];
                  if (_selectedCategory != null &&
                      !cats.contains(_selectedCategory)) {
                    cats.insert(0, _selectedCategory!);
                  }
                  return _dropdownField(
                    value: _selectedCategory ?? (cats.isNotEmpty ? cats.first : null),
                    items: cats,
                    onChanged: (v) => setState(() => _selectedCategory = v),
                  );
                }),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _labeledField(
          label: 'Dirección Física',
          child: _textField(_addressCtrl),
        ),
        const SizedBox(height: 16),
        _labeledField(
          label: 'Ubicación GPS',
          trailing: TextButton(
            onPressed: () => _showMapPlaceholder(context),
            style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap),
            child: const Text('Abrir Selector en Mapa',
                style: TextStyle(
                    fontSize: 12,
                    color: _purple,
                    fontWeight: FontWeight.w600)),
          ),
          child: _gpsMapWidget(),
        ),
      ],
    );
  }

  Widget _gpsMapWidget() {
    return Obx(() {
      _ctrl.storeId.value; // observe
      final lat = _ctrl.currentStore.latitude;
      final lng = _ctrl.currentStore.longitude;
      return Container(
        height: 160,
        decoration: BoxDecoration(
          color: const Color(0xFFE8F4FD),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Stack(
          children: [
            // Map background pattern
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: CustomPaint(
                size: const Size(double.infinity, 160),
                painter: _MapGridPainter(),
              ),
            ),
            // Pin icon
            const Center(
              child: Icon(Icons.location_on,
                  size: 40, color: _purple),
            ),
            // Coordinates overlay
            Positioned(
              bottom: 10,
              left: 10,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 4)
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.location_on_outlined,
                        size: 14, color: _purple),
                    const SizedBox(width: 4),
                    Text(
                      lat != null && lng != null
                          ? 'Coord: ${lat.toStringAsFixed(4)}, ${lng.toStringAsFixed(4)}'
                          : 'Sin coordenadas',
                      style: const TextStyle(
                          fontSize: 11, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ),
            if (lat != null && lng != null)
              const Positioned(
                bottom: 30,
                left: 10,
                child: SizedBox(),
              ),
          ],
        ),
      );
    });
  }

  // ─── ROLES SECTION ────────────────────────────────────────────────────────────

  Widget _rolesSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _sectionHeader(Icons.people_outline, 'Gestión de Roles'),
            const Spacer(),
            ElevatedButton.icon(
              onPressed: () => _showInviteUserDialog(context),
              icon: const Icon(Icons.person_add_outlined,
                  size: 16, color: Colors.white),
              label: const Text('Invitar Usuario',
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: _purple,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Column(
            children: [
              _usersTableHeader(),
              const Divider(height: 1),
              Obx(() {
                if (_ctrl.storeUsers.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 32),
                    child: Center(
                      child: Text('Sin usuarios registrados.',
                          style: TextStyle(color: Colors.grey)),
                    ),
                  );
                }
                return Column(
                  children: _ctrl.storeUsers
                      .map((u) => _userRow(context, u))
                      .toList(),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _usersTableHeader() {
    const style = TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: Colors.grey,
        letterSpacing: 0.3);
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        children: [
          Expanded(flex: 3, child: Text('Usuario', style: style)),
          Expanded(flex: 2, child: Text('Rol', style: style)),
          Expanded(child: Text('Estado', style: style)),
          SizedBox(width: 60, child: Text('Acciones', style: style)),
        ],
      ),
    );
  }

  Widget _userRow(BuildContext context, StoreUserModel user) {
    final roleLabel = user.roleLabel;
    final isPrivileged = user.isAdmin;
    final roleBg = isPrivileged ? _purpleLight : const Color(0xFFF3F4F6);
    final roleColor = isPrivileged ? _purple : Colors.grey.shade700;

    return Column(
      children: [
        Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: Row(
            children: [
              // Avatar + name + email
              Expanded(
                flex: 3,
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: _purpleLight,
                      child: user.avatarUrl != null
                          ? ClipOval(
                              child: Image.network(
                                user.avatarUrl!,
                                width: 40,
                                height: 40,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) =>
                                    _userInitials(user),
                              ),
                            )
                          : _userInitials(user),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(user.displayName,
                              style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600)),
                          Text(user.email,
                              style: const TextStyle(
                                  fontSize: 11, color: Colors.grey),
                              overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Role badge
              Expanded(
                flex: 2,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: roleBg,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(roleLabel,
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: roleColor),
                      textAlign: TextAlign.center),
                ),
              ),
              // Estado
              Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: user.isActive
                            ? Colors.green
                            : Colors.grey,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(user.isActive ? 'Activo' : 'Inactivo',
                        style: const TextStyle(fontSize: 13)),
                  ],
                ),
              ),
              // Acciones
              SizedBox(
                width: 60,
                child: user.isOwner
                    ? const SizedBox.shrink()
                    : PopupMenuButton<String>(
                        icon: const Icon(Icons.more_vert,
                            size: 18, color: Colors.grey),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        onSelected: (v) =>
                            _handleUserAction(context, user, v),
                        itemBuilder: (_) => [
                          const PopupMenuItem(
                              value: 'change_role',
                              child: Text('Cambiar rol',
                                  style: TextStyle(fontSize: 13))),
                          if (user.canBeRemoved)
                            const PopupMenuItem(
                                value: 'remove',
                                child: Text('Eliminar',
                                    style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.red))),
                        ],
                      ),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
      ],
    );
  }

  Widget _userInitials(StoreUserModel user) {
    return Text(user.initials,
        style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: _purple));
  }

  // ─── SECURITY SECTION ─────────────────────────────────────────────────────────

  Widget _securitySection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader(Icons.shield_outlined, 'Seguridad'),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Column(
            children: [
              // PIN
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('PIN de la Tienda',
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF111827))),
                        const SizedBox(height: 2),
                        const Text(
                            'Requerido para autorizar canjes manuales',
                            style: TextStyle(
                                fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                  ),
                  OutlinedButton(
                    onPressed: () => _showChangePinDialog(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _purple,
                      side: const BorderSide(color: _purple),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('Cambiar\nPIN',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Divider(height: 1),
              const SizedBox(height: 20),
              // 2FA
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Doble Factor (2FA)',
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF111827))),
                        const SizedBox(height: 2),
                        const Text(
                            'Confirmación vía App móvil para cambios críticos',
                            style: TextStyle(
                                fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                  ),
                  Switch(
                    value: _twoFactorEnabled,
                    onChanged: (v) {
                      setState(() => _twoFactorEnabled = v);
                      _ctrl.toggleTwoFactor(v);
                    },
                    activeColor: _purple,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ─── FISCAL SECTION ───────────────────────────────────────────────────────────

  Widget _fiscalSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader(Icons.receipt_long_outlined, 'Datos Fiscales'),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _labeledField(
                label: 'CIF / NIF',
                child: _textField(_fiscalIdCtrl),
              ),
              const SizedBox(height: 16),
              _labeledField(
                label: 'Dirección de Facturación',
                child: _textField(
                  _billingAddressCtrl,
                  enabled: !_sameAddressForBilling,
                  maxLines: 2,
                ),
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _sameAddressForBilling = !_sameAddressForBilling;
                    if (_sameAddressForBilling) {
                      _billingAddressCtrl.text = _addressCtrl.text;
                    }
                  });
                },
                child: Row(
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: Checkbox(
                        value: _sameAddressForBilling,
                        onChanged: (v) {
                          setState(() {
                            _sameAddressForBilling = v ?? false;
                            if (_sameAddressForBilling) {
                              _billingAddressCtrl.text = _addressCtrl.text;
                            }
                          });
                        },
                        activeColor: _purple,
                        materialTapTargetSize:
                            MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                        'Usar la misma dirección que la tienda física',
                        style:
                            TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ─── BOTTOM BAR ───────────────────────────────────────────────────────────────

  Widget _bottomBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFEEEEEE))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(
            onPressed: () {
              setState(() => _populateFromStore());
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.grey.shade700,
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text('Descartar',
                style:
                    TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
          ),
          const SizedBox(width: 12),
          Obx(() => ElevatedButton(
                onPressed: _ctrl.isSavingSettings.value
                    ? null
                    : () => _saveChanges(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _purple,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 28, vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: _ctrl.isSavingSettings.value
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : const Text('Guardar Cambios',
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600)),
              )),
        ],
      ),
    );
  }

  // ─── HELPERS ──────────────────────────────────────────────────────────────────

  Widget _labeledField({
    required String label,
    required Widget child,
    Widget? trailing,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(label,
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF374151))),
            if (trailing != null) ...[
              const Spacer(),
              trailing,
            ],
          ],
        ),
        const SizedBox(height: 6),
        child,
      ],
    );
  }

  Widget _textField(TextEditingController ctrl,
      {bool enabled = true, int maxLines = 1}) {
    return TextField(
      controller: ctrl,
      enabled: enabled,
      maxLines: maxLines,
      style: const TextStyle(fontSize: 13),
      decoration: InputDecoration(
        filled: true,
        fillColor: enabled ? Colors.white : const Color(0xFFF9F9F9),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
          borderSide: const BorderSide(color: _purple, width: 1.5),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFEEEEEE)),
        ),
      ),
    );
  }

  Widget _dropdownField({
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      height: 46,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: (value != null && items.contains(value)) ? value : null,
          isExpanded: true,
          hint: const Text('Seleccionar',
              style: TextStyle(fontSize: 13, color: Colors.grey)),
          items: items
              .map((e) => DropdownMenuItem(
                    value: e,
                    child: Text(e,
                        style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF374151))),
                  ))
              .toList(),
          onChanged: onChanged,
          icon: const Icon(Icons.keyboard_arrow_down,
              size: 18, color: Colors.grey),
          style: const TextStyle(
              fontSize: 13, color: Color(0xFF374151)),
        ),
      ),
    );
  }

  // ─── ACTIONS ─────────────────────────────────────────────────────────────────

  Future<void> _saveChanges() async {
    final payload = <String, dynamic>{
      'name': _nameCtrl.text.trim(),
      'address': _addressCtrl.text.trim(),
      'cif': _fiscalIdCtrl.text.trim(),
      'billing_address': _sameAddressForBilling
          ? _addressCtrl.text.trim()
          : _billingAddressCtrl.text.trim(),
      if (_selectedCategory != null) 'category': _selectedCategory,
    };
    await _ctrl.saveStoreSettings(payload);
  }

  void _showInviteUserDialog(BuildContext context) {
    final emailCtrl = TextEditingController();
    String selectedRole = StoreUserModel.roleAdmin;
    // Map role values to display labels for the dropdown
    const roleOptions = {
      StoreUserModel.roleAdmin: 'Administrador',
      StoreUserModel.roleMember: 'Miembro',
    };
    showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlgState) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Invitar Usuario'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Email:',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              TextField(
                controller: emailCtrl,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintText: 'usuario@empresa.com',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 10),
                ),
                autofocus: true,
              ),
              const SizedBox(height: 16),
              const Text('Rol:',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              Container(
                height: 46,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: selectedRole,
                    isExpanded: true,
                    items: roleOptions.entries
                        .map((e) => DropdownMenuItem(
                              value: e.key,
                              child: Text(e.value,
                                  style: const TextStyle(fontSize: 13)),
                            ))
                        .toList(),
                    onChanged: (v) {
                      if (v != null) setDlgState(() => selectedRole = v);
                    },
                    icon: const Icon(Icons.keyboard_arrow_down,
                        size: 18, color: Colors.grey),
                  ),
                ),
              ),
            ],
          ),
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
                final email = emailCtrl.text.trim();
                if (email.isEmpty) return;
                Navigator.of(ctx).pop();
                await _ctrl.inviteUser(email, selectedRole);
              },
              child: const Text('Invitar'),
            ),
          ],
        ),
      ),
    );
  }

  void _handleUserAction(
      BuildContext context, StoreUserModel user, String action) {
    if (action == 'remove') {
      showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16)),
          title: const Text('Eliminar usuario'),
          content: Text(
              '¿Eliminar a ${user.displayName} de la tienda?'),
          actions: [
            TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Cancelar')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () async {
                Navigator.of(ctx).pop();
                await _ctrl.removeUser(user.id);
              },
              child: const Text('Eliminar'),
            ),
          ],
        ),
      );
    } else if (action == 'change_role') {
      final newRole = user.role.toUpperCase() == StoreUserModel.roleAdmin
          ? StoreUserModel.roleMember
          : StoreUserModel.roleAdmin;
      _ctrl.updateUserRole(user.id, newRole);
    }
  }

  void _showChangePinDialog(BuildContext context) {
    final currentCtrl = TextEditingController();
    final newCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        title: const Text('Cambiar PIN'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _pinField(currentCtrl, 'PIN actual'),
            const SizedBox(height: 12),
            _pinField(newCtrl, 'Nuevo PIN'),
            const SizedBox(height: 12),
            _pinField(confirmCtrl, 'Confirmar nuevo PIN'),
          ],
        ),
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
              if (newCtrl.text != confirmCtrl.text) {
                Get.snackbar('Error', 'Los PINs no coinciden',
                    snackPosition: SnackPosition.BOTTOM);
                return;
              }
              Navigator.of(ctx).pop();
              await _ctrl.changePin(currentCtrl.text, newCtrl.text);
            },
            child: const Text('Cambiar PIN'),
          ),
        ],
      ),
    );
  }

  Widget _pinField(TextEditingController ctrl, String label) {
    return TextField(
      controller: ctrl,
      obscureText: true,
      keyboardType: TextInputType.number,
      maxLength: 6,
      decoration: InputDecoration(
        labelText: label,
        counterText: '',
        border:
            OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        contentPadding: const EdgeInsets.symmetric(
            horizontal: 12, vertical: 10),
      ),
    );
  }

  void _showImagePickerPlaceholder(String type) {
    Get.snackbar(
      'Subir ${type == 'banner' ? 'Portada' : 'Logo'}',
      'La subida de imágenes requiere permisos de galería.',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }

  void _showMapPlaceholder(BuildContext context) {
    Get.snackbar(
      'Selector de Mapa',
      'Integración con Google Maps próximamente.',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
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
}

// ─── MAP GRID PAINTER ─────────────────────────────────────────────────────────

class _MapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final roadPaint = Paint()
      ..color = const Color(0xFFCBE0F5)
      ..strokeWidth = 2;
    final blockPaint = Paint()..color = const Color(0xFFD4EAF7);

    // Draw grid blocks
    for (double x = 0; x < size.width; x += 40) {
      for (double y = 0; y < size.height; y += 35) {
        canvas.drawRect(
            Rect.fromLTWH(x + 2, y + 2, 32, 28), blockPaint);
      }
    }
    // Horizontal roads
    for (double y = 0; y < size.height; y += 35) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), roadPaint);
    }
    // Vertical roads
    for (double x = 0; x < size.width; x += 40) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), roadPaint);
    }
  }

  @override
  bool shouldRepaint(_) => false;
}
