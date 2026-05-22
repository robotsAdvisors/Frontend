import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../../components/custom_button.dart';
import '../../../routes/app_pages.dart';
import '../controllers/welcome_controller.dart';

class WelcomeView extends GetView<WelcomeController> {
  const WelcomeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final titleSize = (theme.textTheme.headlineSmall?.fontSize ?? 24) / 2;
    final subtitleSize = (theme.textTheme.bodyMedium?.fontSize ?? 14) / 2;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding:
                  EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                    minHeight: constraints.maxHeight - 32.h),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SvgPicture.asset(
                      'assets/vectors/letdem_logo.svg',
                      width: 186.w,
                      height: 41.h,
                      fit: BoxFit.contain,
                    ).animate().fade().slideY(
                          duration: 300.ms,
                          begin: -1,
                          curve: Curves.easeInSine,
                        ),
                    20.verticalSpace,
                    Text(
                      'Bienvenido a Letdem',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: titleSize,
                      ),
                      textAlign: TextAlign.center,
                    ).animate().fade().slideY(
                          duration: 300.ms,
                          begin: -1,
                          curve: Curves.easeInSine,
                        ),
                    12.verticalSpace,
                    Text(
                      'Tu marketplace de productos frescos con beneficios, vouchers y experiencia personalizada.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontSize: subtitleSize,
                      ),
                      textAlign: TextAlign.center,
                    ).animate().fade().slideY(
                          duration: 300.ms,
                          begin: 1,
                          curve: Curves.easeInSine,
                        ),
                    28.verticalSpace,
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24.w),
                      child: CustomButton(
                        text: 'Comenzar',
                        onPressed: () => Get.offNamed(Routes.LOGIN),
                        fontSize: 15.sp,
                        radius: 50.r,
                        verticalPadding: 14.h,
                        hasShadow: false,
                      ).animate().fade().slideY(
                            duration: 300.ms,
                            begin: 1,
                            curve: Curves.easeInSine,
                          ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
