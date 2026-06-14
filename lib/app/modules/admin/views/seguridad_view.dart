import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../data/services/auth_service.dart';
import '../../../routes/app_pages.dart';
import '../controllers/admin_controller.dart';

class SeguridadView extends StatefulWidget {
  const SeguridadView({super.key});

  @override
  State<SeguridadView> createState() => _SeguridadViewState();
}

class _SeguridadViewState extends State<SeguridadView> {
  static const Color _purple      = Color(0xFF7C3AED);
  static const Color _purpleLight = Color(0xFFEDE9FE);
  static const Color _bg          = Color(0xFFF8F7FF);
  static const Color _dark        = Color(0xFF1E1B4B);
  static const Color _border      = Color(0xFFEEEEEE);
  static const Color _green       = Color(0xFF10B981);
  static const Color _red         = Color(0xFFEF4444);
  static const Color _blue        = Color(0xFF3B82F6);

  late final AdminController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = Get.find<AdminController>();
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 900;
    if (isDesktop) {
      return Scaffold(
        backgroundColor: _bg,
        body: Row(children: [
          _sidebar(context),
          Expanded(child: _body()),
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
        title: const Text('Seguridad',
            style: TextStyle(color: _dark, fontSize: 16, fontWeight: FontWeight.w700)),
      ),
      body: _body(),
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
              Text('LetDem',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: _dark)),
              Text('Admin Tienda',
                  style: TextStyle(fontSize: 10, color: Colors.grey)),
            ]),
          ]),
        ),
        Container(height: 1, color: _border),
        const SizedBox(height: 8),
        _navItem(icon: Icons.grid_view_outlined,  label: 'Inicio',
            onTap: () => Get.offAllNamed(Routes.ADMIN)),
        _navItem(icon: Icons.group_outlined,       label: 'Equipo',
            onTap: () => Get.toNamed(Routes.EMPLEADOS)),
        _navItem(icon: Icons.receipt_outlined,     label: 'Pedidos',
            onTap: () => Get.toNamed(Routes.CONFIRMAR_ENTREGA)),
        _navItem(icon: Icons.inventory_2_outlined, label: 'Productos',
            onTap: () => Get.toNamed(Routes.INVENTARIO)),
        _navItem(icon: Icons.badge_outlined,       label: 'Empleados',
            onTap: () => Get.toNamed(Routes.EMPLEADOS)),
        _navItem(icon: Icons.security_outlined,    label: 'Seguridad', selected: true),
        _navItem(icon: Icons.settings_outlined,    label: 'Configuraciones',
            onTap: () => Get.toNamed(Routes.ADMIN_SETTINGS)),
        const Spacer(),
        Container(height: 1, color: _border),
        ListTile(
          dense: true,
          leading: const Icon(Icons.logout, size: 18, color: Colors.grey),
          title: const Text('Cerrar Sesión',
              style: TextStyle(fontSize: 13, color: Colors.grey)),
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

  Widget _body() {
    return Column(children: [
      Expanded(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(28, 28, 28, 0),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _header(),
            const SizedBox(height: 24),
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(child: _pinCard()),
              const SizedBox(width: 16),
              Expanded(child: _twoFactorCard()),
            ]),
            const SizedBox(height: 20),
            _securityLogSection(),
            const SizedBox(height: 20),
          ]),
        ),
      ),
      _bottomBar(),
    ]);
  }

  // ─── HEADER ───────────────────────────────────────────────────────────────

  Widget _header() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        const Text('Seguridad y PIN de tienda',
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
          'Protege y controla variables de identidad de tu tienda, configura accesos del comando',
          style: TextStyle(fontSize: 13, color: Colors.grey)),
    ]);
  }

  // ─── PIN CARD ─────────────────────────────────────────────────────────────

  Widget _pinCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
                color: _purpleLight, borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.pin_outlined, size: 20, color: _purple),
          ),
          const SizedBox(width: 12),
          const Text('PIN de tienda',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: _dark)),
        ]),
        const SizedBox(height: 16),
        const Text(
          'Con él, tus clientes podrán canjear o usar uno de sus vales de canjes en el establecimiento',
          style: TextStyle(fontSize: 13, color: Colors.grey, height: 1.5),
        ),
        const SizedBox(height: 24),
        Obx(() {
          final revealed = _ctrl.regeneratedPin.value;
          if (revealed.isNotEmpty) return _revealedPinWidget(revealed);
          return Wrap(
            spacing: 8,
            children: List.generate(6, (_) => Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                  color: _purpleLight, borderRadius: BorderRadius.circular(8)),
              child: const Icon(Icons.circle, size: 10, color: _purple),
            )),
          );
        }),
        const SizedBox(height: 24),
        Obx(() => _ctrl.isRegeneratingPin.value
            ? const Center(child: SizedBox(width: 24, height: 24,
                child: CircularProgressIndicator(strokeWidth: 2, color: _purple)))
            : Wrap(
                spacing: 10,
                runSpacing: 8,
                children: [
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _purple,
                      side: const BorderSide(color: _purple),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    icon: const Icon(Icons.lock_reset_outlined, size: 16),
                    label: const Text('Cambiar PIN',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                    onPressed: _showChangePinDialog,
                  ),
                  TextButton(
                    onPressed: _ctrl.regeneratedPin.value.isNotEmpty
                        ? _ctrl.clearRegeneratedPin
                        : _showRegenerateConfirmDialog,
                    child: Text(
                      _ctrl.regeneratedPin.value.isNotEmpty ? 'Ocultar PIN' : 'Regenerar',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ),
                ],
              )),
      ]),
    );
  }

  Widget _revealedPinWidget(String pin) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDF4),
        border: Border.all(color: Color.fromRGBO(16, 185, 129, 0.3)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Row(children: [
          Icon(Icons.check_circle_outline, size: 15, color: _green),
          SizedBox(width: 6),
          Text('PIN generado — guárdalo ahora',
              style: TextStyle(fontSize: 12, color: _green, fontWeight: FontWeight.w600)),
        ]),
        const SizedBox(height: 10),
        Row(children: [
          Text(pin,
              style: const TextStyle(
                  fontSize: 26, fontWeight: FontWeight.w800,
                  letterSpacing: 8, color: _dark)),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: () => Clipboard.setData(ClipboardData(text: pin)),
            child: const Icon(Icons.copy_outlined, size: 18, color: Colors.grey),
          ),
        ]),
        const SizedBox(height: 6),
        const Text('Este PIN no volverá a mostrarse.',
            style: TextStyle(fontSize: 11, color: Colors.grey)),
      ]),
    );
  }

  // ─── 2FA CARD ─────────────────────────────────────────────────────────────

  Widget _twoFactorCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.verified_user_outlined, size: 20, color: _blue),
          ),
          const SizedBox(width: 12),
          const Text('Doble factor y accesos',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: _dark)),
        ]),
        const SizedBox(height: 20),
        // 2FA toggle — reads storeId to react to toggleTwoFactor's storeId.refresh()
        Obx(() {
          _ctrl.storeId.value; // subscribe so Obx rebuilds on refresh
          final enabled = _ctrl.currentStore.twoFactorEnabled;
          return _infoRow(
            label: '2FA Habilitado',
            trailing: Row(mainAxisSize: MainAxisSize.min, children: [
              Text(
                enabled ? 'Activo' : 'Inactivo',
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: enabled ? _green : Colors.grey),
              ),
              const SizedBox(width: 8),
              Transform.scale(
                scale: 0.8,
                child: Switch(
                  value: enabled,
                  activeColor: _purple,
                  onChanged: _ctrl.toggleTwoFactor,
                ),
              ),
            ]),
          );
        }),
        const Divider(height: 28),
        // Derived from security log — missing backend field: last_2fa_used_at
        Obx(() => _infoRow(
          label: 'Último canjeo 2FA',
          trailing: Text(
            _last2faUsedLabel(),
            style: const TextStyle(
                fontSize: 13, fontWeight: FontWeight.w500, color: _dark),
          ),
        )),
        const Divider(height: 28),
        // ⚠️ HARDCODED: backend needs branch_count in GET /stores/{id}/pin/ or /security/
        Obx(() {
          final count = _ctrl.storePinData.value['branch_count']
              ?? _ctrl.storePinData.value['location_count'];
          return _infoRow(
            label: 'Ubicación automática',
            trailing: Text(
              count != null ? '$count sucursales' : '—',
              style: const TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w500, color: _dark),
            ),
          );
        }),
      ]),
    );
  }

  Widget _infoRow({required String label, required Widget trailing}) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(label, style: const TextStyle(fontSize: 13, color: Colors.grey)),
      trailing,
    ]);
  }

  // ─── SECURITY LOG ─────────────────────────────────────────────────────────

  Widget _securityLogSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('Historial de seguridad',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: _dark)),
        ]),
        const SizedBox(height: 4),
        const Text('Eventos recientes registrados para esta tienda',
            style: TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 16),
        Obx(() {
          final log = _ctrl.securityLog;
          if (log.isEmpty) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text('Sin eventos registrados',
                    style: TextStyle(fontSize: 13, color: Colors.grey)),
              ),
            );
          }
          return Column(
            children: log.take(6).map(_logRow).toList(),
          );
        }),
      ]),
    );
  }

  Widget _logRow(Map<String, dynamic> event) {
    final type  = (event['type']  ?? '').toString();
    final title = (event['title'] ?? type).toString();
    final desc  = (event['description'] ?? '').toString();
    final ts    = event['timestamp'] ?? event['created_at'];
    final time  = ts != null
        ? _relativeTime(DateTime.tryParse(ts.toString()))
        : '';

    final (icon, iconColor, iconBg) = switch (type) {
      'pin_changed'          => (Icons.lock_reset_outlined,      _purple,                  _purpleLight),
      'password_changed'     => (Icons.password_outlined,        _red,                     const Color(0xFFFEF2F2)),
      'role_added'           => (Icons.person_add_outlined,      _green,                   const Color(0xFFECFDF5)),
      'role_removed'         => (Icons.person_remove_outlined,   _red,                     const Color(0xFFFEF2F2)),
      'role_changed'         => (Icons.manage_accounts_outlined, _blue,                    const Color(0xFFEFF6FF)),
      'two_factor_enabled'   => (Icons.verified_user_outlined,   _blue,                    const Color(0xFFEFF6FF)),
      'two_factor_disabled'  => (Icons.no_encryption_outlined,   const Color(0xFFF59E0B),  const Color(0xFFFFFBEB)),
      'two_factor_verified'  => (Icons.key_outlined,             _green,                   const Color(0xFFECFDF5)),
      _                      => (Icons.security_outlined,        Colors.grey,              const Color(0xFFF5F5F5)),
    };

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(children: [
        Container(
          width: 34, height: 34,
          decoration: BoxDecoration(
              color: iconBg, borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, size: 16, color: iconColor),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title,
                style: const TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w500, color: _dark)),
            if (desc.isNotEmpty)
              Text(desc,
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                  maxLines: 1, overflow: TextOverflow.ellipsis),
          ]),
        ),
        Text(time, style: const TextStyle(fontSize: 11, color: Colors.grey)),
      ]),
    );
  }

  // ─── BOTTOM BAR ──────────────────────────────────────────────────────────

  Widget _bottomBar() {
    return Container(
      color: const Color(0xFFF0FDF4),
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
      child: const Row(children: [
        Icon(Icons.info_outline, size: 16, color: _green),
        SizedBox(width: 8),
        Expanded(
          child: Text(
            'Cada cambio sensible debe quedar registrado en historial de tienda',
            style: TextStyle(
                fontSize: 12, color: _green, fontWeight: FontWeight.w500),
          ),
        ),
      ]),
    );
  }

  // ─── HELPERS ──────────────────────────────────────────────────────────────

  String _last2faUsedLabel() {
    // Prefer direct field returned by GET /stores/{id}/pin/ (last_2fa_used_at)
    final direct = _ctrl.storePinData.value['last_2fa_used_at']?.toString();
    if (direct != null && direct.isNotEmpty) {
      return _relativeTime(DateTime.tryParse(direct));
    }
    // Fallback: derive from security log events
    final event = _ctrl.securityLog.firstWhereOrNull((e) {
      final t = (e['type'] ?? '').toString();
      return t.contains('2fa') || t.contains('two_factor');
    });
    if (event == null) return 'Sin registro';
    final ts = event['timestamp'] ?? event['created_at'];
    return _relativeTime(DateTime.tryParse((ts ?? '').toString()));
  }

  String _relativeTime(DateTime? dt) {
    if (dt == null) return '';
    final diff = DateTime.now().difference(dt.toLocal());
    if (diff.inMinutes < 60) return 'Hace ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'Hace ${diff.inHours} h';
    return 'Hace ${diff.inDays} días';
  }

  // ─── DIALOGS ──────────────────────────────────────────────────────────────

  Future<void> _showChangePinDialog() async {
    final currentCtrl = TextEditingController();
    final newCtrl     = TextEditingController();
    final confirmCtrl = TextEditingController();
    bool obscure = true;

    await showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Cambiar PIN',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
          content: SizedBox(
            width: 360,
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              TextField(
                controller: currentCtrl,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(8),
                ],
                obscureText: obscure,
                decoration: InputDecoration(
                  labelText: 'PIN actual',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                  suffixIcon: IconButton(
                    icon: Icon(
                        obscure ? Icons.visibility_off : Icons.visibility,
                        size: 18),
                    onPressed: () => setS(() => obscure = !obscure),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: newCtrl,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(8),
                ],
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'PIN nuevo',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: confirmCtrl,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(8),
                ],
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Confirmar PIN nuevo',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ]),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar',
                  style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _purple, foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () async {
                if (newCtrl.text != confirmCtrl.text) {
                  Get.snackbar('Error', 'Los PINs no coinciden',
                      snackPosition: SnackPosition.TOP);
                  return;
                }
                if (newCtrl.text.length < 4) {
                  Get.snackbar('Error', 'El PIN debe tener al menos 4 dígitos',
                      snackPosition: SnackPosition.TOP);
                  return;
                }
                Navigator.pop(ctx);
                await _ctrl.changePin(currentCtrl.text, newCtrl.text);
              },
              child: const Text('Confirmar'),
            ),
          ],
        ),
      ),
    );
    currentCtrl.dispose();
    newCtrl.dispose();
    confirmCtrl.dispose();
  }

  Future<void> _showRegenerateConfirmDialog() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('¿Regenerar PIN?',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
        content: const Text(
          'Se generará un nuevo PIN aleatorio. El PIN anterior quedará inutilizado de inmediato.',
          style: TextStyle(fontSize: 13, color: Colors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar',
                style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _red, foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Regenerar'),
          ),
        ],
      ),
    );
    if (confirmed == true) await _ctrl.regeneratePin();
  }
}
