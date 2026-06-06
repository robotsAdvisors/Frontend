import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../data/models/parking_spot_model.dart';
import '../controllers/update_parking_controller.dart';

class UpdateParkingView extends GetView<UpdateParkingController> {
  const UpdateParkingView({super.key});

  static const Color _purple = Color(0xFF7C3AED);
  static const Color _purpleLight = Color(0xFFEDE9FE);
  static const Color _purpleFaint = Color(0xFFF5F3FF);
  static const Color _bg = Color(0xFFF8F7FF);
  static const Color _textDark = Color(0xFF1E1B4B);
  static const Color _textMid = Color(0xFF374151);
  static const Color _textSoft = Color(0xFF6B7280);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: Obx(() {
        if (controller.isLoading.value && controller.spot.value == null) {
          return const Center(child: CircularProgressIndicator(color: _purple));
        }
        return CustomScrollView(
          slivers: [
            _heroSliverAppBar(),
            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _infoRow(),
                  SizedBox(height: 20.h),
                  _waitingTimeCard(),
                  SizedBox(height: 16.h),
                  _incentiveCard(),
                  SizedBox(height: 28.h),
                  _updateButton(),
                  SizedBox(height: 12.h),
                  _deleteButton(),
                  SizedBox(height: 24.h),
                ]),
              ),
            ),
          ],
        );
      }),
    );
  }

  // ─── HERO APP BAR ────────────────────────────────────────────────────────────

  Widget _heroSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 260.h,
      pinned: true,
      backgroundColor: Colors.white,
      elevation: 0,
      leading: Padding(
        padding: EdgeInsets.all(8.r),
        child: _circleButton(icon: Icons.arrow_back_ios_new_rounded, onTap: () => Get.back()),
      ),
      actions: [
        Padding(
          padding: EdgeInsets.only(right: 12.w, top: 8.h, bottom: 8.h),
          child: _circleButton(icon: Icons.help_outline_rounded, onTap: _showHelpSheet),
        ),
      ],
      title: const Text(
        'Actualizar aparcamiento',
        style: TextStyle(color: _textDark, fontSize: 16, fontWeight: FontWeight.w700),
      ),
      flexibleSpace: FlexibleSpaceBar(background: _heroPhoto()),
    );
  }

  Widget _heroPhoto() {
    return Obx(() {
      final s = controller.spot.value;
      final photoUrl = s?.photo ?? '';
      return Stack(
        fit: StackFit.expand,
        children: [
          // Foto del spot (prioriza reporte reciente, backend ya lo resuelve)
          photoUrl.isNotEmpty
              ? Image.network(
                  photoUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _photoPlaceholder(),
                )
              : _photoPlaceholder(),

          // Gradiente inferior
          Positioned(
            left: 0, right: 0, bottom: 0,
            child: Container(
              height: 110.h,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Color(0xEE1E1B4B), Colors.transparent],
                ),
              ),
            ),
          ),

          // Nombre + dirección en la foto
          Positioned(
            left: 16.w, bottom: 16.h, right: 60.w,
            child: Obx(() {
              final spot = controller.spot.value;
              if (spot == null) return const SizedBox.shrink();
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (spot.name.isNotEmpty)
                    Text(
                      spot.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  if (spot.address.isNotEmpty)
                    Row(
                      children: [
                        const Icon(Icons.location_on_rounded, color: Colors.white70, size: 12),
                        SizedBox(width: 3.w),
                        Flexible(
                          child: Text(
                            spot.address,
                            style: const TextStyle(color: Colors.white70, fontSize: 11),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                ],
              );
            }),
          ),

          // Badge disponibilidad
          Positioned(
            right: 16.w, top: 80.h,
            child: Obx(() {
              final available = controller.spot.value?.isAvailable ?? true;
              return Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                decoration: BoxDecoration(
                  color: available
                      ? const Color(0xFF10B981).withValues(alpha: 0.9)
                      : Colors.red.shade400.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      available ? Icons.check_circle_rounded : Icons.cancel_rounded,
                      color: Colors.white,
                      size: 12,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      available ? 'Disponible' : 'Ocupado',
                      style: const TextStyle(
                        color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),

          // Botón cámara (para futura integración con image_picker)
          Positioned(
            right: 16.w, bottom: 16.h,
            child: GestureDetector(
              onTap: _showPhotoComingSoon,
              child: Container(
                width: 44.r, height: 44.r,
                decoration: BoxDecoration(
                  color: _purple, shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: _purple.withValues(alpha: 0.4),
                      blurRadius: 12, offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 20),
              ),
            ),
          ),
        ],
      );
    });
  }

  Widget _photoPlaceholder() {
    return Container(
      color: const Color(0xFFD1C4E9),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.local_parking_rounded, size: 60.r, color: _purple.withValues(alpha: 0.35)),
          SizedBox(height: 8.h),
          Text(
            'Sin foto',
            style: TextStyle(color: _purple.withValues(alpha: 0.5), fontSize: 13, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  // ─── INFO ROW ────────────────────────────────────────────────────────────────

  Widget _infoRow() {
    return Obx(() {
      final s = controller.spot.value;
      return Row(
        children: [
          Expanded(child: _priceCard(s?.price)),
          SizedBox(width: 12.w),
          Expanded(child: _demandCard(s?.demand ?? DemandLevel.low)),
        ],
      );
    });
  }

  Widget _priceCard(double? price) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _cardIcon(Icons.euro_rounded, _purple, _purpleLight),
          SizedBox(height: 10.h),
          Text(
            price != null ? '€ ${price.toStringAsFixed(2)}' : '—',
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: _textDark),
          ),
          SizedBox(height: 2.h),
          const Text('por hora', style: TextStyle(fontSize: 11, color: _textSoft)),
          SizedBox(height: 6.h),
          GestureDetector(
            onTap: _showHelpSheet,
            child: const Text(
              '¿Qué es esto?',
              style: TextStyle(
                fontSize: 11, color: _purple, fontWeight: FontWeight.w600,
                decoration: TextDecoration.underline, decorationColor: _purple,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _demandCard(DemandLevel demand) {
    final label = _demandLabel(demand);
    final color = _demandColor(demand);
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _cardIcon(_demandIcon(demand), color, color.withValues(alpha: 0.1)),
          SizedBox(height: 10.h),
          Text(
            label,
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: color),
          ),
          SizedBox(height: 2.h),
          const Text('demanda', style: TextStyle(fontSize: 11, color: _textSoft)),
          SizedBox(height: 8.h),
          _demandBar(demand, color),
        ],
      ),
    );
  }

  Widget _demandBar(DemandLevel demand, Color color) {
    final fill = demand == DemandLevel.low ? 0.33 : demand == DemandLevel.medium ? 0.66 : 1.0;
    return ClipRRect(
      borderRadius: BorderRadius.circular(4.r),
      child: LinearProgressIndicator(
        value: fill,
        minHeight: 5.h,
        backgroundColor: const Color(0xFFEEEEEE),
        valueColor: AlwaysStoppedAnimation<Color>(color),
      ),
    );
  }

  // ─── WAITING TIME CARD ───────────────────────────────────────────────────────

  Widget _waitingTimeCard() {
    return Container(
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: const Color(0xFFEEEEEE)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.r),
                decoration: BoxDecoration(color: _purpleLight, borderRadius: BorderRadius.circular(10.r)),
                child: const Icon(Icons.timer_outlined, size: 18, color: _purple),
              ),
              SizedBox(width: 10.w),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Tiempo de espera', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: _textDark)),
                    Text('Minutos estimados hasta que quede libre', style: TextStyle(fontSize: 11, color: _textSoft)),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          _waitingStepper(),
          SizedBox(height: 16.h),
          _waitingSlider(),
          SizedBox(height: 8.h),
          _waitingStatusLabel(),
        ],
      ),
    );
  }

  Widget _waitingStepper() {
    return Obx(() {
      final val = controller.waitTime.value;
      return Row(
        children: [
          _stepperBtn(Icons.remove_rounded, controller.decrement, val > 0),
          Expanded(
            child: GestureDetector(
              onTap: _showWaitingInputDialog,
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 12.w),
                padding: EdgeInsets.symmetric(vertical: 14.h),
                decoration: BoxDecoration(
                  color: _purpleFaint,
                  borderRadius: BorderRadius.circular(14.r),
                  border: Border.all(color: _purpleLight, width: 1.5),
                ),
                child: Column(
                  children: [
                    Text(
                      '$val',
                      style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: _purple),
                    ),
                    Text(
                      'minutos',
                      style: TextStyle(fontSize: 12, color: _purple.withValues(alpha: 0.7), fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ),
          ),
          _stepperBtn(Icons.add_rounded, controller.increment, val < 120),
        ],
      );
    });
  }

  Widget _stepperBtn(IconData icon, VoidCallback onTap, bool enabled) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 48.r, height: 48.r,
        decoration: BoxDecoration(
          color: enabled ? _purple : const Color(0xFFEEEEEE),
          borderRadius: BorderRadius.circular(14.r),
          boxShadow: enabled
              ? [BoxShadow(color: _purple.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 3))]
              : null,
        ),
        child: Icon(icon, color: enabled ? Colors.white : Colors.grey.shade400, size: 22),
      ),
    );
  }

  Widget _waitingSlider() {
    return Obx(() {
      return SliderTheme(
        data: SliderThemeData(
          activeTrackColor: _purple,
          inactiveTrackColor: _purpleLight,
          thumbColor: _purple,
          overlayColor: _purple.withValues(alpha: 0.15),
          trackHeight: 4,
          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
        ),
        child: Slider(
          value: controller.waitTime.value.toDouble(),
          min: 0, max: 120, divisions: 24,
          onChanged: (v) => controller.setWaitTime(v.toInt()),
        ),
      );
    });
  }

  Widget _waitingStatusLabel() {
    return Obx(() {
      final t = controller.waitTime.value;
      final String label;
      final Color color;
      if (t == 0) {
        label = 'Disponible ahora';
        color = const Color(0xFF10B981);
      } else if (t <= 15) {
        label = 'Casi libre';
        color = const Color(0xFF10B981);
      } else if (t <= 45) {
        label = 'Espera moderada';
        color = const Color(0xFFF59E0B);
      } else {
        label = 'Espera larga';
        color = Colors.red.shade400;
      }
      return Row(
        children: [
          Icon(Icons.circle, size: 8, color: color),
          SizedBox(width: 6.w),
          Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color)),
        ],
      );
    });
  }

  // ─── INCENTIVE CARD ──────────────────────────────────────────────────────────

  Widget _incentiveCard() {
    return Obx(() {
      final pts = controller.spot.value?.points ?? 50;
      return Container(
        padding: EdgeInsets.all(18.r),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF7C3AED), Color(0xFF6D28D9)],
            begin: Alignment.topLeft, end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [BoxShadow(color: _purple.withValues(alpha: 0.35), blurRadius: 16, offset: const Offset(0, 6))],
        ),
        child: Row(
          children: [
            Container(
              width: 48.r, height: 48.r,
              decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), shape: BoxShape.circle),
              child: const Icon(Icons.people_alt_rounded, color: Colors.white, size: 24),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Incentivo de comunidad',
                    style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'Ayuda a otros conductores y gana $pts puntos de recompensa.',
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 12, height: 1.4),
                  ),
                ],
              ),
            ),
            SizedBox(width: 10.w),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
              ),
              child: Column(
                children: [
                  const Icon(Icons.star_rounded, color: Color(0xFFFFD700), size: 18),
                  Text(
                    '+$pts',
                    style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w800),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  // ─── BUTTONS ─────────────────────────────────────────────────────────────────

  Widget _updateButton() {
    return Obx(() {
      final loading = controller.isSaving.value;
      return GestureDetector(
        onTap: loading ? null : controller.submitUpdate,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 56.h,
          decoration: BoxDecoration(
            color: loading ? _purple.withValues(alpha: 0.6) : _purple,
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: loading ? null : [
              BoxShadow(color: _purple.withValues(alpha: 0.4), blurRadius: 16, offset: const Offset(0, 6)),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (loading)
                const SizedBox(width: 20, height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              else ...[
                const Icon(Icons.edit_rounded, color: Colors.white, size: 20),
                SizedBox(width: 10.w),
                const Text('Actualizar',
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700, letterSpacing: 0.3)),
              ],
            ],
          ),
        ),
      );
    });
  }

  Widget _deleteButton() {
    return Obx(() {
      final loading = controller.isDeleting.value;
      return GestureDetector(
        onTap: loading ? null : _confirmAndDelete,
        child: Container(
          height: 48.h,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(color: Colors.red.shade300, width: 1.2),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (loading)
                SizedBox(
                  width: 18, height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.red.shade400),
                )
              else ...[
                Icon(Icons.delete_outline_rounded, color: Colors.red.shade400, size: 18),
                SizedBox(width: 8.w),
                Text('Eliminar reporte',
                    style: TextStyle(color: Colors.red.shade400, fontSize: 14, fontWeight: FontWeight.w600)),
              ],
            ],
          ),
        ),
      );
    });
  }

  // ─── HELPERS ─────────────────────────────────────────────────────────────────

  BoxDecoration _cardDecoration() => BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFEEEEEE)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
      );

  Widget _cardIcon(IconData icon, Color color, Color bg) => Container(
        padding: EdgeInsets.all(6.r),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8.r)),
        child: Icon(icon, size: 14, color: color),
      );

  Widget _circleButton({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36.r, height: 36.r,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.92),
          shape: BoxShape.circle,
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 6, offset: const Offset(0, 2))],
        ),
        child: Icon(icon, size: 16, color: _textDark),
      ),
    );
  }

  String _demandLabel(DemandLevel d) =>
      d == DemandLevel.high ? 'Alta' : d == DemandLevel.medium ? 'Media' : 'Baja';

  Color _demandColor(DemandLevel d) => d == DemandLevel.high
      ? Colors.red.shade500
      : d == DemandLevel.medium
          ? const Color(0xFFF59E0B)
          : const Color(0xFF10B981);

  IconData _demandIcon(DemandLevel d) => d == DemandLevel.high
      ? Icons.trending_up_rounded
      : d == DemandLevel.medium
          ? Icons.trending_flat_rounded
          : Icons.trending_down_rounded;

  // ─── DIALOGS / SHEETS ────────────────────────────────────────────────────────

  void _confirmAndDelete() {
    Get.dialog<void>(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
        child: Padding(
          padding: EdgeInsets.all(24.r),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56.r, height: 56.r,
                decoration: BoxDecoration(color: Colors.red.shade50, shape: BoxShape.circle),
                child: Icon(Icons.delete_forever_rounded, color: Colors.red.shade400, size: 28),
              ),
              SizedBox(height: 16.h),
              const Text('¿Eliminar reporte?',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: _textDark)),
              SizedBox(height: 8.h),
              const Text(
                'Esta acción no se puede deshacer. Tu reporte será eliminado.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: _textSoft, height: 1.5),
              ),
              SizedBox(height: 24.h),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFDDDDDD)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                      ),
                      child: const Text('Cancelar', style: TextStyle(color: _textSoft, fontWeight: FontWeight.w600)),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Get.back();
                        controller.deleteReport();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade400,
                        foregroundColor: Colors.white, elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                      ),
                      child: const Text('Eliminar', style: TextStyle(fontWeight: FontWeight.w700)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showWaitingInputDialog() {
    final ctrl = TextEditingController(
      text: controller.waitTime.value > 0 ? controller.waitTime.value.toString() : '',
    );
    Get.dialog<void>(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
        child: Padding(
          padding: EdgeInsets.all(24.r),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Tiempo de espera',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: _textDark)),
              SizedBox(height: 16.h),
              TextField(
                controller: ctrl,
                keyboardType: TextInputType.number,
                autofocus: true,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: _dialogInputDecoration(hint: 'Ej. 15', suffix: 'min'),
              ),
              SizedBox(height: 20.h),
              _dialogButtons(
                onApply: () {
                  controller.setWaitTime(int.tryParse(ctrl.text.trim()) ?? 0);
                  Get.back();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPhotoComingSoon() {
    Get.snackbar(
      'Próximamente',
      'La subida de fotos desde la cámara estará disponible en la siguiente versión.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: _purpleFaint,
      colorText: _purple,
      margin: EdgeInsets.all(16.r),
      borderRadius: 14,
      duration: const Duration(seconds: 3),
    );
  }

  void _showHelpSheet() {
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.fromLTRB(24.w, 20.h, 24.w, 32.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40.w, height: 4.h,
                decoration: BoxDecoration(color: const Color(0xFFDDDDDD), borderRadius: BorderRadius.circular(2.r)),
              ),
            ),
            SizedBox(height: 20.h),
            const Text('Sobre el precio',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: _textDark)),
            SizedBox(height: 8.h),
            const Text(
              'El precio por hora es la tarifa oficial del aparcamiento y no puede modificarse desde la app. Si detectas un error, usa el botón de reportar.',
              style: TextStyle(fontSize: 13, color: _textMid, height: 1.6),
            ),
            SizedBox(height: 20.h),
            const Text('Sobre los puntos',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: _textDark)),
            SizedBox(height: 8.h),
            const Text(
              'Al actualizar la información contribuyes a la comunidad y recibes puntos de recompensa canjeables en tiendas asociadas.',
              style: TextStyle(fontSize: 13, color: _textMid, height: 1.6),
            ),
            SizedBox(height: 24.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Get.back(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _purple, foregroundColor: Colors.white, elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                ),
                child: const Text('Entendido', style: TextStyle(fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _dialogInputDecoration({String? hint, String? suffix}) => InputDecoration(
        hintText: hint,
        suffixText: suffix,
        filled: true, fillColor: _purpleFaint,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r), borderSide: const BorderSide(color: _purpleLight)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r), borderSide: const BorderSide(color: _purple, width: 1.5)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r), borderSide: const BorderSide(color: _purpleLight)),
      );

  Widget _dialogButtons({required VoidCallback onApply}) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => Get.back(),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFFDDDDDD)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
              padding: EdgeInsets.symmetric(vertical: 12.h),
            ),
            child: const Text('Cancelar', style: TextStyle(color: _textSoft, fontWeight: FontWeight.w600)),
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: ElevatedButton(
            onPressed: onApply,
            style: ElevatedButton.styleFrom(
              backgroundColor: _purple, foregroundColor: Colors.white, elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
              padding: EdgeInsets.symmetric(vertical: 12.h),
            ),
            child: const Text('Aplicar', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ),
      ],
    );
  }
}
