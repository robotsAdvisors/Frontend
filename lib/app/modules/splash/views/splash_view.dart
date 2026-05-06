import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../utils/constants.dart';
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
              CircleAvatar(
                radius: 55.r,
                backgroundColor: Colors.white.withOpacity(0.18),
                child: Image.asset(Constants.logo, width: 67.w, height: 55.h),
              ).animate().fade().slideY(
                duration: 500.ms,
                begin: 1,
                curve: Curves.easeInSine,
              ),
              20.verticalSpace,
              Text(
                'Letdem',
                style: theme.textTheme.headline2?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 2,
                ),
              ).animate().fade(delay: 200.ms, duration: 400.ms),
              8.verticalSpace,
              Text(
                'Tu marketplace de confianza',
                style: theme.textTheme.bodyText2?.copyWith(color: Colors.white70),
              ).animate().fade(delay: 350.ms, duration: 400.ms),
            ],
          ),
        ),
      ),
    );
  }
}