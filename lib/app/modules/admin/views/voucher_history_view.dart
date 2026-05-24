import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/models/voucher_model.dart';
import '../../../data/services/auth_service.dart';
import '../../../routes/app_pages.dart';
import '../controllers/admin_controller.dart';

class VoucherHistoryView extends StatefulWidget {
  const VoucherHistoryView({Key? key}) : super(key: key);

  @override
  State<VoucherHistoryView> createState() => _VoucherHistoryViewState();
}

class _VoucherHistoryViewState extends State<VoucherHistoryView> {
  final AdminController _ctrl = Get.find<AdminController>();
  int _tab = 0; // 0=canjeados, 1=expirados
  int _page = 1;
  int _pageSize = 10;
  String _search = '';
  final TextEditingController _searchCtrl = TextEditingController();

  static const _purple = Color(0xFF7C3AED);
  static const _purpleLight = Color(0xFFEDE9FE);
  static const _bg = Color(0xFFF8F7FF);

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<VoucherModel> get _filtered {
    final base =
        _tab == 0 ? _ctrl.redeemedVouchers : _ctrl.expiredUnredeemedVouchers;
    if (_search.isEmpty) return base;
    final q = _search.toLowerCase();
    return base.where((v) {
      return v.id.toLowerCase().contains(q) ||
          v.code.toLowerCase().contains(q) ||
          _ctrl.customerNameFor(v).toLowerCase().contains(q) ||
          _ctrl.productNameFor(v).toLowerCase().contains(q);
    }).toList();
  }

  List<VoucherModel> get _paginated {
    final f = _filtered;
    final start = (_page - 1) * _pageSize;
    if (start >= f.length) return [];
    return f.sublist(start, (start + _pageSize).clamp(0, f.length));
  }

  int get _totalPages => (_filtered.length / _pageSize).ceil().clamp(1, 9999);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: Row(
        children: [
          _sidebar(),
          Expanded(child: _mainArea()),
        ],
      ),
    );
  }

  // ── Sidebar ──────────────────────────────────────────────────────────────

  Widget _sidebar() {
    return Container(
      width: 240,
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  const Icon(Icons.bolt, color: _purple, size: 22),
                  const SizedBox(width: 4),
                  const Text('Lentem Admin',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Colors.black87)),
                ]),
                const SizedBox(height: 2),
                const Text('Shop Management',
                    style: TextStyle(fontSize: 11, color: Colors.grey)),
              ],
            ),
          ),
          const Divider(height: 1),
          const SizedBox(height: 12),
          _navItem(
            icon: Icons.dashboard_outlined,
            label: 'Dashboard',
            onTap: () => Get.offNamed(Routes.ADMIN),
          ),
          _navItem(
            icon: Icons.inventory_2_outlined,
            label: 'Inventory',
            onTap: () => Get.offNamed(Routes.ADMIN),
          ),
          _navItem(
            icon: Icons.receipt_long_outlined,
            label: 'Vouchers',
            selected: true,
          ),
          _navItem(
            icon: Icons.analytics_outlined,
            label: 'Analytics',
            onTap: () => Get.toNamed(Routes.ANALYTICS),
          ),
          _navItem(
            icon: Icons.settings_outlined,
            label: 'Settings',
            onTap: () {},
          ),
          const Spacer(),
          const Divider(height: 1),
          _profileRow(),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 4, 12, 20),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => Get.toNamed(Routes.ADD_PRODUCT),
                icon: const Icon(Icons.add, color: Colors.white, size: 18),
                label: const Text('Add New Product',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _purple,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  elevation: 0,
                ),
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
    return Material(
      color: selected ? _purple : Colors.transparent,
      child: ListTile(
        dense: true,
        leading: Icon(icon,
            size: 18,
            color: selected ? Colors.white : Colors.grey.shade600),
        title: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
            color: selected ? Colors.white : Colors.grey.shade800,
          ),
        ),
        onTap: onTap,
      ),
    );
  }

  Widget _profileRow() {
    final email = AuthService.currentUserEmail ?? '';
    final displayName =
        email.contains('@') ? email.split('@').first : email;
    final role =
        AuthService.isStoreAdmin ? 'STORE ADMIN' : 'STORE VIEWER';
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(children: [
        CircleAvatar(
          radius: 18,
          backgroundColor: Colors.grey.shade800,
          child: Text(
            displayName.isNotEmpty ? displayName[0].toUpperCase() : 'A',
            style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(displayName,
                style: const TextStyle(
                    fontSize: 12, fontWeight: FontWeight.w700),
                overflow: TextOverflow.ellipsis),
            Text(role,
                style: const TextStyle(
                    fontSize: 9, color: Colors.grey, letterSpacing: 0.5)),
          ]),
        ),
        IconButton(
          icon: const Icon(Icons.logout, size: 16, color: Colors.grey),
          onPressed: () async {
            await AuthService.signOut();
            Get.offAllNamed(Routes.WELCOME);
          },
        ),
      ]),
    );
  }

  // ── Main area ─────────────────────────────────────────────────────────────

  Widget _mainArea() {
    return Column(children: [
      _topBar(),
      Expanded(
        child: Obx(() {
          if (_ctrl.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(32, 24, 32, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _breadcrumb(),
                const SizedBox(height: 8),
                _titleRow(),
                const SizedBox(height: 24),
                _statCards(),
                const SizedBox(height: 24),
                _tableCard(),
              ],
            ),
          );
        }),
      ),
    ]);
  }

  Widget _topBar() {
    return Container(
      height: 64,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Row(children: [
        Expanded(
          child: Container(
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(10),
            ),
            child: TextField(
              controller: _searchCtrl,
              decoration: const InputDecoration(
                border: InputBorder.none,
                prefixIcon:
                    Icon(Icons.search, size: 18, color: Colors.grey),
                hintText: 'Buscar por Voucher ID o nombre de usuario...',
                hintStyle: TextStyle(fontSize: 13, color: Colors.grey),
                contentPadding: EdgeInsets.symmetric(vertical: 10),
              ),
              onChanged: (v) => setState(() {
                _search = v;
                _page = 1;
              }),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Stack(children: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined,
                color: Colors.black54),
            onPressed: () {},
          ),
          Positioned(
            right: 8,
            top: 8,
            child: Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                  color: Colors.orange, shape: BoxShape.circle),
            ),
          ),
        ]),
        const SizedBox(width: 8),
        OutlinedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.tune, size: 16, color: Colors.black54),
          label: const Text('Filtros Avanzados',
              style: TextStyle(color: Colors.black54, fontSize: 13)),
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: Color(0xFFE5E7EB)),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8)),
          ),
        ),
      ]),
    );
  }

  Widget _breadcrumb() {
    return Row(children: [
      const Text('Admin',
          style: TextStyle(fontSize: 13, color: Colors.grey)),
      const Text(' / ', style: TextStyle(color: Colors.grey)),
      Text('Vouchers',
          style: TextStyle(
              fontSize: 13,
              color: _purple,
              fontWeight: FontWeight.w600)),
    ]);
  }

  Widget _titleRow() {
    return Row(children: [
      const Text('Historial de Vouchers',
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800)),
      const Spacer(),
      TextButton.icon(
        onPressed: _exportCsv,
        icon: const Icon(Icons.download_outlined, color: _purple, size: 18),
        label: const Text('Exportar CSV',
            style: TextStyle(color: _purple, fontWeight: FontWeight.w600)),
      ),
    ]);
  }

  // ── Stat cards ────────────────────────────────────────────────────────────

  Widget _statCards() {
    final redeemed = _ctrl.redeemedVouchers;
    final expired = _ctrl.expiredUnredeemedVouchers;
    final totalPts =
        _ctrl.vouchers.fold<int>(0, (s, v) => s + v.pointsUsed);
    final summary = _ctrl.analyticsSummary.value;
    final growthPct = summary['redemptions_growth_pct'] as num?;

    return Row(children: [
      Expanded(
        flex: 2,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF7C3AED), Color(0xFF9F5FFF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                const Text('TOTAL CANJEADOS',
                    style: TextStyle(
                        fontSize: 11,
                        color: Colors.white70,
                        letterSpacing: 0.8,
                        fontWeight: FontWeight.w600)),
                const Spacer(),
                Icon(Icons.confirmation_number_outlined,
                    color: Colors.white.withValues(alpha: 0.35),
                    size: 44),
              ]),
              const SizedBox(height: 12),
              Text(_fmtNum(redeemed.length),
                  style: const TextStyle(
                      fontSize: 42,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      height: 1)),
              const SizedBox(height: 16),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(
                    growthPct != null && growthPct >= 0
                        ? Icons.trending_up
                        : Icons.trending_down,
                    color: Colors.white,
                    size: 14,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    growthPct != null
                        ? '${growthPct >= 0 ? '+' : ''}${growthPct.toStringAsFixed(0)}% vs mes anterior'
                        : 'Datos del mes actual',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600),
                  ),
                ]),
              ),
            ],
          ),
        ),
      ),
      const SizedBox(width: 16),
      Expanded(
        child: _miniCard(
          label: 'Total Expirados',
          value: _fmtNum(expired.length),
          sub: 'Sin canjear',
          subIcon: Icons.warning_amber_outlined,
          subColor: Colors.orange,
          trailingIcon: Icons.cancel_outlined,
          trailingColor: Colors.orange,
          trailingBg: const Color(0xFFFFF7ED),
        ),
      ),
      const SizedBox(width: 16),
      Expanded(
        child: _miniCard(
          label: 'Puntos Emitidos',
          value: _fmtNum(totalPts),
          sub: 'Valor en Marketplace',
          subIcon: Icons.stars_outlined,
          subColor: Colors.orange,
          trailingIcon: Icons.stars_outlined,
          trailingColor: Colors.orange,
          trailingBg: const Color(0xFFFFF7ED),
        ),
      ),
    ]);
  }

  Widget _miniCard({
    required String label,
    required String value,
    required String sub,
    required IconData subIcon,
    required Color subColor,
    required IconData trailingIcon,
    required Color trailingColor,
    required Color trailingBg,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(
            child: Text(label,
                style: const TextStyle(
                    fontSize: 13,
                    color: Colors.black54,
                    fontWeight: FontWeight.w500)),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
                color: trailingBg, borderRadius: BorderRadius.circular(8)),
            child: Icon(trailingIcon, color: trailingColor, size: 18),
          ),
        ]),
        const SizedBox(height: 10),
        Text(value,
            style: const TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.w800,
                color: Colors.black87)),
        const SizedBox(height: 6),
        Row(children: [
          Icon(subIcon, size: 14, color: subColor),
          const SizedBox(width: 4),
          Expanded(
            child: Text(sub,
                style: TextStyle(fontSize: 12, color: subColor),
                overflow: TextOverflow.ellipsis),
          ),
        ]),
        const SizedBox(height: 12),
        Icon(Icons.receipt_long_outlined,
            color: Colors.grey.shade200, size: 28),
      ]),
    );
  }

  // ── Table ─────────────────────────────────────────────────────────────────

  Widget _tableCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(children: [
        _tableTabs(),
        const Divider(height: 1),
        _tableHeader(),
        const Divider(height: 1),
        if (_paginated.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 48),
            child: Center(
              child: Text(
                _search.isNotEmpty
                    ? 'Sin resultados para "$_search"'
                    : 'Sin registros',
                style:
                    const TextStyle(color: Colors.grey, fontSize: 14),
              ),
            ),
          )
        else
          ..._paginated.map(_tableRow),
        const Divider(height: 1),
        _paginationBar(),
      ]),
    );
  }

  Widget _tableTabs() {
    final showing = _paginated.length;
    final from =
        _filtered.isEmpty ? 0 : (_page - 1) * _pageSize + 1;
    final to = from + showing - 1;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(children: [
        _tabBtn(0, Icons.check_circle_outline, 'Canjeados'),
        const SizedBox(width: 4),
        _tabBtn(1, Icons.cancel_outlined, 'Expirados'),
        const Spacer(),
        if (_filtered.isNotEmpty)
          Text('Mostrando $from-$to de ${_filtered.length}',
              style:
                  const TextStyle(fontSize: 12, color: Colors.grey)),
      ]),
    );
  }

  Widget _tabBtn(int index, IconData icon, String label) {
    final sel = _tab == index;
    return GestureDetector(
      onTap: () => setState(() {
        _tab = index;
        _page = 1;
      }),
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
                color: sel ? _purple : Colors.transparent, width: 2),
          ),
        ),
        child: Row(children: [
          Icon(icon, size: 16, color: sel ? _purple : Colors.grey),
          const SizedBox(width: 6),
          Text(label,
              style: TextStyle(
                  fontSize: 14,
                  fontWeight:
                      sel ? FontWeight.w600 : FontWeight.normal,
                  color: sel ? _purple : Colors.grey)),
        ]),
      ),
    );
  }

  Widget _tableHeader() {
    const style = TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: Colors.grey,
        letterSpacing: 0.5);
    return Padding(
      padding:
          const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(children: const [
        SizedBox(width: 150, child: Text('VOUCHER ID', style: style)),
        Expanded(flex: 2, child: Text('RECOMPENSA', style: style)),
        Expanded(flex: 2, child: Text('USUARIO', style: style)),
        Expanded(child: Text('FECHA DE CANJE', style: style)),
        SizedBox(width: 110, child: Text('ESTADO', style: style)),
      ]),
    );
  }

  Widget _tableRow(VoucherModel v) {
    final isRedeemed = v.isRedeemed;
    final statusLabel = isRedeemed ? 'Canjeado' : 'Expirado';
    final statusColor =
        isRedeemed ? Colors.green.shade600 : Colors.grey.shade500;
    final customerName = _ctrl.customerNameFor(v);
    final initials = customerName
        .split(' ')
        .map((s) => s.isNotEmpty ? s[0] : '')
        .take(2)
        .join()
        .toUpperCase();
    final productName = _ctrl.productNameFor(v);
    final eventDate = v.redeemedAt ?? v.expiresAt;
    final shortId =
        '#VOU-${v.id.length > 5 ? v.id.substring(0, 5).toUpperCase() : v.id.toUpperCase()}';

    return Column(children: [
      Padding(
        padding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(children: [
          SizedBox(
            width: 150,
            child: Text(shortId,
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isRedeemed ? _purple : Colors.black54)),
          ),
          Expanded(
            flex: 2,
            child: Row(children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                    color: _purpleLight,
                    borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.card_giftcard_outlined,
                    size: 18, color: _purple),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(productName,
                          style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600),
                          overflow: TextOverflow.ellipsis),
                      Text(
                          v.redeemType == 'IN_STORE'
                              ? 'Physical Code'
                              : 'Digital Voucher',
                          style: const TextStyle(
                              fontSize: 11, color: Colors.grey)),
                    ]),
              ),
            ]),
          ),
          Expanded(
            flex: 2,
            child: Row(children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: const Color(0xFFE8D5FF),
                child: Text(
                  initials.isEmpty ? '?' : initials,
                  style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: _purple),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(customerName,
                    style: const TextStyle(fontSize: 13),
                    overflow: TextOverflow.ellipsis),
              ),
            ]),
          ),
          Expanded(
            child: eventDate == null
                ? const Text('—',
                    style: TextStyle(color: Colors.grey))
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_fmtDate(eventDate.toLocal()),
                          style: const TextStyle(fontSize: 13)),
                      if (!isRedeemed)
                        Text('Expiró ${_fmtTime(eventDate.toLocal())}',
                            style: const TextStyle(
                                fontSize: 11, color: Colors.orange))
                      else
                        Text(_fmtTime(eventDate.toLocal()),
                            style: const TextStyle(
                                fontSize: 11, color: Colors.grey)),
                    ],
                  ),
          ),
          SizedBox(
            width: 110,
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.circle, size: 7, color: statusColor),
                const SizedBox(width: 5),
                Text(statusLabel,
                    style: TextStyle(
                        fontSize: 12,
                        color: statusColor,
                        fontWeight: FontWeight.w600)),
              ]),
            ),
          ),
        ]),
      ),
      const Divider(height: 1),
    ]);
  }

  // ── Pagination ────────────────────────────────────────────────────────────

  Widget _paginationBar() {
    return Padding(
      padding:
          const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(children: [
        const Text('Filas por página:',
            style: TextStyle(fontSize: 13, color: Colors.grey)),
        const SizedBox(width: 8),
        DropdownButton<int>(
          value: _pageSize,
          underline: const SizedBox.shrink(),
          style: const TextStyle(fontSize: 13, color: Colors.black87),
          items: [10, 20, 50]
              .map((n) =>
                  DropdownMenuItem(value: n, child: Text('$n')))
              .toList(),
          onChanged: (v) {
            if (v != null) setState(() { _pageSize = v; _page = 1; });
          },
        ),
        const Spacer(),
        _pgBtn(Icons.chevron_left,
            _page > 1 ? () => setState(() => _page--) : null),
        const SizedBox(width: 4),
        ..._pageNums().map((n) => n == -1
            ? const Padding(
                padding: EdgeInsets.symmetric(horizontal: 4),
                child:
                    Text('...', style: TextStyle(color: Colors.grey)),
              )
            : _pgNum(n, n == _page, () => setState(() => _page = n))),
        const SizedBox(width: 4),
        _pgBtn(Icons.chevron_right,
            _page < _totalPages
                ? () => setState(() => _page++)
                : null),
      ]),
    );
  }

  List<int> _pageNums() {
    final t = _totalPages;
    if (t <= 5) return List.generate(t, (i) => i + 1);
    if (_page <= 3) return [1, 2, 3, -1, t];
    if (_page >= t - 2) return [1, -1, t - 2, t - 1, t];
    return [1, -1, _page, -1, t];
  }

  Widget _pgBtn(IconData icon, VoidCallback? onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFE5E7EB)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon,
            size: 18,
            color: onTap != null
                ? Colors.black87
                : Colors.grey.shade300),
      ),
    );
  }

  Widget _pgNum(int n, bool current, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        margin: const EdgeInsets.symmetric(horizontal: 2),
        decoration: BoxDecoration(
          color: current ? _purple : Colors.transparent,
          border: Border.all(
              color:
                  current ? _purple : const Color(0xFFE5E7EB)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text('$n',
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: current ? Colors.white : Colors.black87)),
        ),
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  void _exportCsv() {
    final rows = _filtered;
    Get.snackbar(
      'CSV generado',
      'Se exportaron ${rows.length} registros.',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  static String _fmtNum(int n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 10000) return '${(n / 1000).toStringAsFixed(0)}K';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
    return n.toString();
  }

  static String _fmtDate(DateTime d) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[d.month - 1]} ${d.day}, ${d.year}';
  }

  static String _fmtTime(DateTime d) {
    final h = d.hour.toString().padLeft(2, '0');
    final m = d.minute.toString().padLeft(2, '0');
    return '$h:$m ${d.hour >= 12 ? 'PM' : 'AM'}';
  }
}
