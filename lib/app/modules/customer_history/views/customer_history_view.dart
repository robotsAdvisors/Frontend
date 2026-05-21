import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../data/models/order_model.dart';
import '../../../data/models/voucher_model.dart';
import '../controllers/customer_history_controller.dart';

class CustomerHistoryView extends GetView<CustomerHistoryController> {
  const CustomerHistoryView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final bool isWide = MediaQuery.of(context).size.width >= 1000;
    final double contentMaxWidth = isWide ? 980 : double.infinity;
    return Scaffold(
      appBar: AppBar(
        title: Text('Historial Wallet', style: theme.textTheme.displaySmall),
        centerTitle: true,
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: contentMaxWidth),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
            child: Obx(
              () => SingleChildScrollView(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _walletCard(theme),
                20.verticalSpace,
                _statsCard(theme),
                20.verticalSpace,
                Text('Movimientos y canjes', style: theme.textTheme.headlineSmall),
                12.verticalSpace,
                if (controller.walletMovements.isEmpty)
                  Text('No hay movimientos en tu wallet todavía.', style: theme.textTheme.bodyMedium)
                else
                  Column(
                    children: controller.walletMovements
                        .map((voucher) => _movementCard(theme, voucher))
                        .toList(),
                  ),
                20.verticalSpace,
                Text('Mis compras', style: theme.textTheme.headlineSmall),
                12.verticalSpace,
                _ordersSection(theme),
              ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _walletCard(ThemeData theme) {
    if (controller.loadingWallet.value) {
      return Container(
        width: double.infinity,
        padding: EdgeInsets.all(18.w),
        decoration: BoxDecoration(
          color: theme.primaryColor,
          borderRadius: BorderRadius.circular(18.r),
        ),
        child: const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: theme.primaryColor,
        borderRadius: BorderRadius.circular(18.r),
        boxShadow: [
          BoxShadow(
            color: theme.primaryColor.withValues(alpha: 0.24),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Tarjeta virtual de puntos', style: theme.textTheme.titleLarge?.copyWith(color: Colors.white)),
          12.verticalSpace,
          Text(
            controller.walletCode.value,
            style: theme.textTheme.headlineSmall?.copyWith(color: Colors.white, letterSpacing: 1.1),
          ),
          10.verticalSpace,
          Text('Estado wallet: ${controller.walletStatus.value}', style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white70)),
          14.verticalSpace,
          OutlinedButton.icon(
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: controller.walletCode.value));
              Get.snackbar('Código listo', 'Código de wallet copiado para canjear en tienda.');
            },
            icon: const Icon(Icons.qr_code_2, color: Colors.white),
            label: const Text('Usar código para canjear', style: TextStyle(color: Colors.white)),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.white70),
            ),
          ),
        ],
      ),
    );
  }

  Widget _movementCard(ThemeData theme, VoucherModel voucher) {
    final status = controller.statusLabel(voucher);
    final color = status == 'Canjeado'
        ? Colors.green
        : status == 'Pendiente'
            ? Colors.orange
            : Colors.redAccent;

    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: theme.dividerColor),
        boxShadow: [
          BoxShadow(
            color: theme.primaryColor.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text('Código: ${voucher.code}', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(status, style: TextStyle(color: color, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          8.verticalSpace,
          Text('Producto: ${controller.productNameFor(voucher)}', style: theme.textTheme.bodyMedium),
          Text('Descuento obtenido: ${controller.discountText(voucher)}', style: theme.textTheme.bodyMedium),
          Text('Creado: ${voucher.createdAt.toLocal()}', style: theme.textTheme.bodySmall),
          if (voucher.redeemedAt != null)
            Text('Canjeado: ${voucher.redeemedAt!.toLocal()}', style: theme.textTheme.bodySmall),
          Text('Tiempo restante: ${controller.remainingTime(voucher)}', style: theme.textTheme.bodySmall),
          if (controller.canRate(voucher)) ...[
            10.verticalSpace,
            Text('Valorar producto', style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
            6.verticalSpace,
            Row(
              children: List.generate(5, (index) {
                final score = index + 1;
                return Obx(
                  () => IconButton(
                    onPressed: () => controller.rateVoucher(voucher.id, score),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: Icon(
                      controller.ratingFor(voucher.id) >= score ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                    ),
                  ),
                );
              }),
            ),
          ],
        ],
      ),
    );
  }

  Widget _statsCard(ThemeData theme) {
    if (controller.loadingOrders.value) {
      return SizedBox(
        height: 80.h,
        child: const Center(child: CircularProgressIndicator()),
      );
    }
    final page = controller.ordersPage.value;
    if (page == null) {
      return const SizedBox.shrink();
    }
    final stats = page.stats;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Resumen de actividad', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          12.verticalSpace,
          Wrap(
            spacing: 16.w,
            runSpacing: 12.h,
            children: [
              _statTile(theme, 'Compras', '${stats.totalOrders}'),
              _statTile(theme, 'Gastado', '\u20ac${stats.totalSpent.toStringAsFixed(2)}'),
              _statTile(theme, 'Ahorrado', '\u20ac${stats.totalSaved.toStringAsFixed(2)}'),
              _statTile(theme, 'Puntos usados', '${stats.totalPointsUsed}'),
              _statTile(theme, 'Puntos actuales', '${stats.currentPoints}'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statTile(ThemeData theme, String label, String value) {
    return SizedBox(
      width: 120.w,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: theme.textTheme.bodySmall),
          4.verticalSpace,
          Text(value, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _ordersSection(ThemeData theme) {
    if (controller.loadingOrders.value) {
      return SizedBox(
        height: 80.h,
        child: const Center(child: CircularProgressIndicator()),
      );
    }
    final page = controller.ordersPage.value;
    if (page == null) {
      return Text('No se pudo cargar el historial de compras.', style: theme.textTheme.bodyMedium);
    }
    if (controller.orders.isEmpty) {
      return Text('Aún no tienes compras registradas.', style: theme.textTheme.bodyMedium);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Mostrando ${controller.orders.length} de ${page.meta.total} compras',
          style: theme.textTheme.bodySmall,
        ),
        12.verticalSpace,
        ...controller.orders.map((order) => _orderCard(theme, order)),
        if (page.meta.hasMore) ...[
          8.verticalSpace,
          Center(
            child: controller.loadingMoreOrders.value
                ? const CircularProgressIndicator()
                : OutlinedButton.icon(
                    onPressed: controller.loadMoreOrders,
                    icon: const Icon(Icons.expand_more),
                    label: const Text('Cargar más compras'),
                  ),
          ),
        ],
      ],
    );
  }

  Widget _orderCard(ThemeData theme, OrderModel order) {
    final color = order.status == 'PAID' || order.status == 'CLOSED'
        ? Colors.green
        : order.status == 'CANCELLED'
            ? Colors.redAccent
            : Colors.orange;
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Orden #${order.id}', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(order.status, style: TextStyle(color: color, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          6.verticalSpace,
          Text('Fecha: ${order.createdAt.toLocal()}', style: theme.textTheme.bodySmall),
          Text('Artículos: ${order.items.length}', style: theme.textTheme.bodySmall),
          if (order.pointsDiscount > 0)
            Text('Descuento puntos: -\u20ac${order.pointsDiscount.toStringAsFixed(2)}', style: theme.textTheme.bodySmall),
          4.verticalSpace,
          Text('Total: \u20ac${order.total.toStringAsFixed(2)}',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: theme.primaryColor)),
        ],
      ),
    );
  }
}
