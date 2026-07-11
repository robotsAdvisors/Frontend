import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../data/models/virtual_card_model.dart';
import '../controllers/virtual_card_controller.dart';

class VirtualCardView extends GetView<VirtualCardController> {
  const VirtualCardView({super.key});

  static const _purple = Color(0xFF7C3AED);
  static const _purpleLight = Color(0xFFEDE9FE);
  static const _purpleFaint = Color(0xFFF5F3FF);
  static const _bg = Color(0xFFF8F7FF);
  static const _gold = Color(0xFFF59E0B);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: NestedScrollView(
        headerSliverBuilder: (_, __) => [_appBar()],
        body: _body(),
      ),
      bottomNavigationBar: _scannerButton(),
    );
  }

  // ─── AppBar ───────────────────────────────────────────────────────────────

  SliverAppBar _appBar() {
    return SliverAppBar(
      pinned: true,
      backgroundColor: Colors.white,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      shadowColor: Colors.black12,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios_new_rounded,
            size: 20.r, color: Colors.black87),
        onPressed: () => Get.back(),
      ),
      title: Text(
        'Mi Tarjeta Virtual',
        style: TextStyle(
          fontSize: 17.sp,
          fontWeight: FontWeight.w700,
          color: Colors.black87,
        ),
      ),
      centerTitle: true,
      actions: [
        Obx(() => controller.isLoading.value
            ? Padding(
                padding: EdgeInsets.only(right: 16.w),
                child: SizedBox(
                  width: 18.r,
                  height: 18.r,
                  child: const CircularProgressIndicator(
                      strokeWidth: 2, color: _purple),
                ),
              )
            : IconButton(
                icon: Icon(Icons.refresh_rounded, size: 22.r, color: _purple),
                onPressed: controller.refresh,
              )),
      ],
    );
  }

  // ─── Cuerpo ───────────────────────────────────────────────────────────────

  Widget _body() {
    return Obx(() {
      if (controller.isLoading.value && controller.card.value == null) {
        return const Center(
            child: CircularProgressIndicator(color: _purple));
      }
      final card = controller.card.value;
      if (card == null) return _errorState();
      return _content(card);
    });
  }

  Widget _content(VirtualCardModel card) {
    return ListView(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
      children: [
        _cardWidget(card),
        SizedBox(height: 24.h),
        _howToUseCard(),
        SizedBox(height: 24.h),
        _benefitsSection(card),
        SizedBox(height: 24.h),
      ],
    );
  }

  // ─── Tarjeta visual ───────────────────────────────────────────────────────

  Widget _cardWidget(VirtualCardModel card) {
    return Obx(() {
      final isActive = controller.card.value?.isActive ?? card.isActive;
      return AnimatedOpacity(
        duration: const Duration(milliseconds: 300),
        opacity: isActive ? 1.0 : 0.6,
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF3B0764), Color(0xFF6D28D9), Color(0xFF7C3AED)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20.r),
            boxShadow: [
              BoxShadow(
                color: _purple.withValues(alpha: 0.45),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          padding: EdgeInsets.all(20.r),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ─── Fila superior: logo + chip ───────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'LetDem',
                        style: TextStyle(
                          fontSize: 22.sp,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 0.5,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        (controller.card.value ?? card).tierLabel,
                        style: TextStyle(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white60,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ],
                  ),
                  _chipIcon(),
                ],
              ),
              SizedBox(height: 20.h),
              // ─── Fila central: puntos + código de barras ──────
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(child: _pointsSection(card)),
                  SizedBox(width: 12.w),
                  _barcodeSection(card),
                ],
              ),
              SizedBox(height: 16.h),
              // ─── Fila inferior: nombre + toggle ───────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'CARDHOLDER NAME',
                        style: TextStyle(
                          fontSize: 9.sp,
                          color: Colors.white54,
                          letterSpacing: 1.2,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 3.h),
                      Obx(() => Text(
                            (controller.card.value ?? card)
                                .cardholderName
                                .toUpperCase(),
                            style: TextStyle(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: 0.8,
                            ),
                          )),
                    ],
                  ),
                  _activeToggle(isActive),
                ],
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _chipIcon() {
    return Container(
      width: 40.r,
      height: 30.r,
      decoration: BoxDecoration(
        color: _gold,
        borderRadius: BorderRadius.circular(6.r),
        gradient: const LinearGradient(
          colors: [Color(0xFFFCD34D), Color(0xFFD97706)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Container(
          width: 24.r,
          height: 18.r,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(3.r),
            border: Border.all(
                color: Colors.white.withValues(alpha: 0.5), width: 1),
          ),
          child: Column(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    border: Border(
                        bottom: BorderSide(
                            color: Colors.white.withValues(alpha: 0.5),
                            width: 1)),
                  ),
                ),
              ),
              Expanded(child: Container()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _pointsSection(VirtualCardModel card) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'AVAILABLE REWARDS',
          style: TextStyle(
            fontSize: 9.sp,
            color: _gold,
            letterSpacing: 1.5,
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: 8.h),
        Obx(() => Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(Icons.star_rounded, color: _gold, size: 22.r),
                SizedBox(width: 6.w),
                Text(
                  _formatPoints(
                      (controller.card.value ?? card).pointsBalance),
                  style: TextStyle(
                    fontSize: 26.sp,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    height: 1,
                  ),
                ),
                SizedBox(width: 4.w),
                Padding(
                  padding: EdgeInsets.only(top: 6.h),
                  child: Text(
                    'pts',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.white70,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            )),
      ],
    );
  }

  Widget _barcodeSection(VirtualCardModel card) {
    return Obx(() {
      final code = (controller.card.value ?? card).cardCode;
      return Container(
        width: 110.w,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10.r),
        ),
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
        child: Column(
          children: [
            SizedBox(
              height: 48.h,
              width: double.infinity,
              child: CustomPaint(painter: _BarcodePainter(code)),
            ),
            SizedBox(height: 4.h),
            Text(
              code,
              style: TextStyle(
                fontSize: 8.5.sp,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
                letterSpacing: 0.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    });
  }

  Widget _activeToggle(bool isActive) {
    return Row(
      children: [
        Text(
          isActive ? 'Activa' : 'Inactiva',
          style: TextStyle(
            fontSize: 11.sp,
            color: isActive ? Colors.white70 : Colors.white38,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(width: 8.w),
        Obx(() => GestureDetector(
              onTap: controller.isToggling.value ? null : controller.toggleActive,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                width: 42.w,
                height: 24.h,
                padding: EdgeInsets.all(2.r),
                decoration: BoxDecoration(
                  color: (controller.card.value?.isActive ?? isActive)
                      ? Colors.white.withValues(alpha: 0.35)
                      : Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                      color: Colors.white.withValues(alpha: 0.4), width: 1),
                ),
                child: AnimatedAlign(
                  duration: const Duration(milliseconds: 250),
                  alignment:
                      (controller.card.value?.isActive ?? isActive)
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                  child: Container(
                    width: 18.r,
                    height: 18.r,
                    decoration: BoxDecoration(
                      color: (controller.card.value?.isActive ?? isActive)
                          ? Colors.white
                          : Colors.white54,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
            )),
      ],
    );
  }

  // ─── Sección "Cómo usar" ──────────────────────────────────────────────────

  Widget _howToUseCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: EdgeInsets.all(16.r),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36.r,
            height: 36.r,
            decoration: BoxDecoration(
              color: _purpleLight,
              shape: BoxShape.circle,
            ),
            child:
                Icon(Icons.info_outline_rounded, color: _purple, size: 18.r),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Cómo usar',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  'Presenta esta tarjeta virtual en cualquier estación de aparcamiento asociada o terminal de premios para acumular puntos y desbloquear descuentos exclusivos en la ciudad.',
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: Colors.black54,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Sección de beneficios ────────────────────────────────────────────────

  Widget _benefitsSection(VirtualCardModel card) {
    if (card.benefits.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(width: 3.w, height: 16.h, color: _gold),
            SizedBox(width: 8.w),
            Text(
              'Beneficios de miembro',
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        ...card.benefits.asMap().entries.map((entry) {
          final benefit = entry.value;
          final isLast = entry.key == card.benefits.length - 1;
          return Column(
            children: [
              _benefitTile(benefit),
              if (!isLast) SizedBox(height: 8.h),
            ],
          );
        }),
      ],
    );
  }

  Widget _benefitTile(CardBenefit benefit) {
    final (icon, bg, fg) = _benefitIcon(benefit.key);
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding:
            EdgeInsets.symmetric(horizontal: 14.w, vertical: 4.h),
        leading: Container(
          width: 44.r,
          height: 44.r,
          decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12.r)),
          child: Icon(icon, color: fg, size: 22.r),
        ),
        title: Text(
          benefit.title,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
        subtitle: benefit.description.isNotEmpty
            ? Text(
                benefit.description,
                style: TextStyle(fontSize: 12.sp, color: Colors.black45),
              )
            : null,
        trailing:
            Icon(Icons.chevron_right_rounded, color: Colors.black26, size: 22.r),
      ),
    );
  }

  // ─── Botón scanner ────────────────────────────────────────────────────────

  Widget _scannerButton() {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        child: Obx(() {
          final card = controller.card.value;
          if (card == null) return const SizedBox.shrink();
          return GestureDetector(
            onTap: () => _openScannerSheet(card),
            child: Container(
              height: 52.h,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF4C1D95), Color(0xFF7C3AED)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(14.r),
                boxShadow: [
                  BoxShadow(
                    color: _purple.withValues(alpha: 0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.qr_code_scanner_rounded,
                      color: Colors.white, size: 22.r),
                  SizedBox(width: 10.w),
                  Text(
                    'Abrir escáner completo',
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  // ─── Bottom sheet del escáner ─────────────────────────────────────────────

  void _openScannerSheet(VirtualCardModel card) {
    Get.bottomSheet(
      Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        ),
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            SizedBox(height: 20.h),
            Text(
              'Código de tarjeta',
              style: TextStyle(
                fontSize: 17.sp,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              'Muestra este código al lector del terminal',
              style: TextStyle(fontSize: 13.sp, color: Colors.black45),
            ),
            SizedBox(height: 24.h),
            // Código de barras grande
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
              decoration: BoxDecoration(
                color: Colors.white,
                border:
                    Border.all(color: Colors.grey.shade200, width: 1.5),
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Column(
                children: [
                  SizedBox(
                    height: 90.h,
                    width: double.infinity,
                    child: CustomPaint(painter: _BarcodePainter(card.cardCode)),
                  ),
                  SizedBox(height: 10.h),
                  Text(
                    card.cardCode,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w800,
                      color: Colors.black87,
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.h),
            Row(
              children: [
                _infoChip(Icons.person_outline_rounded, card.cardholderName),
                SizedBox(width: 10.w),
                _infoChip(Icons.workspace_premium_rounded,
                    card.tierLabel.split(' ').first),
              ],
            ),
            SizedBox(height: 24.h),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _infoChip(IconData icon, String label) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 12.w),
        decoration: BoxDecoration(
          color: _purpleFaint,
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 15.r, color: _purple),
            SizedBox(width: 6.w),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: _purple,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Estado de error ──────────────────────────────────────────────────────

  Widget _errorState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.r),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72.r,
              height: 72.r,
              decoration: BoxDecoration(
                  color: _purpleLight, shape: BoxShape.circle),
              child: Icon(Icons.credit_card_off_rounded,
                  size: 36.r, color: _purple),
            ),
            SizedBox(height: 20.h),
            Text(
              'Tarjeta no disponible',
              style: TextStyle(
                  fontSize: 17.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87),
            ),
            SizedBox(height: 8.h),
            Text(
              'No se pudo cargar tu tarjeta virtual.\nInténtalo de nuevo.',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 14.sp, color: Colors.black45, height: 1.5),
            ),
            SizedBox(height: 24.h),
            GestureDetector(
              onTap: controller.refresh,
              child: Container(
                padding:
                    EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                decoration: BoxDecoration(
                  color: _purple,
                  borderRadius: BorderRadius.circular(30.r),
                ),
                child: Text(
                  'Reintentar',
                  style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────

  (IconData, Color, Color) _benefitIcon(String key) {
    switch (key.toLowerCase()) {
      case 'ev_boost':
      case 'ev_boost_rewards':
        return (Icons.bolt_rounded, _purpleLight, _purple);
      case 'marketplace_access':
        return (Icons.storefront_rounded,
            const Color(0xFFFFF7ED), const Color(0xFFEA580C));
      case 'free_hours':
        return (Icons.timer_rounded,
            const Color(0xFFE0F2FE), const Color(0xFF0369A1));
      case 'cashback':
        return (Icons.savings_rounded,
            const Color(0xFFF0FDF4), const Color(0xFF15803D));
      default:
        return (Icons.star_rounded, _purpleLight, _purple);
    }
  }

  static String _formatPoints(int pts) {
    if (pts >= 1000) {
      final k = pts / 1000;
      return k == k.truncateToDouble()
          ? '${k.toInt()}k'
          : '${k.toStringAsFixed(1)}k';
    }
    return pts.toString();
  }
}

// ─── Barcode CustomPainter ────────────────────────────────────────────────────

class _BarcodePainter extends CustomPainter {
  final String data;

  const _BarcodePainter(this.data);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black87
      ..style = PaintingStyle.fill;

    // Genera una secuencia determinista de anchos de barra a partir del texto
    final bytes = data.codeUnits;
    final sequence = <int>[];
    for (int i = 0; i < 80; i++) {
      final b = bytes[i % bytes.length];
      sequence.add(((b >> (i % 8)) & 1) == 1 ? 2 : 1);
    }

    // Escala para que las barras cubran exactamente el ancho disponible
    final totalUnits = sequence.fold(0, (s, v) => s + v);
    final unitWidth = size.width / totalUnits;

    double x = 0;
    for (int i = 0; i < sequence.length; i++) {
      final barWidth = sequence[i] * unitWidth;
      if (i.isEven) {
        canvas.drawRect(
          Rect.fromLTWH(x, 0, barWidth - 0.4, size.height),
          paint,
        );
      }
      x += barWidth;
    }
  }

  @override
  bool shouldRepaint(_BarcodePainter old) => old.data != data;
}
