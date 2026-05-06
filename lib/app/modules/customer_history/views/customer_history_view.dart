import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

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
        title: Text('Historial Wallet', style: theme.textTheme.headline3),
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
                Text('Movimientos y canjes', style: theme.textTheme.headline5),
                12.verticalSpace,
                if (controller.walletMovements.isEmpty)
                  Text('No hay movimientos en tu wallet todavía.', style: theme.textTheme.bodyText2)
                else
                  Column(
                    children: controller.walletMovements
                        .map((voucher) => _movementCard(theme, voucher))
                        .toList(),
                  ),
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
            color: theme.primaryColor.withOpacity(0.24),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Tarjeta virtual de puntos', style: theme.textTheme.headline6?.copyWith(color: Colors.white)),
          12.verticalSpace,
          Text(
            controller.walletCode.value,
            style: theme.textTheme.headline5?.copyWith(color: Colors.white, letterSpacing: 1.1),
          ),
          10.verticalSpace,
          Text('Estado wallet: ${controller.walletStatus.value}', style: theme.textTheme.bodyText2?.copyWith(color: Colors.white70)),
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
            color: theme.primaryColor.withOpacity(0.08),
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
                child: Text('Código: ${voucher.code}', style: theme.textTheme.subtitle1?.copyWith(fontWeight: FontWeight.bold)),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(status, style: TextStyle(color: color, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          8.verticalSpace,
          Text('Producto: ${controller.productNameFor(voucher)}', style: theme.textTheme.bodyText2),
          Text('Descuento obtenido: ${controller.discountText(voucher)}', style: theme.textTheme.bodyText2),
          Text('Creado: ${voucher.createdAt.toLocal()}', style: theme.textTheme.caption),
          if (voucher.redeemedAt != null)
            Text('Canjeado: ${voucher.redeemedAt!.toLocal()}', style: theme.textTheme.caption),
          Text('Tiempo restante: ${controller.remainingTime(voucher)}', style: theme.textTheme.caption),
          if (controller.canRate(voucher)) ...[
            10.verticalSpace,
            Text('Valorar producto', style: theme.textTheme.bodyText2?.copyWith(fontWeight: FontWeight.w600)),
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
}
