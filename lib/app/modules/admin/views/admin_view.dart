import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../utils/constants.dart';
import '../../../components/custom_button.dart';
import '../../../data/models/product_model.dart';
import '../../../data/services/auth_service.dart';
import '../../../routes/app_pages.dart';
import '../controllers/admin_controller.dart';

class AdminView extends GetView<AdminController> {
  const AdminView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final bool isWide = MediaQuery.of(context).size.width >= 1200;
    final double contentMaxWidth = isWide ? 1180 : double.infinity;
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Panel de tienda', style: theme.textTheme.displaySmall),
          centerTitle: true,
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Productos'),
              Tab(text: 'Datos de tu tienda'),
              Tab(text: 'Vouchers'),
            ],
          ),
        ),
        body: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: contentMaxWidth),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
              child: TabBarView(
                children: [
                  _productsTab(context, theme),
                  _storeDetailsTab(theme),
                  _vouchersTab(theme),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _productsTab(BuildContext context, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Visión general', style: theme.textTheme.headlineMedium),
        20.verticalSpace,
        Obx(
          () => Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _metricCard(
                label: 'Productos',
                value: controller.totalProducts.value.toString(),
                icon: Icons.inventory_2,
                color: theme.primaryColor,
              ),
              _metricCard(
                label: 'Stock',
                value: controller.totalStock.value.toString(),
                icon: Icons.storage,
                color: theme.colorScheme.secondary,
              ),
              _metricCard(
                label: 'Precio medio',
                value: '\$${controller.averagePrice.value.toStringAsFixed(2)}',
                icon: Icons.price_change,
                color: theme.primaryColorDark,
              ),
            ],
          ),
        ),
        30.verticalSpace,
        if (AuthService.isStoreAdmin)
          Row(
            children: [
              Expanded(
                child: CustomButton(
                  text: 'Añadir producto',
                  onPressed: () => _showCreateProductDialog(context),
                  backgroundColor: theme.primaryColor,
                  foregroundColor: Colors.white,
                  radius: 14.r,
                  verticalPadding: 16.h,
                  hasShadow: true,
                ),
              ),
            ],
          )
        else
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(14.w),
            decoration: BoxDecoration(
              color: theme.primaryColor.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(14.r),
            ),
            child: Text(
              'Estás en modo solo visualización. No puedes agregar ni editar productos.',
              style: theme.textTheme.bodyMedium,
            ),
          ),
        30.verticalSpace,
        Text('Productos de la tienda', style: theme.textTheme.headlineSmall),
        16.verticalSpace,
        Expanded(
          child: Obx(
            () {
              if (controller.products.isEmpty) {
                return Center(
                  child: Text(
                    'No hay productos registrados para esta tienda.',
                    style: theme.textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                );
              }
              return LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth < 940) {
                    return ListView.separated(
                      itemCount: controller.products.length,
                      separatorBuilder: (_, __) => 12.verticalSpace,
                      itemBuilder: (context, index) {
                        final item = controller.products[index];
                        return _productCard(context, item);
                      },
                    );
                  }

                  return GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 14.w,
                      mainAxisSpacing: 12.h,
                      mainAxisExtent: 260.h,
                    ),
                    itemCount: controller.products.length,
                    itemBuilder: (context, index) {
                      final item = controller.products[index];
                      return _productCard(context, item);
                    },
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _storeDetailsTab(ThemeData theme) {
    final store = controller.currentStore;
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20.r),
              child: store.logoUrl.startsWith('assets/')
                  ? Image.asset(store.logoUrl, width: 120.w, height: 120.w, fit: BoxFit.cover)
                  : Image.network(store.logoUrl, width: 120.w, height: 120.w, fit: BoxFit.cover),
            ),
          ),
          20.verticalSpace,
          Text(store.name, style: theme.textTheme.headlineSmall),
          8.verticalSpace,
          Text(store.description, style: theme.textTheme.bodyMedium),
          24.verticalSpace,
          _sectionTitle(theme, 'Datos fiscales'),
          10.verticalSpace,
          _infoRow(theme, 'ID fiscal', store.fiscalId),
          _infoRow(theme, 'Email de facturación', store.billingEmail),
          _infoRow(theme, 'Teléfono facturación', store.billingPhone),
          24.verticalSpace,
          _sectionTitle(theme, 'Dirección de la tienda'),
          10.verticalSpace,
          _infoRow(theme, 'Dirección', store.address),
          _infoRow(theme, 'Correo del dueño', store.ownerEmail),
          _infoRow(theme, 'PIN de la tienda', store.pin),
          24.verticalSpace,
          _sectionTitle(theme, 'Usuarios de la tienda'),
          10.verticalSpace,
          Obx(
            () => Column(
              children: controller.storeUsers.map((user) {
                return Container(
                  width: double.infinity,
                  margin: EdgeInsets.only(bottom: 10.h),
                  padding: EdgeInsets.all(14.w),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(color: theme.dividerColor),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.person_outline),
                      12.horizontalSpace,
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(user.email, style: theme.textTheme.bodyLarge),
                            Text(user.role == AuthService.storeAdminRole ? 'Administrador' : 'Visualizador', style: theme.textTheme.bodySmall),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          24.verticalSpace,
          _sectionTitle(theme, 'Facturación'),
          10.verticalSpace,
          _infoRow(theme, 'Facturación habilitada', 'Sí'),
          _infoRow(theme, 'Correo facturas', store.billingEmail),
        ],
      ),
    );
  }

  Widget _vouchersTab(ThemeData theme) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 700;
        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Dashboard de Vouchers', style: theme.textTheme.headlineMedium),
                  CustomButton(
                    text: 'Ver historial',
                    onPressed: () => Get.toNamed(Routes.VOUCHER_HISTORY),
                    backgroundColor: theme.primaryColor,
                    foregroundColor: Colors.white,
                    radius: 14.r,
                    fontSize: 12.sp,
                    verticalPadding: 12.h,
                  ),
                ],
              ),
              20.verticalSpace,
              Obx(
                () => Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _metricCard(
                      label: 'Vouchers últimos 3 meses',
                      value: controller.recentValidVouchers.length.toString(),
                      icon: Icons.history,
                      color: theme.primaryColor,
                    ),
                    _metricCard(
                      label: 'Vouchers últimos 30 días',
                      value: controller.lastMonthValidVouchers.length.toString(),
                      icon: Icons.calendar_today,
                      color: theme.colorScheme.secondary,
                    ),
                  ],
                ),
              ),
              24.verticalSpace,
              Text('Vouchers activos (3 meses)', style: theme.textTheme.headlineSmall),
              12.verticalSpace,
              Obx(
                () {
                  final vouchers = controller.recentValidVouchers;
                  if (vouchers.isEmpty) {
                    return Text('No hay vouchers activos en los últimos 3 meses.', style: theme.textTheme.bodyMedium);
                  }
                  if (isWide) {
                    return _voucherTable(theme, vouchers);
                  }
                  return Column(
                    children: vouchers.map((v) => _voucherCard(theme, v)).toList(),
                  );
                },
              ),
              24.verticalSpace,
              Text('Vouchers activos (30 días)', style: theme.textTheme.headlineSmall),
              12.verticalSpace,
              Obx(
                () {
                  final vouchers = controller.lastMonthValidVouchers;
                  if (vouchers.isEmpty) {
                    return Text('No hay vouchers activos en los últimos 30 días.', style: theme.textTheme.bodyMedium);
                  }
                  if (isWide) {
                    return _voucherTable(theme, vouchers);
                  }
                  return Column(
                    children: vouchers.map((v) => _voucherCard(theme, v)).toList(),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _voucherTable(ThemeData theme, List<dynamic> vouchers) {
    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: theme.dividerColor),
      ),
      clipBehavior: Clip.antiAlias,
      child: DataTable(
        headingRowColor: WidgetStateProperty.all(theme.primaryColor.withValues(alpha: 0.08)),
        dataRowColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? theme.primaryColor.withValues(alpha: 0.05)
              : null,
        ),
        columnSpacing: 24,
        columns: [
          DataColumn(label: Text('Código', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold))),
          DataColumn(label: Text('Usuario', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold))),
          DataColumn(label: Text('Email', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold))),
          DataColumn(label: Text('Creado', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold))),
        ],
        rows: vouchers.map((voucher) {
          return DataRow(cells: [
            DataCell(
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: theme.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(voucher.code, style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold, color: theme.primaryColor)),
              ),
            ),
            DataCell(Text(controller.customerNameFor(voucher), style: theme.textTheme.bodyMedium)),
            DataCell(Text(controller.customerEmailFor(voucher), style: theme.textTheme.bodyMedium)),
            DataCell(Text(voucher.createdAt.toLocal().toString().split(' ').first, style: theme.textTheme.bodySmall)),
          ]);
        }).toList(),
      ),
    );
  }

  Widget _voucherCard(ThemeData theme, dynamic voucher) {
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
          Text('Código: ${voucher.code}', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          8.verticalSpace,
          Text('Usuario: ${controller.customerNameFor(voucher)}', style: theme.textTheme.bodyMedium),
          Text('Email: ${controller.customerEmailFor(voucher)}', style: theme.textTheme.bodyMedium),
          Text('Creado: ${voucher.createdAt.toLocal().toString().split(' ').first}', style: theme.textTheme.bodySmall),
        ],
      ),
    );
  }

  Widget _productCard(BuildContext context, ProductModel item) {
    final theme = context.theme;
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.r),
        color: theme.cardColor,
        border: Border.all(color: theme.dividerColor),
        boxShadow: [
          BoxShadow(
            color: theme.primaryColor.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.inventory_2, size: 28.w, color: theme.primaryColor),
          14.horizontalSpace,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name, style: theme.textTheme.titleLarge),
                8.verticalSpace,
                Text(item.description, style: theme.textTheme.bodyMedium),
                8.verticalSpace,
                Text('Stock disponible: ${item.quantity}', style: theme.textTheme.bodyMedium),
                4.verticalSpace,
                Text('Categoria: ${item.category}', style: theme.textTheme.bodyMedium),
                Text('SKU: ${item.sku}', style: theme.textTheme.bodyMedium),
                Text('Precio original: \$${item.originalPrice.toStringAsFixed(2)}', style: theme.textTheme.bodyMedium),
                Text('Precio con descuento: \$${item.discountPrice.toStringAsFixed(2)}', style: theme.textTheme.bodyMedium),
              ],
            ),
          ),
          Column(
            children: [
              CustomButton(
                text: 'Editar',
                onPressed: AuthService.isStoreAdmin ? () {} : null,
                backgroundColor: theme.primaryColor,
                foregroundColor: Colors.white,
                fontSize: 12.sp,
                radius: 12.r,
                verticalPadding: 10.h,
                width: 90.w,
              ),
              8.verticalSpace,
              CustomButton(
                text: 'Eliminar',
                onPressed: AuthService.isStoreAdmin ? () => controller.deleteProduct(item) : null,
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                fontSize: 12.sp,
                radius: 12.r,
                verticalPadding: 10.h,
                width: 90.w,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(ThemeData theme, String title) {
    return Text(title, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold));
  }

  Widget _infoRow(ThemeData theme, String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text('$label:', style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
          ),
          Expanded(
            flex: 3,
            child: Text(value, style: theme.textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }

  Widget _metricCard({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: color.withValues(alpha: 0.25)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 24.w),
            18.verticalSpace,
            Text(value, style: Get.textTheme.headlineSmall?.copyWith(color: color, fontWeight: FontWeight.bold)),
            8.verticalSpace,
            Text(label, style: Get.textTheme.bodyMedium?.copyWith(color: color.withValues(alpha: 0.8))),
          ],
        ),
      ),
    );
  }

  void _showCreateProductDialog(BuildContext context) {
    final imageController = TextEditingController();
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    final categoryController = TextEditingController();
    final skuController = TextEditingController();
    final originalPriceController = TextEditingController();
    final discountPriceController = TextEditingController();
    final stockController = TextEditingController();

    Get.dialog(
      AlertDialog(
        title: const Text('Añadir producto'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: imageController,
                decoration: const InputDecoration(labelText: 'URL de imagen del producto'),
              ),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Nombre del producto'),
              ),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'Descripción completa'),
                maxLines: 3,
              ),
              TextField(
                controller: categoryController,
                decoration: const InputDecoration(labelText: 'Categoría'),
              ),
              TextField(
                controller: skuController,
                decoration: const InputDecoration(labelText: 'SKU'),
              ),
              TextField(
                controller: originalPriceController,
                decoration: const InputDecoration(labelText: 'Precio original'),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
              ),
              TextField(
                controller: discountPriceController,
                decoration: const InputDecoration(labelText: 'Precio con descuento'),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
              ),
              TextField(
                controller: stockController,
                decoration: const InputDecoration(labelText: 'Stock disponible'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              final image = imageController.text.trim();
              final name = nameController.text.trim();
              final description = descriptionController.text.trim();
              final originalPrice = double.tryParse(originalPriceController.text.trim());
              final discountPrice = double.tryParse(discountPriceController.text.trim());
              final stock = int.tryParse(stockController.text.trim());

              if (name.isEmpty || description.isEmpty || categoryController.text.trim().isEmpty || skuController.text.trim().isEmpty ||
                  originalPrice == null || discountPrice == null || stock == null) {
                Get.snackbar('Error', 'Complete todos los campos obligatorios.');
                return;
              }

              final product = ProductModel(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                image: image.isNotEmpty ? image : Constants.background,
                name: name,
                description: description,
                category: categoryController.text.trim(),
                sku: skuController.text.trim(),
                quantity: stock,
                originalPrice: originalPrice,
                discountPrice: discountPrice,
                storeId: controller.storeId.value.isNotEmpty ? controller.storeId.value : 'store_1',
              );

              controller.addProduct(product);
              Get.back();
              Get.snackbar('Éxito', 'Producto agregado correctamente');
            },
            child: const Text('Agregar'),
          ),
        ],
      ),
    );
  }
}
