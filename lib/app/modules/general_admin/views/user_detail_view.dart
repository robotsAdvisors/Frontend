import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/models/admin_user_model.dart';
import '../../../data/models/audit_log_model.dart';
import '../../../data/services/auth_service.dart';
import '../../../routes/app_pages.dart';
import '../controllers/general_admin_controller.dart';

class UserDetailView extends GetView<GeneralAdminController> {
  const UserDetailView({Key? key}) : super(key: key);

  static const Color _purple = Color(0xFF7C3AED);
  static const Color _purpleLight = Color(0xFFEDE9FE);
  static const Color _bg = Color(0xFFF8F7FF);

  @override
  Widget build(BuildContext context) {
    // Load user from arguments if passed
    final userId = Get.arguments as String?;
    if (userId != null && userId.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        controller.selectUser(userId);
      });
    }

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
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 24, 20, 12),
            child: Text('Backoffice',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1E1B4B))),
          ),
          const Divider(height: 1),
          const SizedBox(height: 8),
          _navItem(icon: Icons.dashboard_outlined, label: 'Dashboard',
              onTap: () => Get.offNamed(Routes.GENERAL_ADMIN)),
          _navItem(icon: Icons.people_outline, label: 'Usuarios', selected: true),
          _navItem(icon: Icons.privacy_tip_outlined, label: 'GDPR',
              onTap: () => Get.toNamed(Routes.GDPR_REQUESTS)),
          _navItem(icon: Icons.gavel_outlined, label: 'Legal'),
          _navItem(icon: Icons.flag_outlined, label: 'Moderación'),
          _navItem(icon: Icons.payments_outlined, label: 'Pagos'),
          _navItem(icon: Icons.fact_check_outlined, label: 'Auditoría'),
          _navItem(icon: Icons.settings_outlined, label: 'Configuración'),
          const Spacer(),
          const Divider(height: 1),
          ListTile(
            dense: true,
            leading: const Icon(Icons.logout, size: 18, color: Colors.grey),
            title: const Text('Logout',
                style: TextStyle(fontSize: 13, color: Colors.grey)),
            onTap: () async {
              await AuthService.signOut();
              Get.offAllNamed(Routes.LOGIN);
            },
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

  // ─── MAIN AREA ───────────────────────────────────────────────────────────────

  Widget _mainArea(BuildContext context) {
    return Column(
      children: [
        _topBar(),
        Expanded(
          child: Obx(() {
            if (controller.isLoadingUser.value) {
              return const Center(child: CircularProgressIndicator());
            }
            final user = controller.selectedUser.value;
            if (user == null) {
              return const Center(
                child: Text('Selecciona un usuario para ver su ficha.',
                    style: TextStyle(color: Colors.grey)),
              );
            }
            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _pageHeader(context, user),
                  const SizedBox(height: 20),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: _profileCard(user)),
                      const SizedBox(width: 16),
                      SizedBox(
                        width: 260,
                        child: Column(
                          children: [
                            _fechasCard(user),
                            const SizedBox(height: 16),
                            _complianceCard(user),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _activityRow(user),
                  const SizedBox(height: 20),
                  _auditLogTable(context, user),
                  const SizedBox(height: 24),
                ],
              ),
            );
          }),
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
          Expanded(
            child: SizedBox(
              height: 38,
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Buscar por email, ID o alias...',
                  hintStyle: TextStyle(fontSize: 13, color: Colors.grey.shade400),
                  prefixIcon: Icon(Icons.search, size: 18, color: Colors.grey.shade400),
                  filled: true,
                  fillColor: const Color(0xFFF5F5F5),
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(50),
                    borderSide: BorderSide.none,
                  ),
                ),
                onSubmitted: (v) {
                  if (v.trim().isNotEmpty) controller.loadAdminUsers(search: v.trim());
                },
              ),
            ),
          ),
          const SizedBox(width: 20),
          const Icon(Icons.notifications_outlined, size: 22, color: Color(0xFF374151)),
          const SizedBox(width: 16),
          const Icon(Icons.help_outline, size: 22, color: Color(0xFF374151)),
          const SizedBox(width: 20),
          Obx(() => Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: _purpleLight,
                    child: Text(
                      controller.currentUserInitials.value.isEmpty
                          ? 'SA'
                          : controller.currentUserInitials.value,
                      style: const TextStyle(
                          fontSize: 11, fontWeight: FontWeight.w700, color: _purple),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        controller.currentUserName.value.isEmpty
                            ? 'Super Admin'
                            : controller.currentUserName.value,
                        style: const TextStyle(
                            fontSize: 12, fontWeight: FontWeight.w700),
                      ),
                      const Text('Letdem Tienda',
                          style: TextStyle(fontSize: 10, color: Colors.grey)),
                    ],
                  ),
                ],
              )),
        ],
      ),
    );
  }

  // ─── PAGE HEADER ─────────────────────────────────────────────────────────────

  Widget _pageHeader(BuildContext context, AdminUserModel user) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Ficha Administrativa de Usuario',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800,
                      color: Color(0xFF111827))),
              const SizedBox(height: 4),
              const Text('Gestión centralizada de perfil, cumplimiento y estado de cuenta',
                  style: TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Obx(() => ElevatedButton.icon(
              onPressed: controller.isSuspending.value
                  ? null
                  : () => _confirmSuspend(context, user),
              icon: const Icon(Icons.block, size: 16, color: Colors.white),
              label: Text(
                user.isSuspended ? 'Reactivar cuenta' : 'Suspender cuenta',
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
                    color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: user.isSuspended
                    ? Colors.green
                    : const Color(0xFFDC2626),
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            )),
        const SizedBox(width: 8),
        ElevatedButton.icon(
          onPressed: () => _showEditProfileDialog(Get.context!, user),
          icon: const Icon(Icons.edit_outlined, size: 16, color: Colors.white),
          label: const Text('Editar perfil',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
                  color: Colors.white)),
          style: ElevatedButton.styleFrom(
            backgroundColor: _purple,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
      ],
    );
  }

  // ─── PROFILE CARD ────────────────────────────────────────────────────────────

  Widget _profileCard(AdminUserModel user) {
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
              Stack(
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: _purpleLight,
                    child: Text(
                      _initials(user.name),
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w800, color: _purple),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(user.name,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.tag, size: 13, color: Colors.grey),
                        const SizedBox(width: 2),
                        Text(user.id,
                            style: const TextStyle(fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: user.isSuspended
                      ? const Color(0xFFFEE2E2)
                      : const Color(0xFFD1FAE5),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  user.statusLabel,
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: user.isSuspended
                          ? const Color(0xFF991B1B)
                          : const Color(0xFF065F46)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(height: 1),
          const SizedBox(height: 16),
          _profileField('EMAIL', user.emailMasked),
          const SizedBox(height: 12),
          _docField(user),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _profileField('PAÍS', user.country.isNotEmpty ? user.country : '—')),
              const SizedBox(width: 24),
              Expanded(child: _profileField('IDIOMA', user.language.isNotEmpty ? user.language : '—')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _profileField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 10, fontWeight: FontWeight.w700,
                color: Colors.grey, letterSpacing: 0.6)),
        const SizedBox(height: 4),
        Text(value,
            style: const TextStyle(fontSize: 13, color: Color(0xFF374151))),
      ],
    );
  }

  Widget _docField(AdminUserModel user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(user.documentType.toUpperCase(),
            style: const TextStyle(
                fontSize: 10, fontWeight: FontWeight.w700,
                color: Colors.grey, letterSpacing: 0.6)),
        const SizedBox(height: 4),
        Row(
          children: [
            Obx(() {
              final revealed = controller.revealedDocument.value;
              return Text(
                revealed.isNotEmpty ? revealed : user.documentMasked,
                style: const TextStyle(fontSize: 13, color: Color(0xFF374151)),
              );
            }),
            const SizedBox(width: 12),
            OutlinedButton(
              onPressed: () => _confirmRevealDoc(Get.context!),
              style: OutlinedButton.styleFrom(
                foregroundColor: _purple,
                side: const BorderSide(color: _purple),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Enviar', style: TextStyle(fontSize: 12)),
            ),
          ],
        ),
      ],
    );
  }

  // ─── FECHAS CLAVE ─────────────────────────────────────────────────────────────

  Widget _fechasCard(AdminUserModel user) {
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
          const Text('Fechas clave',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
          const SizedBox(height: 16),
          _dateRow('Registro', _fmtDate(user.registeredAt)),
          _dateRow('Último Acceso', _fmtRelative(user.lastAccessAt)),
          _dateRow('Última Compra', _fmtDate(user.lastPurchaseAt)),
        ],
      ),
    );
  }

  Widget _dateRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(fontSize: 12, color: Colors.grey)),
          Text(value,
              style: const TextStyle(
                  fontSize: 12, fontWeight: FontWeight.w600,
                  color: Color(0xFF374151))),
        ],
      ),
    );
  }

  // ─── CUMPLIMIENTO ─────────────────────────────────────────────────────────────

  Widget _complianceCard(AdminUserModel user) {
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
          const Text('Cumplimiento (Compliance)',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
          const SizedBox(height: 16),
          // Consentimiento progress
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Consentimiento',
                      style: TextStyle(fontSize: 12, color: Colors.grey)),
                  Text('${user.consentPercent}%',
                      style: const TextStyle(
                          fontSize: 12, fontWeight: FontWeight.w700,
                          color: Color(0xFF059669))),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: user.consentPercent / 100.0,
                  minHeight: 6,
                  backgroundColor: const Color(0xFFE5E7EB),
                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF059669)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _complianceRow('KYC', user.kycEnabled, 'Activado', 'Pendiente'),
          _complianceRow('Autenticación', user.authEnabled, 'Activado', 'Inactiva'),
          _complianceRow('Facturación', user.hasBillingInfo, 'Completa', 'Sin factura'),
        ],
      ),
    );
  }

  Widget _complianceRow(String label, bool ok, String okText, String nokText) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(
            ok ? Icons.check_circle_outline : Icons.cancel_outlined,
            size: 16,
            color: ok ? const Color(0xFF059669) : const Color(0xFFDC2626),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(label,
                style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ),
          Text(
            ok ? okText : nokText,
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: ok
                    ? const Color(0xFF059669)
                    : const Color(0xFFDC2626)),
          ),
        ],
      ),
    );
  }

  // ─── ACTIVIDAD EN MARKETPLACE ────────────────────────────────────────────────

  Widget _activityRow(AdminUserModel user) {
    return Row(
      children: [
        Expanded(child: _activityStat(_fmtCount(user.totalPoints), 'PUNTOS ACUMULADOS')),
        const SizedBox(width: 12),
        Expanded(child: _activityStat('${user.totalRedemptions}', 'CANJES REALIZADOS')),
        const SizedBox(width: 12),
        Expanded(child: _activityStat('${user.openDisputes}', 'DISPUTAS ABIERTAS')),
      ],
    );
  }

  Widget _activityStat(String value, String label) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        children: [
          Text(value,
              style: const TextStyle(
                  fontSize: 22, fontWeight: FontWeight.w800, color: _purple)),
          const SizedBox(height: 4),
          Text(label,
              style: const TextStyle(fontSize: 10, color: Colors.grey,
                  fontWeight: FontWeight.w600, letterSpacing: 0.4),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }

  // ─── AUDIT LOG TABLE ──────────────────────────────────────────────────────────

  Widget _auditLogTable(BuildContext context, AdminUserModel user) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                const Text('Registro de Auditoría de Acciones',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                const Spacer(),
                GestureDetector(
                  onTap: () {},
                  child: const Text('↗ Exportar Log',
                      style: TextStyle(
                          fontSize: 12, color: _purple, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          _auditTableHeader(),
          const Divider(height: 1),
          Obx(() {
            final log = controller.auditLog;
            if (log.isEmpty) {
              return const Padding(
                padding: EdgeInsets.all(24),
                child: Center(
                  child: Text('Sin registros de auditoría.',
                      style: TextStyle(color: Colors.grey)),
                ),
              );
            }
            return Column(
              children: log.map((e) => _auditRow(context, e)).toList(),
            );
          }),
        ],
      ),
    );
  }

  Widget _auditTableHeader() {
    const style = TextStyle(
        fontSize: 10, fontWeight: FontWeight.w700,
        color: Colors.grey, letterSpacing: 0.4);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      color: const Color(0xFFF9FAFB),
      child: const Row(
        children: [
          SizedBox(width: 140, child: Text('FECHA Y HORA', style: style)),
          Expanded(flex: 2, child: Text('ACCIÓN', style: style)),
          Expanded(flex: 2, child: Text('ADMIN/AUDITOR', style: style)),
          Expanded(flex: 3, child: Text('MOTIVO/DETALLE', style: style)),
          SizedBox(width: 80, child: Text('ESTADO', style: style)),
        ],
      ),
    );
  }

  Widget _auditRow(BuildContext context, AuditLogModel entry) {
    final statusDone = entry.status == 'done' || entry.status == 'reviewed';
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            children: [
              SizedBox(
                width: 140,
                child: Text(
                  _fmtDateTime(entry.timestamp),
                  style: const TextStyle(fontSize: 12, color: Color(0xFF374151)),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(entry.action,
                    style: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w600)),
              ),
              Expanded(
                flex: 2,
                child: Text(entry.adminUser,
                    style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ),
              Expanded(
                flex: 3,
                child: Text(entry.reason,
                    style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ),
              SizedBox(
                width: 80,
                child: OutlinedButton(
                  onPressed: () => _showAuditDialog(Get.context!, entry),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: statusDone ? Colors.grey : _purple,
                    side: BorderSide(
                        color: statusDone ? Colors.grey.shade300 : _purple),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('Auditar',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
      ],
    );
  }

  // ─── DIALOGS ─────────────────────────────────────────────────────────────────

  void _confirmSuspend(BuildContext context, AdminUserModel user) {
    final reasonCtrl = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(user.isSuspended ? 'Reactivar cuenta' : 'Suspender cuenta'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(user.isSuspended
                ? '¿Confirmas la reactivación de la cuenta de ${user.name}?'
                : '¿Confirmas la suspensión de la cuenta de ${user.name}?'),
            const SizedBox(height: 12),
            TextField(
              controller: reasonCtrl,
              decoration: InputDecoration(
                labelText: 'Motivo',
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
              backgroundColor: user.isSuspended ? Colors.green : const Color(0xFFDC2626),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () async {
              Navigator.of(ctx).pop();
              await controller.suspendSelectedUser(reasonCtrl.text.trim());
            },
            child: Text(user.isSuspended ? 'Reactivar' : 'Suspender'),
          ),
        ],
      ),
    );
  }

  void _showEditProfileDialog(BuildContext context, AdminUserModel user) {
    final fnCtrl   = TextEditingController(text: user.firstName);
    final lnCtrl   = TextEditingController(text: user.lastName);
    final emailCtrl = TextEditingController(text: user.emailFull);
    final langCtrl  = TextEditingController(text: user.language);
    bool isStaff    = user.isStaff;

    showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlg) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Editar perfil'),
          content: SizedBox(
            width: 420,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(children: [
                  Expanded(child: _dlgField(fnCtrl, 'Nombre')),
                  const SizedBox(width: 12),
                  Expanded(child: _dlgField(lnCtrl, 'Apellido')),
                ]),
                const SizedBox(height: 12),
                _dlgField(emailCtrl, 'Email', keyboardType: TextInputType.emailAddress),
                const SizedBox(height: 12),
                _dlgField(langCtrl, 'Idioma (ej: es, en)'),
                const SizedBox(height: 12),
                Row(children: [
                  Switch(
                    value: isStaff,
                    onChanged: (v) => setDlg(() => isStaff = v),
                    activeColor: _purple,
                  ),
                  const SizedBox(width: 8),
                  const Text('Es Staff (is_staff)',
                      style: TextStyle(fontSize: 13)),
                ]),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Cancelar')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _purple, foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () async {
                Navigator.of(ctx).pop();
                await controller.editSelectedUser({
                  'first_name': fnCtrl.text.trim(),
                  'last_name':  lnCtrl.text.trim(),
                  'email':      emailCtrl.text.trim(),
                  'language':   langCtrl.text.trim(),
                  'is_staff':   isStaff,
                });
              },
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dlgField(TextEditingController ctrl, String label,
      {TextInputType keyboardType = TextInputType.text}) {
    return TextField(
      controller: ctrl,
      keyboardType: keyboardType,
      style: const TextStyle(fontSize: 13),
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        isDense: true,
      ),
    );
  }

  void _showAuditDialog(BuildContext context, AuditLogModel entry) {
    final notesCtrl = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Marcar como Auditado'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Acción: ${entry.action}',
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Text(entry.reason,
                style: const TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 16),
            TextField(
              controller: notesCtrl,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Notas de revisión (opcional)',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 10),
              ),
              autofocus: true,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _purple, foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () async {
              Navigator.of(ctx).pop();
              await controller.markAsAudited(
                controller.selectedUser.value?.id ?? '',
                notesCtrl.text.trim(),
              );
            },
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
  }

  void _confirmRevealDoc(BuildContext context) {
    final reasonCtrl = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Revelar Documento'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
                'Esta acción queda registrada en el log de auditoría. Indica el motivo:'),
            const SizedBox(height: 12),
            TextField(
              controller: reasonCtrl,
              decoration: InputDecoration(
                labelText: 'Motivo (ej: ticket #1234)',
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
              final reason = reasonCtrl.text.trim();
              if (reason.isEmpty) return;
              Navigator.of(ctx).pop();
              await controller.revealDocument(reason);
            },
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
  }

  // ─── HELPERS ─────────────────────────────────────────────────────────────────

  String _initials(String name) {
    final parts = name.trim().split(' ').where((w) => w.isNotEmpty).toList();
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  String _fmtDate(DateTime? dt) {
    if (dt == null) return '—';
    const months = ['', 'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
                    'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'];
    return '${dt.day} ${months[dt.month]} ${dt.year}';
  }

  String _fmtRelative(DateTime? dt) {
    if (dt == null) return '—';
    final now = DateTime.now();
    final local = dt.toLocal();
    final today = DateTime(now.year, now.month, now.day);
    final date  = DateTime(local.year, local.month, local.day);
    final time  = '${local.hour.toString().padLeft(2,'0')}:${local.minute.toString().padLeft(2,'0')}';
    if (date == today) return 'Hoy, $time';
    return _fmtDate(local);
  }

  String _fmtDateTime(DateTime dt) {
    final local = dt.toLocal();
    final date = '${local.day.toString().padLeft(2,'0')}/'
        '${local.month.toString().padLeft(2,'0')}/${local.year}';
    final time = '${local.hour.toString().padLeft(2,'0')}:${local.minute.toString().padLeft(2,'0')}';
    return '$date\n$time';
  }

  String _fmtCount(int n) {
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}k';
    return n.toString();
  }
}
