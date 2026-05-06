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
          Text('Vouchers canjeados', style: theme.textTheme.headline5),
          16.verticalSpace,
          Obx(
            () {
              final redeemed = controller.redeemedVouchers;
              if (redeemed.isEmpty) {
                return Text('No hay vouchers canjeados todavía.', style: theme.textTheme.bodyText2);
              }
              return Column(
                children: redeemed.map(_buildRedeemedCard).toList(),
              );
            },
          ),
          30.verticalSpace,
          Text('Vouchers expirados sin canjear', style: theme.textTheme.headline5),
          16.verticalSpace,
          Obx(
            () {
              final expired = controller.expiredUnredeemedVouchers;
              if (expired.isEmpty) {
                return Text('No hay vouchers expirados sin canjear.', style: theme.textTheme.bodyText2);
              }
              return Column(
                children: expired.map(_buildExpiredCard).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _favoritesTab(ThemeData theme) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Clientes favoritos', style: theme.textTheme.headline5),
          16.verticalSpace,
          Obx(
            () {
              final favorites = controller.favoriteVouchers;
              if (favorites.isEmpty) {
                return Text('No has marcado ningún cliente como favorito.', style: theme.textTheme.bodyText2);
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
                child: Text('Código: ${voucher.code}', style: theme.textTheme.subtitle1?.copyWith(fontWeight: FontWeight.bold)),
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
          Text('Cliente: ${controller.customerNameFor(voucher)}', style: theme.textTheme.bodyText2),
          Text('Email: ${controller.customerEmailFor(voucher)}', style: theme.textTheme.bodyText2),
          Text('Producto retirado: ${controller.productNameFor(voucher)}', style: theme.textTheme.bodyText2),
          Text('Fecha de creación: ${voucher.createdAt.toLocal()}', style: theme.textTheme.caption),
          Text('Fecha y hora de canje: ${voucher.redeemedAt?.toLocal() ?? '-'}', style: theme.textTheme.caption),
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
                child: Text('Código: ${voucher.code}', style: theme.textTheme.subtitle1?.copyWith(fontWeight: FontWeight.bold)),
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
          Text('Cliente: ${controller.customerNameFor(voucher)}', style: theme.textTheme.bodyText2),
          Text('Email: ${controller.customerEmailFor(voucher)}', style: theme.textTheme.bodyText2),
          Text('Producto asociado: ${controller.productNameFor(voucher)}', style: theme.textTheme.bodyText2),
          Text('Fecha de creación: ${voucher.createdAt.toLocal()}', style: theme.textTheme.caption),
          Text('Estado: Expirado sin canjear', style: theme.textTheme.caption),
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
                child: Text('Código: ${voucher.code}', style: theme.textTheme.subtitle1?.copyWith(fontWeight: FontWeight.bold)),
              ),
              Icon(Icons.star, color: Colors.amber),
            ],
          ),
          8.verticalSpace,
          Text('Cliente: ${controller.customerNameFor(voucher)}', style: theme.textTheme.bodyText2),
          Text('Email: ${controller.customerEmailFor(voucher)}', style: theme.textTheme.bodyText2),
          Text('Producto: ${controller.productNameFor(voucher)}', style: theme.textTheme.bodyText2),
          Text('Fecha de creación: ${voucher.createdAt.toLocal()}', style: theme.textTheme.caption),
          if (voucher.isRedeemed) ...[
            Text('Canjeado: ${voucher.redeemedAt?.toLocal() ?? '-'}', style: theme.textTheme.caption),
          ] else ...[
            Text('Estado: ${voucher.isExpired ? 'Expirado sin canjear' : 'Pendiente'}', style: theme.textTheme.caption),
          ],
        ],
      ),
    );
  }
}
