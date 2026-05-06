import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../components/custom_button.dart';
import '../../../data/models/store_model.dart';
import '../../../data/models/store_user_model.dart';
import '../controllers/general_admin_controller.dart';

class GeneralAdminView extends GetView<GeneralAdminController> {
  const GeneralAdminView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Scaffold(
      appBar: AppBar(
        title: Text('Administrador General', style: theme.textTheme.headline3),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Visión general', style: theme.textTheme.headline4),
            20.verticalSpace,
            Obx(
              () => Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _metricCard(
                    label: 'Tiendas',
                    value: controller.totalStores.value.toString(),
                    icon: Icons.store,
                    color: theme.primaryColor,
                  ),
                  _metricCard(
                    label: 'Usuarios de tienda',
                    value: controller.totalStoreUsers.value.toString(),
                    icon: Icons.people,
                    color: theme.colorScheme.secondary,
                  ),
                ],
              ),
            ),
            30.verticalSpace,
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    text: 'Crear Tienda',
                    onPressed: () => _showCreateStoreDialog(context),
                    backgroundColor: theme.primaryColor,
                    foregroundColor: Colors.white,
                    radius: 12.r,
                    verticalPadding: 12.h,
                  ),
                ),
                16.horizontalSpace,
                Expanded(
                  child: CustomButton(
                    text: 'Crear Usuario',
                    onPressed: () => _showCreateUserDialog(context),
                    backgroundColor: theme.colorScheme.secondary,
                    foregroundColor: Colors.white,
                    radius: 12.r,
                    verticalPadding: 12.h,
                  ),
                ),
              ],
            ),
            30.verticalSpace,
            Text('Tiendas registradas', style: theme.textTheme.headline5),
            16.verticalSpace,
            Expanded(
              child: Obx(
                () => ListView.separated(
                  itemCount: controller.stores.length,
                  separatorBuilder: (_, __) => 12.verticalSpace,
                  itemBuilder: (context, index) {
                    final store = controller.stores[index];
                    return Container(
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20.r),
                        color: theme.cardColor,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.store, size: 28.w, color: theme.primaryColor),
                              14.horizontalSpace,
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(store.name, style: theme.textTheme.headline6),
                                    4.verticalSpace,
                                    Text('Dueño: ${store.ownerEmail}', style: theme.textTheme.bodyText2),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _confirmDeleteStore(store.id),
                              ),
                            ],
                          ),
                          12.verticalSpace,
                          Text(store.description, style: theme.textTheme.bodyText2),
                          8.verticalSpace,
                          Text('Admins: ${store.adminUserIds.length}', style: theme.textTheme.caption),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
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
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 24.w),
            18.verticalSpace,
            Text(value, style: Get.textTheme.headline5?.copyWith(color: color, fontWeight: FontWeight.bold)),
            8.verticalSpace,
            Text(label, style: Get.textTheme.bodyText2?.copyWith(color: color.withOpacity(0.8))),
          ],
        ),
      ),
    );
  }

  void _showCreateStoreDialog(BuildContext context) {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    final ownerEmailController = TextEditingController();

    Get.dialog(
      AlertDialog(
        title: const Text('Crear Nueva Tienda'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Nombre de la tienda'),
            ),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(labelText: 'Descripción'),
            ),
            TextField(
              controller: ownerEmailController,
              decoration: const InputDecoration(labelText: 'Email del dueño'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              if (nameController.text.isNotEmpty &&
                  descriptionController.text.isNotEmpty &&
                  ownerEmailController.text.isNotEmpty) {
                final store = StoreModel(
                  id: 'store_${DateTime.now().millisecondsSinceEpoch}',
                  name: nameController.text,
                  description: descriptionController.text,
                  ownerId: 'owner_${DateTime.now().millisecondsSinceEpoch}',
                  ownerEmail: ownerEmailController.text,
                  adminUserIds: [],
                  fiscalId: 'FISCAL${DateTime.now().millisecondsSinceEpoch}',
                  address: 'Dirección por definir',
                  logoUrl: Constants.logo,
                  billingEmail: ownerEmailController.text,
                  billingPhone: '000 000 0000',
                  pin: '0000',
                  createdAt: DateTime.now(),
                );
                controller.addStore(store);
                Get.back();
                Get.snackbar('Éxito', 'Tienda creada correctamente');
              }
            },
            child: const Text('Crear'),
          ),
        ],
      ),
    );
  }

  void _showCreateUserDialog(BuildContext context) {
    final emailController = TextEditingController();
    final storeIdController = TextEditingController();

    Get.dialog(
      AlertDialog(
        title: const Text('Crear Usuario de Tienda'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Email del usuario'),
            ),
            TextField(
              controller: storeIdController,
              decoration: const InputDecoration(labelText: 'ID de la tienda'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              if (emailController.text.isNotEmpty && storeIdController.text.isNotEmpty) {
                final user = StoreUserModel(
                  id: 'admin_${DateTime.now().millisecondsSinceEpoch}',
                  email: emailController.text,
                  role: 'store_admin',
                  storeId: storeIdController.text,
                  createdAt: DateTime.now(),
                );
                controller.addStoreUser(user);
                Get.back();
                Get.snackbar('Éxito', 'Usuario creado correctamente');
              }
            },
            child: const Text('Crear'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteStore(String storeId) {
    Get.dialog(
      AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: const Text('¿Estás seguro de que quieres eliminar esta tienda?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              controller.removeStore(storeId);
              Get.back();
              Get.snackbar('Éxito', 'Tienda eliminada correctamente');
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}