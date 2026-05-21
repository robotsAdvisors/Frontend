import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../components/custom_button.dart';
import '../../../components/custom_form_field.dart';
import '../../../data/services/auth_service.dart';
import '../../../../utils/constants.dart';
import '../controllers/login_controller.dart';

class LoginView extends GetView<LoginController> {
  const LoginView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 18.h),
          child: Form(
            key: controller.formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                14.verticalSpace,
                Row(
                  children: [
                    Container(
                      width: 46.w,
                      height: 46.w,
                      decoration: BoxDecoration(
                        color: theme.primaryColorDark,
                        borderRadius: BorderRadius.circular(14.r),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(8.r),
                        child: Image.asset(Constants.logo),
                      ),
                    ),
                    12.horizontalSpace,
                    Text(
                      'Letdem',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        color: theme.primaryColor,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                24.verticalSpace,
                Text(
                  'Bienvenido',
                  style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                10.verticalSpace,
                Text(
                  'Inicia sesión con tu correo y contraseña para continuar en el marketplace.',
                  style: theme.textTheme.bodyLarge,
                ),
                40.verticalSpace,
                CustomFormField(
                  label: 'Correo electrónico',
                  hint: 'ejemplo@correo.com',
                  controller: controller.emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: controller.validateEmail,
                  textInputAction: TextInputAction.next,
                ),
                20.verticalSpace,
                Obx(
                  () => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Tipo de cuenta', style: theme.textTheme.titleMedium),
                      10.verticalSpace,
                      Column(
                        children: [
                          GestureDetector(
                            onTap: () => controller.selectedRole.value = AuthService.customerRole,
                            child: Container(
                              width: double.infinity,
                              padding: EdgeInsets.symmetric(vertical: 14.h),
                              margin: EdgeInsets.only(bottom: 12.h),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12.r),
                                border: Border.all(
                                  color: controller.selectedRole.value == AuthService.customerRole
                                      ? theme.primaryColor
                                      : theme.dividerColor,
                                ),
                                color: controller.selectedRole.value == AuthService.customerRole
                                    ? theme.primaryColor.withValues(alpha: 0.1)
                                    : null,
                              ),
                              child: Center(
                                child: Text(
                                  'Usuario',
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    color: controller.selectedRole.value == AuthService.customerRole
                                        ? theme.primaryColor
                                        : theme.textTheme.bodyLarge?.color,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () => controller.selectedRole.value = AuthService.storeAdminRole,
                            child: Container(
                              width: double.infinity,
                              padding: EdgeInsets.symmetric(vertical: 14.h),
                              margin: EdgeInsets.only(bottom: 12.h),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12.r),
                                border: Border.all(
                                  color: controller.selectedRole.value == AuthService.storeAdminRole
                                      ? theme.primaryColor
                                      : theme.dividerColor,
                                ),
                                color: controller.selectedRole.value == AuthService.storeAdminRole
                                    ? theme.primaryColor.withValues(alpha: 0.1)
                                    : null,
                              ),
                              child: Center(
                                child: Text(
                                  'Administrador de Tienda',
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    color: controller.selectedRole.value == AuthService.storeAdminRole
                                        ? theme.primaryColor
                                        : theme.textTheme.bodyLarge?.color,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () => controller.selectedRole.value = AuthService.storeViewerRole,
                            child: Container(
                              width: double.infinity,
                              padding: EdgeInsets.symmetric(vertical: 14.h),
                              margin: EdgeInsets.only(bottom: 12.h),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12.r),
                                border: Border.all(
                                  color: controller.selectedRole.value == AuthService.storeViewerRole
                                      ? theme.primaryColor
                                      : theme.dividerColor,
                                ),
                                color: controller.selectedRole.value == AuthService.storeViewerRole
                                    ? theme.primaryColor.withValues(alpha: 0.1)
                                    : null,
                              ),
                              child: Center(
                                child: Text(
                                  'Visualizador de Tienda',
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    color: controller.selectedRole.value == AuthService.storeViewerRole
                                        ? theme.primaryColor
                                        : theme.textTheme.bodyLarge?.color,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () => controller.selectedRole.value = AuthService.generalAdminRole,
                            child: Container(
                              width: double.infinity,
                              padding: EdgeInsets.symmetric(vertical: 14.h),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12.r),
                                border: Border.all(
                                  color: controller.selectedRole.value == AuthService.generalAdminRole
                                      ? theme.primaryColor
                                      : theme.dividerColor,
                                ),
                                color: controller.selectedRole.value == AuthService.generalAdminRole
                                    ? theme.primaryColor.withValues(alpha: 0.1)
                                    : null,
                              ),
                              child: Center(
                                child: Text(
                                  'Administrador General',
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    color: controller.selectedRole.value == AuthService.generalAdminRole
                                        ? theme.primaryColor
                                        : theme.textTheme.bodyLarge?.color,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                20.verticalSpace,
                Obx(
                  () => CustomFormField(
                    label: 'Contraseña',
                    hint: '********',
                    controller: controller.passwordController,
                    obscureText: controller.hidePassword.value,
                    validator: controller.validatePassword,
                    suffixIcon: IconButton(
                      icon: Icon(
                        controller.hidePassword.value
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: theme.iconTheme.color,
                      ),
                      onPressed: () => controller.hidePassword.value = !controller.hidePassword.value,
                    ),
                    textInputAction: TextInputAction.done,
                  ),
                ),
                30.verticalSpace,
                Obx(
                  () => CustomButton(
                    text: controller.isLoading.value ? 'Cargando...' : 'Iniciar sesión',
                    onPressed: controller.isLoading.value ? null : controller.login,
                    backgroundColor: theme.primaryColor,
                    foregroundColor: Colors.white,
                    radius: 14.r,
                    verticalPadding: 16.h,
                    disabled: controller.isLoading.value,
                    hasShadow: true,
                  ),
                ),
                12.verticalSpace,
                Row(
                  children: [
                    const Expanded(child: Divider()),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12.w),
                      child: Text(
                        'o',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                    const Expanded(child: Divider()),
                  ],
                ),
                12.verticalSpace,
                Obx(
                  () => CustomButton(
                    text: 'Continuar con Google',
                    onPressed: controller.isLoading.value
                        ? null
                        : controller.loginWithGoogle,
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black87,
                    radius: 14.r,
                    verticalPadding: 14.h,
                    disabled: controller.isLoading.value,
                    hasShadow: true,
                    icon: const Icon(
                      Icons.account_circle,
                      color: Colors.redAccent,
                    ),
                  ),
                ),
                16.verticalSpace,
                Center(
                  child: TextButton(
                    onPressed: controller.register,
                    child: Text(
                      '¿No tienes cuenta? Regístrate',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
