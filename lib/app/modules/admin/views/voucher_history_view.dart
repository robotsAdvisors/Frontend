import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../data/models/voucher_model.dart';
import '../controllers/admin_controller.dart';

class VoucherHistoryView extends GetView<AdminController> {
  const VoucherHistoryView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Historial de vouchers'),
          centerTitle: true,
          bottom: TabBar(
            tabs: [
              Tab(text: 'Historial'),
              Tab(text: 'Favoritos'),
            ],
          ),
        ),
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
          child: TabBarView(
            children: [
              _historyTab(theme),
              _favoritesTab(theme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _historyTab(ThemeData theme) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Vouchers canjeados', style: theme.textTheme.headlineSmall),
          16.verticalSpace,
          Obx(
            () {
              final redeemed = controller.redeemedVouchers;
              if (redeemed.isEmpty) {
                return Text('No hay vouchers canjeados todavía.', style: theme.textTheme.bodyMedium);
              }
              return Column(
                children: redeemed.map(_buildRedeemedCard).toList(),
              );
            },
          ),
          30.verticalSpace,
          Text('Vouchers expirados sin canjear', style: theme.textTheme.headlineSmall),
          16.verticalSpace,
          Obx(
            () {
              final expired = controller.expiredUnredeemedVouchers;
              if (expired.isEmpty) {
                return Text('No hay vouchers expirados sin canjear.', style: theme.textTheme.bodyMedium);
              }
              return Column(
                children: expired.map(_buildExpiredCard).toList(),
              );
            },
          ),
          24.verticalSpace,
          Obx(() {
            final meta = controller.vouchersMeta.value;
            final shown = controller.vouchers.length;
            if (meta.total == 0) return const SizedBox.shrink();
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Mostrando $shown de ${meta.total} vouchers',
                  style: theme.textTheme.bodySmall,
                ),
                12.verticalSpace,
                if (meta.hasMore)
                  Center(
                    child: controller.isLoadingMoreVouchers.value
                        ? const CircularProgressIndicator()
                        : OutlinedButton.icon(
                            onPressed: controller.loadMoreVouchers,
                            icon: const Icon(Icons.expand_more),
                            label: const Text('Cargar más vouchers'),
                          ),
                  ),
              ],
            );
          }),
          20.verticalSpace,
        ],
      ),
    );
  }

  Widget _favoritesTab(ThemeData theme) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Clientes favoritos', style: theme.textTheme.headlineSmall),
          16.verticalSpace,
          Obx(
            () {
              final favorites = controller.favoriteVouchers;
              if (favorites.isEmpty) {
                return Text('No has marcado ningún cliente como favorito.', style: theme.textTheme.bodyMedium);
              }
              return Column(
                children: favorites.map(_buildFavoriteCard).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRedeemedCard(VoucherModel voucher) {
    final theme = Get.context!.theme;
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 14.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20.r),
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
              Obx(
                () => IconButton(
                  icon: Icon(
                    controller.isFavorite(voucher.id) ? Icons.star : Icons.star_border,
                    color: controller.isFavorite(voucher.id) ? Colors.amber : theme.iconTheme.color,
                  ),
                  onPressed: () => controller.toggleFavorite(voucher.id),
                ),
              ),
            ],
          ),
          8.verticalSpace,
          Text('Cliente: ${controller.customerNameFor(voucher)}', style: theme.textTheme.bodyMedium),
          Text('Email: ${controller.customerEmailFor(voucher)}', style: theme.textTheme.bodyMedium),
          Text('Producto retirado: ${controller.productNameFor(voucher)}', style: theme.textTheme.bodyMedium),
          Text('Fecha de creación: ${voucher.createdAt.toLocal()}', style: theme.textTheme.bodySmall),
          Text('Fecha y hora de canje: ${voucher.redeemedAt?.toLocal() ?? '-'}', style: theme.textTheme.bodySmall),
        ],
      ),
    );
  }

  Widget _buildExpiredCard(VoucherModel voucher) {
    final theme = Get.context!.theme;
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 14.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20.r),
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
              Obx(
                () => IconButton(
                  icon: Icon(
                    controller.isFavorite(voucher.id) ? Icons.star : Icons.star_border,
                    color: controller.isFavorite(voucher.id) ? Colors.amber : theme.iconTheme.color,
                  ),
                  onPressed: () => controller.toggleFavorite(voucher.id),
                ),
              ),
            ],
          ),
          8.verticalSpace,
          Text('Cliente: ${controller.customerNameFor(voucher)}', style: theme.textTheme.bodyMedium),
          Text('Email: ${controller.customerEmailFor(voucher)}', style: theme.textTheme.bodyMedium),
          Text('Producto asociado: ${controller.productNameFor(voucher)}', style: theme.textTheme.bodyMedium),
          Text('Fecha de creación: ${voucher.createdAt.toLocal()}', style: theme.textTheme.bodySmall),
          Text('Estado: Expirado sin canjear', style: theme.textTheme.bodySmall),
        ],
      ),
    );
  }

  Widget _buildFavoriteCard(VoucherModel voucher) {
    final theme = Get.context!.theme;
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 14.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20.r),
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
              Icon(Icons.star, color: Colors.amber),
            ],
          ),
          8.verticalSpace,
          Text('Cliente: ${controller.customerNameFor(voucher)}', style: theme.textTheme.bodyMedium),
          Text('Email: ${controller.customerEmailFor(voucher)}', style: theme.textTheme.bodyMedium),
          Text('Producto: ${controller.productNameFor(voucher)}', style: theme.textTheme.bodyMedium),
          Text('Fecha de creación: ${voucher.createdAt.toLocal()}', style: theme.textTheme.bodySmall),
          if (voucher.isRedeemed) ...[
            Text('Canjeado: ${voucher.redeemedAt?.toLocal() ?? '-'}', style: theme.textTheme.bodySmall),
          ] else ...[
            Text('Estado: ${voucher.isExpired ? 'Expirado sin canjear' : 'Pendiente'}', style: theme.textTheme.bodySmall),
          ],
        ],
      ),
    );
  }
}
