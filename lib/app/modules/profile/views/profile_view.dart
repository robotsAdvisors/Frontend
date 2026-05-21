import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../components/custom_button.dart';
import '../../../components/custom_form_field.dart';
import '../controllers/profile_controller.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final bool isWide = MediaQuery.of(context).size.width >= 1000;
    final double contentMaxWidth = isWide ? 980 : double.infinity;
    return Scaffold(
      appBar: AppBar(
        title: Text('Mi perfil', style: theme.textTheme.displaySmall),
        centerTitle: true,
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: contentMaxWidth),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
            child: SingleChildScrollView(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Configuración de cliente', style: theme.textTheme.headlineSmall),
              16.verticalSpace,
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: theme.dividerColor),
                  boxShadow: [
                    BoxShadow(
                      color: theme.primaryColor.withValues(alpha: 0.08),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Obx(
                  () {
                    final isEditing = controller.isEditingProfile.value;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [                        // ── Profile photo ──────────────────────────────
                        Center(
                          child: Stack(
                            children: [
                              Obx(() {
                                final imageBytes = controller.profileImageBytes;
                                return CircleAvatar(
                                  radius: 44.r,
                                  backgroundColor: theme.primaryColorDark,
                                  backgroundImage: imageBytes != null
                                      ? MemoryImage(imageBytes)
                                      : null,
                                  child: imageBytes == null
                                      ? Icon(Icons.person, size: 44.r, color: theme.primaryColor)
                                      : null,
                                );
                              }),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: GestureDetector(
                                  onTap: controller.pickProfileImage,
                                  child: CircleAvatar(
                                    radius: 14.r,
                                    backgroundColor: theme.primaryColor,
                                    child: Icon(Icons.camera_alt, size: 14.r, color: Colors.white),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        14.verticalSpace,
                        // ── Mis datos header ───────────────────────────
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Mis datos', style: theme.textTheme.titleLarge),
                            if (!isEditing)
                              TextButton(
                                onPressed: controller.startEditingProfile,
                                child: const Text('Editar'),
                              ),
                          ],
                        ),
                        12.verticalSpace,
                        if (!isEditing) ...[
                          _infoRow(theme, 'Nombre', controller.customerName.value),
                          _infoRow(theme, 'Email', controller.userEmail.value),
                          _infoRow(theme, 'Teléfono', controller.customerPhone.value),
                          _infoRow(theme, 'Dirección', controller.customerAddress.value),
                        ] else ...[
                          CustomFormField(
                            controller: controller.nameController,
                            hint: 'Nombre completo',
                            maxLines: 1,
                          ),
                          10.verticalSpace,
                          CustomFormField(
                            controller: controller.phoneController,
                            hint: 'Teléfono',
                            keyboardType: TextInputType.phone,
                            maxLines: 1,
                          ),
                          10.verticalSpace,
                          CustomFormField(
                            controller: controller.addressController,
                            hint: 'Dirección',
                            maxLines: 2,
                          ),
                          14.verticalSpace,
                          Row(
                            children: [
                              Expanded(
                                child: CustomButton(
                                  text: 'Cancelar',
                                  onPressed: controller.cancelEditingProfile,
                                  backgroundColor: theme.primaryColorDark,
                                  foregroundColor: theme.appBarTheme.iconTheme?.color ?? Colors.white,
                                  radius: 12,
                                  verticalPadding: 12,
                                ),
                              ),
                              10.horizontalSpace,
                              Expanded(
                                child: CustomButton(
                                  text: 'Guardar',
                                  onPressed: controller.saveCustomerData,
                                  backgroundColor: theme.primaryColor,
                                  foregroundColor: Colors.white,
                                  radius: 12,
                                  verticalPadding: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    );
                  },
                ),
              ),
              20.verticalSpace,
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.primaryColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: theme.primaryColor.withValues(alpha: 0.25),
                      blurRadius: 12,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Obx(
                  () {
                    if (controller.isLoadingVirtualCard.value) {
                      return const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      );
                    }
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          controller.virtualCardType.value,
                          style: theme.textTheme.titleLarge?.copyWith(color: Colors.white),
                        ),
                        18.verticalSpace,
                        Text(
                          controller.virtualCardNumber.value,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            color: Colors.white,
                            letterSpacing: 1.2,
                          ),
                        ),
                        14.verticalSpace,
                        Text(
                          'Válida hasta ${controller.virtualCardExpiry.value}',
                          style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white70),
                        ),
                        10.verticalSpace,
                        Text(
                          'Tarjeta asignada por backend (solo lectura)',
                          style: theme.textTheme.bodySmall?.copyWith(color: Colors.white70),
                        ),
                      ],
                    );
                  },
                ),
              ),
              24.verticalSpace,
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: theme.dividerColor),
                ),
                child: Obx(
                  () => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Preferencias', style: theme.textTheme.titleLarge),
                      14.verticalSpace,
                      Text('Idioma', style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                      10.verticalSpace,
                      Row(
                        children: [
                          Expanded(
                            child: CustomButton(
                              text: 'Espanol',
                              onPressed: () => controller.changeLanguage('es'),
                              backgroundColor: controller.selectedLanguageCode.value == 'es'
                                  ? theme.primaryColor
                                  : theme.primaryColorDark,
                              foregroundColor: controller.selectedLanguageCode.value == 'es'
                                  ? Colors.white
                                  : (theme.textTheme.bodyLarge?.color ?? Colors.black),
                              radius: 12,
                              verticalPadding: 12,
                              hasShadow: controller.selectedLanguageCode.value == 'es',
                            ),
                          ),
                          10.horizontalSpace,
                          Expanded(
                            child: CustomButton(
                              text: 'English',
                              onPressed: () => controller.changeLanguage('en'),
                              backgroundColor: controller.selectedLanguageCode.value == 'en'
                                  ? theme.primaryColor
                                  : theme.primaryColorDark,
                              foregroundColor: controller.selectedLanguageCode.value == 'en'
                                  ? Colors.white
                                  : (theme.textTheme.bodyLarge?.color ?? Colors.black),
                              radius: 12,
                              verticalPadding: 12,
                              hasShadow: controller.selectedLanguageCode.value == 'en',
                            ),
                          ),
                        ],
                      ),
                      16.verticalSpace,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Modo oscuro', style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                              2.verticalSpace,
                              Text(
                                controller.isDarkMode.value ? 'Activado' : 'Desactivado',
                                style: theme.textTheme.bodySmall,
                              ),
                            ],
                          ),
                          Switch(
                            value: controller.isDarkMode.value,
                            onChanged: controller.toggleDarkMode,
                            activeColor: theme.primaryColor,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              24.verticalSpace,
              Text(
                'Gestión del servicio',
                style: theme.textTheme.titleLarge,
              ),
              12.verticalSpace,
              CustomButton(
                text: 'Darme de baja del servicio',
                onPressed: controller.unsubscribeService,
                backgroundColor: theme.colorScheme.error,
                foregroundColor: Colors.white,
                radius: 14,
                verticalPadding: 16,
              ),
              10.verticalSpace,
              CustomButton(
                text: 'Cerrar sesión',
                onPressed: controller.logout,
                backgroundColor: theme.primaryColorDark,
                foregroundColor: theme.appBarTheme.iconTheme?.color ?? Colors.white,
                radius: 14,
                verticalPadding: 16,
              ),
              ],
            ),
          ),
          ),
        ),
      ),
    );
  }

  Widget _infoRow(ThemeData theme, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(
              '$label:',
              style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}