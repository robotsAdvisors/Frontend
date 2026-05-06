import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomSnackBar {
  static showCustomSnackBar({required String title, required String message, Duration? duration}) {
    final theme = Get.theme;
    Get.snackbar(
      title,
      message,
      duration: duration ?? const Duration(seconds: 3),
      margin: const EdgeInsets.only(top: 10, left: 10, right: 10),
      colorText: Colors.white,
      backgroundColor: theme.primaryColor,
      icon: const Icon(Icons.check_circle, color: Colors.white),
    );
  }


  static showCustomErrorSnackBar({required String title, required String message, Color? color, Duration? duration}) {
    final theme = Get.theme;
    Get.snackbar(
      title,
      message,
      duration: duration ?? const Duration(seconds: 3),
      margin: const EdgeInsets.only(top: 10,left: 10,right: 10),
      colorText: Colors.white,
      backgroundColor: color ?? theme.colorScheme.error,
      icon: const Icon(Icons.error, color: Colors.white,),
    );
  }



  static showCustomToast({String? title, required String message, Color? color, Duration? duration}) {
    final theme = Get.theme;
    Get.rawSnackbar(
      title: title,
      duration: duration ?? const Duration(seconds: 3),
      snackStyle: SnackStyle.GROUNDED,
      backgroundColor: color ?? theme.primaryColor,
      onTap: (snack){
        Get.closeAllSnackbars();
      },
      //overlayBlur: 0.8,
      message: message,
    );
  }


  static showCustomErrorToast({String? title, required String message, Color? color,Duration? duration}) {
    final theme = Get.theme;
    Get.rawSnackbar(
      title: title,
      duration: duration ?? const Duration(seconds: 3),
      snackStyle: SnackStyle.GROUNDED,
      backgroundColor: color ?? theme.colorScheme.error,
      onTap: (snack){
        Get.closeAllSnackbars();
      },
      //overlayBlur: 0.8,
      message: message,
    );
  }
}