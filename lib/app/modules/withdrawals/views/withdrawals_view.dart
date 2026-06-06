import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../data/models/withdrawal_model.dart';
import '../controllers/withdrawals_controller.dart';

class WithdrawalsView extends GetView<WithdrawalsController> {
  const WithdrawalsView({super.key});

  static const Color _purple = Color(0xFF7C3AED);
  static const Color _purpleLight = Color(0xFFEDE9FE);
  static const Color _purpleFaint = Color(0xFFF5F3FF);
  static const Color _bg = Color(0xFFF8F7FF);
  static const Color _textDark = Color(0xFF1E1B4B);
  static const Color _textMid = Color(0xFF374151);
  static const Color _textSoft = Color(0xFF6B7280);
  static const Color _green = Color(0xFF10B981);
  static const Color _amber = Color(0xFFF59E0B);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _appBar(),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(
                    child: CircularProgressIndicator(color: _purple),
                  );
                }
                return RefreshIndicator(
                  color: _purple,
                  onRefresh: controller.refresh,
                  child: CustomScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    slivers: [
                      SliverToBoxAdapter(
                        child: Column(
                          children: [
                            _balanceHeroCard(),
                            SizedBox(height: 16.h),
                            _statsRow(),
                            SizedBox(height: 20.h),
                          ],
                        ),
                      ),
                      _methodsSection(),
                      SliverToBoxAdapter(child: SizedBox(height: 20.h)),
                      _historySection(),
                      SliverToBoxAdapter(child: SizedBox(height: 100.h)),
                    ],
                  ),
                );
              }),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _bottomWithdrawBar(),
    );
  }

  // ─── APP BAR ─────────────────────────────────────────────────────────────────

  Widget _appBar() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
      color: Colors.white,
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Get.back(),
            child: Container(
              width: 38.r,
              height: 38.r,
              decoration: BoxDecoration(
                color: _purpleFaint,
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: const Icon(Icons.arrow_back_ios_new_rounded,
                  size: 16, color: _textDark),
            ),
          ),
          SizedBox(width: 14.w),
          const Expanded(
            child: Text(
              'Retirar fondos',
              style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.w700, color: _textDark),
            ),
          ),
          GestureDetector(
            onTap: controller.refresh,
            child: Container(
              width: 38.r,
              height: 38.r,
              decoration: BoxDecoration(
                color: _purpleFaint,
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: const Icon(Icons.refresh_rounded, size: 18, color: _purple),
            ),
          ),
        ],
      ),
    );
  }

  // ─── BALANCE HERO ─────────────────────────────────────────────────────────────

  Widget _balanceHeroCard() {
    return Obx(() {
      final balance = controller.availableBalance;
      final verified = controller.isVerified;
      return Container(
        margin: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 0),
        padding: EdgeInsets.all(24.r),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF7C3AED), Color(0xFF5B21B6)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24.r),
          boxShadow: [
            BoxShadow(
              color: _purple.withValues(alpha: 0.4),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Saldo disponible',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: verified
                        ? _green.withValues(alpha: 0.25)
                        : Colors.orange.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(
                      color: verified
                          ? _green.withValues(alpha: 0.6)
                          : Colors.orange.withValues(alpha: 0.6),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        verified
                            ? Icons.verified_rounded
                            : Icons.warning_amber_rounded,
                        color: verified ? _green : Colors.orange,
                        size: 12,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        verified ? 'Verificado' : 'Sin verificar',
                        style: TextStyle(
                          color: verified ? _green : Colors.orange,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Text(
              '€ ${balance.toStringAsFixed(2)}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 38,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
            SizedBox(height: 16.h),
            const Divider(color: Colors.white24, height: 1),
            SizedBox(height: 14.h),
            Obx(() {
              final hasInstant = controller.config.value.hasInstant;
              return Wrap(
                spacing: 8.w,
                children: [
                  if (hasInstant)
                    _heroPill(
                      icon: Icons.flash_on_rounded,
                      label:
                          'Instantáneo hasta €${controller.instantLimit.toStringAsFixed(0)}',
                    ),
                  _heroPill(
                    icon: Icons.schedule_rounded,
                    label: '1-3 días laborables',
                  ),
                  if (!hasInstant)
                    _heroPill(
                      icon: Icons.flash_off_rounded,
                      label: 'Sin retiro instantáneo',
                    ),
                ],
              );
            }),
          ],
        ),
      );
    });
  }

  Widget _heroPill({required IconData icon, required String label}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white70, size: 12),
          SizedBox(width: 4.w),
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 11),
          ),
        ],
      ),
    );
  }

  // ─── STATS ROW ───────────────────────────────────────────────────────────────

  Widget _statsRow() {
    return Obx(() => Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Row(
            children: [
              _statCard(
                label: 'Total retirado',
                value:
                    '€ ${controller.totalWithdrawn.toStringAsFixed(2)}',
                icon: Icons.arrow_upward_rounded,
                color: _purple,
              ),
              SizedBox(width: 12.w),
              _statCard(
                label: 'Pendientes',
                value: controller.pendingCount.toString(),
                icon: Icons.hourglass_top_rounded,
                color: _amber,
              ),
              SizedBox(width: 12.w),
              _statCard(
                label: 'Completados',
                value: controller.withdrawals
                    .where((w) => w.status == WithdrawalStatus.completed)
                    .length
                    .toString(),
                icon: Icons.check_circle_outline_rounded,
                color: _green,
              ),
            ],
          ),
        ));
  }

  Widget _statCard({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(14.r),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: const Color(0xFFEEEEEE)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(6.r),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(icon, size: 14, color: color),
            ),
            SizedBox(height: 8.h),
            Text(
              value,
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: _textDark),
            ),
            SizedBox(height: 2.h),
            Text(
              label,
              style: const TextStyle(fontSize: 10, color: _textSoft),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  // ─── METHODS SECTION ─────────────────────────────────────────────────────────

  Widget _methodsSection() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Obx(() {
          final methods = controller.availableMethods;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Método de retiro',
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: _textDark),
              ),
              SizedBox(height: 12.h),
              if (methods.isEmpty)
                _noMethodsBanner()
              else
                ...methods.map((m) => Padding(
                      padding: EdgeInsets.only(bottom: 10.h),
                      child: _payoutMethodTile(m),
                    )),
              SizedBox(height: 6.h),
              _quickInfoCard(),
            ],
          );
        }),
      ),
    );
  }

  Widget _payoutMethodTile(PayoutMethod method) {
    return Obx(() {
      final selected = controller.selectedMethod.value?.id == method.id;
      return GestureDetector(
        onTap: () => controller.selectMethod(method),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 16.w),
          decoration: BoxDecoration(
            color: selected ? _purpleLight : Colors.white,
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(
              color: selected ? _purple : const Color(0xFFDDDDDD),
              width: selected ? 1.5 : 1,
            ),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: _purple.withValues(alpha: 0.12),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    )
                  ]
                : null,
          ),
          child: Row(
            children: [
              Container(
                width: 40.r,
                height: 40.r,
                decoration: BoxDecoration(
                  color: selected
                      ? _purple.withValues(alpha: 0.12)
                      : const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(
                  Icons.account_balance_rounded,
                  size: 18,
                  color: selected ? _purple : Colors.grey.shade500,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            method.accountHolderName,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: selected
                                  ? FontWeight.w700
                                  : FontWeight.w600,
                              color: selected ? _purple : _textDark,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (method.isDefault) ...[
                          SizedBox(width: 6.w),
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 6.w, vertical: 2.h),
                            decoration: BoxDecoration(
                              color: _green.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(6.r),
                            ),
                            child: const Text(
                              'Por defecto',
                              style: TextStyle(
                                  fontSize: 9,
                                  color: _green,
                                  fontWeight: FontWeight.w700),
                            ),
                          ),
                        ],
                      ],
                    ),
                    SizedBox(height: 3.h),
                    Text(
                      method.shortLabel,
                      style: TextStyle(
                        fontSize: 11,
                        color: selected
                            ? _purple.withValues(alpha: 0.7)
                            : _textSoft,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8.w),
              // Country flag text
              Text(
                method.country,
                style: TextStyle(
                  fontSize: 11,
                  color: selected ? _purple : _textSoft,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(width: 8.w),
              Icon(
                selected
                    ? Icons.check_circle_rounded
                    : Icons.radio_button_unchecked_rounded,
                size: 18,
                color: selected ? _purple : Colors.grey.shade300,
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _noMethodsBanner() {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: Colors.orange.shade600, size: 20),
          SizedBox(width: 10.w),
          const Expanded(
            child: Text(
              'No tienes métodos de cobro vinculados.\nAñade una cuenta bancaria para retirar fondos.',
              style: TextStyle(fontSize: 12, color: _textMid, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _quickInfoCard() {
    return Obx(() {
      final cfg = controller.config.value;
      final verified = cfg.isVerified;
      final hasInstant = cfg.hasInstant;
      final Color iconColor = hasInstant ? _green : _amber;
      return Container(
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: const Color(0xFFEEEEEE)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(8.r),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.info_outline_rounded, color: iconColor, size: 18),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    hasInstant ? 'Retiro rápido disponible' : 'Retiro estándar',
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: _textDark),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    hasInstant
                        ? 'Las cuentas verificadas pueden retirar hasta €${cfg.instantLimit.toStringAsFixed(0)} de forma instantánea al método vinculado.'
                        : verified
                            ? 'El retiro se procesará en 1-3 días laborables a tu cuenta vinculada.'
                            : 'Verifica tu cuenta para habilitar los retiros a tu cuenta bancaria.',
                    style: const TextStyle(
                        fontSize: 12, color: _textSoft, height: 1.5),
                  ),
                  if (!verified) ...[
                    SizedBox(height: 8.h),
                    GestureDetector(
                      onTap: () => Get.snackbar(
                        'Verificación',
                        'La verificación de cuenta estará disponible próximamente.',
                        snackPosition: SnackPosition.BOTTOM,
                      ),
                      child: const Text(
                        'Verificar cuenta →',
                        style: TextStyle(
                          fontSize: 12,
                          color: _purple,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  // ─── HISTORY SECTION ─────────────────────────────────────────────────────────

  Widget _historySection() {
    return Obx(() {
      final list = controller.withdrawals;
      return SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Historial de retiros',
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: _textDark),
                  ),
                  if (list.isNotEmpty)
                    Text(
                      '${list.length} ${list.length == 1 ? "retiro" : "retiros"}',
                      style:
                          const TextStyle(fontSize: 12, color: _textSoft),
                    ),
                ],
              ),
              SizedBox(height: 12.h),
              list.isEmpty
                  ? _emptyState()
                  : ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: list.length,
                      separatorBuilder: (_, __) => SizedBox(height: 10.h),
                      itemBuilder: (_, i) => _withdrawalTile(list[i]),
                    ),
            ],
          ),
        ),
      );
    });
  }

  Widget _emptyState() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 48.h),
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80.r,
            height: 80.r,
            decoration: BoxDecoration(
              color: _purpleLight,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.account_balance_wallet_outlined,
              size: 36,
              color: _purple,
            ),
          ),
          SizedBox(height: 20.h),
          const Text(
            'Sin retiros aún',
            style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.w700, color: _textDark),
          ),
          SizedBox(height: 8.h),
          const Text(
            'Tu historial de retiros\naparecerá aquí.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: _textSoft, height: 1.6),
          ),
        ],
      ),
    );
  }

  Widget _withdrawalTile(WithdrawalModel w) {
    final statusColor = _statusColor(w.status);
    final statusLabel = _statusLabel(w.status);
    // Busca el método en los disponibles para mostrar el nombre real
    final knownMethod = controller.availableMethods
        .where((m) => m.id == w.payoutMethodId)
        .firstOrNull;
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFEEEEEE)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44.r,
            height: 44.r,
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(Icons.account_balance_rounded, size: 20, color: statusColor),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  knownMethod?.accountHolderName ?? 'Cuenta bancaria',
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: _textDark),
                ),
                SizedBox(height: 3.h),
                Row(
                  children: [
                    Text(
                      _formatDate(w.createdAt),
                      style:
                          const TextStyle(fontSize: 11, color: _textSoft),
                    ),
                    if (w.destinationLabel != null) ...[
                      const Text(' · ',
                          style: TextStyle(fontSize: 11, color: _textSoft)),
                      Text(
                        knownMethod?.accountNumber ??
                            (w.destinationLabel != null
                                ? '···· ${w.destinationLabel}'
                                : ''),
                        style: const TextStyle(fontSize: 11, color: _textSoft),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '- €${w.amount.toStringAsFixed(2)}',
                style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: _textDark),
              ),
              SizedBox(height: 4.h),
              Container(
                padding:
                    EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Text(
                  statusLabel,
                  style: TextStyle(
                      fontSize: 10,
                      color: statusColor,
                      fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── BOTTOM WITHDRAW BAR ─────────────────────────────────────────────────────

  Widget _bottomWithdrawBar() {
    return Obx(() {
      final canWithdraw = controller.canWithdraw;
      return Container(
        padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 28.h),
        decoration: BoxDecoration(
          color: Colors.white,
          border: const Border(top: BorderSide(color: Color(0xFFEEEEEE))),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 12,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: GestureDetector(
          onTap: canWithdraw ? _showWithdrawSheet : null,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: 54.h,
            decoration: BoxDecoration(
              color: canWithdraw ? _purple : const Color(0xFFCCCCCC),
              borderRadius: BorderRadius.circular(16.r),
              boxShadow: canWithdraw
                  ? [
                      BoxShadow(
                        color: _purple.withValues(alpha: 0.4),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      )
                    ]
                  : null,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.account_balance_wallet_rounded,
                  color: canWithdraw ? Colors.white : Colors.white70,
                  size: 20,
                ),
                SizedBox(width: 10.w),
                Text(
                  canWithdraw
                      ? 'Retirar fondos'
                      : controller.isVerified
                          ? 'Saldo insuficiente'
                          : 'Cuenta no verificada',
                  style: TextStyle(
                    color: canWithdraw ? Colors.white : Colors.white70,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  // ─── WITHDRAW SHEET ──────────────────────────────────────────────────────────

  void _showWithdrawSheet() {
    controller.selectedAmount.value = 0;
    Get.bottomSheet(
      _WithdrawAmountSheet(ctrl: controller),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  // ─── HELPERS ─────────────────────────────────────────────────────────────────

  static const _months = [
    '', 'ene', 'feb', 'mar', 'abr', 'may', 'jun',
    'jul', 'ago', 'sep', 'oct', 'nov', 'dic'
  ];

  String _formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')} ${_months[d.month]} ${d.year}';

  Color _statusColor(WithdrawalStatus s) {
    switch (s) {
      case WithdrawalStatus.completed:
        return _green;
      case WithdrawalStatus.failed:
        return Colors.red.shade400;
      case WithdrawalStatus.cancelled:
        return _textSoft;
      case WithdrawalStatus.pending:
        return _amber;
    }
  }

  String _statusLabel(WithdrawalStatus s) {
    switch (s) {
      case WithdrawalStatus.completed:
        return 'Completado';
      case WithdrawalStatus.failed:
        return 'Fallido';
      case WithdrawalStatus.cancelled:
        return 'Cancelado';
      case WithdrawalStatus.pending:
        return 'Pendiente';
    }
  }
}

// ─── WITHDRAW AMOUNT BOTTOM SHEET ────────────────────────────────────────────

class _WithdrawAmountSheet extends StatefulWidget {
  final WithdrawalsController ctrl;
  const _WithdrawAmountSheet({required this.ctrl});

  @override
  State<_WithdrawAmountSheet> createState() => _WithdrawAmountSheetState();
}

class _WithdrawAmountSheetState extends State<_WithdrawAmountSheet> {
  static const Color _purple = Color(0xFF7C3AED);
  static const Color _purpleLight = Color(0xFFEDE9FE);
  static const Color _purpleFaint = Color(0xFFF5F3FF);
  static const Color _textDark = Color(0xFF1E1B4B);
  static const Color _textSoft = Color(0xFF6B7280);

  final _amountCtrl = TextEditingController();

  @override
  void dispose() {
    _amountCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final balance = widget.ctrl.availableBalance;
    final minAmt = widget.ctrl.minAmount;
    final maxAmt = widget.ctrl.maxAmount;

    return Container(
      padding: EdgeInsets.fromLTRB(24.w, 20.h, 24.w, 32.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: const Color(0xFFDDDDDD),
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
          ),
          SizedBox(height: 20.h),
          const Text(
            '¿Cuánto quieres retirar?',
            style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.w700, color: _textDark),
          ),
          SizedBox(height: 4.h),
          Text(
            'Disponible: €${balance.toStringAsFixed(2)} · Min: €${minAmt.toStringAsFixed(0)} · Máx: €${maxAmt.toStringAsFixed(0)}',
            style: const TextStyle(fontSize: 12, color: _textSoft),
          ),
          SizedBox(height: 20.h),

          // Amount input
          Container(
            decoration: BoxDecoration(
              color: _purpleFaint,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: _purpleLight, width: 1.5),
            ),
            child: Row(
              children: [
                Padding(
                  padding: EdgeInsets.only(left: 16.w),
                  child: const Text(
                    '€',
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: _purple),
                  ),
                ),
                Expanded(
                  child: TextField(
                    controller: _amountCtrl,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    autofocus: true,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                          RegExp(r'^\d+\.?\d{0,2}')),
                    ],
                    onChanged: (v) {
                      final parsed = double.tryParse(v) ?? 0;
                      widget.ctrl.setAmount(parsed);
                    },
                    style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: _purple),
                    decoration: InputDecoration(
                      hintText: '0.00',
                      hintStyle: TextStyle(
                          fontSize: 24,
                          color: _purple.withValues(alpha: 0.3),
                          fontWeight: FontWeight.w700),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                          horizontal: 8.w, vertical: 16.h),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    _amountCtrl.text = balance.toStringAsFixed(2);
                    widget.ctrl.setAmount(balance);
                  },
                  child: Container(
                    margin: EdgeInsets.only(right: 12.w),
                    padding: EdgeInsets.symmetric(
                        horizontal: 10.w, vertical: 5.h),
                    decoration: BoxDecoration(
                      color: _purpleLight,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: const Text(
                      'Todo',
                      style: TextStyle(
                          fontSize: 12,
                          color: _purple,
                          fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 10.h),

          // Toggle "Retirar todo"
          Obx(() {
            final all = widget.ctrl.withdrawAll.value;
            return GestureDetector(
              onTap: () {
                widget.ctrl.toggleWithdrawAll();
                if (!all) {
                  _amountCtrl.text = balance.toStringAsFixed(2);
                } else {
                  _amountCtrl.clear();
                }
              },
              child: Row(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    width: 20.r,
                    height: 20.r,
                    decoration: BoxDecoration(
                      color: all ? _purple : Colors.transparent,
                      borderRadius: BorderRadius.circular(6.r),
                      border: Border.all(
                          color: all ? _purple : Colors.grey.shade300,
                          width: 1.5),
                    ),
                    child: all
                        ? const Icon(Icons.check_rounded,
                            size: 13, color: Colors.white)
                        : null,
                  ),
                  SizedBox(width: 8.w),
                  const Text(
                    'Retirar todo el saldo disponible',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: _textDark),
                  ),
                ],
              ),
            );
          }),
          SizedBox(height: 14.h),

          // Quick amount chips
          Wrap(
            spacing: 8.w,
            children: [25.0, 50.0, 100.0, 200.0]
                .where((v) => v <= balance)
                .map((v) => _quickAmountChip(v))
                .toList(),
          ),
          SizedBox(height: 24.h),

          // Confirm button
          Obx(() {
            final loading = widget.ctrl.isRequesting.value;
            final all = widget.ctrl.withdrawAll.value;
            final amount = widget.ctrl.selectedAmount.value;
            final valid = all || (amount >= widget.ctrl.minAmount && amount <= balance);
            return GestureDetector(
              onTap: (valid && !loading) ? widget.ctrl.requestWithdrawal : null,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: 54.h,
                decoration: BoxDecoration(
                  color: (valid && !loading)
                      ? _purple
                      : const Color(0xFFCCCCCC),
                  borderRadius: BorderRadius.circular(16.r),
                  boxShadow: (valid && !loading)
                      ? [
                          BoxShadow(
                            color: _purple.withValues(alpha: 0.35),
                            blurRadius: 14,
                            offset: const Offset(0, 5),
                          )
                        ]
                      : null,
                ),
                child: Center(
                  child: loading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : Text(
                          all
                              ? 'Confirmar retiro de €${balance.toStringAsFixed(2)}'
                              : amount > 0
                                  ? 'Confirmar retiro de €${amount.toStringAsFixed(2)}'
                                  : 'Introduce un importe',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w700),
                        ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _quickAmountChip(double v) {
    return Obx(() {
      final selected = widget.ctrl.selectedAmount.value == v;
      return GestureDetector(
        onTap: () {
          _amountCtrl.text = v.toStringAsFixed(2);
          widget.ctrl.setAmount(v);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 7.h),
          decoration: BoxDecoration(
            color: selected ? _purple : _purpleFaint,
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(
              color: selected ? _purple : _purpleLight,
            ),
          ),
          child: Text(
            '€${v.toStringAsFixed(0)}',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: selected ? Colors.white : _purple,
            ),
          ),
        ),
      );
    });
  }
}
