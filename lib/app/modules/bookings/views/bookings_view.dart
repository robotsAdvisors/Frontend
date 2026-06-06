import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../data/models/booking_model.dart';
import '../controllers/bookings_controller.dart';

class BookingsView extends GetView<BookingsController> {
  const BookingsView({super.key});

  // ─── Paleta ──────────────────────────────────────────────────────────────

  static const _purple = Color(0xFF7C3AED);
  static const _purpleLight = Color(0xFFEDE9FE);
  static const _purpleFaint = Color(0xFFF5F3FF);
  static const _bg = Color(0xFFF8F7FF);

  // ─── Localización de meses ───────────────────────────────────────────────

  static const _months = [
    '', 'ene', 'feb', 'mar', 'abr', 'may', 'jun',
    'jul', 'ago', 'sep', 'oct', 'nov', 'dic',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: NestedScrollView(
        headerSliverBuilder: (_, __) => [_appBar()],
        body: Column(
          children: [
            _filterRow(),
            Expanded(child: _body()),
          ],
        ),
      ),
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
        'Mis reservas',
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
                icon: Icon(Icons.filter_list_rounded,
                    size: 22.r, color: _purple),
                onPressed: () {},
              )),
      ],
    );
  }

  // ─── Filtros ──────────────────────────────────────────────────────────────

  Widget _filterRow() {
    const filters = [
      (BookingFilter.all, 'Todas'),
      (BookingFilter.active, 'Activas'),
      (BookingFilter.upcoming, 'Próximas'),
      (BookingFilter.completed, 'Finalizadas'),
      (BookingFilter.cancelled, 'Canceladas'),
    ];

    return Container(
      color: Colors.white,
      child: Column(
        children: [
          Divider(height: 1, thickness: 1, color: Colors.grey.shade100),
          SizedBox(
            height: 52.h,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
              itemCount: filters.length,
              separatorBuilder: (_, __) => SizedBox(width: 8.w),
              itemBuilder: (_, i) {
                final (filter, label) = filters[i];
                return Obx(() {
                  final selected = controller.activeFilter.value == filter;
                  return GestureDetector(
                    onTap: () => controller.setFilter(filter),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: EdgeInsets.symmetric(
                          horizontal: 14.w, vertical: 6.h),
                      decoration: BoxDecoration(
                        color: selected ? _purple : Colors.white,
                        borderRadius: BorderRadius.circular(20.r),
                        border: Border.all(
                          color: selected ? _purple : Colors.grey.shade300,
                          width: 1.2,
                        ),
                      ),
                      child: Text(
                        label,
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                          color: selected ? Colors.white : Colors.black54,
                        ),
                      ),
                    ),
                  );
                });
              },
            ),
          ),
          Divider(height: 1, thickness: 1, color: Colors.grey.shade100),
        ],
      ),
    );
  }

  // ─── Cuerpo principal ─────────────────────────────────────────────────────

  Widget _body() {
    return Obx(() {
      if (controller.isLoading.value && controller.bookings.isEmpty) {
        return const Center(
            child: CircularProgressIndicator(color: _purple));
      }
      if (controller.bookings.isEmpty) {
        return _emptyState();
      }
      return _list();
    });
  }

  Widget _list() {
    return RefreshIndicator(
      color: _purple,
      onRefresh: controller.refresh,
      child: Obx(() {
        final items = controller.displayed;
        return ListView.separated(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
          itemCount: items.length,
          separatorBuilder: (_, __) => SizedBox(height: 12.h),
          itemBuilder: (_, i) => _bookingCard(items[i]),
        );
      }),
    );
  }

  // ─── Tarjeta de reserva ───────────────────────────────────────────────────

  Widget _bookingCard(BookingModel b) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _cardHeader(b),
          Divider(height: 1, thickness: 1, color: Colors.grey.shade100),
          _cardFooter(b),
          if (b.status == BookingStatus.upcoming) ...[
            Divider(height: 1, thickness: 1, color: Colors.grey.shade100),
            _cancelButton(b),
          ],
        ],
      ),
    );
  }

  Widget _cardHeader(BookingModel b) {
    return Padding(
      padding: EdgeInsets.all(14.r),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─── Icono de localización ─────────────────────────────
          Container(
            width: 42.r,
            height: 42.r,
            decoration: BoxDecoration(
              color: _purpleFaint,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(Icons.location_on_rounded,
                color: _purple, size: 22.r),
          ),
          SizedBox(width: 12.w),
          // ─── Dirección y tipo ──────────────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  b.address.isNotEmpty ? b.address : b.spotName,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4.h),
                Text(
                  _spotSubtitle(b),
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.black45,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 8.w),
          _statusBadge(b.status),
        ],
      ),
    );
  }

  Widget _cardFooter(BookingModel b) {
    final costColor = b.status == BookingStatus.active
        ? _purple
        : b.status == BookingStatus.upcoming
            ? Colors.orange.shade700
            : Colors.black45;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      child: Row(
        children: [
          Icon(Icons.calendar_today_rounded,
              size: 15.r, color: Colors.black45),
          SizedBox(width: 6.w),
          Expanded(
            child: Text(
              _formatDateRange(b.startAt, b.endAt),
              style: TextStyle(
                fontSize: 12.sp,
                color: Colors.black54,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            '€${b.totalCost.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w700,
              color: costColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _cancelButton(BookingModel b) {
    return Obx(() => InkWell(
          onTap: controller.isCancelling.value
              ? null
              : () => _confirmCancel(b),
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(16.r),
            bottomRight: Radius.circular(16.r),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 10.h),
            child: Center(
              child: controller.isCancelling.value
                  ? SizedBox(
                      height: 16.r,
                      width: 16.r,
                      child: const CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.redAccent),
                    )
                  : Text(
                      'Cancelar reserva',
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.redAccent,
                      ),
                    ),
            ),
          ),
        ));
  }

  // ─── Estado vacío ─────────────────────────────────────────────────────────

  Widget _emptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.r),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80.r,
              height: 80.r,
              decoration: BoxDecoration(
                color: _purpleLight,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.calendar_month_outlined,
                  size: 40.r, color: _purple),
            ),
            SizedBox(height: 20.h),
            Text(
              'Sin reservas',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Aquí aparecerán tus reservas\nde plazas de aparcamiento.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.black45,
                height: 1.5,
              ),
            ),
            SizedBox(height: 28.h),
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
                  'Actualizar',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Helpers de UI ────────────────────────────────────────────────────────

  Widget _statusBadge(BookingStatus status) {
    final (label, bg, fg) = switch (status) {
      BookingStatus.active => ('Activa', const Color(0xFFDCFCE7), const Color(0xFF166534)),
      BookingStatus.upcoming => ('Próxima', const Color(0xFFFEF9C3), const Color(0xFF854D0E)),
      BookingStatus.completed => ('Finalizada', const Color(0xFFF3F4F6), const Color(0xFF6B7280)),
      BookingStatus.cancelled => ('Cancelada', const Color(0xFFFEE2E2), const Color(0xFF991B1B)),
    };

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11.sp,
          fontWeight: FontWeight.w700,
          color: fg,
        ),
      ),
    );
  }

  String _spotSubtitle(BookingModel b) {
    final parts = <String>[];
    final typeLabel = b.spotTypeLabel;
    if (typeLabel.isNotEmpty) parts.add(typeLabel);
    if (b.pricePerHour != null) {
      parts.add('${b.pricePerHour!.toStringAsFixed(2)}€/hora');
    }
    return parts.join(' • ');
  }

  String _formatDateRange(DateTime start, DateTime end) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final startDay = DateTime(start.year, start.month, start.day);

    String dayLabel;
    if (startDay == today) {
      dayLabel = 'Hoy';
    } else if (startDay == tomorrow) {
      dayLabel = 'Mañana';
    } else {
      dayLabel = '${start.day} ${_months[start.month]}';
    }

    final startTime = _time(start);
    final endTime = _time(end);
    return '$dayLabel, $startTime - $endTime';
  }

  static String _time(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  // ─── Diálogo de cancelación ───────────────────────────────────────────────

  void _confirmCancel(BookingModel b) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r)),
        title: Text(
          '¿Cancelar reserva?',
          style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.w700),
        ),
        content: Text(
          'Esta acción no se puede deshacer.\n¿Seguro que quieres cancelar tu reserva en ${b.address.isNotEmpty ? b.address : b.spotName}?',
          style: TextStyle(fontSize: 14.sp, color: Colors.black54, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Volver',
              style: TextStyle(
                  color: Colors.black54, fontWeight: FontWeight.w600),
            ),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              controller.cancelBooking(b);
            },
            child: Text(
              'Cancelar reserva',
              style: TextStyle(
                  color: Colors.redAccent, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}
