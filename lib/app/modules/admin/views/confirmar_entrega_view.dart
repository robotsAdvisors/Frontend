import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../data/models/voucher_model.dart';
import '../../../data/services/auth_service.dart';
import '../../../routes/app_pages.dart';
import '../controllers/admin_controller.dart';

class ConfirmarEntregaView extends StatefulWidget {
  const ConfirmarEntregaView({super.key});

  @override
  State<ConfirmarEntregaView> createState() => _ConfirmarEntregaViewState();
}

class _ConfirmarEntregaViewState extends State<ConfirmarEntregaView> {
  static const Color _purple      = Color(0xFF7C3AED);
  static const Color _purpleLight = Color(0xFFEDE9FE);
  static const Color _bg          = Color(0xFFF8F7FF);
  static const Color _dark        = Color(0xFF1E1B4B);
  static const Color _border      = Color(0xFFEEEEEE);
  static const Color _green       = Color(0xFF10B981);
  static const Color _red         = Color(0xFFEF4444);
  static const Color _amber       = Color(0xFFF59E0B);

  late final AdminController _ctrl;
  final _codeCtrl = TextEditingController();
  bool _isConfirming = false;
  bool _justConfirmed = false;

  @override
  void initState() {
    super.initState();
    _ctrl = Get.find<AdminController>();
  }

  @override
  void dispose() {
    _codeCtrl.dispose();
    _ctrl.clearVoucherPreview();
    super.dispose();
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
        title: const Text('Confirmar entrega',
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
        _navItem(icon: Icons.grid_view_outlined, label: 'Inicio',
            onTap: () => Get.offAllNamed(Routes.ADMIN)),
        _navItem(icon: Icons.receipt_long_outlined, label: 'Canjes', selected: true),
        _navItem(icon: Icons.inventory_2_outlined, label: 'Productos',
            onTap: () => Get.toNamed(Routes.INVENTARIO)),
        _navItem(icon: Icons.history_outlined, label: 'Historial',
            onTap: () => Get.toNamed(Routes.VOUCHER_HISTORY)),
        _navItem(icon: Icons.security_outlined, label: 'Seguridad',
            onTap: () => Get.toNamed(Routes.SEGURIDAD)),
        _navItem(icon: Icons.settings_outlined, label: 'Configuraciones',
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
            const SizedBox(height: 20),
            _searchBar(),
            const SizedBox(height: 20),
            if (_justConfirmed)
              _successBanner()
            else
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 5, child: _codeCard()),
                  const SizedBox(width: 16),
                  Expanded(flex: 4, child: _detailCard()),
                ],
              ),
            const SizedBox(height: 20),
          ]),
        ),
      ),
      _bottomBar(),
    ]);
  }

  // ─── HEADER ───────────────────────────────────────────────────────────────

  Widget _header() {
    return Row(children: [
      const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Confirmar entrega de canje',
            style: TextStyle(
                fontSize: 22, fontWeight: FontWeight.w800, color: _dark)),
        SizedBox(height: 4),
        Text('Busca el código del voucher para verificar y confirmar la entrega al cliente.',
            style: TextStyle(fontSize: 13, color: Colors.grey)),
      ]),
      const Spacer(),
      Obx(() {
        final store = _ctrl.currentStore;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: _purpleLight,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(children: [
            Container(
              width: 28, height: 28,
              decoration: BoxDecoration(
                  color: _purple, borderRadius: BorderRadius.circular(14)),
              child: const Icon(Icons.store_outlined, size: 14, color: Colors.white),
            ),
            const SizedBox(width: 8),
            Text(store.name.isNotEmpty ? store.name : 'Admin Tienda',
                style: const TextStyle(
                    fontSize: 12, fontWeight: FontWeight.w600, color: _purple)),
          ]),
        );
      }),
    ]);
  }

  // ─── SEARCH BAR ───────────────────────────────────────────────────────────

  Widget _searchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _border),
      ),
      child: Row(children: [
        const Icon(Icons.search, size: 18, color: Colors.grey),
        const SizedBox(width: 10),
        Expanded(
          child: TextField(
            controller: _codeCtrl,
            textCapitalization: TextCapitalization.characters,
            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9\-]'))],
            style: const TextStyle(fontSize: 14, color: _dark),
            decoration: const InputDecoration(
              hintText: 'Ingresa el código del voucher para confirmar...',
              hintStyle: TextStyle(fontSize: 13, color: Colors.grey),
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.zero,
            ),
            onSubmitted: (v) => _ctrl.previewVoucherCode(v.trim()),
          ),
        ),
        const SizedBox(width: 8),
        Obx(() => _ctrl.isPreviewingVoucher.value
            ? const SizedBox(
                width: 36, height: 36,
                child: Center(
                  child: SizedBox(
                    width: 18, height: 18,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: _purple)),
                ))
            : TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: _purple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 18, vertical: 10),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () =>
                    _ctrl.previewVoucherCode(_codeCtrl.text.trim()),
                child: const Text('Buscar',
                    style: TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w600)),
              )),
      ]),
    );
  }

  // ─── CODE CARD ────────────────────────────────────────────────────────────

  Widget _codeCard() {
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
            child: const Icon(Icons.qr_code_outlined, size: 20, color: _purple),
          ),
          const SizedBox(width: 12),
          const Text('Código de canje',
              style: TextStyle(
                  fontSize: 16, fontWeight: FontWeight.w700, color: _dark)),
        ]),
        const SizedBox(height: 20),

        // ── Found code badge ────────────────────────────────────────────────
        Obx(() {
          final v = _ctrl.previewedVoucher.value;
          final err = _ctrl.previewError.value;

          if (err.isNotEmpty) {
            return _errorChip(err);
          }

          if (v == null) {
            return _emptyCodeState();
          }

          return _foundCodeBadge(v.code);
        }),

        const SizedBox(height: 20),

        // ── Scan button ─────────────────────────────────────────────────────
        // ⚠️ HARDCODED: QR scanning requires mobile_scanner plugin (not in pubspec).
        // Currently shows "próximamente" toast. Add to pubspec and implement when ready.
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: _purple,
              side: const BorderSide(color: _purple),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            icon: const Icon(Icons.qr_code_scanner_outlined, size: 18),
            label: const Text('Escanear código',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            onPressed: () => Get.snackbar(
              'Próximamente',
              'El escáner QR estará disponible en la próxima versión.',
              snackPosition: SnackPosition.TOP,
              backgroundColor: Colors.white,
              colorText: _dark,
              duration: const Duration(seconds: 2),
            ),
          ),
        ),
        const SizedBox(height: 10),

        // ── Clear button ────────────────────────────────────────────────────
        Obx(() => _ctrl.previewedVoucher.value != null
            ? SizedBox(
                width: double.infinity,
                child: TextButton.icon(
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.grey,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  icon: const Icon(Icons.clear, size: 16),
                  label: const Text('Limpiar código',
                      style: TextStyle(fontSize: 13)),
                  onPressed: () {
                    _codeCtrl.clear();
                    _ctrl.clearVoucherPreview();
                    setState(() => _justConfirmed = false);
                  },
                ),
              )
            : const SizedBox.shrink()),

        const SizedBox(height: 20),
        Container(height: 1, color: _border),
        const SizedBox(height: 16),

        // ── Verification info ────────────────────────────────────────────────
        _infoPoint(
          icon: Icons.verified_user_outlined,
          color: _purple,
          text: 'Verifica siempre el estado del voucher antes de confirmar.',
        ),
        const SizedBox(height: 8),
        _infoPoint(
          icon: Icons.block_outlined,
          color: _red,
          text: 'No confirmes vouchers expirados o ya canjeados.',
        ),
        const SizedBox(height: 8),
        _infoPoint(
          icon: Icons.person_outline,
          color: _amber,
          text: 'Asegúrate de que el cliente está presente en la tienda.',
        ),
      ]),
    );
  }

  Widget _emptyCodeState() {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: const Color(0xFFF9F9F9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _border, style: BorderStyle.solid),
      ),
      child: const Center(
        child: Text(
          'Ingresa o escanea un código para comenzar',
          style: TextStyle(fontSize: 13, color: Colors.grey),
        ),
      ),
    );
  }

  Widget _foundCodeBadge(String code) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 18),
      decoration: BoxDecoration(
        color: _purpleLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Color.fromRGBO(124, 58, 237, 0.25)),
      ),
      child: Column(children: [
        const Icon(Icons.check_circle_outline, size: 22, color: _purple),
        const SizedBox(height: 8),
        Text(code,
            style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: _purple,
                letterSpacing: 1.5)),
        const SizedBox(height: 4),
        const Text('Voucher encontrado',
            style: TextStyle(fontSize: 11, color: _purple)),
      ]),
    );
  }

  Widget _errorChip(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Color.fromRGBO(239, 68, 68, 0.25)),
      ),
      child: Row(children: [
        const Icon(Icons.error_outline, size: 16, color: _red),
        const SizedBox(width: 8),
        Expanded(
          child: Text(message,
              style: const TextStyle(fontSize: 13, color: _red)),
        ),
      ]),
    );
  }

  Widget _infoPoint({
    required IconData icon,
    required Color color,
    required String text,
  }) {
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Icon(icon, size: 14, color: color),
      const SizedBox(width: 8),
      Expanded(
        child: Text(text,
            style: const TextStyle(
                fontSize: 12, color: Colors.grey, height: 1.4)),
      ),
    ]);
  }

  // ─── DETAIL CARD ──────────────────────────────────────────────────────────

  Widget _detailCard() {
    return Obx(() {
      final v = _ctrl.previewedVoucher.value;

      if (v == null) {
        return _emptyDetailCard();
      }

      final customerName = _ctrl.customerNameFor(v);
      final productName  = _ctrl.productNameFor(v);
      final pointsFmt    = NumberFormat('#,###').format(v.pointsUsed);
      final issuedFmt    = DateFormat('dd/MM/yyyy').format(v.issuedAt.toLocal());
      final expiresFmt   = v.expiresAt != null
          ? DateFormat('dd/MM/yyyy').format(v.expiresAt!.toLocal())
          : '—';
      final canConfirm   = v.status == VoucherStatus.paid ||
          v.status == VoucherStatus.pending;

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
                  color: const Color(0xFFECFDF5),
                  borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.local_offer_outlined,
                  size: 20, color: _green),
            ),
            const SizedBox(width: 12),
            const Text('Detalle del canje',
                style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w700, color: _dark)),
          ]),
          const SizedBox(height: 20),

          // Product image placeholder or network image
          if (v.productImageUrl != null && v.productImageUrl!.isNotEmpty)
            Container(
              height: 120,
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 14),
              decoration: BoxDecoration(
                color: _purpleLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  v.productImageUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const Icon(
                      Icons.image_not_supported_outlined,
                      color: Colors.grey),
                ),
              ),
            ),

          // Product name
          Text(productName,
              style: const TextStyle(
                  fontSize: 16, fontWeight: FontWeight.w700, color: _dark)),
          const SizedBox(height: 4),

          // Points
          Row(children: [
            const Icon(Icons.stars_rounded, size: 16, color: _purple),
            const SizedBox(width: 4),
            Text('$pointsFmt puntos',
                style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: _purple)),
          ]),

          if (v.paymentAmountEur != null && v.paymentAmountEur! > 0) ...[
            const SizedBox(height: 4),
            Text(
              'Pago adicional: €${v.paymentAmountEur!.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],

          const SizedBox(height: 16),
          Container(height: 1, color: _border),
          const SizedBox(height: 14),

          _detailRow('Cliente',   customerName),
          _detailRow('Estado',    _statusLabel(v.status)),
          _detailRow('Emitido',   issuedFmt),
          _detailRow('Vence',     expiresFmt),
          if (v.redeemType.isNotEmpty)
            _detailRow('Tipo', v.redeemType == 'IN_STORE' ? 'En tienda' : 'Online'),

          // Payment verified badge
          if (v.paymentVerified) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFECFDF5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(children: [
                Icon(Icons.verified_outlined, size: 14, color: _green),
                SizedBox(width: 6),
                Text('Pago verificado',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _green)),
              ]),
            ),
          ],

          const SizedBox(height: 20),

          // ── Status warning if not confirmable ───────────────────────────
          if (!canConfirm)
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF2F2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(children: [
                const Icon(Icons.warning_amber_outlined,
                    size: 14, color: _red),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Este voucher no puede confirmarse (${_statusLabel(v.status)}).',
                    style: const TextStyle(
                        fontSize: 12, color: _red, height: 1.4),
                  ),
                ),
              ]),
            ),

          // ── Confirm button ──────────────────────────────────────────────
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: canConfirm ? _purple : Colors.grey.shade200,
                foregroundColor:
                    canConfirm ? Colors.white : Colors.grey,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              icon: _isConfirming
                  ? const SizedBox(
                      width: 16, height: 16,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.check_circle_outline, size: 18),
              label: Text(
                _isConfirming ? 'Confirmando...' : 'Confirmar entrega',
                style: const TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w600),
              ),
              onPressed: canConfirm && !_isConfirming
                  ? () => _confirmDelivery(v)
                  : null,
            ),
          ),
        ]),
      );
    });
  }

  Widget _emptyDetailCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border),
      ),
      child: Column(children: [
        const SizedBox(height: 32),
        Container(
          width: 56, height: 56,
          decoration: BoxDecoration(
              color: _purpleLight, borderRadius: BorderRadius.circular(14)),
          child:
              const Icon(Icons.local_offer_outlined, size: 26, color: _purple),
        ),
        const SizedBox(height: 14),
        const Text('Sin voucher seleccionado',
            style: TextStyle(
                fontSize: 14, fontWeight: FontWeight.w600, color: _dark)),
        const SizedBox(height: 6),
        const Text(
          'Busca o escanea el código del voucher para ver el detalle y confirmar la entrega.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 12, color: Colors.grey, height: 1.5),
        ),
        const SizedBox(height: 32),
      ]),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SizedBox(
          width: 70,
          child: Text(label,
              style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ),
        Expanded(
          child: Text(value,
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: _dark),
              maxLines: 2,
              overflow: TextOverflow.ellipsis),
        ),
      ]),
    );
  }

  // ─── SUCCESS BANNER ───────────────────────────────────────────────────────

  Widget _successBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: const Color(0xFFECFDF5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Color.fromRGBO(16, 185, 129, 0.3)),
      ),
      child: Column(children: [
        Container(
          width: 64, height: 64,
          decoration: BoxDecoration(
              color: _green, borderRadius: BorderRadius.circular(32)),
          child:
              const Icon(Icons.check, size: 32, color: Colors.white),
        ),
        const SizedBox(height: 16),
        const Text('¡Entrega confirmada!',
            style: TextStyle(
                fontSize: 20, fontWeight: FontWeight.w800, color: _green)),
        const SizedBox(height: 6),
        const Text(
          'El voucher fue marcado como canjeado correctamente.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 13, color: Colors.grey),
        ),
        const SizedBox(height: 20),
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: _purple,
            foregroundColor: Colors.white,
            padding:
                const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)),
            elevation: 0,
          ),
          icon: const Icon(Icons.add_circle_outline, size: 16),
          label: const Text('Confirmar otro canje',
              style: TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w600)),
          onPressed: () {
            _codeCtrl.clear();
            _ctrl.clearVoucherPreview();
            setState(() => _justConfirmed = false);
          },
        ),
      ]),
    );
  }

  // ─── BOTTOM BAR ──────────────────────────────────────────────────────────

  Widget _bottomBar() {
    return Container(
      color: const Color(0xFFFEF3C7),
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
      child: const Row(children: [
        Icon(Icons.warning_amber_outlined, size: 16, color: _amber),
        SizedBox(width: 8),
        Expanded(
          child: Text(
            'Cada entrega confirmada queda registrada. Asegúrate de que el cliente recibió el producto antes de confirmar.',
            style: TextStyle(
                fontSize: 12,
                color: _amber,
                fontWeight: FontWeight.w500),
          ),
        ),
      ]),
    );
  }

  // ─── HELPERS ──────────────────────────────────────────────────────────────

  String _statusLabel(VoucherStatus status) => switch (status) {
    VoucherStatus.pending   => 'Pendiente',
    VoucherStatus.paid      => 'Pagado',
    VoucherStatus.redeemed  => 'Canjeado',
    VoucherStatus.expired   => 'Expirado',
    VoucherStatus.cancelled => 'Cancelado',
  };

  Future<void> _confirmDelivery(VoucherModel voucher) async {
    setState(() => _isConfirming = true);
    try {
      final ok = await _ctrl.validateVoucherCode(voucher.code);
      if (ok && mounted) {
        setState(() => _justConfirmed = true);
      }
    } finally {
      if (mounted) setState(() => _isConfirming = false);
    }
  }
}
