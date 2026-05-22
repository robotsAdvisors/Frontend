import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../controllers/splash_controller.dart';

class SplashView extends GetView<SplashController> {
  const SplashView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Get.put(SplashController());
    var theme = context.theme;
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [theme.primaryColorDark, theme.primaryColor, theme.primaryColorLight],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 18.h),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.12),
                      blurRadius: 18,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: SvgPicture.asset(
                  'assets/vectors/letdem_logo.svg',
                  width: 200.w,
                  height: 44.h,
                  fit: BoxFit.contain,
                ),
              ).animate().fade().slideY(
                duration: 500.ms,
                begin: 1,
                curve: Curves.easeInSine,
              ),
              20.verticalSpace,
              Text(
                'Tu marketplace de confianza',
                style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white70),
              ).animate().fade(delay: 350.ms, duration: 400.ms),
            ],
          ),
        ),
      ),
    );
  }
}