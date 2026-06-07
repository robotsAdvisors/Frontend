import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../data/models/store_user_model.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/services/auth_service.dart';
import '../../../data/services/http/api_client.dart';
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
  bool _pinVisible = false;

  @override
  void initState() {
    super.initState();
    _ctrl = Get.find<AdminController>();
    _ctrl.reloadStoreUsers();
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
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _purple,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.store, color: Colors.white, size: 22),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Obx(() {
                        _ctrl.storeId.value;
                        return Text(
                          _ctrl.currentStore.name,
                          style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF111827)),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        );
                      }),
                      const Text('Gestión de Tienda',
                          style: TextStyle(fontSize: 10, color: Colors.grey)),
                    ],
                  ),
                ),
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
          _navItem(icon: Icons.bar_chart_outlined, label: 'Estadísticas',
              onTap: () => Get.offNamed(Routes.ANALYTICS)),
          _navItem(icon: Icons.lock_outline, label: 'PIN', selected: true),
          _navItem(icon: Icons.security_outlined, label: 'Seguridad'),
          const Spacer(),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => Get.offNamed(Routes.ADMIN),
                icon: const Icon(Icons.add, size: 16, color: Colors.white),
                label: const Text('Nuevo Canje',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E1B4B),
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
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
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Row 1: PIN card + 2FA card
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _pinCard(context)),
                    const SizedBox(width: 16),
                    SizedBox(width: 280, child: _twoFactorCard(context)),
                  ],
                ),
                const SizedBox(height: 20),
                // Row 2: Personal y Accesos + Registro de Actividad
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _personnelSection(context)),
                    const SizedBox(width: 16),
                    SizedBox(width: 280, child: _activityLogSection()),
                  ],
                ),
                const SizedBox(height: 24),
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
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFEEEEEE))),
      ),
      child: Row(
        children: [
          const Text(
            'Seguridad y PIN de Tienda',
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Color(0xFF111827)),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: SizedBox(
              height: 38,
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Buscar en seguridad...',
                  hintStyle:
                      TextStyle(fontSize: 13, color: Colors.grey.shade400),
                  prefixIcon: Icon(Icons.search,
                      size: 18, color: Colors.grey.shade400),
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
                            color: Colors.orange, shape: BoxShape.circle),
                      )
                    : const SizedBox.shrink()),
              ),
            ],
          ),
          const SizedBox(width: 20),
          const Icon(Icons.settings_outlined,
              size: 22, color: Color(0xFF374151)),
          const SizedBox(width: 20),
          const Icon(Icons.help_outline, size: 22, color: Color(0xFF374151)),
          const SizedBox(width: 20),
          Obx(() {
            _ctrl.storeId.value;
            return CircleAvatar(
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
            );
          }),
        ],
      ),
    );
  }

  // ─── PIN CARD ─────────────────────────────────────────────────────────────────

  Widget _pinCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _purpleLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.lock_outline, color: _purple, size: 18),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('PIN de Tienda',
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w700)),
                    Text('Este código permite validar transacciones físicas',
                        style: TextStyle(fontSize: 11, color: Colors.grey)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text('CÓDIGO ACTUAL',
              style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey,
                  letterSpacing: 0.8)),
          const SizedBox(height: 8),
          Obx(() {
            final pin = _ctrl.regeneratedPin.value.isNotEmpty
                ? _ctrl.regeneratedPin.value
                : _ctrl.pinMasked;
            return Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9FAFB),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            _pinVisible ? pin : '●' * pin.length,
                            style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 4),
                          ),
                        ),
                        GestureDetector(
                          onTap: () =>
                              setState(() => _pinVisible = !_pinVisible),
                          child: Icon(
                            _pinVisible
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            size: 18,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                OutlinedButton(
                  onPressed: () => _copyPin(pin),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.grey.shade700,
                    side: BorderSide(color: Colors.grey.shade300),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Copiar',
                      style: TextStyle(fontSize: 13)),
                ),
                const SizedBox(width: 8),
                Obx(() => ElevatedButton(
                      onPressed: _ctrl.isRegeneratingPin.value
                          ? null
                          : () => _confirmRegenerate(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _purple,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      child: _ctrl.isRegeneratingPin.value
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white))
                          : const Text('Regenerar',
                              style: TextStyle(fontSize: 13)),
                    )),
              ],
            );
          }),
          const SizedBox(height: 14),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFBEB),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFFDE68A)),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.warning_amber_rounded,
                    size: 16, color: Color(0xFFD97706)),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Atención: El PIN es confidencial y solo debe compartirse con personal autorizado. LetDem renueva la estructura del código por fuera del sistema de validación.',
                    style: TextStyle(fontSize: 11, color: Color(0xFF92400E)),
                  ),
                ),
              ],
            ),
          ),
          // Aviso si el PIN fue regenerado (se muestra una sola vez)
          Obx(() {
            if (_ctrl.regeneratedPin.value.isEmpty) {
              return const SizedBox.shrink();
            }
            return Column(
              children: [
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFECFDF5),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFF6EE7B7)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle_outline,
                          size: 16, color: Color(0xFF059669)),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'PIN regenerado. Guárdalo ahora — solo se muestra una vez.',
                          style: TextStyle(
                              fontSize: 11, color: Color(0xFF065F46)),
                        ),
                      ),
                      GestureDetector(
                        onTap: _ctrl.clearRegeneratedPin,
                        child: const Icon(Icons.close,
                            size: 16, color: Color(0xFF059669)),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  // ─── 2FA CARD ─────────────────────────────────────────────────────────────────

  Widget _twoFactorCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('Autenticación 2FA',
                  style: TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w700)),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFD1FAE5),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text('NUEVA',
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF065F46))),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'Protección adicional requerida para acciones administrativas críticas.',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 16),
          // Google Authenticator option
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border:
                        Border.all(color: const Color(0xFFE5E7EB)),
                  ),
                  child: const Icon(Icons.qr_code,
                      size: 18, color: Color(0xFF374151)),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Google Authenticator',
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600)),
                      Text('App TOTP compatible',
                          style: TextStyle(
                              fontSize: 11, color: Colors.grey)),
                    ],
                  ),
                ),
                Obx(() {
                  final enabled =
                      _ctrl.currentStore.twoFactorEnabled;
                  return Switch(
                    value: enabled,
                    onChanged: (v) {
                      if (v) {
                        _showSetup2FADialog(context);
                      } else {
                        _ctrl.toggleTwoFactor(false);
                      }
                    },
                    activeColor: _purple,
                    materialTapTargetSize:
                        MaterialTapTargetSize.shrinkWrap,
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => _showBackupMethodDialog(context),
              style: OutlinedButton.styleFrom(
                foregroundColor: _purple,
                side: const BorderSide(color: _purple),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Configurar Método de Respaldo',
                  style:
                      TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }

  // ─── PERSONAL Y ACCESOS ───────────────────────────────────────────────────────

  Widget _personnelSection(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        children: [
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                const Text('Personal y Accesos',
                    style: TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w700)),
                const Spacer(),
                GestureDetector(
                  onTap: () => _showInviteUserDialog(context),
                  child: const Text('+ Gestionar Staff',
                      style: TextStyle(
                          fontSize: 13,
                          color: _purple,
                          fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
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
    );
  }

  Widget _usersTableHeader() {
    const style = TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: Colors.grey,
        letterSpacing: 0.3);
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          Expanded(flex: 3, child: Text('USUARIO', style: style)),
          Expanded(flex: 2, child: Text('ROL', style: style)),
          Expanded(child: Text('ESTADO', style: style)),
          SizedBox(width: 40),
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
              const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: _purpleLight,
                      child: user.avatarUrl != null
                          ? ClipOval(
                              child: Image.network(
                                user.avatarUrl!,
                                width: 36,
                                height: 36,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) =>
                                    _userInitials(user),
                              ),
                            )
                          : _userInitials(user),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(user.displayName,
                              style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600),
                              overflow: TextOverflow.ellipsis),
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
              Expanded(
                flex: 2,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: roleBg,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(roleLabel,
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: roleColor),
                      textAlign: TextAlign.center),
                ),
              ),
              Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: user.isOnline ? Colors.green : Colors.grey,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(user.presenceLabel,
                          style: const TextStyle(fontSize: 12),
                          overflow: TextOverflow.ellipsis),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: 40,
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
            fontSize: 12, fontWeight: FontWeight.w700, color: _purple));
  }

  // ─── REGISTRO DE ACTIVIDAD ────────────────────────────────────────────────────

  Widget _activityLogSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Registro de Actividad',
              style:
                  TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
          const SizedBox(height: 16),
          Obx(() {
            final log = _ctrl.securityLog;
            if (log.isEmpty) {
              return const Text('Sin actividad registrada.',
                  style: TextStyle(fontSize: 12, color: Colors.grey));
            }
            return Column(
              children: log.take(5).map(_logItem).toList(),
            );
          }),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () => Get.toNamed(Routes.VOUCHER_HISTORY),
            child: const Center(
              child: Text('Ver Historial Completo',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _purple)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _logItem(Map<String, dynamic> event) {
    final type = (event['event_type'] ?? event['type'] ?? '').toString();
    final description =
        (event['description'] ?? event['body'] ?? '').toString();
    final ts = event['timestamp'] ?? event['created_at'];
    final dateTime = DateTime.tryParse(ts?.toString() ?? '');
    final timeLabel = _fmtLogDate(dateTime);
    final icon = _logIcon(type);
    final iconColor = _logColor(type);

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: iconColor),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(timeLabel,
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Colors.grey.shade500)),
                const SizedBox(height: 2),
                Text(description,
                    style: const TextStyle(
                        fontSize: 12, color: Color(0xFF374151))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _logIcon(String type) {
    switch (type) {
      case 'pin_changed':
        return Icons.lock_outline;
      case 'password_changed':
        return Icons.key_outlined;
      case 'role_added':
        return Icons.person_add_outlined;
      default:
        return Icons.info_outline;
    }
  }

  Color _logColor(String type) {
    switch (type) {
      case 'pin_changed':
        return _purple;
      case 'password_changed':
        return const Color(0xFF2563EB);
      case 'role_added':
        return const Color(0xFF059669);
      default:
        return Colors.grey;
    }
  }

  String _fmtLogDate(DateTime? dt) {
    if (dt == null) return '';
    final now = DateTime.now();
    final local = dt.toLocal();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final date = DateTime(local.year, local.month, local.day);
    final timeStr =
        '${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
    if (date == today) return 'HOY $timeStr';
    if (date == yesterday) return 'AYER, $timeStr';
    return '${local.day} ${_month(local.month)}, $timeStr';
  }

  String _month(int m) {
    const months = [
      '', 'ENE', 'FEB', 'MAR', 'ABR', 'MAY', 'JUN',
      'JUL', 'AGO', 'SEP', 'OCT', 'NOV', 'DIC'
    ];
    return months[m];
  }

  // ─── DIALOGS & ACTIONS ───────────────────────────────────────────────────────

  void _copyPin(String pin) {
    final actual = pin.contains('●') ? '' : pin;
    if (actual.isEmpty) {
      Get.snackbar('Sin PIN', 'Regenera el PIN para copiarlo.',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }
    Clipboard.setData(ClipboardData(text: actual));
    Get.snackbar('Copiado', 'PIN copiado al portapapeles.',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2));
  }

  void _confirmRegenerate(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Regenerar PIN'),
        content: const Text(
            'Se generará un nuevo PIN aleatorio. El PIN anterior quedará inválido. ¿Continuar?'),
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
              setState(() => _pinVisible = true);
              await _ctrl.regeneratePin();
            },
            child: const Text('Regenerar'),
          ),
        ],
      ),
    );
  }

  void _showSetup2FADialog(BuildContext context) {
    final codeCtrl = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Configurar Google Authenticator'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
                '1. Abre Google Authenticator en tu móvil.\n'
                '2. Escanea el código QR o ingresa la clave manualmente.\n'
                '3. Ingresa el código de 6 dígitos para confirmar.',
                style: TextStyle(fontSize: 13)),
            const SizedBox(height: 16),
            TextField(
              controller: codeCtrl,
              keyboardType: TextInputType.number,
              maxLength: 6,
              decoration: InputDecoration(
                labelText: 'Código de verificación',
                counterText: '',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10)),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 10),
              ),
              autofocus: true,
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
              final code = codeCtrl.text.trim();
              if (code.length < 6) return;
              Navigator.of(ctx).pop();
              try {
                final ok =
                    await AuthRepository.instance.verify2FA(code);
                if (ok) {
                  _ctrl.toggleTwoFactor(true);
                  Get.snackbar('2FA activado',
                      'Autenticación de dos factores habilitada.',
                      snackPosition: SnackPosition.BOTTOM);
                } else {
                  Get.snackbar('Código inválido',
                      'El código no coincide. Intenta de nuevo.',
                      snackPosition: SnackPosition.BOTTOM);
                }
              } on ApiException catch (e) {
                Get.snackbar('Error', e.message,
                    snackPosition: SnackPosition.BOTTOM);
              }
            },
            child: const Text('Verificar'),
          ),
        ],
      ),
    );
  }

  void _showBackupMethodDialog(BuildContext context) {
    String selectedMethod = 'email';
    final valueCtrl = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlg) => AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16)),
          title: const Text('Método de Respaldo'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Selecciona cómo recibirás el código de respaldo:',
                  style: TextStyle(fontSize: 13)),
              const SizedBox(height: 12),
              Row(
                children: [
                  _methodChip(
                      'Email', 'email', selectedMethod,
                      () => setDlg(() => selectedMethod = 'email')),
                  const SizedBox(width: 8),
                  _methodChip(
                      'SMS', 'sms', selectedMethod,
                      () => setDlg(() => selectedMethod = 'sms')),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: valueCtrl,
                keyboardType: selectedMethod == 'sms'
                    ? TextInputType.phone
                    : TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: selectedMethod == 'sms'
                      ? 'Número de teléfono'
                      : 'Email de respaldo',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 10),
                ),
                autofocus: true,
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
                final value = valueCtrl.text.trim();
                if (value.isEmpty) return;
                Navigator.of(ctx).pop();
                try {
                  await AuthRepository.instance
                      .configureBackupMethod(selectedMethod, value);
                  Get.snackbar('Método configurado',
                      'Método de respaldo guardado correctamente.',
                      snackPosition: SnackPosition.BOTTOM);
                } on ApiException catch (e) {
                  Get.snackbar('Error', e.message,
                      snackPosition: SnackPosition.BOTTOM);
                }
              },
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _methodChip(String label, String value, String selected,
      VoidCallback onTap) {
    final isSelected = value == selected;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? _purpleLight : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: isSelected ? _purple : const Color(0xFFE5E7EB)),
        ),
        child: Text(label,
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isSelected ? _purple : Colors.grey.shade700)),
      ),
    );
  }

  void _showInviteUserDialog(BuildContext context) {
    final emailCtrl = TextEditingController();
    String selectedRole = StoreUserModel.roleAdmin;
    const roleOptions = {
      StoreUserModel.roleAdmin: 'Administrador',
      StoreUserModel.roleMember: 'Miembro',
      'MANAGER': 'Manager',
      'VALIDATOR': 'Validador',
    };
    showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlg) => AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16)),
          title: const Text('Invitar Usuario'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Email:',
                  style: TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w600)),
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
                  style: TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              Container(
                height: 46,
                padding:
                    const EdgeInsets.symmetric(horizontal: 14),
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
                                  style:
                                      const TextStyle(fontSize: 13)),
                            ))
                        .toList(),
                    onChanged: (v) {
                      if (v != null) {
                        setDlg(() => selectedRole = v);
                      }
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
