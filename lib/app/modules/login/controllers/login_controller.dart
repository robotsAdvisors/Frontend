import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/services/auth_service.dart';
import '../../../data/services/http/api_client.dart';
import '../../../routes/app_pages.dart';

class LoginController extends GetxController {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final RxBool isLoading = false.obs;
  final RxBool hidePassword = true.obs;
  final RxString selectedRole = AuthService.customerRole.obs;
  final RxBool showAdminRoles = false.obs;

  void toggleAdminPanel() {
    showAdminRoles.value = !showAdminRoles.value;
    selectedRole.value = showAdminRoles.value
        ? AuthService.storeAdminRole
        : AuthService.customerRole;
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  Future<void> login() async {
    if (!formKey.currentState!.validate()) return;

    isLoading.value = true;
    try {
      await AuthService.signInWithEmailPassword(
        emailController.text.trim(),
        passwordController.text.trim(),
        selectedRole.value,
      );
      Get.offAllNamed(
        AuthService.isStoreAdmin || AuthService.isStoreViewer
            ? Routes.ADMIN
            : AuthService.isGeneralAdmin
                ? Routes.GENERAL_ADMIN
                : Routes.BASE,
      );
    } on ApiException catch (exception) {
      Get.snackbar(
        'Error',
        exception.message,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (error) {
      Get.snackbar(
        'Error',
        error.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> register() async {
    if (!formKey.currentState!.validate()) return;

    isLoading.value = true;
    try {
      await AuthService.registerWithEmailPassword(
        emailController.text.trim(),
        passwordController.text.trim(),
        selectedRole.value,
      );
      Get.offAllNamed(
        selectedRole.value == AuthService.storeAdminRole
            ? Routes.ADMIN
            : selectedRole.value == AuthService.generalAdminRole
                ? Routes.GENERAL_ADMIN
                : Routes.BASE,
      );
    } on ApiException catch (exception) {
      Get.snackbar(
        'Error',
        exception.message,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (error) {
      Get.snackbar(
        'Error',
        error.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Login social: Google -> Firebase -> backend (`/accounts/auth/social-login/`).
  Future<void> loginWithGoogle() async {
    isLoading.value = true;
    try {
      final ok = await AuthService.signInWithGoogle(role: selectedRole.value);
      if (!ok) return; // usuario cancelo
      Get.offAllNamed(
        AuthService.isStoreAdmin || AuthService.isStoreViewer
            ? Routes.ADMIN
            : AuthService.isGeneralAdmin
                ? Routes.GENERAL_ADMIN
                : Routes.BASE,
      );
    } on ApiException catch (exception) {
      Get.snackbar(
        'Error',
        exception.message,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (error) {
      Get.snackbar(
        'Error',
        'No se pudo iniciar sesion con Google: $error',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Ingresa tu correo electrónico.';
    }
    if (!GetUtils.isEmail(value.trim())) {
      return 'Ingresa un correo válido.';
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Ingresa tu contraseña.';
    }
    if (value.trim().length < 6) {
      return 'La contraseña debe tener al menos 6 caracteres.';
    }
    return null;
  }
}
