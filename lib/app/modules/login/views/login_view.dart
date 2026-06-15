import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../../components/custom_form_field.dart';
import '../../../data/services/auth_service.dart';
import '../../../routes/app_pages.dart';
import '../controllers/login_controller.dart';

class LoginView extends GetView<LoginController> {
  const LoginView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Scaffold(
      body: Stack(
        children: [
          // Gradient background
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFF0EBFF), Colors.white, Color(0xFFFDF4FF)],
                  stops: [0.0, 0.55, 1.0],
                ),
              ),
            ),
          ),
          // Purple blob top-left
          Positioned(
            top: -90,
            left: -70,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF7C3AED).withValues(alpha: 0.2),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          // Faint pink blob
          Positioned(
            top: 40,
            left: 110,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFFE879F9).withValues(alpha: 0.1),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          // Main scrollable content
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 440),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 20.w, vertical: 28.h),
                          child: Container(
                            padding: EdgeInsets.all(28.r),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(24.r),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF7C3AED)
                                      .withValues(alpha: 0.08),
                                  blurRadius: 48,
                                  offset: const Offset(0, 12),
                                ),
                              ],
                            ),
                            child: Form(
                              key: controller.formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  _buildLogoSection(),
                                  24.verticalSpace,
                                  Obx(() {
                                    final role = controller.selectedRole.value;
                                    final label = role == AuthService.generalAdminRole
                                        ? 'Super Admin'
                                        : role == AuthService.storeViewerRole
                                            ? 'Store Viewer'
                                            : 'Admin Tienda';
                                    return Column(children: [
                                      Container(
                                        width: double.infinity,
                                        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF7C3AED).withValues(alpha: 0.08),
                                          borderRadius: BorderRadius.circular(12.r),
                                          border: Border.all(color: const Color(0xFF7C3AED).withValues(alpha: 0.3)),
                                        ),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            const Icon(Icons.admin_panel_settings, size: 16, color: Color(0xFF7C3AED)),
                                            6.horizontalSpace,
                                            Flexible(
                                              child: Text(
                                                'Modo administrador — $label',
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                  color: Color(0xFF7C3AED),
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 13,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      12.verticalSpace,
                                    ]);
                                  }),
                                  Text(
                                    'Bienvenido a Letdem',
                                    style: theme.textTheme.headlineMedium
                                        ?.copyWith(fontWeight: FontWeight.bold),
                                    textAlign: TextAlign.center,
                                  ),
                                  8.verticalSpace,
                                  Text(
                                    'Panel de administración',
                                    style: theme.textTheme.bodyMedium,
                                    textAlign: TextAlign.center,
                                  ),
                                  32.verticalSpace,
                                  // Email field
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      'Correo Electrónico',
                                      style: theme.textTheme.bodyLarge
                                          ?.copyWith(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 13.sp),
                                    ),
                                  ),
                                  8.verticalSpace,
                                  Semantics(

                                    label: 'Correo Electrónico',
                                    textField: true,
                                    child: CustomFormField(
                                      hint: 'ejemplo@correo.com',
                                      controller: controller.emailController,
                                      keyboardType: TextInputType.emailAddress,
                                      validator: controller.validateEmail,
                                      textInputAction: TextInputAction.next,
                                      prefixIcon: Icon(Icons.email_outlined,
                                          color: theme.primaryColor, size: 20),
                                    ),
                                  ),
                                  20.verticalSpace,
                                  // Password label row
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Flexible(
                                        child: Text(
                                          'Contraseña',
                                          overflow: TextOverflow.ellipsis,
                                          style: theme.textTheme.bodyLarge
                                              ?.copyWith(
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 13.sp),
                                        ),
                                      ),
                                      Flexible(
                                        child: GestureDetector(
                                          onTap: () => Get.toNamed(Routes.FORGOT_PASSWORD),
                                          child: Text(
                                            '¿Olvidaste tu contraseña?',
                                            textAlign: TextAlign.end,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              color: theme.primaryColor,
                                              fontSize: 12.sp,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  8.verticalSpace,
                                  Obx(() => Semantics(
                                        label: 'Contraseña',
                                        textField: true,
                                        child: CustomFormField(
                                          hint: '••••••••',
                                          controller:
                                              controller.passwordController,
                                          obscureText:
                                              controller.hidePassword.value,
                                          validator:
                                              controller.validatePassword,
                                          prefixIcon: Icon(Icons.lock_outline,
                                              color: theme.primaryColor,
                                              size: 20),
                                          suffixIcon: IconButton(
                                            icon: Icon(
                                              controller.hidePassword.value
                                                  ? Icons
                                                      .visibility_off_outlined
                                                  : Icons.visibility_outlined,
                                              color: theme.hintColor,
                                              size: 20,
                                            ),
                                            onPressed: () => controller
                                                    .hidePassword.value =
                                                !controller.hidePassword.value,
                                          ),
                                          textInputAction: TextInputAction.done,
                                        ),
                                      )),
                                  28.verticalSpace,
                                  // Login button
                                  Obx(() {
                                    final role = controller.selectedRole.value;
                                    final isAdmin = role != AuthService.customerRole;
                                    final btnLabel = controller.isLoading.value
                                        ? 'Cargando...'
                                        : isAdmin
                                            ? 'Entrar como Administrador'
                                            : 'Iniciar Sesión';
                                    return SizedBox(
                                      width: double.infinity,
                                      height: 52.h,
                                      child: ElevatedButton(
                                        onPressed: controller.isLoading.value
                                            ? null
                                            : controller.login,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: isAdmin
                                              ? const Color(0xFF5B21B6)
                                              : const Color(0xFF7C3AED),
                                          foregroundColor: Colors.white,
                                          disabledBackgroundColor:
                                              const Color(0xFF7C3AED).withValues(alpha: 0.5),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(14.r),
                                          ),
                                          elevation: 0,
                                        ),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            if (isAdmin && !controller.isLoading.value) ...[
                                              const Icon(Icons.admin_panel_settings,
                                                  color: Colors.white, size: 18),
                                              8.horizontalSpace,
                                            ],
                                            Text(
                                              btnLabel,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w600,
                                                fontSize: 15,
                                              ),
                                            ),
                                            if (!isAdmin && !controller.isLoading.value) ...[
                                              8.horizontalSpace,
                                              const Icon(Icons.arrow_forward,
                                                  color: Colors.white, size: 18),
                                            ],
                                          ],
                                        ),
                                      ),
                                    );
                                  }),
                                  20.verticalSpace,
                                  // Divider
                                  Row(
                                    children: [
                                      const Expanded(child: Divider()),
                                      Flexible(
                                        child: Padding(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 12.w),
                                          child: Text(
                                            'o continúa con',
                                            style: theme.textTheme.bodySmall,
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                          ),
                                        ),
                                      ),
                                      const Expanded(child: Divider()),
                                    ],
                                  ),
                                  16.verticalSpace,
                                  // Google button
                                  Obx(() => SizedBox(
                                        width: double.infinity,
                                        height: 52.h,
                                        child: OutlinedButton(
                                          onPressed: controller.isLoading.value
                                              ? null
                                              : controller.loginWithGoogle,
                                          style: OutlinedButton.styleFrom(
                                            backgroundColor: Colors.white,
                                            side: BorderSide(
                                                color: Colors.grey.shade300),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(14.r),
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              const _GoogleIcon(),
                                              10.horizontalSpace,
                                              const Text(
                                                'Google',
                                                style: TextStyle(
                                                  color: Colors.black87,
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 15,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      )),
                                  const Divider(height: 24),
                                  Row(children: [
                                    _adminRoleChip(theme, 'Tienda',      AuthService.storeAdminRole),
                                    8.horizontalSpace,
                                    _adminRoleChip(theme, 'Viewer',      AuthService.storeViewerRole),
                                    8.horizontalSpace,
                                    _adminRoleChip(theme, 'Super Admin', AuthService.generalAdminRole),
                                  ]),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                _buildFooter(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoSection() {
    return SvgPicture.asset(
      'assets/vectors/letdem_logo.svg',
      width: 160.w,
      height: 36.h,
      fit: BoxFit.contain,
    );
  }

  Widget _adminRoleChip(ThemeData theme, String label, String role) {
    return Expanded(
      child: Obx(() {
        final selected = controller.selectedRole.value == role;
        return GestureDetector(
          onTap: () => controller.selectedRole.value = role,
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 8.h),
            decoration: BoxDecoration(
              color: selected
                  ? theme.primaryColor.withValues(alpha: 0.1)
                  : null,
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(
                color: selected ? theme.primaryColor : theme.dividerColor,
              ),
            ),
            child: Center(
              child: Text(
                label,
                style: TextStyle(
                  color: selected
                      ? theme.primaryColor
                      : theme.textTheme.bodyMedium?.color,
                  fontWeight:
                      selected ? FontWeight.w600 : FontWeight.normal,
                  fontSize: 12.sp,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildFooter() {
    const linkStyle = TextStyle(color: Color(0xFF9CA3AF), fontSize: 12);
    const dot = Padding(
      padding: EdgeInsets.symmetric(horizontal: 6),
      child: Text('·', style: linkStyle),
    );
    final btnStyle = TextButton.styleFrom(
      minimumSize: Size.zero,
      padding: EdgeInsets.zero,
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12.h),
      child: Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          TextButton(
              onPressed: () {},
              style: btnStyle,
              child: const Text('Términos', style: linkStyle)),
          dot,
          TextButton(
              onPressed: () {},
              style: btnStyle,
              child: const Text('Privacidad', style: linkStyle)),
          dot,
          TextButton(
              onPressed: () {},
              style: btnStyle,
              child: const Text('Ayuda', style: linkStyle)),
        ],
      ),
    );
  }
}

class _GoogleIcon extends StatelessWidget {
  const _GoogleIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: const Center(
        child: Text(
          'G',
          style: TextStyle(
            color: Color(0xFF4285F4),
            fontWeight: FontWeight.bold,
            fontSize: 13,
            height: 1.2,
          ),
        ),
      ),
    );
  }
}
